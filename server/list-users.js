/**
 * List all users in the database with their GitHub usernames
 */

require('dotenv').config();

async function listUsers() {
    console.log('📋 Listing All Users in Database\n');

    const { initializeFirebase, collections } = require('./src/config/firebase');
    await initializeFirebase();
    console.log('✅ Firebase initialized\n');

    console.log('═'.repeat(60));
    console.log('GitHub Username'.padEnd(25) + 'Email'.padEnd(35));
    console.log('═'.repeat(60));

    const usersSnapshot = await collections.users().get();

    let count = 0;
    usersSnapshot.forEach(doc => {
        const user = doc.data();
        if (user.githubUsername) {
            count++;
            const username = (user.githubUsername || 'N/A').padEnd(25);
            const email = (user.email || 'NO EMAIL').padEnd(35);
            console.log(`${username}${email}`);
        }
    });

    console.log('═'.repeat(60));
    console.log(`Total users with GitHub connected: ${count}`);

    process.exit(0);
}

listUsers().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
