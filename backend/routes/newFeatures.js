/**
 * NexusOMS - New API Routes
 * All new features implementation
 * To be integrated into server.js
 */

const jwt = require('jsonwebtoken');
const { verifyToken, optionalAuth } = require('../middleware/auth');
const { allowRoles, requireApprover } = require('../middleware/rbac');

// Import models
const User = require('../models/User');
const Product = require('../models/Product');
const Customer = require('../models/Customer');
const Order = require('../models/Order');
const PerformanceRecord = require('../models/PerformanceRecord');
const PackagingMaterial = require('../models/PackagingMaterial');
const PackagingTransaction = require('../models/PackagingTransaction');

// Import services
const { generateBulkOrderTemplate, parseBulkOrderExcel } = require('../services/excelService');

module.exports = (app) => {



    // ==================== UPDATED LOGIN WITH JWT ====================
    app.post('/api/login', async (req, res) => {
        const { email, password } = req.body;
        console.log(`🔐 Login attempt: ${email}`);

        try {
            // Find user by ID or email
            const user = await User.findOne({ $or: [{ id: email }, { email: email }] });

            if (!user) {
                console.log(`❌ Login failed: ${email} (User not found)`);
                return res.status(404).json({
                    success: false,
                    message: 'EMAIL_NOT_FOUND'
                });
            }

            // Compare password using bcrypt
            const isPasswordValid = await user.comparePassword(password);

            if (!isPasswordValid) {
                console.log(`❌ Login failed: ${email} (Incorrect password)`);
                return res.status(401).json({
                    success: false,
                    message: 'WRONG_PASSWORD'
                });
            }

            // Update last login
            user.lastLogin = new Date();
            await user.save();

            // Generate JWT token
            const token = jwt.sign(
                user.getJWTPayload(),
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRY || '7d' }
            );

            console.log(`✅ Login successful: ${email}`);

            res.json({
                success: true,
                token,
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: user.role,
                    isApprover: user.isApprover,
                    status: user.status
                }
            });
        } catch (error) {
            console.error('Login error:', error);
            res.status(500).json({
                success: false,
                message: 'Server error'
            });
        }
    });

    // ==================== PERFORMANCE MANAGEMENT SYSTEM (PMS) ====================

    // Get user performance record
    app.get('/api/pms/:userId', verifyToken, allowRoles(['Admin', 'Sales']), async (req, res) => {
        try {
            const { userId } = req.params;
            const { month } = req.query;

            // Check if user can access this record
            if (req.user.role !== 'Admin' && req.user.userId !== userId) {
                return res.status(403).json({
                    success: false,
                    message: 'You can only view your own performance record'
                });
            }

            // Get current month if not provided
            const targetMonth = month || new Date().toLocaleDateString('en-US', { month: 'short', year: '2-digit' }).replace(' ', "'");

            let record = await PerformanceRecord.findOne({ userId, month: targetMonth });

            if (!record) {
                // Create default record if not exists
                const user = await User.findOne({ id: userId });
                if (!user) {
                    return res.status(404).json({
                        success: false,
                        message: 'User not found'
                    });
                }

                record = new PerformanceRecord({
                    userId,
                    userName: user.name,
                    month: targetMonth,
                    grossMonthlySalary: 0,
                    kras: []
                });
                await record.save();
            }

            res.json({
                success: true,
                data: record
            });
        } catch (error) {
            console.error('PMS fetch error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching performance record'
            });
        }
    });

    // Get leaderboard
    app.get('/api/pms/leaderboard', verifyToken, allowRoles(['Admin', 'Sales']), async (req, res) => {
        try {
            const { period = 'month' } = req.query;

            // Get current month
            const currentMonth = new Date().toLocaleDateString('en-US', { month: 'short', year: '2-digit' }).replace(' ', "'");

            const records = await PerformanceRecord.find({ month: currentMonth })
                .sort({ totalScore: -1 });

            const leaderboard = records.map((record, index) => ({
                rank: index + 1,
                userId: record.userId,
                userName: record.userName,
                totalScore: record.totalScore,
                incentiveAmount: record.incentiveAmount,
                incentivePercentage: record.incentivePercentage
            }));

            res.json({
                success: true,
                data: leaderboard,
                period: currentMonth
            });
        } catch (error) {
            console.error('Leaderboard error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching leaderboard'
            });
        }
    });

    // Update KRA achievement
    app.post('/api/pms/kra/update', verifyToken, allowRoles(['Admin']), async (req, res) => {
        try {
            const { userId, month, kraId, achievedValue } = req.body;

            const record = await PerformanceRecord.findOne({ userId, month });

            if (!record) {
                return res.status(404).json({
                    success: false,
                    message: 'Performance record not found'
                });
            }

            const kra = record.kras.find(k => k.id === kraId);

            if (!kra) {
                return res.status(404).json({
                    success: false,
                    message: 'KRA not found'
                });
            }

            kra.achieved = achievedValue;
            record.calculateTotalScore();
            await record.save();

            res.json({
                success: true,
                message: 'KRA updated successfully',
                data: record
            });
        } catch (error) {
            console.error('KRA update error:', error);
            res.status(500).json({
                success: false,
                message: 'Error updating KRA'
            });
        }
    });

    // Update OD balance
    app.post('/api/pms/od-balance/update', verifyToken, allowRoles(['Admin', 'Credit Control']), async (req, res) => {
        try {
            const { userId, month, chennai, self, hyd } = req.body;

            const record = await PerformanceRecord.findOne({ userId, month });

            if (!record) {
                return res.status(404).json({
                    success: false,
                    message: 'Performance record not found'
                });
            }

            record.odBalances = { chennai, self, hyd };
            record.calculateTotalScore();
            await record.save();

            res.json({
                success: true,
                message: 'OD balances updated successfully',
                data: record
            });
        } catch (error) {
            console.error('OD balance update error:', error);
            res.status(500).json({
                success: false,
                message: 'Error updating OD balance'
            });
        }
    });

    // ==================== NEAR EXPIRY CLEARANCE ====================

    // Get expiring products
    app.get('/api/products/expiring', verifyToken, allowRoles(['Admin', 'Sales', 'Warehouse']), async (req, res) => {
        try {
            const { days = 90 } = req.query;
            const products = await Product.find();

            const expiringItems = [];

            products.forEach(product => {
                const expiringBatches = product.getExpiringBatches(parseInt(days));

                expiringBatches.forEach(batch => {
                    expiringItems.push({
                        productId: product.id,
                        skuCode: product.skuCode,
                        productName: product.name,
                        batchNumber: batch.batchNumber,
                        expDate: batch.expDate,
                        quantity: batch.quantity,
                        weight: batch.weight,
                        mrp: product.mrp,
                        baseRate: product.baseRate
                    });
                });
            });

            res.json({
                success: true,
                data: expiringItems,
                count: expiringItems.length
            });
        } catch (error) {
            console.error('Expiring products error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching expiring products'
            });
        }
    });

    // Create clearance order
    app.post('/api/orders/clearance', verifyToken, allowRoles(['Admin', 'Sales']), async (req, res) => {
        try {
            const { customerId, items } = req.body;

            // Validate customer
            const customer = await Customer.findOne({ id: customerId });
            if (!customer) {
                return res.status(404).json({
                    success: false,
                    message: 'Customer not found'
                });
            }

            // Validate and process items
            const orderItems = [];
            let totalAmount = 0;

            for (const item of items) {
                const product = await Product.findOne({ id: item.productId });

                if (!product) {
                    return res.status(404).json({
                        success: false,
                        message: `Product ${item.productId} not found`
                    });
                }

                const batch = product.batches.find(b => b.batchNumber === item.batchNumber && b.isActive);

                if (!batch) {
                    return res.status(404).json({
                        success: false,
                        message: `Batch ${item.batchNumber} not found or inactive`
                    });
                }

                if (batch.quantity < item.quantity) {
                    return res.status(400).json({
                        success: false,
                        message: `Insufficient quantity in batch ${item.batchNumber}. Available: ${batch.quantity}, Requested: ${item.quantity}`
                    });
                }

                // Check expiry date (must be within 90 days)
                const daysToExpiry = Math.ceil((new Date(batch.expDate) - new Date()) / (1000 * 60 * 60 * 24));
                if (daysToExpiry > 90) {
                    return res.status(400).json({
                        success: false,
                        message: `Batch ${item.batchNumber} is not eligible for clearance (expires in ${daysToExpiry} days)`
                    });
                }

                // Reduce batch quantity
                product.reduceBatchQuantity(item.batchNumber, item.quantity);
                await product.save();

                const itemTotal = item.proposedRate * item.quantity;
                totalAmount += itemTotal;

                orderItems.push({
                    productId: product.id,
                    productName: product.name,
                    skuCode: product.skuCode,
                    batchNumber: item.batchNumber,
                    quantity: item.quantity,
                    price: item.proposedRate,
                    total: itemTotal
                });
            }

            // Create clearance order
            const order = new Order({
                id: `CLR-${Date.now().toString().slice(-6)}`,
                customerId: customer.id,
                customerName: customer.name,
                items: orderItems,
                total: totalAmount,
                status: 'Pending Credit Approval',
                isClearance: true,
                salespersonId: req.user.userId,
                createdAt: new Date().toISOString(),
                statusHistory: [{
                    status: 'Pending Credit Approval',
                    timestamp: new Date().toISOString()
                }]
            });

            await order.save();

            res.status(201).json({
                success: true,
                message: 'Clearance order created successfully',
                data: order
            });
        } catch (error) {
            console.error('Clearance order error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Error creating clearance order'
            });
        }
    });

    // Get clearance order history
    app.get('/api/orders/clearance/history', verifyToken, allowRoles(['Admin', 'Sales', 'Credit Control']), async (req, res) => {
        try {
            const orders = await Order.find({ isClearance: true }).sort({ createdAt: -1 });

            res.json({
                success: true,
                data: orders
            });
        } catch (error) {
            console.error('Clearance history error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching clearance history'
            });
        }
    });

    // ==================== PACKAGING INVENTORY ====================

    // Get all packaging materials
    app.get('/api/packaging/materials', verifyToken, allowRoles(['Admin', 'Warehouse', 'Procurement']), async (req, res) => {
        try {
            const materials = await PackagingMaterial.find();

            const materialsWithStatus = materials.map(m => ({
                ...m.toObject(),
                isLowStock: m.isLowStock()
            }));

            res.json({
                success: true,
                data: materialsWithStatus
            });
        } catch (error) {
            console.error('Packaging materials error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching packaging materials'
            });
        }
    });

    // Get packaging transactions
    app.get('/api/packaging/transactions', verifyToken, allowRoles(['Admin', 'Warehouse']), async (req, res) => {
        try {
            const { materialId, startDate, endDate, page = 1, limit = 20 } = req.query;

            let query = {};
            if (materialId) query.materialId = materialId;
            if (startDate && endDate) {
                query.date = {
                    $gte: new Date(startDate),
                    $lte: new Date(endDate)
                };
            }

            const transactions = await PackagingTransaction.find(query)
                .sort({ date: -1 })
                .limit(parseInt(limit))
                .skip((parseInt(page) - 1) * parseInt(limit));

            const total = await PackagingTransaction.countDocuments(query);

            res.json({
                success: true,
                data: transactions,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / parseInt(limit))
                }
            });
        } catch (error) {
            console.error('Packaging transactions error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching packaging transactions'
            });
        }
    });

    // Inward packaging material
    app.post('/api/packaging/inward', verifyToken, allowRoles(['Admin', 'Warehouse', 'Procurement']), async (req, res) => {
        try {
            const { materialId, qty, batch, mfgDate, expDate, vendorName, referenceNo, attachment } = req.body;

            const material = await PackagingMaterial.findOne({ id: materialId });

            if (!material) {
                return res.status(404).json({
                    success: false,
                    message: 'Packaging material not found'
                });
            }

            // Create transaction
            const transaction = new PackagingTransaction({
                id: `PKG-IN-${Date.now().toString().slice(-6)}`,
                materialId,
                type: 'IN',
                qty,
                batch,
                mfgDate: mfgDate ? new Date(mfgDate) : undefined,
                expDate: expDate ? new Date(expDate) : undefined,
                vendorName,
                referenceNo,
                attachment,
                createdBy: req.user.userId
            });

            await transaction.save();

            // Update material balance
            material.balance += qty;
            material.lastMovementDate = new Date();
            await material.save();

            res.status(201).json({
                success: true,
                message: 'Inward entry created successfully',
                data: {
                    transaction,
                    material
                }
            });
        } catch (error) {
            console.error('Packaging inward error:', error);
            res.status(500).json({
                success: false,
                message: 'Error creating inward entry'
            });
        }
    });

    // Outward packaging material
    app.post('/api/packaging/outward', verifyToken, allowRoles(['Admin', 'Warehouse']), async (req, res) => {
        try {
            const { materialId, qty } = req.body;

            const material = await PackagingMaterial.findOne({ id: materialId });

            if (!material) {
                return res.status(404).json({
                    success: false,
                    message: 'Packaging material not found'
                });
            }

            if (material.balance < qty) {
                return res.status(400).json({
                    success: false,
                    message: `Insufficient balance. Available: ${material.balance}, Requested: ${qty}`
                });
            }

            // Create transaction
            const transaction = new PackagingTransaction({
                id: `PKG-OUT-${Date.now().toString().slice(-6)}`,
                materialId,
                type: 'OUT',
                qty,
                createdBy: req.user.userId
            });

            await transaction.save();

            // Update material balance
            material.balance -= qty;
            material.lastMovementDate = new Date();
            await material.save();

            res.status(201).json({
                success: true,
                message: 'Outward entry created successfully',
                data: {
                    transaction,
                    material
                }
            });
        } catch (error) {
            console.error('Packaging outward error:', error);
            res.status(500).json({
                success: false,
                message: 'Error creating outward entry'
            });
        }
    });

    // Get low stock materials
    app.get('/api/packaging/low-stock', verifyToken, allowRoles(['Admin', 'Warehouse']), async (req, res) => {
        try {
            const materials = await PackagingMaterial.find();
            const lowStockMaterials = materials.filter(m => m.isLowStock());

            res.json({
                success: true,
                data: lowStockMaterials,
                count: lowStockMaterials.length
            });
        } catch (error) {
            console.error('Low stock error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching low stock materials'
            });
        }
    });

    // ==================== BULK ORDER UPLOAD ====================

    // Download Excel template
    app.get('/api/orders/bulk/template', verifyToken, allowRoles(['Admin', 'Sales']), async (req, res) => {
        try {
            const buffer = await generateBulkOrderTemplate();

            res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            res.setHeader('Content-Disposition', 'attachment; filename="NexusOMS_BulkOrder_Template.xlsx"');
            res.setHeader('Content-Length', buffer.length);

            res.send(buffer);
        } catch (error) {
            console.error('Template generation error:', error);
            res.status(500).json({
                success: false,
                message: 'Error generating template'
            });
        }
    });

    // Upload bulk orders
    app.post('/api/orders/bulk', verifyToken, allowRoles(['Admin', 'Sales']), async (req, res) => {
        try {
            const { excelData } = req.body; // Base64 encoded Excel file

            if (!excelData) {
                return res.status(400).json({
                    success: false,
                    message: 'Excel file data is required'
                });
            }

            // Decode base64 to buffer
            const buffer = Buffer.from(excelData, 'base64');

            // Parse Excel file
            let parsedOrders;
            try {
                parsedOrders = await parseBulkOrderExcel(buffer);
            } catch (parseError) {
                // Check if it's a validation error
                if (parseError.message.includes('VALIDATION_ERROR')) {
                    const errorData = JSON.parse(parseError.message);
                    return res.status(400).json({
                        success: false,
                        message: 'Validation errors found in Excel file',
                        errors: errorData.errors
                    });
                }
                throw parseError;
            }

            console.log(`📊 Parsed ${parsedOrders.length} orders from Excel`);

            // Validate customers and products
            const validationErrors = [];
            const validatedOrders = [];

            for (const orderData of parsedOrders) {
                const { customerId, skuCode, quantity, appliedRate, remarks, rowNumber } = orderData;

                // Validate customer
                const customer = await Customer.findOne({ id: customerId });
                if (!customer) {
                    validationErrors.push({
                        row: rowNumber,
                        field: 'Customer ID',
                        message: `Customer ${customerId} not found`
                    });
                    continue;
                }

                // Validate product
                const product = await Product.findOne({ skuCode: skuCode });
                if (!product) {
                    validationErrors.push({
                        row: rowNumber,
                        field: 'SKU Code',
                        message: `Product with SKU ${skuCode} not found`
                    });
                    continue;
                }

                // Calculate price
                const price = appliedRate || product.baseRate || product.price || 0;

                validatedOrders.push({
                    customerId: customer.id,
                    customerName: customer.name,
                    items: [{
                        productId: product.id,
                        productName: product.name,
                        skuCode: product.skuCode,
                        quantity: quantity,
                        price: price,
                        total: price * quantity
                    }],
                    total: price * quantity,
                    status: 'Pending Credit Approval',
                    salespersonId: req.user.userId,
                    remarks: remarks,
                    isBulkUpload: true,
                    createdAt: new Date().toISOString(),
                    statusHistory: [{
                        status: 'Pending Credit Approval',
                        timestamp: new Date().toISOString()
                    }]
                });
            }

            // If there are validation errors, return them
            if (validationErrors.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation errors found',
                    errors: validationErrors,
                    validCount: validatedOrders.length,
                    errorCount: validationErrors.length
                });
            }

            // Generate order IDs
            const timestamp = Date.now();
            validatedOrders.forEach((order, index) => {
                order.id = `ORD-${(timestamp + index).toString().slice(-6)}`;
            });

            // Insert all orders at once
            const createdOrders = await Order.insertMany(validatedOrders);

            console.log(`✅ Created ${createdOrders.length} bulk orders`);

            res.status(201).json({
                success: true,
                message: `${createdOrders.length} orders created successfully`,
                data: {
                    totalOrders: createdOrders.length,
                    orders: createdOrders.map(o => ({
                        id: o.id,
                        customerName: o.customerName,
                        total: o.total,
                        status: o.status
                    }))
                }
            });

        } catch (error) {
            console.error('Bulk order upload error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Error processing bulk order upload'
            });
        }
    });

    // ==================== AI-POWERED CREDIT INSIGHTS ====================

    // Import Gemini service
    const { getCreditInsight } = require('../services/geminiService');

    // Get AI credit insight for an order
    app.post('/api/ai/credit-insight', verifyToken, allowRoles(['Admin', 'Credit Control']), async (req, res) => {
        try {
            const { orderId, customerId } = req.body;

            if (!orderId || !customerId) {
                return res.status(400).json({
                    success: false,
                    message: 'Order ID and Customer ID are required'
                });
            }

            // Fetch order
            const order = await Order.findOne({ id: orderId });
            if (!order) {
                return res.status(404).json({
                    success: false,
                    message: 'Order not found'
                });
            }

            // Fetch customer
            const customer = await Customer.findOne({ id: customerId });
            if (!customer) {
                return res.status(404).json({
                    success: false,
                    message: 'Customer not found'
                });
            }

            // Get AI insight
            const insight = await getCreditInsight(order, customer);

            res.json({
                success: true,
                insight,
                orderId: order.id,
                customerName: customer.name,
                orderValue: order.total,
                outstanding: customer.outstanding || 0,
                timestamp: new Date().toISOString()
            });

        } catch (error) {
            console.error('AI credit insight error:', error);
            res.status(500).json({
                success: false,
                message: 'Error generating AI insight',
                error: error.message
            });
        }
    });

}; // End of module.exports


