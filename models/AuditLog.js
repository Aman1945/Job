/**
 * NexusOMS - Audit Log Model
 * ISO 27001:2022 Control A.8.16 - Monitoring Activities
 */

const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
        index: true
    },
    userName: {
        type: String,
        required: true
    },
    action: {
        type: String,
        required: true,
        enum: [
            'LOGIN',
            'LOGOUT',
            'CREATE',
            'UPDATE',
            'DELETE',
            'STATUS_CHANGE',
            'PRICE_CHANGE',
            'ROLE_CHANGE',
            'EXPORT',
            'APPROVE',
            'REJECT',
            'BULK_UPLOAD',
            'FILE_UPLOAD',
            'PASSWORD_RESET'
        ],
        index: true
    },
    entityType: {
        type: String,
        enum: ['ORDER', 'CUSTOMER', 'PRODUCT', 'USER', 'PROCUREMENT', 'INVOICE', 'PACKAGING', 'PMS', 'SYSTEM'],
        index: true
    },
    entityId: {
        type: String,
        index: true
    },
    oldData: {
        type: mongoose.Schema.Types.Mixed
    },
    newData: {
        type: mongoose.Schema.Types.Mixed
    },
    ipAddress: {
        type: String
    },
    userAgent: {
        type: String
    },
    timestamp: {
        type: Date,
        default: Date.now,
        index: true
    },
    success: {
        type: Boolean,
        default: true
    },
    errorMessage: {
        type: String
    }
}, {
    timestamps: true
});

// Compound indexes for common queries
auditLogSchema.index({ userId: 1, timestamp: -1 });
auditLogSchema.index({ entityType: 1, entityId: 1, timestamp: -1 });
auditLogSchema.index({ action: 1, timestamp: -1 });

// TTL index - auto-delete logs older than 2 years (ISO compliance)
auditLogSchema.index({ timestamp: 1 }, { expireAfterSeconds: 63072000 }); // 2 years

module.exports = mongoose.model('AuditLog', auditLogSchema);
