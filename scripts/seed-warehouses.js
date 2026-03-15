const mongoose = require('mongoose');
require('dotenv').config();
const Warehouse = require('../models/Warehouse');

async function seedWarehouses() {
    try {
        console.log('🔄 Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected\n');

        const warehouses = [
            {
                name: 'Kurla Cold Storage',
                location: 'Mumbai',
                capacityTotal: 50000,
                temperature: { current: -18, min: -22, max: 4 },
                inventory: [
                    {
                        skuCode: 'RICE-BASMATI-5KG',
                        name: 'Premium Basmati Rice 5kg',
                        qty: 1000,
                        batches: [{ batchNumber: 'B001', qty: 1000, expiry: new Date('2026-12-01') }]
                    },
                    {
                        skuCode: 'DAL-TOOR-1KG',
                        name: 'Toor Dal 1kg',
                        qty: 500,
                        batches: [{ batchNumber: 'B101', qty: 500, expiry: new Date('2026-06-01') }]
                    }
                ]
            },
            {
                name: 'DP World Nhava Sheva',
                location: 'Navi Mumbai',
                capacityTotal: 80000,
                temperature: { current: -20, min: -25, max: -18 },
                inventory: [
                    {
                        skuCode: 'OIL-SUNFLOWER-1L',
                        name: 'Sunflower Oil 1L',
                        qty: 2000,
                        batches: [{ batchNumber: 'B901', qty: 2000, expiry: new Date('2026-09-01') }]
                    }
                ]
            }
        ];

        for (const wh of warehouses) {
            const existing = await Warehouse.findOne({ name: wh.name });
            if (!existing) {
                const newWh = new Warehouse(wh);
                newWh.recalculateCapacity();
                await newWh.save();
                console.log(`✅ Created warehouse: ${wh.name}`);
            } else {
                console.log(`⏭️  Warehouse already exists: ${wh.name}`);
            }
        }

        console.log('\n✅ Seeding complete');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err.message);
        process.exit(1);
    }
}

seedWarehouses();
