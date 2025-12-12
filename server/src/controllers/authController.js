/**
 * Auth Controller
 * Handles user authentication and profile management
 */

const { collections } = require('../config/firebase');
const { clerkClient } = require('@clerk/clerk-sdk-node');
const { APIError } = require('../middleware/errorHandler');

/**
 * Sync user from Clerk to Firestore
 * POST /api/auth/sync
 */
const syncUser = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        // Get user details from Clerk
        const clerkUser = await clerkClient.users.getUser(userId);

        if (!clerkUser) {
            throw new APIError('User not found in Clerk', 404);
        }

        // Extract GitHub data if connected
        const githubAccount = clerkUser.externalAccounts?.find(
            (acc) => acc.provider === 'github'
        );

        // Try to get GitHub OAuth token for private repo access
        let githubAccessToken = null;
        if (githubAccount) {
            try {
                // Get OAuth access token from Clerk
                const oauthTokens = await clerkClient.users.getUserOauthAccessToken(
                    userId,
                    'oauth_github'
                );
                if (oauthTokens?.data?.[0]?.token) {
                    githubAccessToken = oauthTokens.data[0].token;
                    console.log('✅ GitHub OAuth token retrieved for user:', userId);
                }
            } catch (tokenErr) {
                console.warn('⚠️ Could not retrieve GitHub OAuth token:', tokenErr.message);
                // Continue without OAuth token - will fall back to PAT for public repos
            }
        }

        const userData = {
            clerkId: userId,
            email: clerkUser.emailAddresses?.[0]?.emailAddress || null,
            name: `${clerkUser.firstName || ''} ${clerkUser.lastName || ''}`.trim() || null,
            avatarUrl: clerkUser.imageUrl || null,
            githubUsername: githubAccount?.username || null,
            githubId: githubAccount?.externalId || null,
            githubAccessToken: githubAccessToken, // Store for private repo access
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            lastStartTime: null,
            lastEndTime: null,
        };

        // Upsert user in Firestore
        const userRef = collections.users().doc(userId);
        const existingUser = await userRef.get();

        if (existingUser.exists) {
            // Update existing user (preserve lastStartTime/lastEndTime)
            const existing = existingUser.data();
            await userRef.update({
                ...userData,
                createdAt: existing.createdAt, // Keep original creation date
                lastStartTime: existing.lastStartTime,
                lastEndTime: existing.lastEndTime,
            });
        } else {
            // Create new user
            await userRef.set(userData);
        }

        const updatedUser = await userRef.get();

        res.status(200).json({
            success: true,
            message: 'User synced successfully',
            user: updatedUser.data(),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get current user profile
 * GET /api/auth/me
 */
const getMe = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        const userRef = collections.users().doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            throw new APIError('User not found. Please sync your account first.', 404);
        }

        res.status(200).json({
            success: true,
            user: userDoc.data(),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update user's last activity times (for notification logic)
 * PUT /api/auth/activity
 */
const updateActivityTime = async (req, res, next) => {
    try {
        const { userId } = req.auth;
        const { startTime, endTime } = req.body;

        const userRef = collections.users().doc(userId);

        const updateData = {
            updatedAt: new Date().toISOString(),
        };

        if (startTime) {
            updateData.lastStartTime = startTime;
        }

        if (endTime) {
            updateData.lastEndTime = endTime;
        }

        await userRef.update(updateData);

        res.status(200).json({
            success: true,
            message: 'Activity time updated',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete user account
 * DELETE /api/auth/me
 */
const deleteAccount = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        // Delete user's logs
        const logsSnapshot = await collections.logs()
            .where('uid', '==', userId)
            .get();

        const batch = collections.users().firestore.batch();

        logsSnapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });

        // Delete user document
        batch.delete(collections.users().doc(userId));

        await batch.commit();

        res.status(200).json({
            success: true,
            message: 'Account deleted successfully',
        });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    syncUser,
    getMe,
    updateActivityTime,
    deleteAccount,
};
