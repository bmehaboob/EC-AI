# How to Extract District/SRO Metadata

This guide explains how to populate the `locations.json` file with real data from the EC Search portal.

## Step 1: Run the Extraction Script

From the root of the project (`d:/Personal/EC-AI`), run:

```bash
node scripts/extract_metadata.js
```

**What happens:**
1. A Chromium browser window will open (you'll see it).
2. The script navigates to `https://registration.ec.ap.gov.in/ecSearch`.
3. It extracts all District options.
4. For each District, it selects it, waits for SROs to load, and extracts them.
5. Saves everything to `frontend/assets/locations.json`.

**Note:** This may take 1-2 minutes depending on the number of districts.

## Step 2: Verify the JSON

Check that `frontend/assets/locations.json` has content like:

```json
[
  {
    "id": "01",
    "name": "SRIKAKULAM",
    "sros": [
      { "id": "0101", "name": "SRIKAKULAM" },
      { "id": "0102", "name": "NARASANNAPETA" }
    ]
  },
  ...
]
```

## Step 3: Restart Flutter App

If the app is already running, hot restart it:

```bash
cd frontend
flutter run -d chrome
```

The dropdowns should now be populated with the real District and SRO values.

## Troubleshooting

### Script Fails with Selector Error
The website may have changed its HTML structure. Check the actual IDs/selectors by:
1. Opening `https://registration.ec.ap.gov.in/ecSearch` in your browser.
2. Right-click on the District dropdown → Inspect.
3. Update `extract_metadata.js` with the correct `#districtCode` and `#sroCode` selectors.

### Browser Doesn't Open
Ensure Playwright is installed:
```bash
npx playwright install chromium
```

### JSON Not Loading in Flutter
Make sure you ran `flutter pub get` after updating `pubspec.yaml`.
