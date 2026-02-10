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
let useMongoDB = false;
if (process.env.MONGODB_URI && !process.env.MONGODB_URI.includes('your_mongodb')) {
    mongoose.connect(process.env.MONGODB_URI)
        .then(() => {
            console.log('✅ Connected to MongoDB Atlas');
            useMongoDB = true;
        })
        .catch(err => {
            console.error('❌ MongoDB connection error:', err);
            console.log('⚠️ Falling back to JSON storage');
        });
}

// Models
const User = require('./models/User');
const Customer = require('./models/Customer');
const Product = require('./models/Product');
const Order = require('./models/Order');

// Helper functions
const getData = (filename) => {
    const filePath = path.join(__dirname, 'data', `${filename}.json`);
    if (!fs.existsSync(filePath)) return [];
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
};

const saveData = (filename, data) => {
    const filePath = path.join(__dirname, 'data', `${filename}.json`);
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
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
                    <strong>Database:</strong> ${useMongoDB ? '☁️ MongoDB Cloud' : '📁 Local JSON Enterprise'}<br>
                    <strong>Port:</strong> ${PORT}<br>
                    <strong>Version:</strong> v2.0.0
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
        if (useMongoDB) {
            const user = await User.findOne({ id: email, password: password });
            if (user) {
                console.log(`✅ Login successful: ${email}`);
                return res.json(user);
            }
        }

        const users = getData('users');
        const user = users.find(u => u.id === email && u.password === password);
        if (user) {
            console.log(`✅ Login successful: ${email}`);
            const { password, ...rest } = user;
            return res.json(rest);
        }

        console.log(`❌ Login failed: ${email}`);
        res.status(401).json({ message: 'Invalid credentials' });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error' });
    }
});

// ==================== USERS ====================
app.get('/api/users', async (req, res) => {
    try {
        if (useMongoDB) {
            const users = await User.find().select('-password');
            return res.json(users);
        }
        const users = getData('users').map(u => {
            const { password, ...rest } = u;
            return rest;
        });
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching users' });
    }
});

app.post('/api/users', async (req, res) => {
    try {
        const userData = { ...req.body, status: 'Active' };

        if (useMongoDB) {
            const newUser = new User(userData);
            await newUser.save();
            return res.status(201).json(newUser);
        }

        const users = getData('users');
        users.push(userData);
        saveData('users', users);
        res.status(201).json(userData);
    } catch (error) {
        res.status(500).json({ message: 'Error creating user' });
    }
});

app.patch('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (useMongoDB) {
            const user = await User.findOneAndUpdate({ id }, req.body, { new: true });
            if (user) return res.json(user);
        }

        const users = getData('users');
        const index = users.findIndex(u => u.id === id);
        if (index !== -1) {
            users[index] = { ...users[index], ...req.body };
            saveData('users', users);
            return res.json(users[index]);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating user' });
    }
});

// ==================== CUSTOMERS ====================
app.get('/api/customers', async (req, res) => {
    try {
        if (useMongoDB) return res.json(await Customer.find());
        res.json(getData('customers'));
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

        if (useMongoDB) {
            const newCustomer = new Customer(customerData);
            await newCustomer.save();
            return res.status(201).json(newCustomer);
        }

        const customers = getData('customers');
        customers.push(customerData);
        saveData('customers', customers);
        res.status(201).json(customerData);
    } catch (error) {
        res.status(500).json({ message: 'Error creating customer' });
    }
});

app.patch('/api/customers/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (useMongoDB) {
            const customer = await Customer.findOneAndUpdate({ id }, req.body, { new: true });
            if (customer) return res.json(customer);
        }

        const customers = getData('customers');
        const index = customers.findIndex(c => c.id === id);
        if (index !== -1) {
            customers[index] = { ...customers[index], ...req.body };
            saveData('customers', customers);
            return res.json(customers[index]);
        }
        res.status(404).json({ message: 'Customer not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating customer' });
    }
});

// ==================== PRODUCTS ====================
app.get('/api/products', async (req, res) => {
    try {
        if (useMongoDB) return res.json(await Product.find());
        res.json(getData('products'));
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

        if (useMongoDB) {
            const newProduct = new Product(productData);
            await newProduct.save();
            return res.status(201).json(newProduct);
        }

        const products = getData('products');
        products.push(productData);
        saveData('products', products);
        res.status(201).json(productData);
    } catch (error) {
        res.status(500).json({ message: 'Error creating product' });
    }
});

app.patch('/api/products/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (useMongoDB) {
            const product = await Product.findOneAndUpdate({ id }, req.body, { new: true });
            if (product) return res.json(product);
        }

        const products = getData('products');
        const index = products.findIndex(p => p.id === id || p.skuCode === id);
        if (index !== -1) {
            products[index] = { ...products[index], ...req.body };
            saveData('products', products);
            return res.json(products[index]);
        }
        res.status(404).json({ message: 'Product not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating product' });
    }
});

// ==================== ORDERS ====================
app.get('/api/orders', async (req, res) => {
    try {
        const { status, salespersonId } = req.query;

        if (useMongoDB) {
            let query = {};
            if (status) query.status = status;
            if (salespersonId) query.salespersonId = salespersonId;

            const orders = await Order.find(query).sort({ createdAt: -1 });
            return res.json(orders);
        }

        let orders = getData('orders');
        if (status) orders = orders.filter(o => o.status === status);
        if (salespersonId) orders = orders.filter(o => o.salespersonId === salespersonId);

        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching orders' });
    }
});

app.get('/api/orders/:id', async (req, res) => {
    try {
        const { id } = req.params;

        if (useMongoDB) {
            const order = await Order.findOne({ id });
            if (order) return res.json(order);
        }

        const orders = getData('orders');
        const order = orders.find(o => o.id === id);
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
            const order = await Order.findOneAndUpdate({ id }, updateData, { new: true });
            if (order) {
                console.log(`✅ Order updated: ${id}`);
                return res.json(order);
            }
        }

        const orders = getData('orders');
        const index = orders.findIndex(o => o.id === id);
        if (index !== -1) {
            orders[index] = { ...orders[index], ...updateData };
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
            await Order.updateMany({ id: { $in: orderIds } }, updates);
            const updatedOrders = await Order.find({ id: { $in: orderIds } });
            return res.json(updatedOrders);
        }

        const orders = getData('orders');
        const updatedOrders = orders.map(o => {
            if (orderIds.includes(o.id)) {
                return { ...o, ...updates };
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

// ==================== ANALYTICS ====================
app.get('/api/analytics/dashboard', async (req, res) => {
    try {
        const orders = useMongoDB ? await Order.find() : getData('orders');

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
        const orders = useMongoDB ? await Order.find({ salespersonId }) : getData('orders').filter(o => o.salespersonId === salespersonId);

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
        const orders = useMongoDB ? await Order.find() : getData('orders');

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
        const orders = useMongoDB ? await Order.find() : getData('orders');
        const products = useMongoDB ? await Product.find() : getData('products');
        const customers = useMongoDB ? await Customer.find() : getData('customers');

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

// ==================== PMS API ====================
app.get('/api/analytics/pms', async (req, res) => {
    try {
        const { userId } = req.query;
        const orders = useMongoDB ? await Order.find() : getData('orders');

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
        const orders = useMongoDB ? await Order.find() : getData('orders');
        const products = useMongoDB ? await Product.find() : getData('products');
        const customers = useMongoDB ? await Customer.find() : getData('customers');

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
        const order = useMongoDB ? await Order.findOne({ id: orderId }) : getData('orders').find(o => o.id === orderId);

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
      <EFFECTIVEDATE>${order.createdAt.split('T')[0].replace(/-/g, '')}</EFFECTIVEDATE>
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
app.listen(PORT, () => {
    console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          🚀 NexusOMS Enterprise API v2.0.0            ║
║                                                        ║
║  Status: ✅ ONLINE                                     ║
║  Port: ${PORT}                                         ║
║  Database: ${useMongoDB ? '☁️  MongoDB Atlas' : '📁 JSON Storage'}                          ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
    `);
});
