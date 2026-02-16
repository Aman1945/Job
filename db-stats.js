const mongoose = require('mongoose');
require('dotenv').config();

async function checkDatabaseSize() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const db = mongoose.connection.db;

        console.log('--- MONGODB STORAGE STATS ---');

        const collections = await db.listCollections().toArray();
        const stats = [];

        for (const col of collections) {
            const collectionStats = await db.command({ collStats: col.name });
            stats.push({
                name: col.name,
                count: collectionStats.count,
                sizeKB: (collectionStats.size / 1024).toFixed(2),
                avgObjSize: collectionStats.avgObjSize
            });
        }

        // Sort by size
        stats.sort((a, b) => b.sizeKB - a.sizeKB);

        console.table(stats);

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkDatabaseSize();
