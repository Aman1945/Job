const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('./models/User');

async function fixPasswords() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const users = await User.find({});
        console.log(`Checking ${users.length} users...`);

        for (let user of users) {
            // If password is not already a bcrypt hash (bcrypt hashes usually start with $2a$ or $2b$)
            if (!user.password.startsWith('$2a$') && !user.password.startsWith('$2b$')) {
                console.log(`Hashing password for: ${user.id}`);
                const salt = await bcrypt.genSalt(10);
                user.password = await bcrypt.hash(user.password, salt);
                await user.save();
                console.log(`✅ Fixed: ${user.id}`);
            } else {
                console.log(`⏩ Skipping (already hashed): ${user.id}`);
            }
        }

        console.log('🚀 Password hashing fix complete!');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error fixing passwords:', err.message);
        process.exit(1);
    }
}

fixPasswords();
