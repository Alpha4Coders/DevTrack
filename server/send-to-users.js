/**
 * Send Weekly Reports to Specific Users
 * Finds users by GitHub username and sends them PDF reports
 */

require('dotenv').config();

const TARGET_GITHUB_USERS = [
    'vortex-16',
    'ayushchowdhurycse'
];

async function sendToSpecificUsers() {
    console.log('📧 Sending Weekly Reports to Specific Users\n');
    console.log('Target users:', TARGET_GITHUB_USERS.join(', '));
    console.log('═'.repeat(50));
    console.log('');

    // Initialize Firebase
    const { initializeFirebase, collections } = require('./src/config/firebase');
    await initializeFirebase();
    console.log('✅ Firebase initialized\n');

    const reportService = require('./src/services/reportService');

    let successCount = 0;
    let failCount = 0;

    for (const githubUsername of TARGET_GITHUB_USERS) {
        console.log(`\n📋 Processing: ${githubUsername}`);
        console.log('─'.repeat(40));

        try {
            // Find user by GitHub username
            const userSnapshot = await collections.users()
                .where('githubUsername', '==', githubUsername)
                .limit(1)
                .get();

            if (userSnapshot.empty) {
                console.log(`⚠️  User not found in database: ${githubUsername}`);
                failCount++;
                continue;
            }

            const userDoc = userSnapshot.docs[0];
            const user = userDoc.data();
            const userId = userDoc.id;

            console.log(`   Found user ID: ${userId}`);
            console.log(`   Email: ${user.email || 'NOT SET'}`);
            console.log(`   Name: ${user.name || 'N/A'}`);

            if (!user.email) {
                console.log(`❌ No email address for ${githubUsername}`);
                failCount++;
                continue;
            }

            // Send the report
            console.log(`   Sending report...`);
            const result = await reportService.sendWeeklyReportEmail(userId);

            if (result.success) {
                console.log(`✅ Report sent to ${user.email}`);
                console.log(`   Message ID: ${result.messageId}`);
                successCount++;
            } else {
                console.log(`❌ Failed to send: ${result.error}`);
                failCount++;
            }

            // Small delay between emails to avoid rate limiting
            await new Promise(resolve => setTimeout(resolve, 2000));

        } catch (error) {
            console.log(`❌ Error processing ${githubUsername}: ${error.message}`);
            failCount++;
        }
    }

    console.log('\n' + '═'.repeat(50));
    console.log(`📊 Summary: ${successCount} sent, ${failCount} failed`);
    console.log('═'.repeat(50));

    process.exit(0);
}

sendToSpecificUsers().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
