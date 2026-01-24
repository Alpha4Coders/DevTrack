/**
 * Send Weekly Reports to ALL Users with Emails
 */

require('dotenv').config();

async function sendToAllUsers() {
    console.log('📧 Sending Weekly Reports to ALL Users\n');
    console.log('═'.repeat(50));

    // Initialize Firebase
    const { initializeFirebase } = require('./src/config/firebase');
    await initializeFirebase();
    console.log('✅ Firebase initialized\n');

    const reportService = require('./src/services/reportService');

    console.log('📤 Starting batch send...\n');
    const result = await reportService.sendAllWeeklyReports();

    console.log('\n' + '═'.repeat(50));
    console.log(`📊 Final Summary:`);
    console.log(`   ✅ Sent: ${result.sent}`);
    console.log(`   ❌ Failed: ${result.failed}`);
    if (result.error) {
        console.log(`   ⚠️ Error: ${result.error}`);
    }
    console.log('═'.repeat(50));

    process.exit(0);
}

sendToAllUsers().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
