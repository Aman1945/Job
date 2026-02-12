const mongoose = require('mongoose');
const PerformanceRecord = require('./models/PerformanceRecord');
const User = require('./models/User');
require('dotenv').config();

async function seedMyPerformance() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        // Search by 'id' since that's where the email is stored for this user
        const user = await User.findOne({ id: 'animesh.jamuar@bigsams.in' });
        if (!user) {
            console.log('❌ User not found!');
            return;
        }

        const targetMonth = new Date().toLocaleDateString('en-US', { month: 'short', year: '2-digit' }).replace(' ', "'");

        const myRecord = {
            userId: user.id,
            userName: user.name,
            month: targetMonth,
            grossMonthlySalary: 75000,
            totalScore: 92.5,
            incentivePercentage: 10,
            incentiveAmount: 7500,
            kras: [
                { id: 1, name: 'Order Processing Speed', target: 100, achieved: 95, weightage: 30, type: 'Unrestricted' },
                { id: 2, name: 'Customer Satisfaction', target: 5, achieved: 4.8, weightage: 20, type: 'Restricted' },
                { id: 3, name: 'Operational Accuracy', target: 100, achieved: 98, weightage: 30, type: 'Unrestricted' },
                { id: 4, name: 'New Client Onboarding', target: 10, achieved: 9, weightage: 20, type: 'Restricted' }
            ],
            odBalances: {
                chennai: 1200000,
                self: 500000,
                hyd: 300000
            }
        };

        await PerformanceRecord.findOneAndUpdate(
            { userId: user.id, month: targetMonth },
            myRecord,
            { upsert: true, new: true }
        );

        console.log(`🚀 Performance data created for ${user.name} for month ${targetMonth}`);
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

seedMyPerformance();
