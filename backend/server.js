const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
require('dotenv').config();
const mongoose = require('mongoose');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use('/uploads', express.static('uploads'));

// Multer configuration for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = 'uploads/pod';
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        cb(null, `POD-${Date.now()}-${file.originalname}`);
    }
});
const upload = multer({ storage });

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('✅ Connected to MongoDB Atlas'))
    .catch(err => {
        console.error('❌ MongoDB connection error:', err);
        process.exit(1); // Stop server if database can't connect
    });

// Models
const User = require('./models/User');
const Customer = require('./models/Customer');
const Product = require('./models/Product');
const Order = require('./models/Order');
const Procurement = require('./models/Procurement');

// Use MongoDB as the primary database
const useMongoDB = true;

// Helper functions for local JSON data (fallback)
const getData = (collection) => {
    const filePath = path.join(__dirname, 'data', `${collection}.json`);
    try {
        if (!fs.existsSync(filePath)) return [];
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (e) {
        console.error(`Error reading ${collection}:`, e);
        return [];
    }
};

const saveData = (collection, data) => {
    const dataDir = path.join(__dirname, 'data');
    if (!fs.existsSync(dataDir)) {
        fs.mkdirSync(dataDir, { recursive: true });
    }
    const filePath = path.join(dataDir, `${collection}.json`);
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    } catch (e) {
        console.error(`Error saving ${collection}:`, e);
    }
};


// ==================== HOME ROUTE ====================
app.get('/', (req, res) => {
    res.send(`
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; padding-top: 100px; background-color: #f0fdf4; height: 100vh;">
            <div style="background: white; padding: 40px; border-radius: 30px; display: inline-block; border: 1px solid #10b981; box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);">
                <h1 style="color: #064e3b; margin-bottom: 10px;">🚀 NexusOMS Enterprise API</h1>
                <p style="color: #059669; font-weight: bold;">System Terminal is ONLINE</p>
                <div style="margin-top: 20px; text-align: left; font-size: 14px;">
                    <strong>API Status:</strong> <span style="color: #10b981;">✅ OPERATIONAL</span><br>
                    <strong>Database:</strong> ☁️ MongoDB Cloud (Strict Mode)<br>
                    <strong>Port:</strong> ${PORT}<br>
                    <strong>Version:</strong> v2.1.0
                </div>
            </div>
        </div>
    `);
});

// ==================== AUTHENTICATION ====================
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    console.log(`🔐 Login attempt: ${email}`);

    try {
        // First check if user exists
        const user = await User.findOne({ id: email });

        if (!user) {
            console.log(`❌ Login failed: ${email} (Email not registered)`);
            return res.status(404).json({ message: 'EMAIL_NOT_FOUND' });
        }

        // Check password
        if (user.password !== password) {
            console.log(`❌ Login failed: ${email} (Incorrect password)`);
            return res.status(401).json({ message: 'WRONG_PASSWORD' });
        }

        console.log(`✅ Login successful: ${email}`);
        res.json(user);
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// ==================== USERS ====================
app.get('/api/users', async (req, res) => {
    try {
        const users = await User.find().select('-password');
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching users' });
    }
});

app.post('/api/users', async (req, res) => {
    try {
        const userData = { ...req.body, status: 'Active' };
        const newUser = new User(userData);
        await newUser.save();
        res.status(201).json(newUser);
    } catch (error) {
        res.status(500).json({ message: 'Error creating user' });
    }
});

app.patch('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const user = await User.findOneAndUpdate({ id }, req.body, { new: true });
        if (user) return res.json(user);
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating user' });
    }
});

// ==================== CUSTOMERS ====================
app.get('/api/customers', async (req, res) => {
    try {
        res.json(await Customer.find());
    } catch (error) {
        res.status(500).json({ message: 'Error fetching customers' });
    }
});

app.post('/api/customers', async (req, res) => {
    try {
        const customerData = {
            ...req.body,
            id: req.body.id || `CUST-${Date.now().toString().slice(-6)}`,
            status: 'Active',
            createdAt: new Date().toISOString()
        };
        const newCustomer = new Customer(customerData);
        await newCustomer.save();
        res.status(201).json(newCustomer);
    } catch (error) {
        res.status(500).json({ message: 'Error creating customer' });
    }
});

app.patch('/api/customers/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const customer = await Customer.findOneAndUpdate({ id }, req.body, { new: true });
        if (customer) return res.json(customer);
        res.status(404).json({ message: 'Customer not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating customer' });
    }
});

// ==================== PRODUCTS ====================
app.get('/api/products', async (req, res) => {
    try {
        res.json(await Product.find());
    } catch (error) {
        res.status(500).json({ message: 'Error fetching products' });
    }
});

app.post('/api/products', async (req, res) => {
    try {
        const productData = {
            ...req.body,
            id: req.body.id || req.body.skuCode || `PROD-${Date.now().toString().slice(-6)}`,
            createdAt: new Date().toISOString()
        };
        const newProduct = new Product(productData);
        await newProduct.save();
        res.status(201).json(newProduct);
    } catch (error) {
        res.status(500).json({ message: 'Error creating product' });
    }
});

app.patch('/api/products/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const product = await Product.findOneAndUpdate({ id }, req.body, { new: true });
        if (product) return res.json(product);
        res.status(404).json({ message: 'Product not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating product' });
    }
});

// ==================== ORDERS ====================
app.get('/api/orders', async (req, res) => {
    try {
        const { status, salespersonId } = req.query;
        let query = {};
        if (status) query.status = status;
        if (salespersonId) query.salespersonId = salespersonId;

        const orders = await Order.find(query).sort({ createdAt: -1 });
        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching orders' });
    }
});

app.get('/api/orders/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const order = await Order.findOne({ id });
        if (order) return res.json(order);
        res.status(404).json({ message: 'Order not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching order' });
    }
});

app.post('/api/orders', async (req, res) => {
    try {
        const orderData = {
            ...req.body,
            id: req.body.id || (req.body.isSTN ? `STN-${Date.now().toString().slice(-6)}` : `ORD-${Date.now().toString().slice(-6)}`),
            createdAt: req.body.createdAt || new Date().toISOString(),
            statusHistory: req.body.statusHistory || [{
                status: req.body.status || 'Pending',
                timestamp: new Date().toISOString()
            }]
        };

        if (useMongoDB) {
            const newOrder = new Order(orderData);
            await newOrder.save();
            console.log(`✅ Order created: ${newOrder.id}`);
            return res.status(201).json(newOrder);
        }

        const orders = getData('orders');
        orders.unshift(orderData);
        saveData('orders', orders);
        console.log(`✅ Order created: ${orderData.id}`);
        res.status(201).json(orderData);
    } catch (error) {
        console.error('Order creation error:', error);
        res.status(500).json({ message: 'Error creating order' });
    }
});

app.patch('/api/orders/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = { ...req.body };

        // Add status history if status is being updated
        if (updateData.status) {
            const timestamp = new Date().toISOString();
            if (!updateData.statusHistory) {
                updateData.statusHistory = [];
            }
            updateData.statusHistory.push({ status: updateData.status, timestamp });
        }

        if (useMongoDB) {
            const updateObj = { ...updateData };
            delete updateObj.statusHistory;

            const order = await Order.findOneAndUpdate(
                { id },
                {
                    $set: updateObj,
                    $push: { statusHistory: { status: updateData.status, timestamp: new Date().toISOString() } }
                },
                { new: true }
            );
            if (order) {
                console.log(`✅ Order updated: ${id}`);
                return res.json(order);
            }
        }

        const orders = getData('orders');
        const index = orders.findIndex(o => o.id === id);
        if (index !== -1) {
            const history = orders[index].statusHistory || [];
            if (updateData.status) {
                history.push({ status: updateData.status, timestamp: new Date().toISOString() });
            }
            orders[index] = { ...orders[index], ...updateData, statusHistory: history };
            saveData('orders', orders);
            console.log(`✅ Order updated: ${id}`);
            return res.json(orders[index]);
        }

        res.status(404).json({ message: 'Order not found' });
    } catch (error) {
        console.error('Order update error:', error);
        res.status(500).json({ message: 'Error updating order' });
    }
});

app.delete('/api/orders/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (useMongoDB) {
            const order = await Order.findOneAndDelete({ id });
            if (order) return res.json({ message: 'Order deleted' });
        }

        const orders = getData('orders');
        const filtered = orders.filter(o => o.id !== id);
        if (filtered.length < orders.length) {
            saveData('orders', filtered);
            return res.json({ message: 'Order deleted' });
        }

        res.status(404).json({ message: 'Order not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting order' });
    }
});

// ==================== BULK OPERATIONS ====================
app.post('/api/orders/bulk-update', async (req, res) => {
    try {
        const { orderIds, updates } = req.body;

        if (useMongoDB) {
            const updateObj = { ...updates };
            const query = { $set: updateObj };

            if (updates.status) {
                query.$push = { statusHistory: { status: updates.status, timestamp: new Date().toISOString() } };
            }

            await Order.updateMany({ id: { $in: orderIds } }, query);
            const updatedOrders = await Order.find({ id: { $in: orderIds } });
            return res.json(updatedOrders);
        }

        const orders = getData('orders');
        const updatedOrders = orders.map(o => {
            if (orderIds.includes(o.id)) {
                const history = o.statusHistory || [];
                if (updates.status) {
                    history.push({ status: updates.status, timestamp: new Date().toISOString() });
                }
                return { ...o, ...updates, statusHistory: history };
            }
            return o;
        });
        saveData('orders', updatedOrders);
        res.json(updatedOrders.filter(o => orderIds.includes(o.id)));
    } catch (error) {
        res.status(500).json({ message: 'Error in bulk update' });
    }
});

// ==================== FILE UPLOAD (POD) ====================
app.post('/api/upload/pod', upload.single('pod'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }
        const fileUrl = `/uploads/pod/${req.file.filename}`;
        res.json({ url: fileUrl, filename: req.file.filename });
    } catch (error) {
        res.status(500).json({ message: 'Error uploading file' });
    }
});

// ==================== CREDIT CONTROL ====================
// Get customer payment history
app.get('/api/customers/:customerId/payments', async (req, res) => {
    try {
        const { customerId } = req.params;

        // Mock payment data (in production, fetch from Payment collection)
        const mockPayments = [
            {
                date: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000),
                amount: 45000,
                status: 'Paid',
                orderId: 'ORD-001',
                method: 'Bank Transfer'
            },
            {
                date: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000),
                amount: 32000,
                status: 'Paid',
                orderId: 'ORD-002',
                method: 'Cheque'
            },
            {
                date: new Date(Date.now() - 75 * 24 * 60 * 60 * 1000),
                amount: 28000,
                status: 'Overdue',
                orderId: 'ORD-003',
                method: 'Pending'
            }
        ];

        res.json(mockPayments);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching payment history' });
    }
});

// Get customer credit aging analysis
app.get('/api/customers/:customerId/aging', async (req, res) => {
    try {
        const { customerId } = req.params;

        // Calculate aging buckets
        const agingData = {
            '0-30': { count: 2, amount: 15000 },
            '31-60': { count: 1, amount: 8000 },
            '60+': { count: 1, amount: 28000 },
            totalOutstanding: 51000,
            creditLimit: 100000,
            creditUtilization: 51
        };

        res.json(agingData);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching aging data' });
    }
});

// ==================== LOGISTICS HUB ====================
// Bulk assign logistics to multiple orders
app.post('/api/logistics/bulk-assign', async (req, res) => {
    try {
        const { orderIds, logisticsData } = req.body;

        if (!orderIds || !Array.isArray(orderIds) || orderIds.length === 0) {
            return res.status(400).json({ message: 'Order IDs array is required' });
        }

        const { deliveryAgentId, vehicleNo, vehicleProvider, distanceKm } = logisticsData;

        // Update all orders with logistics info
        const updateResult = await Order.updateMany(
            { _id: { $in: orderIds } },
            {
                $set: {
                    'logistics.deliveryAgentId': deliveryAgentId,
                    'logistics.vehicleNo': vehicleNo,
                    'logistics.vehicleProvider': vehicleProvider,
                    'logistics.distanceKm': distanceKm,
                    'logistics.assignedAt': new Date(),
                    status: 'In Transit'
                }
            }
        );

        res.json({
            success: true,
            message: `${updateResult.modifiedCount} orders assigned to ${deliveryAgentId}`,
            modifiedCount: updateResult.modifiedCount
        });
    } catch (error) {
        console.error('Bulk assignment error:', error);
        res.status(500).json({ message: 'Error assigning logistics' });
    }
});

// ==================== LOGISTICS COST CALCULATOR ====================
// Calculate logistics cost for a route
app.post('/api/logistics/calculate-cost', async (req, res) => {
    try {
        const { origin, destination, vehicleType, distance: providedDistance } = req.body;

        // Mock distance calculation (in production, use Google Maps Distance Matrix API)
        const distance = providedDistance || Math.floor(Math.random() * 500) + 50; // km

        // Cost parameters (configurable)
        const FUEL_RATES = {
            'Truck': 8.5,      // ₹ per km
            'Tempo': 6.5,
            'Van': 5.0,
            'Bike': 2.5
        };

        const DRIVER_ALLOWANCES = {
            'Truck': 800,      // ₹ per day
            'Tempo': 600,
            'Van': 500,
            'Bike': 300
        };

        const selectedVehicle = vehicleType || 'Truck';
        const fuelRate = FUEL_RATES[selectedVehicle] || FUEL_RATES['Truck'];
        const driverAllowance = DRIVER_ALLOWANCES[selectedVehicle] || DRIVER_ALLOWANCES['Truck'];

        // Calculate costs
        const fuelCost = distance * fuelRate;
        const tollCharges = distance > 100 ? Math.floor(distance / 100) * 150 : 0; // ₹150 per 100km
        const miscCharges = 100; // Loading/unloading
        const totalCost = fuelCost + driverAllowance + tollCharges + miscCharges;

        res.json({
            success: true,
            data: {
                origin,
                destination,
                distance,
                vehicleType: selectedVehicle,
                breakdown: {
                    fuelCost: Math.round(fuelCost),
                    driverAllowance,
                    tollCharges,
                    miscCharges,
                    total: Math.round(totalCost)
                },
                estimatedTime: Math.ceil(distance / 60) + ' hours', // Assuming 60 km/h avg speed
            }
        });
    } catch (error) {
        console.error('Cost calculation error:', error);
        res.status(500).json({ message: 'Error calculating logistics cost' });
    }
});

// Get cost history for analytics
app.get('/api/logistics/cost-history', async (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        // Mock cost history data
        const mockHistory = [
            { date: new Date(), orderId: 'ORD-001', route: 'Mumbai-Delhi', cost: 4500, vehicleType: 'Truck' },
            { date: new Date(), orderId: 'ORD-002', route: 'Delhi-Bangalore', cost: 6200, vehicleType: 'Truck' },
            { date: new Date(), orderId: 'ORD-003', route: 'Mumbai-Pune', cost: 1200, vehicleType: 'Tempo' },
        ];

        res.json(mockHistory);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching cost history' });
    }
});

// ==================== ANALYTICS ====================
app.get('/api/analytics/dashboard', async (req, res) => {
    try {
        const orders = await Order.find();

        const totalOrders = orders.length;
        const totalValue = orders.reduce((sum, o) => sum + (o.total || 0), 0);
        const pendingOrders = orders.filter(o => o.status === 'Pending').length;
        const deliveredOrders = orders.filter(o => o.status === 'Delivered').length;

        res.json({
            totalOrders,
            totalValue,
            pendingOrders,
            deliveredOrders,
            averageOrderValue: totalOrders > 0 ? totalValue / totalOrders : 0
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching analytics' });
    }
});

app.get('/api/analytics/sales', async (req, res) => {
    try {
        const { salespersonId } = req.query;
        const orders = await Order.find({ salespersonId });

        const totalSales = orders.reduce((sum, o) => sum + (o.total || 0), 0);
        const totalOrders = orders.length;

        res.json({
            salespersonId,
            totalSales,
            totalOrders,
            averageOrderValue: totalOrders > 0 ? totalSales / totalOrders : 0
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching sales analytics' });
    }
});

// ==================== SALES HUB API ====================
app.get('/api/analytics/sales-hub', async (req, res) => {
    try {
        const { period = 'month' } = req.query;
        const orders = await Order.find();

        const now = new Date();
        let startDate;
        switch (period) {
            case 'today': startDate = new Date(now.setHours(0, 0, 0, 0)); break;
            case 'week': startDate = new Date(now.setDate(now.getDate() - 7)); break;
            case 'six-months': startDate = new Date(now.setMonth(now.getMonth() - 6)); break;
            case 'quarter': startDate = new Date(now.setMonth(now.getMonth() - 3)); break;
            case 'year': startDate = new Date(now.setFullYear(now.getFullYear() - 1)); break;
            default: startDate = new Date(now.setMonth(now.getMonth() - 1));
        }

        const filteredOrders = orders.filter(o => new Date(o.createdAt) >= startDate);
        const totalSales = filteredOrders.reduce((sum, o) => sum + (o.total || 0), 0);
        const completedOrders = filteredOrders.filter(o => o.status === 'Delivered').length;
        const pendingOrders = filteredOrders.filter(o => o.status.includes('Pending')).length;

        const customerSales = {};
        filteredOrders.forEach(order => {
            if (!customerSales[order.customerName]) customerSales[order.customerName] = { name: order.customerName, sales: 0, orders: 0 };
            customerSales[order.customerName].sales += order.total;
            customerSales[order.customerName].orders += 1;
        });

        res.json({
            metrics: { totalSales, completedOrders, pendingOrders, avgOrderValue: filteredOrders.length > 0 ? totalSales / filteredOrders.length : 0 },
            pipeline: {
                newLeads: filteredOrders.filter(o => o.status === 'Pending').length,
                inProgress: filteredOrders.filter(o => o.status.includes('Approved')).length,
                negotiation: filteredOrders.filter(o => o.status.includes('Credit')).length,
                closedWon: filteredOrders.filter(o => o.status === 'Delivered').length
            },
            topCustomers: Object.values(customerSales).sort((a, b) => b.sales - a.sales).slice(0, 5),
            recentActivity: filteredOrders.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)).slice(0, 10)
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching sales hub data' });
    }
});

// ==================== REPORTING API ====================
app.get('/api/analytics/reports', async (req, res) => {
    try {
        const { type = 'sales', startDate, endDate } = req.query;
        const orders = await Order.find();
        const products = await Product.find();
        const customers = await Customer.find();

        let filteredOrders = orders;
        if (startDate && endDate) {
            filteredOrders = orders.filter(o => {
                const d = new Date(o.createdAt);
                return d >= new Date(startDate) && d <= new Date(endDate);
            });
        }

        if (type === 'sales') {
            const totalSales = filteredOrders.reduce((sum, o) => sum + (o.total || 0), 0);
            res.json({ summary: { totalSales, totalOrders: filteredOrders.length, avgOrderValue: filteredOrders.length > 0 ? totalSales / filteredOrders.length : 0 } });
        } else if (type === 'inventory') {
            res.json({ summary: { totalProducts: products.length, totalValue: products.reduce((sum, p) => sum + (p.price * (p.stock || 0)), 0), lowStockCount: products.filter(p => (p.stock || 0) < 10).length } });
        } else {
            res.json({ message: 'Report data generated' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Error generating report' });
    }
});

// ==================== PROCUREMENT GATE API ====================
app.get('/api/procurement', async (req, res) => {
    try {
        if (useMongoDB) {
            const items = await Procurement.find().sort({ createdAt: -1 });
            return res.json(items);
        }
        res.json(getData('procurement'));
    } catch (error) {
        res.status(500).json({ message: 'Error fetching procurement' });
    }
});

app.post('/api/procurement', async (req, res) => {
    try {
        const itemData = {
            ...req.body,
            id: req.body.id || `PRC-${Date.now().toString().slice(-4)}`,
            createdAt: new Date().toISOString(),
            status: 'Pending'
        };

        if (useMongoDB) {
            const newItem = new Procurement(itemData);
            await newItem.save();
            return res.status(201).json(newItem);
        }

        const items = getData('procurement');
        items.unshift(itemData);
        saveData('procurement', items);
        res.status(201).json(itemData);
    } catch (error) {
        res.status(500).json({ message: 'Error creating procurement entry' });
    }
});

app.put('/api/procurement/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        if (useMongoDB) {
            const item = await Procurement.findOneAndUpdate({ id }, updates, { new: true });
            return res.json(item);
        }

        const items = getData('procurement');
        const index = items.findIndex(i => i.id === id);
        if (index !== -1) {
            items[index] = { ...items[index], ...updates };
            saveData('procurement', items);
            return res.json(items[index]);
        }
        res.status(404).json({ message: 'Not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating procurement' });
    }
});

app.delete('/api/procurement/:id', async (req, res) => {
    try {
        const { id } = req.params;
        if (useMongoDB) {
            await Procurement.findOneAndDelete({ id });
            return res.json({ message: 'Deleted' });
        }
        const items = getData('procurement');
        const newItems = items.filter(i => i.id !== id);
        saveData('procurement', newItems);
        res.json({ message: 'Deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting procurement' });
    }
});

// ==================== INTELLIGENCE TERMINAL (EXTENDED) ====================
app.get('/api/analytics/category-split', async (req, res) => {
    try {
        // Mocking sophisticated category split logic
        res.json({
            split: [
                { category: 'BREADED', value: 65, color: '#6366F1' },
                { category: 'MARINATED', value: 20, color: '#10B981' },
                { category: 'RAW CANNED', value: 15, color: '#F59E0B' }
            ],
            concentration: [
                { label: 'BREADED', qty: 450 },
                { label: 'MARINATED', qty: 120 },
                { label: 'RAW CANNED', qty: 90 }
            ]
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching category split data' });
    }
});

app.get('/api/analytics/fleet', async (req, res) => {
    try {
        res.json({
            metrics: {
                coverage: '4.2 KM',
                activeAssets: '12',
                successfulDrops: '89',
                personnel: '15'
            },
            velocity: [
                { time: '08:00', drops: 5 },
                { time: '10:00', drops: 12 },
                { time: '12:00', drops: 8 },
                { time: '14:00', drops: 15 },
                { time: '16:00', drops: 3 }
            ]
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching fleet intelligence data' });
    }
});

// ==================== PMS API ====================
app.get('/api/analytics/pms', async (req, res) => {
    try {
        const { userId } = req.query;
        const orders = await Order.find();

        // Calculate performance for EVERY user to build a leaderboard
        const userPerformanceMap = {};
        orders.forEach(o => {
            const sid = o.salespersonId || 'Unknown';
            if (!userPerformanceMap[sid]) {
                userPerformanceMap[sid] = { name: sid, sales: 0, orders: 0, completed: 0 };
            }
            userPerformanceMap[sid].sales += (o.total || 0);
            userPerformanceMap[sid].orders += 1;
            if (o.status === 'Delivered') userPerformanceMap[sid].completed += 1;
        });

        const leaderboard = Object.values(userPerformanceMap)
            .map(u => ({
                ...u,
                score: Math.min(100, Math.round((u.sales / 10000) + (u.completed * 5))),
                completionRate: u.orders > 0 ? (u.completed / u.orders * 100).toFixed(1) : 0
            }))
            .sort((a, b) => b.score - a.score);

        const targetUser = userId ? leaderboard.find(u => u.name === userId) : leaderboard[0];

        res.json({
            userPerformance: targetUser || { score: 0, rank: 'N/A', growth: '0%', totalSales: 0, totalOrders: 0 },
            kpis: {
                ordersCompleted: targetUser ? targetUser.completed : 0,
                responseTime: 2.5,
                customerSatisfaction: 4.8,
                targetAchievement: targetUser ? Math.min(100, (targetUser.sales / 500000 * 100)).toFixed(1) : 0
            },
            leaderboard: leaderboard.slice(0, 10)
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching PMS data' });
    }
});


// ==================== EXPORT/DOWNLOAD REPORTS ====================
app.get('/api/analytics/export', async (req, res) => {
    try {
        const { type = 'sales_report', format = 'pdf' } = req.query;
        const orders = await Order.find();
        const products = await Product.find();
        const customers = await Customer.find();

        const reportName = type.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        const fileName = `${type}_${Date.now()}.${format}`;

        if (format === 'pdf') {
            // Generate PDF content (simplified - in production use a PDF library)
            const pdfContent = generatePDFContent(reportName, orders, products, customers);

            res.setHeader('Content-Type', 'application/pdf');
            res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
            res.setHeader('Content-Length', Buffer.byteLength(pdfContent));
            res.send(pdfContent);
        } else if (format === 'excel' || format === 'xlsx') {
            // Generate Excel content (simplified - in production use xlsx library)
            const excelContent = generateExcelContent(reportName, orders, products, customers);

            res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
            res.send(excelContent);
        } else if (format === 'csv') {
            // Generate CSV content
            const csvContent = generateCSVContent(orders);

            res.setHeader('Content-Type', 'text/csv');
            res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
            res.send(csvContent);
        } else {
            res.status(400).json({ message: 'Unsupported format' });
        }
    } catch (error) {
        console.error('Export error:', error);
        res.status(500).json({ message: 'Error generating export' });
    }
});

// Helper functions for report generation
function generatePDFContent(reportName, orders, products, customers) {
    // Simplified PDF generation - in production, use pdfkit or similar
    const totalSales = orders.reduce((sum, o) => sum + (o.total || 0), 0);
    const totalOrders = orders.length;

    return `%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/Resources <<
/Font <<
/F1 <<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
>>
>>
/MediaBox [0 0 612 792]
/Contents 4 0 R
>>
endobj
4 0 obj
<<
/Length 200
>>
stream
BT
/F1 24 Tf
50 750 Td
(${reportName}) Tj
0 -30 Td
/F1 12 Tf
(Total Orders: ${totalOrders}) Tj
0 -20 Td
(Total Sales: Rs. ${totalSales.toFixed(2)}) Tj
0 -20 Td
(Generated: ${new Date().toLocaleDateString()}) Tj
ET
endstream
endobj
xref
0 5
0000000000 65535 f
0000000009 00000 n
0000000058 00000 n
0000000115 00000 n
0000000317 00000 n
trailer
<<
/Size 5
/Root 1 0 R
>>
startxref
565
%%EOF`;
}

function generateExcelContent(reportName, orders, products, customers) {
    // Simplified Excel generation - in production, use exceljs or xlsx
    const csvData = generateCSVContent(orders);
    return Buffer.from(csvData);
}

function generateCSVContent(orders) {
    let csv = 'Order ID,Customer Name,Status,Total,Created At\n';
    orders.forEach(order => {
        csv += `${order.id},${order.customerName},${order.status},${order.total},${order.createdAt}\n`;
    });
    return csv;
}

// ==================== TALLY EXPORT ====================
app.get('/api/tally/export/:orderId', async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findOne({ id: orderId });

        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }

        const tallyXml = `<ENVELOPE>
 <HEADER>
  <TALLYREQUEST>Import Data</TALLYREQUEST>
 </HEADER>
 <BODY>
  <IMPORTDATA>
   <REQUESTDESC>
    <REPORTNAME>Vouchers</REPORTNAME>
   </REQUESTDESC>
   <REQUESTDATA>
    <TALLYMESSAGE xmlns:UDF="TallyUDF">
     <VOUCHER VCHTYPE="Sales" ACTION="Create">
      <DATE>${order.createdAt.split('T')[0].replace(/-/g, '')}</DATE>
      <VOUCHERNUMBER>${order.id}</VOUCHERNUMBER>
      <PARTYLEDGERNAME>${order.customerName}</PARTYLEDGERNAME>
      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>${order.customerName}</LEDGERNAME>
       <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
       <AMOUNT>-${order.total}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>
      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>Sales Account</LEDGERNAME>
       <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
       <AMOUNT>${order.total}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>
     </VOUCHER>
    </TALLYMESSAGE>
   </REQUESTDATA>
  </IMPORTDATA>
 </BODY>
</ENVELOPE>`;

        res.set('Content-Type', 'application/xml');
        res.send(tallyXml);
    } catch (error) {
        res.status(500).json({ message: 'Error generating Tally XML' });
    }
});

// ==================== ERROR HANDLING ====================
app.use((req, res) => {
    res.status(404).json({ message: 'Endpoint not found' });
});

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal server error' });
});

// ==================== START SERVER ====================
app.listen(PORT, '0.0.0.0', () => {
    const { networkInterfaces } = require('os');
    const nets = networkInterfaces();
    const ips = [];
    for (const name of Object.keys(nets)) {
        for (const net of nets[name]) {
            if (net.family === 'IPv4' && !net.internal) {
                ips.push(net.address);
            }
        }
    }

    console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          🚀 NexusOMS Enterprise API v2.1.0            ║
║                                                        ║
║  Status: ✅ ONLINE (Strict Mode)                       ║
║  Port: ${PORT}                                         ║
║  Database: ☁️  MongoDB Atlas                            ║
║                                                        ║
║  Local IPs for Mobile Connection:                      ║
${ips.map(ip => `║  🔗 http://${ip}:${PORT}                         `).join('\n')}
║                                                        ║
╚════════════════════════════════════════════════════════╝
    `);
});
