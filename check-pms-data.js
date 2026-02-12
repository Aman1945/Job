const mongoose = require('mongoose');
const PerformanceRecord = require('./models/PerformanceRecord');
require('dotenv').config();

async function checkData() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const records = await PerformanceRecord.find({ userId: 'animesh.jamuar@bigsams.in' });
        console.log('--- RECORDS FOR ANIMESH ---');
        console.log(JSON.stringify(records, null, 2));
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkData();
