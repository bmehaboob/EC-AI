const playwright = require('playwright');
const fs = require('fs');
const path = require('path');

async function extractMetadata() {
    console.log('Launching browser...');
    const browser = await playwright.chromium.launch({ headless: false }); // Visible so user can see progress
    const context = await browser.newContext();
    const page = await context.newPage();

    try {
        console.log('Navigating to EC Search portal...');
        await page.goto('https://registration.ec.ap.gov.in/ecSearch', { timeout: 60000 });

        // Wait for District dropdown to be present
        await page.waitForSelector('#districtCode'); // Assuming ID is districtCode based on common patterns, verifying in loop

        // Get all District Options
        const districts = await page.$$eval('#districtCode option', options => {
            return options
                .filter(o => o.value && o.value !== '0') // Filter out "Select" placeholder
                .map(o => ({ id: o.value, name: o.innerText.trim() }));
        });

        console.log(`Found ${districts.length} districts.`);
        const fullData = [];

        for (const district of districts) {
            console.log(`Processing District: ${district.name} (${district.id})...`);

            // Select District
            await page.selectOption('#districtCode', district.id);

            // Wait for SRO dropdown to populate
            // This usually involves an AJAX call. We wait for the SRO dropdown to undergo a change or stabilization.
            // A simple wait strategy: wait for a short duration or wait for the SRO options to change from empty/default.
            await page.waitForTimeout(1000); // Give it a sec for AJAX

            // Extract SRO Options
            const sros = await page.$$eval('#sroCode option', options => {
                return options
                    .filter(o => o.value && o.value !== '0')
                    .map(o => ({ id: o.value, name: o.innerText.trim() }));
            });

            console.log(`  -> Found ${sros.length} SROs.`);

            fullData.push({
                id: district.id,
                name: district.name,
                sros: sros
            });
        }

        // Save to frontend assets
        const outputDir = path.resolve(__dirname, '../frontend/assets');
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }

        const outputPath = path.join(outputDir, 'locations.json');
        fs.writeFileSync(outputPath, JSON.stringify(fullData, null, 2));

        console.log(`Extraction complete! Saved to ${outputPath}`);

    } catch (error) {
        console.error('Error extracting metadata:', error);
    } finally {
        await browser.close();
    }
}

extractMetadata();
