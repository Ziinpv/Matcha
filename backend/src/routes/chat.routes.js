const express = require('express');
const router = express.Router();
const ChatController = require('../controllers/chat.controller');

router.post('/send', ChatController.sendMessage);
router.get('/:matchId', ChatController.getMessages);

module.exports = router;


