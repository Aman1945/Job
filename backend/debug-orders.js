const mongoose = require('mongoose');
require('dotenv').config();
const Order = require('./models/Order');

async function checkOrders() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const orders = await Order.find({});
        console.log('--- ORDER LIST ---');
        console.log('Total Orders found:', orders.length);

        if (orders.length > 0) {
            orders.slice(0, 5).forEach(o => {
                console.log(`ID: ${o.id}, Status: ${o.status}, Customer: ${o.customerName}, Salesperson: ${o.salespersonId}`);
            });
        }

        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err.message);
        process.exit(1);
    }
}

checkOrders();
