/**
 * NexusOMS - Audit Logger Middleware
 * ISO 27001:2022 Control A.8.16 - Monitoring Activities
 * Automatically logs all CREATE/UPDATE/DELETE operations
 */

const AuditLog = require('../models/AuditLog');

/**
 * Create audit log entry
 * @param {Object} params - Audit log parameters
 */
async function createAuditLog(params) {
    try {
        const {
            userId,
            userName,
            action,
            entityType,
            entityId,
            oldData,
            newData,
            ipAddress,
            userAgent,
            success = true,
            errorMessage
        } = params;

        await AuditLog.create({
            userId,
            userName,
            action,
            entityType,
            entityId,
            oldData,
            newData,
            ipAddress,
            userAgent,
            success,
            errorMessage,
            timestamp: new Date()
        });

        console.log(`📝 Audit Log: ${action} - ${entityType} - ${entityId} by ${userName}`);
    } catch (error) {
        console.error('❌ Audit log error:', error.message);
        // Don't throw error - audit logging should not break main flow
    }
}

/**
 * Middleware to log CREATE operations
 */
function logCreate(entityType) {
    return async (req, res, next) => {
        // Store original send function
        const originalSend = res.send;

        res.send = function (data) {
            // Parse response data
            let responseData;
            try {
                responseData = typeof data === 'string' ? JSON.parse(data) : data;
            } catch (e) {
                responseData = data;
            }

            // Log if successful creation
            if (res.statusCode === 201 || (responseData && responseData.success)) {
                const entityId = responseData.data?.id || responseData.id || 'unknown';

                createAuditLog({
                    userId: req.user?.userId || 'system',
                    userName: req.user?.name || 'System',
                    action: 'CREATE',
                    entityType,
                    entityId,
                    newData: responseData.data || responseData,
                    ipAddress: req.ip || req.connection.remoteAddress,
                    userAgent: req.get('user-agent')
                });
            }

            // Call original send
            originalSend.call(this, data);
        };

        next();
    };
}

/**
 * Middleware to log UPDATE operations
 */
function logUpdate(entityType) {
    return async (req, res, next) => {
        // Store original send function
        const originalSend = res.send;

        res.send = function (data) {
            // Parse response data
            let responseData;
            try {
                responseData = typeof data === 'string' ? JSON.parse(data) : data;
            } catch (e) {
                responseData = data;
            }

            // Log if successful update
            if (res.statusCode === 200 && responseData && responseData.success) {
                const entityId = req.params.id || responseData.data?.id || 'unknown';

                createAuditLog({
                    userId: req.user?.userId || 'system',
                    userName: req.user?.name || 'System',
                    action: 'UPDATE',
                    entityType,
                    entityId,
                    oldData: req.originalData, // Set this before calling update
                    newData: responseData.data || req.body,
                    ipAddress: req.ip || req.connection.remoteAddress,
                    userAgent: req.get('user-agent')
                });
            }

            // Call original send
            originalSend.call(this, data);
        };

        next();
    };
}

/**
 * Middleware to log DELETE operations
 */
function logDelete(entityType) {
    return async (req, res, next) => {
        // Store original send function
        const originalSend = res.send;

        res.send = function (data) {
            // Parse response data
            let responseData;
            try {
                responseData = typeof data === 'string' ? JSON.parse(data) : data;
            } catch (e) {
                responseData = data;
            }

            // Log if successful deletion
            if (res.statusCode === 200 && responseData && responseData.success) {
                const entityId = req.params.id || 'unknown';

                createAuditLog({
                    userId: req.user?.userId || 'system',
                    userName: req.user?.name || 'System',
                    action: 'DELETE',
                    entityType,
                    entityId,
                    oldData: req.originalData, // Set this before calling delete
                    ipAddress: req.ip || req.connection.remoteAddress,
                    userAgent: req.get('user-agent')
                });
            }

            // Call original send
            originalSend.call(this, data);
        };

        next();
    };
}

/**
 * Log login attempts
 */
async function logLogin(userId, userName, success, ipAddress, userAgent, errorMessage = null) {
    await createAuditLog({
        userId: userId || 'unknown',
        userName: userName || 'Unknown User',
        action: 'LOGIN',
        entityType: 'SYSTEM',
        entityId: userId,
        ipAddress,
        userAgent,
        success,
        errorMessage
    });
}

/**
 * Log logout
 */
async function logLogout(userId, userName, ipAddress, userAgent) {
    await createAuditLog({
        userId,
        userName,
        action: 'LOGOUT',
        entityType: 'SYSTEM',
        entityId: userId,
        ipAddress,
        userAgent
    });
}

/**
 * Log status change
 */
async function logStatusChange(userId, userName, entityType, entityId, oldStatus, newStatus, ipAddress, userAgent) {
    await createAuditLog({
        userId,
        userName,
        action: 'STATUS_CHANGE',
        entityType,
        entityId,
        oldData: { status: oldStatus },
        newData: { status: newStatus },
        ipAddress,
        userAgent
    });
}

/**
 * Log bulk upload
 */
async function logBulkUpload(userId, userName, entityType, count, ipAddress, userAgent) {
    await createAuditLog({
        userId,
        userName,
        action: 'BULK_UPLOAD',
        entityType,
        entityId: `bulk-${count}`,
        newData: { count },
        ipAddress,
        userAgent
    });
}

/**
 * Log export
 */
async function logExport(userId, userName, entityType, format, ipAddress, userAgent) {
    await createAuditLog({
        userId,
        userName,
        action: 'EXPORT',
        entityType,
        entityId: `export-${format}`,
        newData: { format },
        ipAddress,
        userAgent
    });
}

module.exports = {
    createAuditLog,
    logCreate,
    logUpdate,
    logDelete,
    logLogin,
    logLogout,
    logStatusChange,
    logBulkUpload,
    logExport
};
