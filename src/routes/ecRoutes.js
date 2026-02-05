const ecController = require('../controllers/ecController');
const express = require('express');

const router = express.Router();

// POST /api/ec/start-search
router.post('/start-search', ecController.startSearch);

// POST /api/ec/fetch-and-parse
router.post('/fetch-and-parse', ecController.fetchAndParseEC);

module.exports = router;
