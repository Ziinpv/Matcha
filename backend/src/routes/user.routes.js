const express = require('express');
const router = express.Router();
const UserController = require('../controllers/user.controller');

router.get('/:id', UserController.getProfile);
router.put('/:id', UserController.updateProfile);

module.exports = router;


