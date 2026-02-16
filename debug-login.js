const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./models/User');

async function debugLogin() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const email = 'animesh.jamuar@bigsams.in';
        const user = await User.findOne({ id: email });

        if (!user) {
            console.log('❌ User not found in DB:', email);
        } else {
            console.log('👤 User found:', user.name);
            console.log('🔑 Password in DB (start):', user.password.substring(0, 10));

            const bcrypt = require('bcryptjs');
            const isMatch = await bcrypt.compare('password123', user.password);
            console.log('🔍 Manual match check for "password123":', isMatch);
        }

        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err.message);
        process.exit(1);
    }
}

debugLogin();
