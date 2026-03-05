/**
 * NexusOMS - MongoDB Data Migration Script
 * Migrates data from Old Atlas DB to New DigitalOcean Managed DB
 */

const { MongoClient } = require('mongodb');

// Source (Old Atlas DB)
const SOURCE_URI = 'mongodb+srv://aman_migration:Aman2024Pass@cluster0.y9nm2y4.mongodb.net/NexusOMS?retryWrites=true&w=majority';
// Destination (New DO Managed DB)
const DEST_URI = 'mongodb+srv://doadmin:l83c0V6pR7f59S1g@db-mongodb-blr1-41071-873a3483.mongo.ondigitalocean.com/NexusOMS?replicaSet=db-mongodb-blr1-41071&tls=true&authSource=admin';

async function migrate() {
    console.log('🚀 Starting Data Migration...');

    const sourceClient = new MongoClient(SOURCE_URI);
    const destClient = new MongoClient(DEST_URI);

    try {
        console.log('🔌 Connecting to Source (Atlas)...');
        await sourceClient.connect();
        console.log('✅ Connected to Source');

        console.log('🔌 Connecting to Destination (DigitalOcean)...');
        await destClient.connect();
        console.log('✅ Connected to Destination');

        const sourceDb = sourceClient.db('NexusOMS');
        const destDb = destClient.db('NexusOMS');

        // Get all collections from source
        const collections = await sourceDb.listCollections().toArray();
        console.log(`📦 Found ${collections.length} collections in source DB`);

        for (const collInfo of collections) {
            const collName = collInfo.name;
            if (collName.startsWith('system.')) continue;

            console.log(`\n--- Migrating collection: ${collName} ---`);

            const sourceColl = sourceDb.collection(collName);
            const destColl = destDb.collection(collName);

            // Fetch all documents
            const docs = await sourceColl.find({}).toArray();
            console.log(`📄 Found ${docs.length} documents in ${collName}`);

            if (docs.length > 0) {
                // Clear destination collection first to avoid duplicates
                await destColl.deleteMany({});
                console.log(`🧹 Cleared destination collection: ${collName}`);

                // Insert into destination
                const result = await destColl.insertMany(docs);
                console.log(`✅ Successfully migrated ${result.insertedCount} documents to ${collName}`);
            } else {
                console.log(`ℹ️ Skipping empty collection: ${collName}`);
            }
        }

        console.log('\n✨ MIGRATION COMPLETE! ✨');

    } catch (err) {
        console.error('❌ Migration Error:', err);
    } finally {
        await sourceClient.close();
        await destClient.close();
    }
}

migrate();
