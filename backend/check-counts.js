const mongoose = require('mongoose');
require('dotenv').config();

// Register all models
const User = require('./models/User');
const Product = require('./models/Product');
const Order = require('./models/Order');

async function checkData() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const orderCount = await Order.countDocuments();
        const userCount = await User.countDocuments();
        const productCount = await Product.countDocuments();

        console.log('--- DATABASE DATA COUNT ---');
        console.log('Orders (Orders collection):', orderCount);
        console.log('Users (Users collection):', userCount);
        console.log('Products (Products collection):', productCount);

        if (orderCount === 0) {
            console.log('⚠️ Warning: Orders collection is EMPTY in MongoDB!');
        }

        process.exit(0);
    } catch (err) {
        console.error('❌ Error during check:', err.message);
        process.exit(1);
    }
}

checkData();
