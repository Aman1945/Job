const mongoose = require('mongoose');
const PerformanceRecord = require('./models/PerformanceRecord');
const User = require('./models/User');
require('dotenv').config();

async function seedMyPerformance() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const user = await User.findOne({ email: 'animesh.jamuar@bigsams.in' });
        if (!user) {
            console.log('❌ User not found!');
            return;
        }

        // Create a record for Animesh
        const myRecord = {
            userId: user._id,
            userName: user.name,
            month: 'February',
            year: 2026,
            totalScore: 88.5,
            incentivePercentage: 10,
            incentiveAmount: 15000,
            kras: [
                { id: 1, name: 'Order Processing Speed', target: 100, achieved: 95, weightage: 30 },
                { id: 2, name: 'Customer Satisfaction', target: 5, achieved: 4.8, weightage: 20 },
                { id: 3, name: 'Operational Accuracy', target: 100, achieved: 98, weightage: 30 },
                { id: 4, name: 'New Client Onboarding', target: 10, achieved: 8, weightage: 20 }
            ]
        };

        await PerformanceRecord.findOneAndUpdate(
            { userId: user._id, month: 'February', year: 2026 },
            myRecord,
            { upsert: true, new: true }
        );

        console.log('🚀 Performance data created for ' + user.name);
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

seedMyPerformance();
