const express = require('express');
const router = express.Router();
const UserController = require('../controllers/user.controller');

// Profile completion flow
router.get('/profile-status', UserController.getProfileStatus);
router.post('/complete-profile', UserController.completeProfile);

router.get('/:id', UserController.getProfile);
router.put('/:id', UserController.updateProfile);

module.exports = router;


