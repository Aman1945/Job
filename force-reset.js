const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();
const User = require('./models/User');

async function forceResetPasswords() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const users = await User.find({});
        console.log(`Force resetting ${users.length} users to "password123"...`);

        for (let user of users) {
            const salt = await bcrypt.genSalt(10);
            const hashed = await bcrypt.hash('password123', salt);

            await User.updateOne({ _id: user._id }, { $set: { password: hashed } });
            console.log(`✅ Reset done: ${user.id}`);
        }

        console.log('🚀 All passwords set to "password123" and hashed correctly.');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error during reset:', err.message);
        process.exit(1);
    }
}

forceResetPasswords();
