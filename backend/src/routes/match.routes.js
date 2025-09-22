const express = require('express');
const router = express.Router();
const MatchController = require('../controllers/match.controller');

router.post('/swipe', MatchController.swipe);
router.post('/check', MatchController.checkMatch);
router.get('/list', MatchController.getMatches);

module.exports = router;


