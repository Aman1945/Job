/**
 * NexusOMS - Sample Data Seeding Script
 * Creates sample data for testing
 */

const mongoose = require('mongoose');
require('dotenv').config();

const User = require('../models/User');
const Customer = require('../models/Customer');
const Product = require('../models/Product');
const PerformanceRecord = require('../models/PerformanceRecord');
const PackagingMaterial = require('../models/PackagingMaterial');

async function seedData() {
    try {
        console.log('🔄 Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB Atlas\n');

        console.log('📊 Seeding sample data...\n');

        // Create sample users
        console.log('Creating sample users...');
        const users = [
            { id: 'SALES-001', name: 'Rajesh Kumar', email: 'rajesh@nexusoms.com', password: 'sales123', role: 'Sales', status: 'Active' },
            { id: 'SALES-002', name: 'Priya Sharma', email: 'priya@nexusoms.com', password: 'sales123', role: 'Sales', status: 'Active' },
            { id: 'CREDIT-001', name: 'Amit Patel', email: 'amit@nexusoms.com', password: 'credit123', role: 'Credit Control', status: 'Active' },
            { id: 'WAREHOUSE-001', name: 'Suresh Reddy', email: 'suresh@nexusoms.com', password: 'warehouse123', role: 'Warehouse', status: 'Active' },
            { id: 'LOGISTICS-001', name: 'Vikram Singh', email: 'vikram@nexusoms.com', password: 'logistics123', role: 'Logistics', status: 'Active' },
        ];

        let userCount = 0;
        for (const userData of users) {
            const existing = await User.findOne({ id: userData.id });
            if (!existing) {
                await User.create(userData);
                console.log(`  ✅ Created user: ${userData.name} (${userData.role})`);
                userCount++;
            } else {
                console.log(`  ⏭️  Skipped user: ${userData.name} (already exists)`);
            }
        }
        console.log(`✅ Users: ${userCount} created\n`);

        // Create sample customers
        console.log('Creating sample customers...');
        const customers = [
            {
                id: 'CUST-001',
                name: 'ABC Traders',
                address: 'Shop 12, Market Road, Mumbai',
                phone: '9876543210',
                outstanding: 15000,
                overdue: 5000,
                ageingDays: 45,
                creditLimit: 50000,
                paymentHistory: 'Good - 2 late payments in last 6 months'
            },
            {
                id: 'CUST-002',
                name: 'XYZ Enterprises',
                address: '45, Industrial Area, Delhi',
                phone: '9876543211',
                outstanding: 8000,
                overdue: 0,
                ageingDays: 15,
                creditLimit: 100000,
                paymentHistory: 'Excellent - Always on time'
            },
            {
                id: 'CUST-003',
                name: 'PQR Distributors',
                address: '78, Main Street, Bangalore',
                phone: '9876543212',
                outstanding: 25000,
                overdue: 12000,
                ageingDays: 75,
                creditLimit: 30000,
                paymentHistory: 'Poor - Multiple delays'
            },
        ];

        let customerCount = 0;
        for (const custData of customers) {
            const existing = await Customer.findOne({ id: custData.id });
            if (!existing) {
                await Customer.create(custData);
                console.log(`  ✅ Created customer: ${custData.name}`);
                customerCount++;
            } else {
                console.log(`  ⏭️  Skipped customer: ${custData.name} (already exists)`);
            }
        }
        console.log(`✅ Customers: ${customerCount} created\n`);

        // Create sample products with batches
        console.log('Creating sample products...');
        const products = [
            {
                id: 'PROD-001',
                skuCode: 'RICE-BASMATI-5KG',
                name: 'Premium Basmati Rice 5kg',
                category: 'Rice',
                baseRate: 450,
                mrp: 500,
                stock: 150,
                batches: [
                    { batchId: 'B001', batchNumber: 'BATCH-001', mfgDate: '2025-12-01', expDate: '2026-06-01', quantity: 100, weight: '5 KG', isActive: true },
                    { batchId: 'B002', batchNumber: 'BATCH-002', mfgDate: '2026-01-01', expDate: '2026-07-01', quantity: 50, weight: '5 KG', isActive: true },
                ]
            },
            {
                id: 'PROD-002',
                skuCode: 'DAL-TOOR-1KG',
                name: 'Toor Dal 1kg',
                category: 'Pulses',
                baseRate: 120,
                mrp: 140,
                stock: 200,
                batches: [
                    { batchId: 'B003', batchNumber: 'BATCH-003', mfgDate: '2026-01-15', expDate: '2026-07-15', quantity: 200, weight: '1 KG', isActive: true },
                ]
            },
            {
                id: 'PROD-003',
                skuCode: 'OIL-SUNFLOWER-1L',
                name: 'Sunflower Oil 1L',
                category: 'Oil',
                baseRate: 180,
                mrp: 200,
                stock: 75,
                batches: [
                    { batchId: 'B004', batchNumber: 'BATCH-004', mfgDate: '2025-11-01', expDate: '2026-05-01', quantity: 75, weight: '1 L', isActive: true },
                ]
            },
        ];

        let productCount = 0;
        for (const prodData of products) {
            const existing = await Product.findOne({ id: prodData.id });
            if (!existing) {
                const product = await Product.create(prodData);
                product.calculateStock();
                await product.save();
                console.log(`  ✅ Created product: ${prodData.name} (${prodData.stock} units)`);
                productCount++;
            } else {
                console.log(`  ⏭️  Skipped product: ${prodData.name} (already exists)`);
            }
        }
        console.log(`✅ Products: ${productCount} created\n`);

        // Create sample performance records
        console.log('Creating sample performance records...');
        const perfRecords = [
            {
                userId: 'SALES-001',
                userName: 'Rajesh Kumar',
                month: "Feb'26",
                grossMonthlySalary: 50000,
                kras: [
                    { id: 1, name: 'Sales Target', type: 'Unrestricted', target: 1000000, achieved: 1200000, weightage: 40, score: 0 },
                    { id: 2, name: 'Collection', type: 'Restricted', target: 500000, achieved: 450000, weightage: 30, score: 0 },
                    { id: 3, name: 'New Customers', type: 'Unrestricted', target: 10, achieved: 12, weightage: 20, score: 0 },
                ],
                odBalances: { chennai: 300000, self: 200000, hyd: 100000 },
                totalScore: 0,
                incentivePercentage: 0,
                incentiveAmount: 0
            },
            {
                userId: 'SALES-002',
                userName: 'Priya Sharma',
                month: "Feb'26",
                grossMonthlySalary: 45000,
                kras: [
                    { id: 1, name: 'Sales Target', type: 'Unrestricted', target: 800000, achieved: 950000, weightage: 40, score: 0 },
                    { id: 2, name: 'Collection', type: 'Restricted', target: 400000, achieved: 420000, weightage: 30, score: 0 },
                    { id: 3, name: 'New Customers', type: 'Unrestricted', target: 8, achieved: 10, weightage: 20, score: 0 },
                ],
                odBalances: { chennai: 250000, self: 150000, hyd: 80000 },
                totalScore: 0,
                incentivePercentage: 0,
                incentiveAmount: 0
            },
        ];

        let perfCount = 0;
        for (const perfData of perfRecords) {
            const existing = await PerformanceRecord.findOne({ userId: perfData.userId, month: perfData.month });
            if (!existing) {
                const record = await PerformanceRecord.create(perfData);
                record.calculateTotalScore();
                await record.save();
                console.log(`  ✅ Created PMS record: ${perfData.userName} - Score: ${record.totalScore.toFixed(2)}%`);
                perfCount++;
            } else {
                console.log(`  ⏭️  Skipped PMS record: ${perfData.userName} (already exists)`);
            }
        }
        console.log(`✅ Performance Records: ${perfCount} created\n`);

        // Create sample packaging materials
        console.log('Creating sample packaging materials...');
        const materials = [
            { id: 'PKG-001', name: 'Poly Bags 5kg', unit: 'PCS', moq: 1000, balance: 500, category: 'Poly Pkts' },
            { id: 'PKG-002', name: 'Vacuum Pouches 1kg', unit: 'PCS', moq: 500, balance: 200, category: 'Vacuum Pouches' },
            { id: 'PKG-003', name: 'Carton Box 10kg', unit: 'PCS', moq: 200, balance: 150, category: 'Cartons' },
            { id: 'PKG-004', name: 'Packing Tape', unit: 'ROLLS', moq: 50, balance: 25, category: 'Tape/Labels' },
        ];

        let materialCount = 0;
        for (const matData of materials) {
            const existing = await PackagingMaterial.findOne({ id: matData.id });
            if (!existing) {
                await PackagingMaterial.create(matData);
                const lowStock = matData.balance <= matData.moq ? '⚠️  LOW STOCK' : '';
                console.log(`  ✅ Created material: ${matData.name} (${matData.balance}/${matData.moq}) ${lowStock}`);
                materialCount++;
            } else {
                console.log(`  ⏭️  Skipped material: ${matData.name} (already exists)`);
            }
        }
        console.log(`✅ Packaging Materials: ${materialCount} created\n`);

        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('✅ Sample data seeding complete!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log(`📊 Summary:`);
        console.log(`   Users: ${userCount} created`);
        console.log(`   Customers: ${customerCount} created`);
        console.log(`   Products: ${productCount} created`);
        console.log(`   Performance Records: ${perfCount} created`);
        console.log(`   Packaging Materials: ${materialCount} created`);
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

        await mongoose.connection.close();
        console.log('🔌 Database connection closed');
        process.exit(0);

    } catch (error) {
        console.error('❌ Error seeding data:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
}

seedData();
