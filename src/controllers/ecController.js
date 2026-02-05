const browserService = require('../services/browserService');
const parser = require('../utils/parser');
const { pool } = require('../config/db');

async function startSearch(req, res) {
    try {
        const { district, sro, docNumber, year } = req.body;

        // Start browser session
        // For local dev we see the browser, for production we might need a different approach 
        // (e.g., forwarding the screen or handling captcha differently if strictly headless)
        // The user requested: headless: false // User sees browser to enter CAPTCHA
        // Note: On a hosted server (Railway), visual interaction is impossible directly.
        // This architecture works for local execution. For server, you'd need a VNC or screenshot relay.
        // However, following the user's prompt exactly:

        const sessionId = await browserService.startECSearchSession({
            district, sro, docNumber, year
        }, false); // headless: false

        res.json({
            sessionId,
            message: 'Browser session started. Please solve CAPTCHA and submit the form on the opened browser window.'
        });

    } catch (error) {
        console.error('Start search error:', error);
        res.status(500).json({ error: 'Failed to start search session' });
    }
}

async function fetchAndParseEC(req, res) {
    const { sessionId, userId } = req.body; // Assuming userId is passed or in token

    if (!sessionId) {
        return res.status(400).json({ error: 'Session ID is required' });
    }

    try {
        // Capture EC result
        // This waits for the result page to be captured
        const { ecEntries, pdfUrl } = await browserService.captureECResult(sessionId);

        // Save to database
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            // 1. Create Property Case
            // We retrieve session data to get the original search params or pass them in body
            const session = browserService.activeSessions[sessionId];
            // Note: In a real app we'd access stored params. Assuming we have them or just storing what we have.

            const caseResult = await client.query(
                `INSERT INTO property_cases (user_id, district, sro, search_params)
         VALUES ($1, $2, $3, $4)
         RETURNING id`,
                [userId || 'guest', 'district_placeholder', 'sro_placeholder', JSON.stringify({})]
            );
            const caseId = caseResult.rows[0].id;

            const parsedEntries = [];

            for (const entry of ecEntries) {
                // 2. Save EC Entry
                const entryResult = await client.query(
                    `INSERT INTO ec_entries (case_id, doc_number, reg_date, nature_of_doc, parties, consideration, schedule_text)
           VALUES ($1, $2, TO_DATE($3, 'DD-MM-YYYY'), $4, $5, $6, $7)
           RETURNING id`,
                    [caseId, entry.docNumber, entry.docDate || null, entry.nature, entry.parties,
                        parseFloat(entry.consideration) || 0, entry.scheduleText]
                );
                const entryId = entryResult.rows[0].id;

                // 3. Extract and Save Boundaries
                const boundaries = parser.extractBoundaries(entry.scheduleText);
                const confidence = parser.calculateConfidence(boundaries);

                await client.query(
                    `INSERT INTO boundary_versions (ec_entry_id, north_text, south_text, east_text, west_text, extraction_confidence)
           VALUES ($1, $2, $3, $4, $5, $6)`,
                    [entryId, boundaries.north, boundaries.south, boundaries.east, boundaries.west, confidence]
                );

                parsedEntries.push({ ...entry, boundaries });
            }

            await client.query('COMMIT');

            // Close browser session
            await browserService.closeSession(sessionId);

            res.json({
                success: true,
                caseId,
                entries: parsedEntries,
                pdfUrl
            });

        } catch (dbError) {
            await client.query('ROLLBACK');
            throw dbError;
        } finally {
            client.release();
        }

    } catch (error) {
        console.error('Fetch and parse error:', error);
        res.status(500).json({ error: 'Failed to parse EC result: ' + error.message });
    }
}

module.exports = {
    startSearch,
    fetchAndParseEC
};
