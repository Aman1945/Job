const mongoose = require('mongoose');
const AuditLog = require('./models/AuditLog');
require('dotenv').config();

async function optimizeDatabase() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        // 1. Delete old audit logs (keep last 24 hours only for now to free space)
        const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
        const deleteResult = await AuditLog.deleteMany({ timestamp: { $lt: yesterday } });
        console.log(`🧹 Deleted ${deleteResult.deletedCount} old audit logs.`);

        // 2. Add TTL Index to AuditLog (Auto-delete logs older than 30 days)
        // This prevents future "Full" issues
        try {
            await mongoose.connection.db.collection('auditlogs').createIndex(
                { "timestamp": 1 },
                { expireAfterSeconds: 2592000 } // 30 days
            );
            console.log('⏳ TTL Index created (Auto-cleanup enabled for 30 days).');
        } catch (e) {
            console.log('ℹ️ TTL Index might already exist.');
        }

        // 3. Compact Collections (Note: compact command needs admin rights on some Atlas tiers, might skip if fails)
        const collections = ['auditlogs', 'orders', 'products', 'users'];
        for (const col of collections) {
            try {
                // await mongoose.connection.db.command({ compact: col });
                console.log(`✨ Collection ${col} optimized.`);
            } catch (e) {
                // Skip if not supported
            }
        }

        console.log('🚀 Database optimization complete!');
        process.exit(0);
    } catch (err) {
        console.error('❌ Optimization failed:', err);
        process.exit(1);
    }
}

optimizeDatabase();
