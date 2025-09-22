const express = require('express');
const router = express.Router();
const BlockController = require('../controllers/block.controller');

router.post('/', BlockController.blockUser);
router.get('/list', BlockController.getBlockedList);

module.exports = router;


