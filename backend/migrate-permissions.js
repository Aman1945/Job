const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./models/User');

async function migratePermissions() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB\n');

        // Role-to-Permission mapping
        const rolePermissionMap = {
            'Admin': [
                'view_orders', 'create_orders', 'approve_credit',
                'manage_warehouse', 'quality_control', 'logistics_costing',
                'invoicing', 'fleet_loading', 'delivery', 'procurement',
                'admin_bypass', 'user_management', 'master_data'
            ],
            'Sales': ['view_orders', 'create_orders'],
            'Credit Control': ['view_orders', 'approve_credit'],
            'WH Manager': ['manage_warehouse', 'quality_control'],
            'WH House': ['manage_warehouse'],
            'Warehouse': ['manage_warehouse'],
            'QC Head': ['quality_control'],
            'Logistics Lead': ['logistics_costing', 'fleet_loading'],
            'Logistics Team': ['logistics_costing'],
            'Billing': ['invoicing'],
            'ATL Executive': ['invoicing'],
            'Hub Lead': ['fleet_loading'],
            'Delivery Team': ['delivery'],
            'Procurement': ['procurement'],
            'Procurement Head': ['procurement']
        };

        const users = await User.find();
        console.log(`Found ${users.length} users to migrate\n`);

        for (const user of users) {
            const permissions = rolePermissionMap[user.role] || [];

            await User.findByIdAndUpdate(user._id, { permissions });
            console.log(`✅ ${user.name} (${user.role}): [${permissions.join(', ')}]`);
        }

        console.log('\n🎉 Migration complete!');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err.message);
        process.exit(1);
    }
}

migratePermissions();
