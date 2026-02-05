const playwright = require('playwright');
const crypto = require('crypto');

// In-memory storage for active sessions
// In production, you might use Redis or a database to manage session state if scaling horizontally,
// but for a single instance, memory is fine.
const activeSessions = {};

/**
 * Generates a unique session ID
 */
function generateSessionId() {
    return crypto.randomBytes(16).toString('hex');
}

/**
 * Starts a browser session and navigates to the EC search page.
 * Returns the session ID.
 */
async function startECSearchSession(searchParams, headless = false) {
    const browser = await playwright.chromium.launch({
        headless: headless
    });

    const context = await browser.newContext();
    const page = await context.newPage();

    try {
        // Navigate to the AP EC Search portal
        // Note: The URL is illustrative based on the prompt. Verify the actual URL.
        await page.goto('https://registration.ec.ap.gov.in/ecSearch', { timeout: 60000 });

        // Fill form if selectors match. 
        // We wrap in try-catch blocks or use waitForSelector to be robust.

        const { district, sro, docNumber, year } = searchParams;

        if (district) await page.selectOption('#district', district).catch(e => console.log('District select error', e));
        if (sro) await page.selectOption('#sro', sro).catch(e => console.log('SRO select error', e));
        if (docNumber) await page.fill('#docNumber', docNumber).catch(e => console.log('DocNumber fill error', e));
        if (year) await page.fill('#year', year).catch(e => console.log('Year fill error', e));

        // Create session
        const sessionId = generateSessionId();
        activeSessions[sessionId] = {
            browser,
            context,
            page,
            createdAt: Date.now(),
            status: 'waiting_for_captcha'
        };

        return sessionId;
    } catch (error) {
        await browser.close();
        throw error;
    }
}

/**
 * checks if the result page is loaded and scrapes the data
 */
async function captureECResult(sessionId) {
    const session = activeSessions[sessionId];
    if (!session) {
        throw new Error('Session not found');
    }

    const { page } = session;

    // Wait for the result table to appear. Increase timeout as CAPTCHA solving might take time.
    // We assume the user has clicked submit manually.
    try {
        await page.waitForSelector('.ec-result-table', { timeout: 120000 }); // 2 minutes wait for manual captcha

        // Scrape data
        const ecEntries = await page.$$eval('.ec-entry-row', rows => {
            return rows.map(row => ({
                docNumber: row.querySelector('.doc-no')?.innerText?.trim(),
                docDate: row.querySelector('.doc-date')?.innerText?.trim(),
                nature: row.querySelector('.nature')?.innerText?.trim(),
                parties: row.querySelector('.parties')?.innerText?.trim(),
                consideration: row.querySelector('.consideration')?.innerText?.trim(),
                scheduleText: row.querySelector('.schedule')?.innerText?.trim()
            }));
        });

        // Try to find PDF link
        let pdfUrl = null;
        try {
            pdfUrl = await page.$eval('.download-pdf', el => el.href);
        } catch (e) {
            console.log('PDF link not found');
        }

        return { ecEntries, pdfUrl };
    } catch (error) {
        throw new Error('Failed to capture results: ' + error.message);
    }
}

/**
 * Closes the browser session
 */
async function closeSession(sessionId) {
    const session = activeSessions[sessionId];
    if (session) {
        await session.browser.close();
        delete activeSessions[sessionId];
    }
}

module.exports = {
    startECSearchSession,
    captureECResult,
    closeSession,
    activeSessions
};
