const mongoose = require('mongoose');
require('dotenv').config();

async function checkDatabaseSize() {
    try {
        console.log('🛰️ Connecting to MongoDB Atlas...');
        await mongoose.connect(process.env.MONGODB_URI);
        const db = mongoose.connection.db;

        console.log('--- MONGODB STORAGE STATS (Atlas) ---');

        const collections = await db.listCollections().toArray();
        const stats = [];

        for (const col of collections) {
            const collectionStats = await db.command({ collStats: col.name });
            stats.push({
                Collection: col.name,
                Documents: collectionStats.count,
                Size_KB: (collectionStats.size / 1024).toFixed(2),
                Storage_KB: (collectionStats.storageSize / 1024).toFixed(2),
                Avg_Obj_Size: (collectionStats.avgObjSize || 0).toFixed(2)
            });
        }

        // Sort by size
        stats.sort((a, b) => b.Size_KB - a.Size_KB);

        console.table(stats);

        const dbStats = await db.command({ dbStats: 1 });
        console.log(`\n📊 Total Database Size: ${(dbStats.dataSize / (1024 * 1024)).toFixed(2)} MB`);
        console.log(`📊 Total Storage Allocated: ${(dbStats.storageSize / (1024 * 1024)).toFixed(2)} MB`);
        console.log(`⚠️ Atlas Free Tier Limit: 512.00 MB`);

        process.exit(0);
    } catch (err) {
        console.error('❌ Error fetching stats:', err.message);
        process.exit(1);
    }
}

checkDatabaseSize();
