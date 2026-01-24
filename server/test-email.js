/**
 * Quick Email Test Script
 * Tests the email service with PDF report attachment
 */

require('dotenv').config();

async function testEmailSetup() {
    console.log('🧪 Starting Email and PDF Report Tests...\n');

    // Test 1: Check environment variables
    console.log('📋 Test 1: Environment Variables');
    console.log('─'.repeat(40));
    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS;

    if (!smtpUser || !smtpPass) {
        console.log('❌ SMTP_USER or SMTP_PASS not set in .env');
        process.exit(1);
    }
    console.log(`✅ SMTP_USER: ${smtpUser}`);
    console.log(`✅ SMTP_PASS: ${'*'.repeat(12)} (hidden)`);
    console.log('');

    // Test 2: Initialize Firebase
    console.log('📋 Test 2: Firebase Connection');
    console.log('─'.repeat(40));
    try {
        const { initializeFirebase } = require('./src/config/firebase');
        await initializeFirebase();
        console.log('✅ Firebase initialized successfully');
    } catch (error) {
        console.log('❌ Firebase initialization failed:', error.message);
        process.exit(1);
    }
    console.log('');

    // Test 3: Email Service - Connection Verification
    console.log('📋 Test 3: Nodemailer SMTP Connection');
    console.log('─'.repeat(40));
    try {
        const emailService = require('./src/services/emailService');
        const isConnected = await emailService.verifyConnection();
        if (isConnected) {
            console.log('✅ SMTP connection verified successfully');
        } else {
            console.log('❌ SMTP connection failed');
            process.exit(1);
        }
    } catch (error) {
        console.log('❌ SMTP test failed:', error.message);
        process.exit(1);
    }
    console.log('');

    // Test 4: Find a test user
    console.log('📋 Test 4: Finding Test User');
    console.log('─'.repeat(40));
    const { collections } = require('./src/config/firebase');

    let testUser = null;
    let testUserId = null;

    try {
        // Get first user with GitHub connected
        const usersSnapshot = await collections.users()
            .where('githubUsername', '!=', null)
            .limit(1)
            .get();

        if (!usersSnapshot.empty) {
            testUser = usersSnapshot.docs[0].data();
            testUserId = usersSnapshot.docs[0].id;
            console.log(`✅ Found test user: ${testUser.githubUsername}`);
            console.log(`   Email: ${testUser.email || 'not set'}`);
        } else {
            console.log('⚠️  No users with GitHub connected found');
            console.log('   Cannot test PDF generation without a GitHub user');
            process.exit(0);
        }
    } catch (error) {
        console.log('❌ User query failed:', error.message);
        process.exit(1);
    }
    console.log('');

    // Test 5: PDF Generation
    console.log('📋 Test 5: PDF Report Generation');
    console.log('─'.repeat(40));
    let pdfBuffer = null;
    try {
        const reportService = require('./src/services/reportService');
        console.log('   Generating PDF report...');
        pdfBuffer = await reportService.generatePDFReport(testUserId);
        console.log(`✅ PDF generated successfully (${pdfBuffer.length} bytes)`);
    } catch (error) {
        console.log('❌ PDF generation failed:', error.message);
        process.exit(1);
    }
    console.log('');

    // Test 6: Send Test Email with PDF
    console.log('📋 Test 6: Send Email with PDF Attachment');
    console.log('─'.repeat(40));

    const targetEmail = testUser.email || process.env.SMTP_USER;
    console.log(`   Sending to: ${targetEmail}`);

    try {
        const emailService = require('./src/services/emailService');
        const result = await emailService.sendWeeklyReport(
            targetEmail,
            testUser.name || testUser.githubUsername,
            pdfBuffer
        );

        if (result.success) {
            console.log('✅ Email sent successfully!');
            console.log(`   Message ID: ${result.messageId}`);
        } else {
            console.log('❌ Email sending failed:', result.error);
        }
    } catch (error) {
        console.log('❌ Email test failed:', error.message);
    }
    console.log('');

    console.log('═'.repeat(40));
    console.log('🎉 All tests completed!');
    console.log('═'.repeat(40));

    process.exit(0);
}

testEmailSetup().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
