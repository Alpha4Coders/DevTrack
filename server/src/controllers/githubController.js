/**
 * GitHub Controller
 * Handles GitHub data fetching and storage
 */

const GitHubService = require('../services/githubService');
const { collections } = require('../config/firebase');
const { APIError } = require('../middleware/errorHandler');

/**
 * Get user's GitHub activity summary
 * GET /api/github/activity
 */
const getActivity = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        // Get user's GitHub username from Firestore
        const userDoc = await collections.users().doc(userId).get();

        if (!userDoc.exists) {
            throw new APIError('User not found', 404);
        }

        const user = userDoc.data();

        if (!user.githubUsername) {
            throw new APIError('GitHub account not connected', 400);
        }

        const githubService = new GitHubService();
        const activity = await githubService.getActivitySummary(user.githubUsername);

        // Store activity snapshot in Firestore
        await collections.activities().doc(`${userId}_${Date.now()}`).set({
            uid: userId,
            date: new Date().toISOString(),
            ...activity,
        });

        res.status(200).json({
            success: true,
            data: {
                username: user.githubUsername,
                activity,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user's recent commits
 * GET /api/github/commits
 */
const getCommits = async (req, res, next) => {
    try {
        const { userId } = req.auth;
        const days = parseInt(req.query.days) || 7;

        const userDoc = await collections.users().doc(userId).get();

        if (!userDoc.exists) {
            throw new APIError('User not found', 404);
        }

        const user = userDoc.data();

        if (!user.githubUsername) {
            // Return empty array instead of error - more graceful for dashboard
            console.log('ℹ️ User has no GitHub username linked');
            return res.status(200).json({
                success: true,
                data: {
                    username: null,
                    days,
                    totalCommits: 0,
                    commits: [],
                    streak: 0,
                    message: 'GitHub account not linked. Add your GitHub username in profile settings.'
                },
            });
        }

        // Use user's OAuth token if available for better rate limits
        const githubService = new GitHubService(user.githubAccessToken || null);
        const result = await githubService.getRecentCommits(user.githubUsername, days);

        // Handle both old array format and new object format
        const commits = Array.isArray(result) ? result : (result.commits || []);
        const streak = result.streak || 0;
        const totalContributions = result.totalContributions || commits.length;

        res.status(200).json({
            success: true,
            data: {
                username: user.githubUsername,
                days,
                totalCommits: commits.length,
                totalContributions,
                streak,
                commits,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user's repositories
 * GET /api/github/repos
 */
const getRepos = async (req, res, next) => {
    try {
        const { userId } = req.auth;
        const limit = parseInt(req.query.limit) || 10;

        const userDoc = await collections.users().doc(userId).get();

        if (!userDoc.exists) {
            throw new APIError('User not found', 404);
        }

        const user = userDoc.data();

        if (!user.githubUsername) {
            throw new APIError('GitHub account not connected', 400);
        }

        const githubService = new GitHubService();
        const repos = await githubService.getRepos(user.githubUsername, limit);

        res.status(200).json({
            success: true,
            data: {
                username: user.githubUsername,
                totalRepos: repos.length,
                repos,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get languages used in user's repos
 * GET /api/github/languages
 */
const getLanguages = async (req, res, next) => {
    try {
        const { userId } = req.auth;

        const userDoc = await collections.users().doc(userId).get();

        if (!userDoc.exists) {
            throw new APIError('User not found', 404);
        }

        const user = userDoc.data();

        if (!user.githubUsername) {
            throw new APIError('GitHub account not connected', 400);
        }

        const githubService = new GitHubService();
        const languages = await githubService.getLanguages(user.githubUsername);

        res.status(200).json({
            success: true,
            data: {
                username: user.githubUsername,
                languages,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user's GitHub profile
 * GET /api/github/profile
 */
const getProfile = async (req, res, next) => {
    try {
        const githubService = new GitHubService();
        const profile = await githubService.getUser();

        res.status(200).json({
            success: true,
            data: profile,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Analyze a specific repository
 * GET /api/github/repo/:owner/:repo
 */
const analyzeRepo = async (req, res, next) => {
    try {
        const { owner, repo } = req.params;

        if (!owner || !repo) {
            throw new APIError('Owner and repo are required', 400);
        }

        // Try to get user's GitHub token for private repo access
        let userToken = null;
        if (req.auth?.userId) {
            try {
                const userDoc = await collections.users().doc(req.auth.userId).get();
                if (userDoc.exists) {
                    const userData = userDoc.data();
                    if (userData.githubAccessToken) {
                        userToken = userData.githubAccessToken;
                        console.log('🔑 Using user OAuth token for private access');
                    }
                }
            } catch (tokenErr) {
                console.warn('⚠️ Could not retrieve user token, falling back to PAT');
            }
        }

        // Use user token if available, otherwise fallback to PAT
        const githubService = new GitHubService(userToken);
        const repoInfo = await githubService.getRepoInfo(owner, repo);

        res.status(200).json({
            success: true,
            data: repoInfo,
        });
    } catch (error) {
        // If it's a 404 and we used user token, provide a helpful message
        if (error.status === 404 || error.message?.includes('Not Found')) {
            return res.status(404).json({
                success: false,
                error: 'Repository not found. If this is a private repo, ensure your GitHub account has access.',
            });
        }
        next(error);
    }
};

module.exports = {
    getActivity,
    getCommits,
    getRepos,
    getLanguages,
    getProfile,
    analyzeRepo,
};
