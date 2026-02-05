function extractBoundaries(scheduleText) {
    if (!scheduleText) return getDefaultBoundaries();

    // Normalize text: remove multiple spaces, newlines
    const text = scheduleText.replace(/\s+/g, ' ').trim();

    // Regex patterns to find boundaries
    // These look for "North", "South", etc., followed by content until the next direction or end of string
    const boundaryRegex = {
        north: /North[:\-\s]+(.*?)(?=(South|East|West|$))/i,
        south: /South[:\-\s]+(.*?)(?=(North|East|West|$))/i,
        east: /East[:\-\s]+(.*?)(?=(North|South|West|$))/i,
        west: /West[:\-\s]+(.*?)(?=(North|South|East|$))/i
    };

    const northMatch = text.match(boundaryRegex.north);
    const southMatch = text.match(boundaryRegex.south);
    const eastMatch = text.match(boundaryRegex.east);
    const westMatch = text.match(boundaryRegex.west);

    return {
        north: cleanBoundaryText(northMatch ? northMatch[1] : null),
        south: cleanBoundaryText(southMatch ? southMatch[1] : null),
        east: cleanBoundaryText(eastMatch ? eastMatch[1] : null),
        west: cleanBoundaryText(westMatch ? westMatch[1] : null)
    };
}

function cleanBoundaryText(text) {
    if (!text) return 'Not specified';
    // Remove trailing punctuation or common noise words
    return text.replace(/[;,.]+$/, '').trim();
}

function getDefaultBoundaries() {
    return {
        north: 'Not specified',
        south: 'Not specified',
        east: 'Not specified',
        west: 'Not specified'
    };
}

// Logic to calculate confidence based on how many boundaries were found
function calculateConfidence(boundaries) {
    let foundCount = 0;
    if (boundaries.north !== 'Not specified') foundCount++;
    if (boundaries.south !== 'Not specified') foundCount++;
    if (boundaries.east !== 'Not specified') foundCount++;
    if (boundaries.west !== 'Not specified') foundCount++;

    return foundCount / 4.0;
}

module.exports = { extractBoundaries, calculateConfidence };
