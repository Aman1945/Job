const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

async function test() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to DB');

        // Find two users
        const users = await User.find({}).limit(2);
        if (users.length < 2) {
            console.log('Not enough users for test');
            process.exit(0);
        }

        const slot = 'test_slot_' + Date.now();

        console.log(`Setting users ${users[0].id} and ${users[1].id} to slot ${slot}`);

        await User.findOneAndUpdate({ id: users[0].id }, { $set: { orgPosition: slot } });
        await User.findOneAndUpdate({ id: users[1].id }, { $set: { orgPosition: slot } });

        const results = await User.find({ orgPosition: slot });
        console.log(`Users in ${slot}:`, results.map(u => u.name));

        if (results.length === 2) {
            console.log('✅ Success: Multiple users saved to one slot');
        } else {
            console.log('❌ Failure: Only ' + results.length + ' user in slot');
        }

        // Clean up
        await User.updateMany({ orgPosition: slot }, { $set: { orgPosition: null } });
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

test();
