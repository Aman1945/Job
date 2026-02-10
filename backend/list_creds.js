require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');

async function listAllCredentials() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const users = await User.find({}, 'id name password role');

        console.log('\n--- 🔑 ALL SYSTEM CREDENTIALS (LIVE DB) ---');
        users.forEach(u => {
            console.log(`Role: [${u.role}] | Name: ${u.name}`);
            console.log(`Email: ${u.id}`);
            console.log(`Password: ${u.password}`);
            console.log('-----------------------------------');
        });
        process.exit(0);
    } catch (err) {
        console.error('Error:', err);
        process.exit(1);
    }
}

listAllCredentials();
