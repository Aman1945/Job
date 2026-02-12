/**
 * NexusOMS - WebSocket Server
 * Real-time updates for orders and other events
 */

const socketIo = require('socket.io');
const jwt = require('jsonwebtoken');

let io;

/**
 * Initialize Socket.IO server
 * @param {Object} server - HTTP server instance
 * @returns {Object} Socket.IO instance
 */
function init(server) {
    io = socketIo(server, {
        cors: {
            origin: [
                'http://localhost:3000',
                'http://localhost:54167',
                'http://localhost:8080',
                'https://nexus-oms-backend.onrender.com',
                'capacitor://localhost',
                'ionic://localhost'
            ],
            credentials: true,
            methods: ['GET', 'POST']
        },
        transports: ['websocket', 'polling']
    });

    // JWT Authentication Middleware for Socket.IO
    io.use((socket, next) => {
        const token = socket.handshake.auth.token;

        if (!token) {
            console.log('❌ Socket connection rejected: No token provided');
            return next(new Error('Authentication error: No token provided'));
        }

        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            socket.userId = decoded.userId;
            socket.userName = decoded.name;
            socket.userRole = decoded.role;
            socket.isApprover = decoded.isApprover;

            console.log(`✅ Socket authenticated: ${socket.userName} (${socket.userRole})`);
            next();
        } catch (err) {
            console.log('❌ Socket connection rejected: Invalid token');
            return next(new Error('Authentication error: Invalid token'));
        }
    });

    // Connection event
    io.on('connection', (socket) => {
        console.log(`🔌 User connected: ${socket.userName} (${socket.userId})`);

        // Join user-specific room
        socket.join(`user:${socket.userId}`);

        // Join role-specific room
        socket.join(`role:${socket.userRole}`);

        // Send welcome message
        socket.emit('connected', {
            message: 'Connected to NexusOMS real-time server',
            userId: socket.userId,
            userName: socket.userName,
            role: socket.userRole
        });

        // Handle disconnection
        socket.on('disconnect', () => {
            console.log(`🔌 User disconnected: ${socket.userName} (${socket.userId})`);
        });

        // Handle custom events
        socket.on('ping', () => {
            socket.emit('pong', { timestamp: Date.now() });
        });
    });

    console.log('✅ Socket.IO server initialized');
    return io;
}

/**
 * Get Socket.IO instance
 * @returns {Object} Socket.IO instance
 */
function getIO() {
    if (!io) {
        throw new Error('Socket.IO not initialized. Call init() first.');
    }
    return io;
}

/**
 * Emit order created event
 * @param {Object} order - Order object
 */
function emitOrderCreated(order) {
    if (!io) return;

    // Broadcast to all connected clients
    io.emit('order:created', {
        orderId: order.id,
        customerName: order.customerName,
        total: order.total,
        status: order.status,
        salespersonId: order.salespersonId,
        createdAt: order.createdAt
    });

    console.log(`📢 Broadcasted order:created - ${order.id}`);
}

/**
 * Emit order updated event
 * @param {Object} order - Updated order object
 */
function emitOrderUpdated(order) {
    if (!io) return;

    // Send to specific user (salesperson)
    if (order.salespersonId) {
        io.to(`user:${order.salespersonId}`).emit('order:updated', {
            orderId: order.id,
            customerName: order.customerName,
            total: order.total,
            status: order.status,
            updatedAt: new Date().toISOString()
        });

        console.log(`📢 Sent order:updated to ${order.salespersonId} - ${order.id}`);
    }

    // Also broadcast to admins and credit control
    io.to('role:Admin').emit('order:updated', {
        orderId: order.id,
        customerName: order.customerName,
        total: order.total,
        status: order.status,
        updatedAt: new Date().toISOString()
    });

    io.to('role:Credit Control').emit('order:updated', {
        orderId: order.id,
        customerName: order.customerName,
        total: order.total,
        status: order.status,
        updatedAt: new Date().toISOString()
    });
}

/**
 * Emit order status changed event
 * @param {Object} data - Status change data
 */
function emitOrderStatusChanged(data) {
    if (!io) return;

    const { orderId, oldStatus, newStatus, salespersonId } = data;

    // Send to salesperson
    if (salespersonId) {
        io.to(`user:${salespersonId}`).emit('order:status-changed', {
            orderId,
            oldStatus,
            newStatus,
            timestamp: new Date().toISOString()
        });
    }

    // Broadcast to relevant roles
    io.to('role:Admin').emit('order:status-changed', {
        orderId,
        oldStatus,
        newStatus,
        timestamp: new Date().toISOString()
    });

    console.log(`📢 Broadcasted order:status-changed - ${orderId}: ${oldStatus} → ${newStatus}`);
}

/**
 * Emit low stock alert
 * @param {Object} material - Packaging material object
 */
function emitLowStockAlert(material) {
    if (!io) return;

    // Send to warehouse and procurement
    io.to('role:Warehouse').emit('packaging:low-stock', {
        materialId: material.id,
        materialName: material.name,
        balance: material.balance,
        moq: material.moq,
        timestamp: new Date().toISOString()
    });

    io.to('role:Procurement').emit('packaging:low-stock', {
        materialId: material.id,
        materialName: material.name,
        balance: material.balance,
        moq: material.moq,
        timestamp: new Date().toISOString()
    });

    console.log(`📢 Low stock alert: ${material.name} (${material.balance}/${material.moq})`);
}

module.exports = {
    init,
    getIO,
    emitOrderCreated,
    emitOrderUpdated,
    emitOrderStatusChanged,
    emitLowStockAlert
};
