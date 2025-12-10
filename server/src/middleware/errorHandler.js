/**
 * Error Handler Middleware
 * Centralized error handling for the API
 */

const errorHandler = (err, req, res, next) => {
    // Log error for debugging
    console.error('Error:', {
        message: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
        path: req.path,
        method: req.method,
    });

    // Default error values
    let statusCode = err.statusCode || 500;
    let message = err.message || 'Internal Server Error';

    // Handle specific error types
    if (err.name === 'ValidationError') {
        statusCode = 400;
        message = err.details?.[0]?.message || 'Validation failed';
    }

    if (err.name === 'UnauthorizedError' || err.code === 'unauthorized') {
        statusCode = 401;
        message = 'Unauthorized access';
    }

    if (err.code === 'LIMIT_FILE_SIZE') {
        statusCode = 400;
        message = 'File too large';
    }

    // Firebase errors
    if (err.code?.startsWith?.('auth/')) {
        statusCode = 401;
        message = 'Authentication failed';
    }

    // Don't leak error details in production
    if (process.env.NODE_ENV === 'production' && statusCode === 500) {
        message = 'Something went wrong. Please try again later.';
    }

    res.status(statusCode).json({
        success: false,
        error: message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};

// Custom error class for API errors
class APIError extends Error {
    constructor(message, statusCode = 500) {
        super(message);
        this.statusCode = statusCode;
        this.name = 'APIError';
    }
}

module.exports = errorHandler;
module.exports.APIError = APIError;
