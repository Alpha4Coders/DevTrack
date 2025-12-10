/**
 * Gemini AI Service
 * Handles AI chat interactions using Google Generative AI (Gemini 2.0 Flash)
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');

class GeminiService {
    constructor() {
        if (!process.env.GEMINI_API_KEY) {
            throw new Error('GEMINI_API_KEY not found in environment variables');
        }

        this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

        // System prompt for developer-focused assistance
        this.systemPrompt = `You are DevTrack AI Assistant, a helpful coding mentor integrated into a developer consistency tracking platform.

Your role is to:
1. Help developers with coding questions and debugging
2. Explain programming concepts clearly
3. Provide best practices and code reviews
4. Suggest learning resources and next steps
5. Motivate and encourage consistent learning habits

Guidelines:
- Be concise but thorough
- Use code examples when helpful
- Format responses with markdown for readability
- Be encouraging and supportive
- If you don't know something, say so honestly
- Focus on practical, actionable advice

Remember: You're helping developers build consistent learning habits while they code.`;
    }

    /**
     * Generate a chat response
     * @param {string} userMessage - The user's question or message
     * @param {string} context - Optional context about what the user is working on
     */
    async chat(userMessage, context = '') {
        try {
            const prompt = this.buildPrompt(userMessage, context);

            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            const text = response.text();

            return {
                success: true,
                message: text,
                model: 'gemini-2.0-flash',
            };
        } catch (error) {
            console.error('Gemini API error:', error.message);

            // Handle specific error types
            if (error.message.includes('SAFETY')) {
                return {
                    success: false,
                    error: 'Your message was flagged by safety filters. Please rephrase.',
                };
            }

            if (error.message.includes('quota') || error.message.includes('rate')) {
                return {
                    success: false,
                    error: 'AI rate limit reached. Please try again in a moment.',
                };
            }

            throw error;
        }
    }

    /**
     * Build the full prompt with system context
     */
    buildPrompt(userMessage, context) {
        let fullPrompt = this.systemPrompt + '\n\n';

        if (context) {
            fullPrompt += `Context about what the user is working on:\n${context}\n\n`;
        }

        fullPrompt += `User's question:\n${userMessage}`;

        return fullPrompt;
    }

    /**
     * Generate a motivational message based on user's activity
     * @param {object} stats - User's activity statistics
     */
    async generateMotivation(stats) {
        const prompt = `${this.systemPrompt}

Based on this developer's recent activity, generate a short (2-3 sentences) motivational message:
- Days active this week: ${stats.daysActive || 0}
- Commits this week: ${stats.commits || 0}
- Current streak: ${stats.streak || 0} days
- Last active: ${stats.lastActive || 'Unknown'}

Make it personal, encouraging, and specific to their progress. Keep it under 100 words.`;

        try {
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            return response.text();
        } catch (error) {
            console.error('Error generating motivation:', error.message);
            return "Keep up the great work! Every day of consistent coding brings you closer to your goals. 🚀";
        }
    }

    /**
     * Get code review suggestions
     * @param {string} code - Code to review
     * @param {string} language - Programming language
     */
    async reviewCode(code, language = 'javascript') {
        const prompt = `${this.systemPrompt}

Please review this ${language} code and provide:
1. Any bugs or issues
2. Suggestions for improvement
3. Best practices recommendations

Keep the review concise and actionable.

Code:
\`\`\`${language}
${code}
\`\`\``;

        try {
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            return {
                success: true,
                review: response.text(),
            };
        } catch (error) {
            console.error('Error reviewing code:', error.message);
            throw error;
        }
    }
}

// Export singleton instance
let instance = null;

const getGeminiService = () => {
    if (!instance) {
        instance = new GeminiService();
    }
    return instance;
};

module.exports = {
    GeminiService,
    getGeminiService,
};
