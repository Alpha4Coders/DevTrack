/**
 * Notification Controller
 * Handles FCM token registration and notification management
 */

const { getNotificationService } = require('../services/notificationService');
const { APIError } = require('../middleware/errorHandler');

/**
 * Register FCM token for push notifications
 * POST /api/notifications/register
 */
const registerToken = async (req, res, next) => {
    try {
        const { userId } = req.auth;
        const { token } = req.body;

        if (!token) {
            throw new APIError('FCM token is required', 400);
        }

        const notificationService = getNotificationService();
        const result = await notificationService.registerToken(userId, token);

        if (!result.success) {
            throw new APIError(result.error, 500);
        }

        res.status(200).json({
            success: true,
            message: 'Push notifications enabled',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Unregister FCM token (disable notifications)
 * DELETE /api/notifications/register
 */
const unregisterToken = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        const notificationService = getNotificationService();
        const result = await notificationService.removeToken(userId);

        if (!result.success) {
            throw new APIError(result.error, 500);
        }

        res.status(200).json({
            success: true,
            message: 'Push notifications disabled',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Send test notification to current user
 * POST /api/notifications/test
 */
const sendTestNotification = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        const notificationService = getNotificationService();
        const result = await notificationService.sendConsistencyReminder(userId);

        if (!result.success) {
            throw new APIError(result.error || 'Failed to send notification', 400);
        }

        res.status(200).json({
            success: true,
            message: 'Test notification sent',
            messageId: result.messageId,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Trigger reminder check (for cron job / Cloud Scheduler)
 * POST /api/notifications/check-reminders
 * Protected by API key for external scheduler
 */
const checkReminders = async (req, res, next) => {
    try {
        // Verify scheduler API key
        const apiKey = req.headers['x-api-key'];
        const expectedKey = process.env.SCHEDULER_API_KEY;

        // If scheduler key is set, verify it
        if (expectedKey && apiKey !== expectedKey) {
            throw new APIError('Invalid API key', 401);
        }

        const notificationService = getNotificationService();
        const result = await notificationService.checkAndSendReminders();

        res.status(200).json({
            success: true,
            ...result,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get notification status for current user
 * GET /api/notifications/status
 */
const getNotificationStatus = async (req, res, next) => {
    try {
        const { userId } = req.auth;
        const { collections } = require('../config/firebase');

        const userDoc = await collections.users().doc(userId).get();

        if (!userDoc.exists) {
            throw new APIError('User not found', 404);
        }

        const user = userDoc.data();

        res.status(200).json({
            success: true,
            data: {
                enabled: !!user.fcmToken,
                lastStartTime: user.lastStartTime || null,
                lastEndTime: user.lastEndTime || null,
                tokenUpdatedAt: user.fcmTokenUpdatedAt || null,
            },
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    registerToken,
    unregisterToken,
    sendTestNotification,
    checkReminders,
    getNotificationStatus,
};
