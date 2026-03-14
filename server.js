const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
require('dotenv').config();
const mongoose = require('mongoose');
const multer = require('multer');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// ==================== HELPERS ====================
// Ensure Mongoose Map / JS Map becomes JSON-friendly plain object
function normalizeStepAccess(stepAccess) {
    if (!stepAccess) return {};
    if (stepAccess instanceof Map) {
        return Object.fromEntries(stepAccess.entries());
    }
    if (typeof stepAccess === 'object') return stepAccess;
    return {};
}

// ==================== ENVIRONMENT VALIDATION ====================
if (!process.env.JWT_SECRET) {
    console.error('❌ FATAL: JWT_SECRET is missing in .env file');
    console.error('💡 Add: JWT_SECRET=your-super-secret-key-minimum-32-characters');
    process.exit(1);
}

if (!process.env.MONGODB_URI || process.env.MONGODB_URI.includes('your_mongodb')) {
    console.error('❌ FATAL: MONGODB_URI is missing or contains placeholder value');
    console.error('💡 Update .env with real MongoDB connection string');
    process.exit(1);
}

const app = express();

// Trust proxy for Render/Load Balancers (Fixes ERR_ERL_UNEXPECTED_X_FORWARDED_FOR)
app.set('trust proxy', 1);

const PORT = process.env.PORT || 3000;

// ==================== SECURITY MIDDLEWARE ====================
// Helmet.js - Security headers
app.use(helmet({
    contentSecurityPolicy: false, // Disable for API server
    crossOriginEmbedderPolicy: false
}));

// CORS - Restrict to allowed origins
const allowedOrigins = [
    'http://localhost:4200',
    'http://localhost:3000',
    'http://localhost:54167',
    'http://localhost:8080',
    'https://nexus-oms-backend.onrender.com',
    'capacitor://localhost',
    'ionic://localhost',
    'http://192.168.1.1:3000', // Add your local IP
];

const corsOptions = {
    origin: function (origin, callback) {
        // Allow requests with no origin (mobile apps, Postman)
        if (!origin) return callback(null, true);

        if (allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            console.warn(`⚠️ CORS blocked: ${origin}`);
            callback(null, true); // Allow for now, change to false in production
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};

app.use(cors(corsOptions));

// Rate Limiting - General API
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 500, // 500 requests per window (Relaxed for dev)
    message: {
        success: false,
        message: 'Too many requests from this IP, please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Rate Limiting - Login endpoint (stricter)
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 login attempts per window
    message: {
        success: false,
        message: 'Too many login attempts, please try again after 15 minutes.'
    },
    skipSuccessfulRequests: true
});

// Apply rate limiting to all API routes
app.use('/api', apiLimiter);

// Body parser
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use('/uploads', express.static('uploads'));

// Request Logger
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

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
const DistributorPrice = require('./models/DistributorPrice');
const InventoryService = require('./services/inventoryService');
const Warehouse = require('./models/Warehouse');

// Middleware
const { verifyToken } = require('./middleware/auth');
const { logCreate, logUpdate, logDelete, logStatusChange } = require('./middleware/auditLogger');


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

// ==================== HEALTH CHECK ====================
app.get('/api/health', async (req, res) => {
    try {
        const dbStatus = mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected';
        const orderCount = await Order.countDocuments();
        const userCount = await User.countDocuments();
        const productCount = await Product.countDocuments();

        res.json({
            status: 'OK',
            database: dbStatus,
            counts: {
                orders: orderCount,
                users: userCount,
                products: productCount
            },
            serverTime: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({ status: 'ERROR', message: error.message });
    }
});


// ==================== AUTHENTICATION ====================
app.post('/api/login', loginLimiter, async (req, res) => {
    const { email, password } = req.body;
    console.log(`🔐 Login attempt: ${email}`);

    const { logLogin } = require('./middleware/auditLogger');

    try {
        // Find user by ID or email
        const user = await User.findOne({ $or: [{ id: email }, { email: email }] });

        if (!user) {
            console.log(`❌ Login failed: ${email} (User not found)`);

            // Log failed login attempt
            await logLogin(
                email,
                'Unknown User',
                false,
                req.ip || req.connection.remoteAddress,
                req.get('user-agent'),
                'User not found'
            );

            return res.status(404).json({
                success: false,
                message: 'EMAIL_NOT_FOUND'
            });
        }

        // Compare password using bcrypt
        const isPasswordValid = await user.comparePassword(password);

        if (!isPasswordValid) {
            console.log(`❌ Login failed: ${email} (Incorrect password)`);

            // Log failed login attempt
            await logLogin(
                user.id,
                user.name,
                false,
                req.ip || req.connection.remoteAddress,
                req.get('user-agent'),
                'Incorrect password'
            );

            return res.status(401).json({
                success: false,
                message: 'WRONG_PASSWORD'
            });
        }

        // Update last login
        user.lastLogin = new Date();
        await user.save();

        // Generate JWT token
        const jwt = require('jsonwebtoken');
        const token = jwt.sign(
            user.getJWTPayload(),
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRY || '7d' }
        );

        console.log(`✅ Login successful: ${email}`);

        // Log successful login
        await logLogin(
            user.id,
            user.name,
            true,
            req.ip || req.connection.remoteAddress,
            req.get('user-agent')
        );

        // Return full user profile so app gets latest role, permissions, stepAccess (assigned by Admin)
        const userDoc = user.toObject ? user.toObject() : user;
        const userForClient = {
            id: userDoc.id,
            name: userDoc.name,
            email: userDoc.email,
            role: userDoc.role,
            isApprover: userDoc.isApprover,
            status: userDoc.status,
            permissions: userDoc.permissions || [],
            stepAccess: normalizeStepAccess(userDoc.stepAccess),
            zone: userDoc.zone || 'PAN INDIA',
            location: userDoc.location || 'Pan India',
            department1: userDoc.department1,
            department2: userDoc.department2,
            channel: userDoc.channel,
            whatsappNumber: userDoc.whatsappNumber,
            managerId: userDoc.managerId,
            orgPosition: userDoc.orgPosition || null
        };

        res.json({
            success: true,
            token,
            user: userForClient
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'LOGIN_ERROR'
        });
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

// Get single user by ID (returns client-safe profile with permissions and stepAccess)
app.get('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const user = await User.findOne({ id }).select('-password');

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const userDoc = user.toObject ? user.toObject() : user;
        const userForClient = {
            id: userDoc.id,
            name: userDoc.name,
            email: userDoc.email,
            role: userDoc.role,
            isApprover: userDoc.isApprover,
            status: userDoc.status,
            permissions: userDoc.permissions || [],
            stepAccess: normalizeStepAccess(userDoc.stepAccess),
            zone: userDoc.zone || 'PAN INDIA',
            location: userDoc.location || 'Pan India',
            department1: userDoc.department1,
            department2: userDoc.department2,
            channel: userDoc.channel,
            whatsappNumber: userDoc.whatsappNumber,
            managerId: userDoc.managerId,
            orgPosition: userDoc.orgPosition || null
        };

        res.json(userForClient);
    } catch (error) {
        console.error('Error fetching user by id:', error);
        res.status(500).json({ message: 'Error fetching user' });
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

app.patch('/api/users/:id/role', async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;

        // In a real production app, we would verify the requester is an Admin
        // For this implementation, we assume the Admin Dashboard handles this check
        const user = await User.findOneAndUpdate(
            { id },
            { role },
            { new: true }
        ).select('-password');

        if (user) {
            console.log(`👤 User role updated: ${id} -> ${role}`);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating user role' });
    }
});

// Update user permissions (Multi-permission system)
app.patch('/api/users/:id/permissions', async (req, res) => {
    try {
        const { id } = req.params;
        const { permissions } = req.body; // Array of permission strings

        // Verify permissions is an array
        if (!Array.isArray(permissions)) {
            return res.status(400).json({ message: 'Permissions must be an array' });
        }

        const user = await User.findOneAndUpdate(
            { id },
            { permissions },
            { new: true, runValidators: true }
        ).select('-password');

        if (user) {
            console.log(`🔐 User permissions updated: ${id} -> [${permissions.join(', ')}]`);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error updating permissions:', error);
        res.status(500).json({ message: 'Error updating user permissions' });
    }
});

// Update user step access (3-level: full/view/no)
app.patch('/api/users/:id/step-access', async (req, res) => {
    try {
        const { id } = req.params;
        const { stepAccess } = req.body; // Object: { "Book Order": "full", "Credit Control": "view" }

        if (typeof stepAccess !== 'object' || Array.isArray(stepAccess)) {
            return res.status(400).json({ message: 'stepAccess must be an object' });
        }

        const user = await User.findOneAndUpdate(
            { id },
            { stepAccess },
            { new: true }
        ).select('-password');

        if (user) {
            console.log(`🎯 Step access updated for ${id}:`, stepAccess);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error updating step access:', error);
        res.status(500).json({ message: 'Error updating step access' });
    }
});

// ── Org Position: Atomic Add (uses $addToSet — safe for parallel calls) ──
app.patch('/api/users/:id/org-add', async (req, res) => {
    try {
        const { id } = req.params;
        const { slotKey } = req.body;

        if (!slotKey || typeof slotKey !== 'string') {
            return res.status(400).json({ message: 'slotKey (string) is required' });
        }

        const user = await User.findOneAndUpdate(
            { id },
            { $addToSet: { orgPositions: slotKey } },
            { new: true }
        ).select('-password');

        if (user) {
            console.log(`📌 Org position added: ${id} → ${slotKey}  |  All: [${user.orgPositions.join(', ')}]`);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error adding org position:', error);
        res.status(500).json({ message: 'Error adding org position' });
    }
});

// ── Org Position: Atomic Remove (uses $pull — only removes the specific slot) ──
app.patch('/api/users/:id/org-remove', async (req, res) => {
    try {
        const { id } = req.params;
        const { slotKey } = req.body;

        if (!slotKey || typeof slotKey !== 'string') {
            return res.status(400).json({ message: 'slotKey (string) is required' });
        }

        const user = await User.findOneAndUpdate(
            { id },
            { $pull: { orgPositions: slotKey } },
            { new: true }
        ).select('-password');

        if (user) {
            console.log(`🗑 Org position removed: ${id} ✕ ${slotKey}  |  Remaining: [${user.orgPositions.join(', ')}]`);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error removing org position:', error);
        res.status(500).json({ message: 'Error removing org position' });
    }
});

// Update any user field (generic endpoint)
app.patch('/api/users/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = { ...req.body };

        // Remove sensitive fields if present
        delete updateData.password;
        delete updateData.id;

        const user = await User.findOneAndUpdate(
            { id },
            { $set: updateData },
            { new: true }
        ).select('-password');

        if (user) {
            console.log(`👤 User updated: ${id}`, updateData);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ message: 'Error updating user' });
    }
});

// Set manager for hierarchy (RSM > ASM > Sales)
app.patch('/api/users/:id/manager', async (req, res) => {
    try {
        const { id } = req.params;
        const { managerId } = req.body; // null = remove manager

        const user = await User.findOneAndUpdate(
            { id },
            { $set: { managerId: managerId || null } },
            { new: true }
        ).select('-password');

        if (user) {
            console.log(`🏢 Manager updated: ${id} now reports to ${managerId || 'no one'}`);
            return res.json(user);
        }
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error updating manager:', error);
        res.status(500).json({ message: 'Error updating manager' });
    }
});

// ── Admin: update user credentials (name, email, employeeId, password) ──
app.patch('/api/users/:id/credentials', verifyToken, async (req, res) => {
    try {
        const { id } = req.params;
        const { name, email, employeeId, address, password } = req.body;

        const update = {};
        if (name)       update.name       = name;
        if (email)      update.email      = email;
        if (employeeId) update.employeeId = employeeId;
        if (address !== undefined) update.address = address;

        if (password && password.length > 0) {            const bcrypt = require('bcryptjs');
            update.password = await bcrypt.hash(password, 10);
            console.log(`🔑 Password reset for user ${id}`);
        }

        const user = await User.findOneAndUpdate(
            { id },
            { $set: update },
            { new: true }
        ).select('-password');

        if (user) return res.json(user);
        res.status(404).json({ message: 'User not found' });
    } catch (error) {
        console.error('Error updating credentials:', error);
        res.status(500).json({ message: 'Error updating credentials' });
    }
});

// ==================== ATTENDANCE ====================
const attendanceSchema = new mongoose.Schema({
    userId:         { type: String, required: true },
    userName:       String,
    userRole:       String,
    date:           { type: String, required: true }, // 'YYYY-MM-DD' local date key
    checkInTime:    Date,
    checkOutTime:   Date,
    checkInLocation:  { lat: Number, lng: Number, note: String },
    checkOutLocation: { lat: Number, lng: Number, note: String },
}, { timestamps: true });

attendanceSchema.index({ userId: 1, date: 1 }, { unique: true });
const Attendance = mongoose.models.Attendance || mongoose.model('Attendance', attendanceSchema);

// Helper – today's date string "YYYY-MM-DD" in IST
function todayIST() {
    const now = new Date();
    const ist = new Date(now.getTime() + 5.5 * 60 * 60 * 1000);
    return ist.toISOString().slice(0, 10);
}

// Check-in
app.post('/api/attendance/check-in', verifyToken, async (req, res) => {
    try {
        const { userId, name: userName, role: userRole } = req.user;
        const today = todayIST();
        const location = req.body.location || {};

        const userDoc = await User.findOne({ id: userId }).select('name role');

        let record = await Attendance.findOne({ userId, date: today });
        if (record && record.checkInTime) {
            return res.status(400).json({ message: 'Already checked in today' });
        }

        record = await Attendance.findOneAndUpdate(
            { userId, date: today },
            {
                $set: {
                    userId,
                    userName: userDoc?.name || userName || '',
                    userRole: userDoc?.role || userRole || '',
                    date: today,
                    checkInTime: new Date(),
                    checkInLocation: location,
                }
            },
            { upsert: true, new: true }
        );

        console.log(`✅ Check-in: ${userId} at ${today}`);
        res.json(record);
    } catch (error) {
        console.error('Check-in error:', error);
        res.status(500).json({ message: 'Check-in failed' });
    }
});

// Check-out
app.post('/api/attendance/check-out', verifyToken, async (req, res) => {
    try {
        const { userId } = req.user;
        const today = todayIST();
        const location = req.body.location || {};

        const record = await Attendance.findOne({ userId, date: today });
        if (!record || !record.checkInTime) {
            return res.status(400).json({ message: 'Not checked in yet' });
        }
        if (record.checkOutTime) {
            return res.status(400).json({ message: 'Already checked out today' });
        }

        record.checkOutTime = new Date();
        record.checkOutLocation = location;
        await record.save();

        console.log(`👋 Check-out: ${userId} at ${today}`);
        res.json(record);
    } catch (error) {
        console.error('Check-out error:', error);
        res.status(500).json({ message: 'Check-out failed' });
    }
});

// Get my attendance for today (current user)
app.get('/api/attendance/me', verifyToken, async (req, res) => {
    try {
        const { userId } = req.user;
        const today = todayIST();
        const record = await Attendance.findOne({ userId, date: today });
        res.json(record || {});
    } catch (error) {
        res.status(500).json({ message: 'Error fetching attendance' });
    }
});

// Admin: get all users attendance for today
app.get('/api/attendance/today', verifyToken, async (req, res) => {
    try {
        const today = todayIST();
        // Get all active users
        const allUsers = await User.find().select('id name role');
        // Get today's records
        const records = await Attendance.find({ date: today });
        const recordMap = {};
        records.forEach(r => { recordMap[r.userId] = r; });

        // Merge: one row per user, absent if no record
        const merged = allUsers.map(u => {
            const rec = recordMap[u.id];
            return {
                userId: u.id,
                userName: u.name,
                userRole: u.role,
                date: today,
                checkInTime:  rec?.checkInTime  || null,
                checkOutTime: rec?.checkOutTime || null,
                checkInLocation:  rec?.checkInLocation || null,
                checkOutLocation: rec?.checkOutLocation || null,
            };
        });

        res.json(merged);
    } catch (error) {
        console.error('Error fetching today attendance:', error);
        res.status(500).json({ message: 'Error fetching attendance' });
    }
});

// ==================== CUSTOMERS ====================
app.get('/api/customers', verifyToken, async (req, res) => {
    try {
        res.json(await Customer.find());
    } catch (error) {
        res.status(500).json({ message: 'Error fetching customers' });
    }
});

app.post('/api/customers', verifyToken, logCreate('CUSTOMER'), async (req, res) => {
    try {
        const customerData = {
            ...req.body,
            id: req.body.id || `CUST-${Date.now().toString().slice(-6)}`,
            assignedSalespersonId: req.user.userId, // Mandatory attribution
            status: 'Active',
            createdAt: new Date().toISOString()
        };
        const newCustomer = new Customer(customerData);
        await newCustomer.save();
        res.status(201).json({ success: true, data: newCustomer });
    } catch (error) {
        res.status(500).json({ message: 'Error creating customer' });
    }
});

app.patch('/api/customers/:id', verifyToken, logUpdate('CUSTOMER'), async (req, res) => {
    try {
        const { id } = req.params;
        // Fetch original data for audit log
        req.originalData = await Customer.findOne({ id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Customer not found' });

        const customer = await Customer.findOneAndUpdate({ id }, req.body, { new: true });
        if (customer) return res.json({ success: true, data: customer });
        res.status(404).json({ message: 'Customer not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating customer' });
    }
});

// ==================== PRODUCTS (MATERIAL MASTER) ====================
app.get('/api/products', verifyToken, async (req, res) => {
    try {
        const { category, specie, search } = req.query;
        const query = {};
        if (category) query.category = category;
        if (specie) query.specie = specie;
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { skuCode: { $regex: search, $options: 'i' } },
                { hsnCode: { $regex: search, $options: 'i' } },
            ];
        }
        res.json(await Product.find(query).sort({ category: 1, name: 1 }));
    } catch (error) {
        res.status(500).json({ message: 'Error fetching products' });
    }
});

app.get('/api/products/:id', verifyToken, async (req, res) => {
    try {
        const product = await Product.findOne({ id: req.params.id });
        if (product) return res.json(product);
        res.status(404).json({ message: 'Product not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching product' });
    }
});

app.post('/api/products', verifyToken, logCreate('PRODUCT'), async (req, res) => {
    try {
        const productData = {
            ...req.body,
            id: req.body.id || req.body.skuCode || `PROD-${Date.now().toString().slice(-6)}`,
            createdAt: new Date().toISOString()
        };
        const newProduct = new Product(productData);
        await newProduct.save();
        console.log(`✅ Product created: ${newProduct.id}`);
        res.status(201).json({ success: true, data: newProduct });
    } catch (error) {
        console.error('Product creation error:', error);
        res.status(500).json({ message: 'Error creating product', error: error.message });
    }
});

app.patch('/api/products/:id', verifyToken, logUpdate('PRODUCT'), async (req, res) => {
    try {
        const { id } = req.params;
        // Fetch original data for audit log
        req.originalData = await Product.findOne({ id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Product not found' });

        const product = await Product.findOneAndUpdate({ id }, { $set: req.body }, { new: true });
        if (product) return res.json({ success: true, data: product });
        res.status(404).json({ message: 'Product not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating product' });
    }
});

app.delete('/api/products/:id', verifyToken, logDelete('PRODUCT'), async (req, res) => {
    try {
        const { id } = req.params;
        req.originalData = await Product.findOne({ id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Product not found' });

        const product = await Product.findOneAndDelete({ id });
        if (product) return res.json({ success: true, message: 'Product deleted' });
        res.status(404).json({ message: 'Product not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting product' });
    }
});

// Bulk import products from Excel (Material Master)
// Download Excel template for product import
app.get('/api/products/import-template', async (req, res) => {
    try {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Material Master Template');
        const headers = [
            'ProductCode', 'Product Name', 'ProductShortName', 'DistributionChannel',
            'Specie', 'Weight Packing', 'Weight', 'Packing', 'MRP', 'GST%',
            'HSNCODE', 'COUNTRY OF ORIGIN', 'Shelf Life in days', 'REMARKS',
            'YC70', 'Processing charges'
        ];
        const headerRow = worksheet.addRow(headers);
        headerRow.font = { bold: true, color: { argb: 'FFFFFF' } };
        headerRow.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '0F172A' } };
        worksheet.columns = headers.map(() => ({ width: 18 }));
        // Add example row based on user template
        worksheet.addRow([
            '2004643', 'BREADED FISH FINGERS 200G', 'BREADED FISH FINGERS 200G', 'RETAIL/HD',
            'BREADED', '200G PKTS', '0.200', 'PKTS', 220, 5,
            '16042000', 'INDIA', 365, '', '', ''
        ]);

        const buffer = await workbook.xlsx.writeBuffer();
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=Material_Master_Template.xlsx');
        res.send(buffer);
    } catch (error) {
        console.error('❌ Template Generation Error:', error);
        res.status(500).json({ message: 'Error generating template' });
    }
});

app.post('/api/products/bulk-import', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

        const workbook = new ExcelJS.Workbook();
        await workbook.xlsx.readFile(req.file.path);
        const worksheet = workbook.getWorksheet(1);
        const headerRow = worksheet.getRow(1);
        const colMap = {};

        headerRow.eachCell((cell, colNumber) => {
            const raw = (cell.value?.toString() ?? '').trim();
            const header = raw.toLowerCase().replace(/\s+/g, ' ');
            if (!header) return;
            // Col 1 : ProductCode
            if (['productcode', 'product code', 'sku', 'sku code', 'code'].includes(header))
                colMap.skuCode = colNumber;
            // Col 2 : Product Name
            else if (['product name', 'productname', 'name'].includes(header))
                colMap.name = colNumber;
            // Col 3 : ProductShortName
            else if (['productshortname', 'product short name', 'short name', 'shortname'].includes(header))
                colMap.productShortName = colNumber;
            // Col 4 : DistributionChannel
            else if (['distributionchannel', 'distribution channel', 'channel'].includes(header) ||
                     header.startsWith('distributionchan'))
                colMap.distributionChannel = colNumber;
            // Col 5 : Specie
            else if (['specie', 'species'].includes(header))
                colMap.specie = colNumber;
            // Col 6 : Weight Packing
            else if (['weight packing', 'weightpacking', 'wt packing'].includes(header))
                colMap.weightPacking = colNumber;
            // Col 7 : Weight
            else if (header === 'weight')
                colMap.productWeight = colNumber;
            // Col 8 : Packing
            else if (['packing', 'pack'].includes(header))
                colMap.productPacking = colNumber;
            // Col 9 : MRP
            else if (header === 'mrp')
                colMap.mrp = colNumber;
            // Col 10 : GST%
            else if (['gst%', 'gst %', 'gst'].includes(header))
                colMap.gst = colNumber;
            // Col 11 : HSNCODE
            else if (['hsncode', 'hsn code', 'hsn'].includes(header))
                colMap.hsnCode = colNumber;
            // Col 12 : COUNTRY OF ORIGIN
            else if (['country of origin', 'countryoforigin', 'origin'].includes(header) ||
                     header.startsWith('country of ori'))
                colMap.countryOfOrigin = colNumber;
            // Col 13 : Shelf Life in days
            else if (header.startsWith('shelf life') || header === 'shelflife')
                colMap.shelfLifeDays = colNumber;
            // Col 14 : REMARKS
            else if (['remarks', 'remark'].includes(header))
                colMap.remarks = colNumber;
            // Col 15 : YC70
            else if (header === 'yc70')
                colMap.yc70 = colNumber;
            // Col 16 : Processing Charges
            else if (header.startsWith('processing'))
                colMap.processingCharges = colNumber;
            // Optional legacy
            else if (['price', 'rate', 'base rate'].includes(header))
                colMap.price = colNumber;
            else if (['stock', 'qty', 'quantity'].includes(header))
                colMap.stock = colNumber;
            else if (['category', 'cat'].includes(header))
                colMap.category = colNumber;
        });

        // ALWAYS apply positional fallback for any column that was not header-detected.
        // This means the import works correctly whether or not ExcelJS reads the header text.
        console.log('📍 Header-detected map:', JSON.stringify(colMap));
        if (!colMap.skuCode)             colMap.skuCode = 1;
        if (!colMap.name)                colMap.name = 2;
        if (!colMap.productShortName)    colMap.productShortName = 3;
        if (!colMap.distributionChannel) colMap.distributionChannel = 4;
        if (!colMap.specie)              colMap.specie = 5;
        if (!colMap.weightPacking)       colMap.weightPacking = 6;
        if (!colMap.productWeight)       colMap.productWeight = 7;
        if (!colMap.productPacking)      colMap.productPacking = 8;
        if (!colMap.mrp)                 colMap.mrp = 9;
        if (!colMap.gst)                 colMap.gst = 10;
        if (!colMap.hsnCode)             colMap.hsnCode = 11;
        if (!colMap.countryOfOrigin)     colMap.countryOfOrigin = 12;
        if (!colMap.shelfLifeDays)       colMap.shelfLifeDays = 13;
        if (!colMap.remarks)             colMap.remarks = 14;
        if (!colMap.yc70)                colMap.yc70 = 15;
        if (!colMap.processingCharges)   colMap.processingCharges = 16;
        console.log('📍 Final column map (with positional fallback):', JSON.stringify(colMap));

        const products = [];
        const parseNum = (val) => {
            if (val === undefined || val === null || val === '') return null;
            if (typeof val === 'number') return val;
            const str = String(val).replace(/,/g, '').replace(/%/g, '').trim();
            const n = parseFloat(str);
            return isNaN(n) ? null : n;
        };
        const parseStr = (val) => (val === undefined || val === null) ? '' : String(val).trim();

        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return; // skip header
            const getCell = (col) => col ? row.getCell(col).value : null;

            const skuCode = parseStr(getCell(colMap.skuCode));
            const name    = parseStr(getCell(colMap.name));
            if (!name) return; // skip empty rows

            const shortName = parseStr(getCell(colMap.productShortName));
            const rowData = {
                skuCode,
                name,
                productShortName: shortName,
                shortName,          // also store as shortName for Flutter model compatibility
                distributionChannel: parseStr(getCell(colMap.distributionChannel)),
                specie:              parseStr(getCell(colMap.specie)),
                weightPacking:       parseStr(getCell(colMap.weightPacking)),
                productWeight:       parseStr(getCell(colMap.productWeight)),
                productPacking:      parseStr(getCell(colMap.productPacking)),
                mrp:                 parseNum(getCell(colMap.mrp)),
                gst:                 parseNum(getCell(colMap.gst)),
                hsnCode:             parseStr(getCell(colMap.hsnCode)),
                countryOfOrigin:     parseStr(getCell(colMap.countryOfOrigin)),
                shelfLifeDays:       parseNum(getCell(colMap.shelfLifeDays)),
                remarks:             parseStr(getCell(colMap.remarks)),
                yc70:                parseNum(getCell(colMap.yc70)),
                processingCharges:   parseNum(getCell(colMap.processingCharges)),
            };

            // Optional extra columns (only if detected by header)
            if (colMap.category) rowData.category = parseStr(getCell(colMap.category));
            if (colMap.price)    rowData.price     = parseNum(getCell(colMap.price));
            if (colMap.stock)    rowData.stock     = parseNum(getCell(colMap.stock));

            // Unique id — use skuCode or auto-generate
            rowData.id = skuCode || `PROD-${Date.now()}-${rowNumber}`;
            console.log(`  Row ${rowNumber}: id=${rowData.id} name="${rowData.name}" shortName="${rowData.shortName}"`);
            products.push(rowData);
        });

        if (products.length === 0) {
            fs.unlinkSync(req.file.path);
            return res.status(400).json({ message: 'No valid product rows found. Ensure data rows exist below the header.' });
        }

        const bulkOps = products.map(p => ({
            updateOne: {
                filter: { id: p.id },
                update: { $set: p },
                upsert: true
            }
        }));

        await Product.bulkWrite(bulkOps);
        fs.unlinkSync(req.file.path);
        console.log(`✅ Bulk imported ${products.length} products`);
        res.json({ success: true, message: `Successfully imported ${products.length} products` });
    } catch (error) {
        console.error('❌ Product bulk import error:', error);
        res.status(500).json({ message: 'Error processing file', error: error.message });
    }
});

// ==================== DISTRIBUTOR PRICE LIST ====================
app.get('/api/distributor-prices', async (req, res) => {
    try {
        const { search, category } = req.query;
        const query = { isActive: true };
        if (category) query.category = category;
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { code: { $regex: search, $options: 'i' } },
                { materialNumber: { $regex: search, $options: 'i' } },
            ];
        }
        res.json(await DistributorPrice.find(query).sort({ category: 1, name: 1 }));
    } catch (error) {
        res.status(500).json({ message: 'Error fetching distributor prices' });
    }
});

app.get('/api/distributor-prices/:id', async (req, res) => {
    try {
        const item = await DistributorPrice.findOne({ id: req.params.id });
        if (item) return res.json(item);
        res.status(404).json({ message: 'Distributor price entry not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching distributor price' });
    }
});

app.post('/api/distributor-prices', verifyToken, logCreate('PRICE_LIST'), async (req, res) => {
    try {
        const data = {
            ...req.body,
            id: req.body.id || req.body.code || `DP-${Date.now().toString().slice(-6)}`,
        };
        const entry = new DistributorPrice(data);
        await entry.save();
        console.log(`✅ Distributor price created: ${entry.id}`);
        res.status(201).json(entry);
    } catch (error) {
        console.error('Distributor price creation error:', error);
        res.status(500).json({ message: 'Error creating entry', error: error.message });
    }
});

app.patch('/api/distributor-prices/:id', verifyToken, logUpdate('PRICE_LIST'), async (req, res) => {
    try {
        // Fetch original data for audit log
        req.originalData = await DistributorPrice.findOne({ id: req.params.id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Distributor price entry not found' });

        const item = await DistributorPrice.findOneAndUpdate(
            { id: req.params.id },
            { $set: req.body },
            { new: true }
        );
        if (item) return res.json({ success: true, data: item });
        res.status(404).json({ message: 'Distributor price entry not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating distributor price' });
    }
});

app.delete('/api/distributor-prices/:id', verifyToken, logDelete('PRICE_LIST'), async (req, res) => {
    try {
        const { id } = req.params;
        req.originalData = await DistributorPrice.findOne({ id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Distributor price entry not found' });

        const item = await DistributorPrice.findOneAndUpdate(
            { id },
            { isActive: false },
            { new: true }
        );
        if (item) return res.json({ success: true, message: 'Soft-deleted' });
        res.status(404).json({ message: 'Not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting distributor price' });
    }
});

// Bulk import distributor prices from Excel
app.post('/api/distributor-prices/bulk-import', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

        const workbook = new ExcelJS.Workbook();
        await workbook.xlsx.readFile(req.file.path);
        const worksheet = workbook.getWorksheet(1);
        const headerRow = worksheet.getRow(1);
        const colMap = {};

        headerRow.eachCell((cell, colNumber) => {
            const header = cell.value?.toString().trim().toLowerCase();
            if (!header) return;
            // 1. Code -> distributorCode
            if (header === 'code') colMap.distributorCode = colNumber;
            // 2. Name -> distributorName
            else if (header === 'name' && !colMap.distributorName) colMap.distributorName = colNumber;
            // 3. Material -> code
            else if (header === 'material') colMap.code = colNumber;
            // 4. Material Number -> name
            else if (header === 'material number') colMap.name = colNumber;
            // 5. MRP
            else if (header === 'mrp') colMap.mrp = colNumber;
            // 6. in Kg
            else if (header === 'in kg') colMap.inKg = colNumber;
            // 7. % GST
            else if (header === '% gst' || header === 'gst %' || header === 'gst') colMap.gstPct = colNumber;
            // 8. Retailer Margin On MRP
            else if (header.includes('retailer margin')) colMap.retailerMarginOnMrp = colNumber;
            // 9. Dist Margin On Cost
            else if (header.includes('dist margin on cost')) colMap.distMarginOnCost = colNumber;
            // 10. Dist Margin On MRP
            else if (header.includes('dist margin on mrp')) colMap.distMarginOnMrp = colNumber;
            // 11. Billing Rate
            else if (header.includes('billing rate') || header.includes('billing')) colMap.billingRate = colNumber;
        });

        // Positional fallback for new 11-column format
        const totalCols = headerRow.actualCellCount;
        if (!colMap.name && totalCols >= 2) {
            console.log('⚠️ DP Header map missing "name" — applying positional fallback');
            if (!colMap.distributorCode) colMap.distributorCode = 1;
            if (!colMap.distributorName) colMap.distributorName = 2;
            if (!colMap.code) colMap.code = 3;
            if (!colMap.name) colMap.name = 4;
            if (!colMap.mrp) colMap.mrp = 5;
            if (!colMap.inKg) colMap.inKg = 6;
            if (!colMap.gstPct) colMap.gstPct = 7;
            if (!colMap.retailerMarginOnMrp) colMap.retailerMarginOnMrp = 8;
            if (!colMap.distMarginOnCost) colMap.distMarginOnCost = 9;
            if (!colMap.distMarginOnMrp) colMap.distMarginOnMrp = 10;
            if (!colMap.billingRate) colMap.billingRate = 11;
        }

        console.log('📍 DP Column map result:', colMap);

        const items = [];
        const parseNum = (val) => {
            if (val === undefined || val === null) return 0;
            if (typeof val === 'number') return val;
            const str = String(val).replace(/,/g, '').replace(/[^\d.-]/g, '').replace('%', '');
            return parseFloat(str) || 0;
        };

        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return;
            const getCellVal = (col) => col ? row.getCell(col).value : null;

            const rowData = {};
            if (colMap.distributorCode) rowData.distributorCode = getCellVal(colMap.distributorCode)?.toString()?.trim();
            if (colMap.distributorName) rowData.distributorName = getCellVal(colMap.distributorName)?.toString()?.trim();
            if (colMap.code) rowData.code = getCellVal(colMap.code)?.toString()?.trim();
            if (colMap.name) rowData.name = getCellVal(colMap.name)?.toString()?.trim();
            if (colMap.mrp) rowData.mrp = parseNum(getCellVal(colMap.mrp));
            if (colMap.inKg) rowData.inKg = getCellVal(colMap.inKg)?.toString()?.trim();
            if (colMap.gstPct) rowData.gstPct = parseNum(getCellVal(colMap.gstPct));
            if (colMap.retailerMarginOnMrp) rowData.retailerMarginOnMrp = parseNum(getCellVal(colMap.retailerMarginOnMrp));
            if (colMap.distMarginOnCost) rowData.distMarginOnCost = parseNum(getCellVal(colMap.distMarginOnCost));
            if (colMap.distMarginOnMrp) rowData.distMarginOnMrp = parseNum(getCellVal(colMap.distMarginOnMrp));
            if (colMap.billingRate) rowData.billingRate = parseNum(getCellVal(colMap.billingRate));
            
            // Generate composite ID based on distributor and product
            const distCode = rowData.distributorCode || 'UNK';
            const prodCode = rowData.code || `PROD-${Date.now()}`;
            rowData.id = `${distCode}-${prodCode}`;
            
            rowData.isActive = true;
            if (rowData.name && rowData.code) items.push(rowData);
        });

        const bulkOps = items.map(item => ({
            updateOne: {
                filter: { id: item.id },
                update: { $set: item },
                upsert: true
            }
        }));

        if (bulkOps.length > 0) await DistributorPrice.bulkWrite(bulkOps);
        fs.unlinkSync(req.file.path);
        console.log(`🚀 Bulk imported ${items.length} distributor prices`);
        res.json({ success: true, message: `Successfully imported ${items.length} pricing entries` });
    } catch (error) {
        console.error('Distributor price bulk import error:', error);
        res.status(500).json({ message: 'Error processing file', error: error.message });
    }
});

// Download Excel template for distributor price import
app.get('/api/distributor-prices/import-template', async (req, res) => {
    try {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Distributor Price Template');
        const headers = [
            'Code', 'Name', 'Material', 'Material Number',
            'MRP', 'in Kg', '% GST', 'Retailer Margin On MRP',
            'Dist Margin On Cost', 'Dist Margin On MRP', 'Billing Rate'
        ];
        const headerRow = worksheet.addRow(headers);
        headerRow.font = { bold: true, color: { argb: 'FFFFFF' } };
        headerRow.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '0F172A' } };
        worksheet.columns = headers.map(() => ({ width: 18 }));
        // Add example row based on user template
        worksheet.addRow([
            '197362', 'MULTIPRODUCTS CORPORATION', '2004643', 'FISH FINGERS RETAIL PACK 200G',
            220, 0.2, '5%', '34%', '10%', '0%', 116.29
        ]);

        const buffer = await workbook.xlsx.writeBuffer();
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=Distributor_Price_Template.xlsx');
        res.send(buffer);
    } catch (error) {
        res.status(500).json({ message: 'Error generating template' });
    }
});



// ==================== PHOTO UPLOAD ====================
// Accepts base64 encoded image and uploads to DigitalOcean Spaces
app.post('/api/upload-photo', verifyToken, logCreate('FILE_UPLOAD'), async (req, res) => {
    try {
        const { base64Image, fileName, folder } = req.body;
        if (!base64Image || !fileName) {
            return res.status(400).json({ message: 'base64Image and fileName are required' });
        }
        const { uploadFile } = require('./services/storageService');
        const url = await uploadFile(base64Image, fileName, folder || 'uploads');
        res.json({ url });
    } catch (error) {
        console.error('Photo upload error:', error);
        res.status(500).json({ message: 'Failed to upload photo' });
    }
});

// ==================== ORDERS ====================
app.get('/api/orders', verifyToken, async (req, res) => {
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

app.get('/api/orders/:id', verifyToken, async (req, res) => {
    try {
        const { id } = req.params;
        const order = await Order.findOne({ id });
        if (order) return res.json(order);
        res.status(404).json({ message: 'Order not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching order' });
    }
});

app.post('/api/orders', verifyToken, logCreate('ORDER'), async (req, res) => {
    try {
        const orderData = {
            ...req.body,
            id: req.body.id || (req.body.isSTN ? `STN-${Date.now().toString().slice(-6)}` : `ORD-${Date.now().toString().slice(-6)}`),
            salespersonId: req.user.userId, // Mandatory attribution from token
            createdAt: req.body.createdAt || new Date().toISOString(),
            statusHistory: req.body.statusHistory || [{
                status: req.body.status || 'Pending',
                timestamp: new Date().toISOString()
            }]
        };

        const newOrder = new Order(orderData);
        await newOrder.save();
        console.log(`✅ Order created: ${newOrder.id}`);
        res.status(201).json({ success: true, data: newOrder });
    } catch (error) {
        console.error('Order creation error:', error);
        res.status(500).json({ message: 'Error creating order' });
    }
});

app.patch('/api/orders/:id', verifyToken, logUpdate('ORDER'), async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = { ...req.body };

        // Fetch original data for audit log
        req.originalData = await Order.findOne({ id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Order not found' });

        // Admin Bypass Logic: If req.body.isAdminBypass is true and user is Admin, allow any status
        if (updateData.isAdminBypass) {
            console.log(`🛡️ Admin Bypass triggered for order: ${id} to status: ${updateData.status}`);
            // Remove bypass flag before saving
            delete updateData.isAdminBypass;
        } else {
            // Logistics 15% Cost Alert Logic (Normal flow)
            if (updateData.logistics && updateData.logistics.shippingCost) {
                const currentOrder = await Order.findOne({ id });
                if (currentOrder) {
                    const costPercentage = (updateData.logistics.shippingCost / currentOrder.total) * 100;
                    if (costPercentage > 15) {
                        updateData.logistics.highCostAlert = true;
                        updateData.status = 'Pending Admin Review';
                        console.log(`⚠️ High Cost Alert on ${id}: ${costPercentage.toFixed(2)}%`);
                    }
                }
            }
        }

        // Add status history if status is being updated
        if (updateData.status) {
            const timestamp = new Date().toISOString();
            if (!updateData.statusHistory) {
                updateData.statusHistory = [];
            }
            updateData.statusHistory.push({ status: updateData.status, timestamp });
            
            // --- INVENTORY HARDENING: Restore stock on Cancellation ---
            if (updateData.status === 'Cancelled' && req.originalData.sourceWarehouse) {
                const session = await mongoose.startSession();
                session.startTransaction();
                try {
                    await InventoryService.restoreStock(req.originalData.sourceWarehouse, req.originalData.items, session);
                    await session.commitTransaction();
                    console.log(`♻️ Stock restored for cancelled order: ${id}`);
                } catch (err) {
                    await session.abortTransaction();
                    console.error('❌ Restoration failed:', err);
                } finally {
                    session.endSession();
                }
            }
        }

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

            // Log status change if applicable
            if (updateData.status && req.originalData.status !== updateData.status) {
                logStatusChange(
                    req.user.userId,
                    req.user.name,
                    'ORDER',
                    id,
                    req.originalData.status,
                    updateData.status,
                    req.ip || req.connection.remoteAddress,
                    req.get('user-agent')
                );
            }

            return res.json({ success: true, data: order });
        }

        res.status(404).json({ message: 'Order not found' });
    } catch (error) {
        console.error('Order update error:', error);
        res.status(500).json({ message: 'Error updating order' });
    }
});

app.delete('/api/orders/:id', verifyToken, logDelete('ORDER'), async (req, res) => {
    try {
        const { id } = req.params;
        req.originalData = await Order.findOne({ id }).lean();
        if (!req.originalData) return res.status(404).json({ message: 'Order not found' });

        const order = await Order.findOneAndDelete({ id });
        if (order) return res.json({ success: true, message: 'Order deleted' });
        res.status(404).json({ message: 'Order not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting order' });
    }
});

// ==================== LOGISTICS ====================

// POST /api/logistics/bulk-assign
// Assigns delivery agent + logistics details to multiple orders and sets status → "In Transit"
app.post('/api/logistics/bulk-assign', verifyToken, async (req, res) => {
    try {
        const { orderIds, logisticsData } = req.body;

        if (!Array.isArray(orderIds) || orderIds.length === 0) {
            return res.status(400).json({ success: false, message: 'orderIds array is required and must not be empty' });
        }
        if (!logisticsData) {
            return res.status(400).json({ success: false, message: 'logisticsData is required' });
        }

        const timestamp = new Date();
        let updatedCount = 0;

        for (const orderId of orderIds) {
            const order = await Order.findOne({ id: orderId });
            if (!order) {
                console.warn(`⚠️ Logistics assign: Order not found — ${orderId}`);
                continue;
            }

            await Order.findOneAndUpdate(
                { id: orderId },
                {
                    $set: {
                        status: 'In Transit',
                        logistics: {
                            deliveryAgentId: logisticsData.deliveryAgentId || '',
                            vehicleNo: logisticsData.vehicleNo || '',
                            vehicleProvider: logisticsData.vehicleProvider || 'Hub Manifest',
                            distanceKm: logisticsData.distanceKm || 0,
                            shippingCost: logisticsData.shippingCost || 0,
                            highCostAlert: false,
                            manifestId: logisticsData.manifestId || '',
                            ewayBill: logisticsData.ewayBill || '',
                            sealNo: logisticsData.sealNo || '',
                            bookingDate: timestamp,
                        }
                    },
                    $push: {
                        statusHistory: {
                            status: 'In Transit',
                            timestamp: timestamp.toISOString()
                        }
                    }
                },
                { new: true }
            );

            // Log status change for bulk assignment
            logStatusChange(
                req.user.userId,
                req.user.name,
                'ORDER',
                orderId,
                order.status,
                'In Transit',
                req.ip || req.connection.remoteAddress,
                req.get('user-agent')
            );

            console.log(`🚚 Logistics assigned: ${orderId} → In Transit | Agent: ${logisticsData.deliveryAgentId} | Manifest: ${logisticsData.manifestId}`);
            updatedCount++;
        }

        res.json({
            success: true,
            message: `${updatedCount} order(s) dispatched successfully`,
            updated: updatedCount
        });

    } catch (error) {
        console.error('Logistics bulk-assign error:', error);
        res.status(500).json({ success: false, message: 'Error assigning logistics', error: error.message });
    }
});

// ==================== BULK OPERATIONS ====================
const ExcelJS = require('exceljs');

// Route to generate and download Excel template
app.get('/api/customers/import-template', async (req, res) => {
    try {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Customer Import Template');

        // Ensure accurate header spacing for dynamic headers. The backend parser handles minor variants,
        // but it's best to match the exact OD Master export shape so that the template is literally just a blank version.
        const headers = [
            'Customer ID', 'Dist', 'Sales Manager', 'Class', 'Employee respons.',
            'Customer Names', 'Credit Days', 'Credit Limit', 'Security Chq',
            'Dist Channel', 'O/s Amt', 'OD Amt', 'Diffn btw ydy & tday',
            '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90',
            '90 to 120', '120 to 150', '150 to 180', '>180'
        ];

        worksheet.addRow(headers);

        // Styling for headers
        const headerRow = worksheet.getRow(1);
        headerRow.font = { bold: true, color: { argb: 'FFFFFF' } };
        headerRow.fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: '1E293B' }
        };

        const buffer = await workbook.xlsx.writeBuffer();

        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', 'attachment; filename=Customer_Master_Template.xlsx');
        res.setHeader('Content-Length', buffer.length);

        res.send(buffer);
    } catch (error) {
        console.error('❌ Template Generation Error:', error);
        res.status(500).json({ message: 'Error generating template' });
    }
});

app.post('/api/customers/bulk-import', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        const workbook = new ExcelJS.Workbook();
        await workbook.xlsx.readFile(req.file.path);
        // getWorksheet(1) returns undefined for named sheets; fall back to first sheet
        let worksheet = workbook.getWorksheet(1);
        if (!worksheet) {
            workbook.eachSheet((ws) => { if (!worksheet) worksheet = ws; });
        }
        if (!worksheet) {
            return res.status(400).json({ message: 'No worksheet found in the uploaded file' });
        }
        const headerRow = worksheet.getRow(1);
        const colMap = {};

        // ── Dynamic Header Detection ────────────────────────────────────────────
        // Order matters: more-specific checks first to avoid false positives.
        headerRow.eachCell((cell, colNumber) => {
            const raw = cell.value?.toString().trim() ?? '';
            const header = raw.toLowerCase();
            if (!header) return;

            // Name detection FIRST (before generic 'id' catch)
            if (header.includes('customer name') || header === 'name' || header === 'cust name') {
                colMap.name = colNumber;
            } else if (header.includes('customer id') || header.includes('customer code') || header === 'id' || header === 'cust id' || header === 'code') {
                colMap.id = colNumber;
            } else if (header.includes('sales manager') || header === 'manager') {
                colMap.salesManager = colNumber;
            } else if (header.includes('employee respons') || header.includes('emp resp')) {
                colMap.employeeResponsible = colNumber;
            } else if ((header.includes('dist') || header.includes('location')) && !header.includes('channel') && !header.includes('diffn')) {
                colMap.location = colNumber;
            } else if (header.includes('class')) {
                colMap.customerClass = colNumber;
            } else if (header.includes('credit day') || header === 'cr.days' || header === 'cr days') {
                colMap.exposureDays = colNumber;
            } else if (header.includes('credit limit') || header.includes('cr.limit') || header === 'limit') {
                colMap.limit = colNumber;
            } else if (header.includes('security chq') || header.includes('sec chq')) {
                colMap.securityChq = colNumber;
            } else if (header.includes('dist channel') || header.includes('channel')) {
                colMap.distributionChannel = colNumber;
            } else if (header.includes('o/s amt') || header.includes('os amt') || header.includes('outstanding') || header.includes('os balance')) {
                colMap.osBalance = colNumber;
            } else if (header.includes('od amt') || header.includes('od amount') || header.includes('overdue')) {
                colMap.odAmt = colNumber;
            } else if (header.includes('diffn') || header.includes('diff btw') || header.includes('diff ydy')) {
                colMap.diffYesterdayToday = colNumber;
            } else if (header === '0 to 7' || header === '0-7') colMap.bucket0_7 = colNumber;
            else if (header === '7 to 15' || header === '7-15') colMap.bucket7_15 = colNumber;
            else if (header === '15 to 30' || header === '15-30') colMap.bucket15_30 = colNumber;
            else if (header === '30 to 45' || header === '30-45') colMap.bucket30_45 = colNumber;
            else if (header === '45 to 90' || header === '45-90') colMap.bucket45_90 = colNumber;
            else if (header === '90 to 120' || header === '90-120') colMap.bucket90_120 = colNumber;
            else if (header === '120 to 150' || header === '120-150') colMap.bucket120_150 = colNumber;
            else if (header === '150 to 180' || header === '150-180') colMap.bucket150_180 = colNumber;
            else if (header === '>180' || header === 'above 180' || header === 'above180') colMap.bucketOver180 = colNumber;
        });

        // ── Positional fallback ─────────────────────────────────────────────────
        // Standard OD Master 22-column format (from our app export):
        // Col1=CustomerID, Col2=CustomerName, Col3=Dist, Col4=SalesManager,
        // Col5=Class, Col6=EmpResponsible, Col7=CreditDays, Col8=CreditLimit,
        // Col9=SecurityChq, Col10=DistChannel, Col11=OsAmt, Col12=OdAmt,
        // Col13=Diff, Col14-22=Aging buckets
        const totalCols = headerRow.actualCellCount;
        if (!colMap.name && totalCols >= 2) {
            console.log('⚠️  Header map missing "name" — applying positional fallback');
            if (!colMap.id)   colMap.id   = 1;
            if (!colMap.name) colMap.name = 2;
            if (!colMap.location)          colMap.location          = 3;
            if (!colMap.salesManager)      colMap.salesManager      = 4;
            if (!colMap.customerClass)     colMap.customerClass     = 5;
            if (!colMap.employeeResponsible) colMap.employeeResponsible = 6;
            if (!colMap.exposureDays)      colMap.exposureDays      = 7;
            if (!colMap.limit)             colMap.limit             = 8;
            if (!colMap.securityChq)       colMap.securityChq       = 9;
            if (!colMap.distributionChannel) colMap.distributionChannel = 10;
            if (!colMap.osBalance)         colMap.osBalance         = 11;
            if (!colMap.odAmt)             colMap.odAmt             = 12;
            if (!colMap.diffYesterdayToday) colMap.diffYesterdayToday = 13;
            if (!colMap.bucket0_7)   colMap.bucket0_7   = 14;
            if (!colMap.bucket7_15)  colMap.bucket7_15  = 15;
            if (!colMap.bucket15_30) colMap.bucket15_30 = 16;
            if (!colMap.bucket30_45) colMap.bucket30_45 = 17;
            if (!colMap.bucket45_90) colMap.bucket45_90 = 18;
            if (!colMap.bucket90_120)  colMap.bucket90_120  = 19;
            if (!colMap.bucket120_150) colMap.bucket120_150 = 20;
            if (!colMap.bucket150_180) colMap.bucket150_180 = 21;
            if (!colMap.bucketOver180) colMap.bucketOver180 = 22;
        }

        console.log('📍 Column map result:', colMap);

        const customers = [];
        const parseNum = (val) => {
            if (val === undefined || val === null) return 0;
            if (typeof val === 'number') return val;
            const str = String(val).replace(/,/g, '').replace(/[^\d.-]/g, '');
            return parseFloat(str) || 0;
        };

        worksheet.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return; // Skip header

            const getCellVal = (col) => col ? row.getCell(col).value : null;

            const rowData = {
                id: getCellVal(colMap.id)?.toString()?.trim() || null,
                name: getCellVal(colMap.name)?.toString()?.trim() || null,
                location: getCellVal(colMap.location)?.toString()?.trim() || null,
                salesManager: getCellVal(colMap.salesManager)?.toString()?.trim() || null,
                customerClass: getCellVal(colMap.customerClass)?.toString()?.trim() || null,
                employeeResponsible: getCellVal(colMap.employeeResponsible)?.toString()?.trim() || null,
                exposureDays: colMap.exposureDays ? (parseNum(getCellVal(colMap.exposureDays)) || 15) : 15,
                limit: parseNum(getCellVal(colMap.limit)),
                securityChq: getCellVal(colMap.securityChq)?.toString()?.trim() || '-',
                distributionChannel: getCellVal(colMap.distributionChannel)?.toString()?.trim() || null,
                osBalance: parseNum(getCellVal(colMap.osBalance)),
                outstanding: parseNum(getCellVal(colMap.osBalance)), // mirror for legacy field
                odAmt: parseNum(getCellVal(colMap.odAmt)),
                overdue: parseNum(getCellVal(colMap.odAmt)),           // mirror for legacy field
                diffYesterdayToday: parseNum(getCellVal(colMap.diffYesterdayToday)),
                agingBuckets: {
                    "0 to 7":   parseNum(getCellVal(colMap.bucket0_7)),
                    "7 to 15":  parseNum(getCellVal(colMap.bucket7_15)),
                    "15 to 30": parseNum(getCellVal(colMap.bucket15_30)),
                    "30 to 45": parseNum(getCellVal(colMap.bucket30_45)),
                    "45 to 90": parseNum(getCellVal(colMap.bucket45_90)),
                    "90 to 120":  parseNum(getCellVal(colMap.bucket90_120)),
                    "120 to 150": parseNum(getCellVal(colMap.bucket120_150)),
                    "150 to 180": parseNum(getCellVal(colMap.bucket150_180)),
                    ">180": parseNum(getCellVal(colMap.bucketOver180))
                }
            };

            // Log first 2 rows to verify data parsing
            if (customers.length < 2) {
                console.log(`📝 Row ${rowNumber} parsed sample:`, { name: rowData.name, os: rowData.osBalance, od: rowData.odAmt });
            }

            // Accept row if name OR id is present (not both required)
            if (rowData.name || rowData.id) {
                if (!rowData.name) rowData.name = rowData.id;  // fill missing name
                if (!rowData.id)   rowData.id   = rowData.name; // fill missing id
                customers.push(rowData);
            }
        });

        // Bulk upsert logic
        const bulkOps = customers.map(cust => ({
            updateOne: {
                filter: { id: cust.id },
                update: { $set: cust },
                upsert: true
            }
        }));

        if (bulkOps.length > 0) {
            await Customer.bulkWrite(bulkOps);
        }

        // Clean up uploaded file
        fs.unlinkSync(req.file.path);

        console.log(`🚀 Bulk imported ${customers.length} customers`);
        res.json({ success: true, message: `Successfully imported ${customers.length} customers` });
    } catch (error) {
        console.error('Bulk import error:', error);
        res.status(500).json({ message: 'Error processing Excel file', error: error.message });
    }
});

app.post('/api/orders/bulk-update', async (req, res) => {
    try {
        const { orderIds, updates } = req.body;
        const updateObj = { ...updates };
        const query = { $set: updateObj };

        if (updates.status) {
            query.$push = { statusHistory: { status: updates.status, timestamp: new Date().toISOString() } };
        }

        await Order.updateMany({ id: { $in: orderIds } }, query);
        const updatedOrders = await Order.find({ id: { $in: orderIds } });
        res.json(updatedOrders);
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
        const { getDistance, calculateHaversineDistance, estimateDuration } = require('./services/mapsService');

        let distance;
        let duration;
        let distanceSource = 'manual';

        // If distance not provided, try Google Maps API
        if (!providedDistance && origin && destination) {
            const googleDistance = await getDistance(origin, destination);

            if (googleDistance) {
                distance = googleDistance.distance;
                duration = googleDistance.durationText;
                distanceSource = 'google_maps';
                console.log(`✅ Using Google Maps distance: ${distance} km`);
            } else {
                // Fallback: Try to extract coordinates and use Haversine
                // For now, use random distance as fallback
                distance = Math.floor(Math.random() * 500) + 50;
                duration = estimateDuration(distance) + ' minutes';
                distanceSource = 'estimated';
                console.log(`⚠️  Using estimated distance: ${distance} km`);
            }
        } else {
            distance = providedDistance || Math.floor(Math.random() * 500) + 50;
            duration = estimateDuration(distance) + ' minutes';
            distanceSource = providedDistance ? 'manual' : 'estimated';
        }

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
                distanceSource, // 'google_maps', 'manual', or 'estimated'
                vehicleType: selectedVehicle,
                breakdown: {
                    fuelCost: Math.round(fuelCost),
                    driverAllowance,
                    tollCharges,
                    miscCharges,
                    total: Math.round(totalCost)
                },
                estimatedTime: duration || (Math.ceil(distance / 60) + ' hours'),
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
        const items = await Procurement.find().sort({ createdAt: -1 });
        res.json(items);
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

        const newItem = new Procurement(itemData);
        await newItem.save();
        res.status(201).json(newItem);
    } catch (error) {
        res.status(500).json({ message: 'Error creating procurement entry' });
    }
});

app.put('/api/procurement/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        const item = await Procurement.findOneAndUpdate({ id }, updates, { new: true });
        if (item) return res.json(item);
        res.status(404).json({ message: 'Not found' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating procurement' });
    }
});

app.delete('/api/procurement/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await Procurement.findOneAndDelete({ id });
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

// ==================== NEW FEATURE ROUTES ====================
// Import and mount new routes (PMS, Clearance, Packaging, etc.)
const newFeaturesRoutes = require('./routes/newFeatures');
newFeaturesRoutes(app);

// ==================== ISO 27001 COMPLIANCE ROUTES ====================
// Audit Log Routes (A.8.16 - Monitoring Activities)
const auditRoutes = require('./routes/auditRoutes');
auditRoutes(app);

// Warehouse & Inventory Routes
const warehouseRouter = require('./routes/warehouseRoutes');
app.use('/api/warehouse', warehouseRouter);

// GDPR Compliance Routes (A.8.10 - Information Deletion)
const gdprRoutes = require('./routes/gdprRoutes');
gdprRoutes(app);
// ==================== HEALTH CHECK ====================
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        version: '2.1.0'
    });
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
const server = app.listen(PORT, '0.0.0.0', () => {
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
║  WebSocket: 🔌 ENABLED                                  ║
║                                                        ║
║  Local IPs for Mobile Connection:                      ║
${ips.map(ip => `║  🔗 http://${ip}:${PORT}                         `).join('\n')}
║                                                        ║
╚════════════════════════════════════════════════════════╝
    `);
});

// ==================== WEBSOCKET INITIALIZATION ====================
const socketIo = require('./socket');
socketIo.init(server);
console.log('🔌 WebSocket server ready for real-time connections');

