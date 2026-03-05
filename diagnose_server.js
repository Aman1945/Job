const mongoose = require('mongoose');
require('dotenv').config({ path: '/root/Job/backend/.env' });

async function diagnose() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const Order = mongoose.connection.collection('orders');

        console.log(`\n--- ALL Orders in Database (Last 50) ---`);
        const orders = await Order.find({}).sort({ createdAt: -1 }).limit(50).toArray();

        console.log(`Total count in collection: ${await Order.countDocuments()}`);

        if (orders.length > 0) {
            console.log(JSON.stringify(orders.map(o => ({
                id: o.id,
                salespersonId: o.salespersonId,
                customerName: o.customerName,
                status: o.status,
                createdAt: o.createdAt
            })), null, 2));
        }

    } catch (err) {
        console.error('❌ Error:', err);
    } finally {
        await mongoose.disconnect();
        process.exit(0);
    }
}

diagnose();
