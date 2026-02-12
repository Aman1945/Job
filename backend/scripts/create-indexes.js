/**
 * NexusOMS - Database Index Creation Script
 * Creates indexes for faster queries
 */

const mongoose = require('mongoose');
require('dotenv').config();

async function createIndexes() {
    try {
        console.log('🔄 Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB Atlas\n');

        const db = mongoose.connection.db;

        console.log('📊 Creating indexes...\n');

        // User indexes
        console.log('Creating User indexes...');
        await db.collection('users').createIndex({ id: 1 }, { unique: true });
        await db.collection('users').createIndex({ email: 1 });
        await db.collection('users').createIndex({ role: 1 });
        await db.collection('users').createIndex({ status: 1 });
        console.log('✅ User indexes created');

        // Customer indexes
        console.log('Creating Customer indexes...');
        await db.collection('customers').createIndex({ id: 1 }, { unique: true });
        await db.collection('customers').createIndex({ name: 1 });
        await db.collection('customers').createIndex({ creditLimit: 1 });
        console.log('✅ Customer indexes created');

        // Product indexes
        console.log('Creating Product indexes...');
        await db.collection('products').createIndex({ id: 1 }, { unique: true });
        await db.collection('products').createIndex({ skuCode: 1 }, { unique: true });
        await db.collection('products').createIndex({ category: 1 });
        await db.collection('products').createIndex({ 'batches.expDate': 1 });
        await db.collection('products').createIndex({ 'batches.batchNumber': 1 });
        console.log('✅ Product indexes created');

        // Order indexes
        console.log('Creating Order indexes...');
        await db.collection('orders').createIndex({ id: 1 }, { unique: true });
        await db.collection('orders').createIndex({ customerId: 1 });
        await db.collection('orders').createIndex({ status: 1 });
        await db.collection('orders').createIndex({ salespersonId: 1 });
        await db.collection('orders').createIndex({ createdAt: -1 });
        await db.collection('orders').createIndex({ isClearance: 1 });
        await db.collection('orders').createIndex({ isBulkUpload: 1 });
        console.log('✅ Order indexes created');

        // Performance Record indexes
        console.log('Creating Performance Record indexes...');
        await db.collection('performancerecords').createIndex({ userId: 1, month: 1 }, { unique: true });
        await db.collection('performancerecords').createIndex({ totalScore: -1 });
        await db.collection('performancerecords').createIndex({ month: 1 });
        console.log('✅ Performance Record indexes created');

        // Packaging Material indexes
        console.log('Creating Packaging Material indexes...');
        await db.collection('packagingmaterials').createIndex({ id: 1 }, { unique: true });
        await db.collection('packagingmaterials').createIndex({ category: 1 });
        await db.collection('packagingmaterials').createIndex({ balance: 1 });
        console.log('✅ Packaging Material indexes created');

        // Packaging Transaction indexes
        console.log('Creating Packaging Transaction indexes...');
        await db.collection('packagingtransactions').createIndex({ id: 1 }, { unique: true });
        await db.collection('packagingtransactions').createIndex({ materialId: 1 });
        await db.collection('packagingtransactions').createIndex({ type: 1 });
        await db.collection('packagingtransactions').createIndex({ date: -1 });
        console.log('✅ Packaging Transaction indexes created');

        // Procurement indexes
        console.log('Creating Procurement indexes...');
        await db.collection('procurements').createIndex({ id: 1 }, { unique: true });
        await db.collection('procurements').createIndex({ status: 1 });
        await db.collection('procurements').createIndex({ createdAt: -1 });
        console.log('✅ Procurement indexes created');

        console.log('\n✅ All indexes created successfully!');
        console.log('📊 Total collections indexed: 8');

        await mongoose.connection.close();
        console.log('🔌 Database connection closed');
        process.exit(0);

    } catch (error) {
        console.error('❌ Error creating indexes:', error.message);
        process.exit(1);
    }
}

createIndexes();
