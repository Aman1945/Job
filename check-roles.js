const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

async function checkRoles() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const users = await User.find({}, 'name id role');
        console.log('--- USER ROLES IN DB ---');
        users.forEach(u => console.log(`${u.id} -> ${u.role}`));
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkRoles();
