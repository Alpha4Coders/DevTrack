/**
 * README Routes
 * Routes for README generation and GitHub commit
 */

const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/auth');
const readmeController = require('../controllers/readmeController');

// Generate README for a project
router.post('/generate/:projectId', requireAuth, readmeController.generateReadme);

// Commit README to GitHub
router.post('/commit/:projectId', requireAuth, readmeController.commitReadme);

module.exports = router;
