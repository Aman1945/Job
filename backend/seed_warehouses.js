const mongoose = require('mongoose');
require('dotenv').config();
const Warehouse = require('./models/Warehouse');

const warehouses = [
    {
        name: 'Kurla Cold Storage',
        location: 'Mumbai, MH',
        capacityTotal: 50000,
        temperature: { current: -18, min: -22, max: -4 }
    },
    {
        name: 'DP World Nhava Sheva',
        location: 'Navi Mumbai, MH',
        capacityTotal: 80000,
        temperature: { current: -20, min: -25, max: -15 }
    },
    {
        name: 'Arihant Delhi',
        location: 'Lawrence Road, Delhi',
        capacityTotal: 60000,
        temperature: { current: -19, min: -23, max: -5 }
    },
    {
        name: 'Jolly BNG',
        location: 'Whitefield, Bangalore',
        capacityTotal: 45000,
        temperature: { current: -18, min: -21, max: -4 }
    }
];

async function seed() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('🛰️ Connected to MongoDB');

        for (const wh of warehouses) {
            const existing = await Warehouse.findOne({ name: wh.name });
            if (existing) {
                console.log(`⚠️  Warehouse ${wh.name} already exists, updating...`);
                Object.assign(existing, wh);
                await existing.save();
            } else {
                console.log(`✅ Creating Warehouse: ${wh.name}`);
                await new Warehouse(wh).save();
            }
        }

        console.log('🚀 Seeding complete!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
}

seed();
