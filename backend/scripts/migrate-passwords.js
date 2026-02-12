/**
 * NexusOMS - Password Migration Script
 * Migrates all plaintext passwords to bcrypt hashed passwords
 * Run once: npm run migrate-passwords
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import User model
const User = require('../models/User');

async function migratePasswords() {
    try {
        console.log('🔄 Starting password migration...\n');

        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB\n');

        // Fetch all users
        const users = await User.find({});
        console.log(`📊 Found ${users.length} users in database\n`);

        let migrated = 0;
        let skipped = 0;
        let errors = 0;

        for (const user of users) {
            try {
                // Check if password is already hashed (bcrypt hashes start with $2b$)
                if (user.password && user.password.startsWith('$2b$')) {
                    console.log(`⏭️  Skipped: ${user.id} (${user.name}) - Already hashed`);
                    skipped++;
                    continue;
                }

                // Store original password for logging
                const originalPassword = user.password;

                // Hash the password
                const salt = await bcrypt.genSalt(10);
                const hashedPassword = await bcrypt.hash(originalPassword, salt);

                // Update user password directly (bypass pre-save hook)
                await User.updateOne(
                    { _id: user._id },
                    { $set: { password: hashedPassword } }
                );

                console.log(`✅ Migrated: ${user.id} (${user.name})`);
                migrated++;

            } catch (error) {
                console.error(`❌ Error migrating ${user.id}:`, error.message);
                errors++;
            }
        }

        console.log('\n' + '='.repeat(60));
        console.log('📊 MIGRATION SUMMARY');
        console.log('='.repeat(60));
        console.log(`✅ Successfully migrated: ${migrated} users`);
        console.log(`⏭️  Skipped (already hashed): ${skipped} users`);
        console.log(`❌ Errors: ${errors} users`);
        console.log(`📊 Total users: ${users.length}`);
        console.log('='.repeat(60) + '\n');

        if (migrated > 0) {
            console.log('🎉 Password migration completed successfully!');
            console.log('💡 All users can now login with their existing passwords.');
            console.log('🔐 Passwords are now securely hashed with bcrypt.\n');
        } else if (skipped === users.length) {
            console.log('ℹ️  All passwords are already hashed. No migration needed.\n');
        }

        process.exit(0);

    } catch (error) {
        console.error('\n❌ FATAL ERROR:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
}

// Run migration
console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║       🔐 NexusOMS Password Migration Tool             ║
║                                                        ║
║  This script will hash all plaintext passwords        ║
║  using bcrypt (10 salt rounds)                        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
`);

migratePasswords();
