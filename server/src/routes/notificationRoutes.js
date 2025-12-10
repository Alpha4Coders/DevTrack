/**
 * Notification Routes
 * Routes for push notification management
 */

const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

// Get notification status
router.get('/status', requireAuth, notificationController.getNotificationStatus);

// Register FCM token
router.post('/register', requireAuth, notificationController.registerToken);

// Unregister FCM token
router.delete('/register', requireAuth, notificationController.unregisterToken);

// Send test notification
router.post('/test', requireAuth, notificationController.sendTestNotification);

// Check and send reminders (for scheduler/cron)
router.post('/check-reminders', notificationController.checkReminders);

module.exports = router;
