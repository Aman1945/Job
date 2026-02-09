require('dotenv').config();
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');

const User = require('./models/User');
const Customer = require('./models/Customer');
const Product = require('./models/Product');
const Order = require('./models/Order');

const mongoURI = process.env.MONGODB_URI;

if (!mongoURI || mongoURI.includes('your_mongodb_connection_string_here')) {
    console.error('Error: Please provide a valid MONGODB_URI in the .env file.');
    process.exit(1);
}

const migrate = async () => {
    try {
        await mongoose.connect(mongoURI);
        console.log('Connected to MongoDB for migration...');

        const dataDir = path.join(__dirname, 'data');

        // Helper to load JSON
        const loadJSON = (file) => JSON.parse(fs.readFileSync(path.join(dataDir, file), 'utf8'));

        // Migrate Users
        console.log('Migrating Users...');
        const users = loadJSON('users.json');
        await User.deleteMany({});
        await User.insertMany(users);

        // Migrate Customers
        console.log('Migrating Customers...');
        const customers = loadJSON('customers.json');
        await Customer.deleteMany({});
        await Customer.insertMany(customers);

        // Migrate Products
        console.log('Migrating Products...');
        const products = loadJSON('products.json');
        await Product.deleteMany({});
        await Product.insertMany(products);

        // Migrate Orders
        console.log('Migrating Orders...');
        const orders = loadJSON('orders.json');
        await Order.deleteMany({});
        await Order.insertMany(orders);

        console.log('Migration successful!');
        process.exit(0);
    } catch (error) {
        console.error('Migration failed:', error);
        process.exit(1);
    }
};

migrate();
