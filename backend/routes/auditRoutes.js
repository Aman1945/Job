/**
 * NexusOMS - Audit Log Routes
 * ISO 27001:2022 Control A.8.16 - Monitoring Activities
 * Admin-only access to audit logs
 */

const express = require('express');
const router = express.Router();
const AuditLog = require('../models/AuditLog');
const { verifyToken } = require('../middleware/auth');
const { allowRoles } = require('../middleware/rbac');

module.exports = (app) => {
    // Get audit logs with filters and pagination
    app.get('/api/audit/logs', verifyToken, allowRoles(['Admin']), async (req, res) => {
        try {
            const {
                page = 1,
                limit = 50,
                userId,
                action,
                entityType,
                entityId,
                fromDate,
                toDate,
                success
            } = req.query;

            // Build filter
            const filter = {};

            if (userId) filter.userId = userId;
            if (action) filter.action = action;
            if (entityType) filter.entityType = entityType;
            if (entityId) filter.entityId = entityId;
            if (success !== undefined) filter.success = success === 'true';

            if (fromDate || toDate) {
                filter.timestamp = {};
                if (fromDate) filter.timestamp.$gte = new Date(fromDate);
                if (toDate) filter.timestamp.$lte = new Date(toDate);
            }

            // Calculate pagination
            const skip = (parseInt(page) - 1) * parseInt(limit);

            // Get logs
            const logs = await AuditLog.find(filter)
                .sort({ timestamp: -1 })
                .skip(skip)
                .limit(parseInt(limit))
                .lean();

            // Get total count
            const total = await AuditLog.countDocuments(filter);

            res.json({
                success: true,
                data: {
                    logs,
                    pagination: {
                        page: parseInt(page),
                        limit: parseInt(limit),
                        total,
                        pages: Math.ceil(total / parseInt(limit))
                    }
                }
            });

        } catch (error) {
            console.error('Audit logs error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching audit logs'
            });
        }
    });

    // Get audit log statistics
    app.get('/api/audit/stats', verifyToken, allowRoles(['Admin']), async (req, res) => {
        try {
            const { fromDate, toDate } = req.query;

            const filter = {};
            if (fromDate || toDate) {
                filter.timestamp = {};
                if (fromDate) filter.timestamp.$gte = new Date(fromDate);
                if (toDate) filter.timestamp.$lte = new Date(toDate);
            }

            // Get action breakdown
            const actionStats = await AuditLog.aggregate([
                { $match: filter },
                { $group: { _id: '$action', count: { $sum: 1 } } },
                { $sort: { count: -1 } }
            ]);

            // Get entity type breakdown
            const entityStats = await AuditLog.aggregate([
                { $match: filter },
                { $group: { _id: '$entityType', count: { $sum: 1 } } },
                { $sort: { count: -1 } }
            ]);

            // Get top users
            const userStats = await AuditLog.aggregate([
                { $match: filter },
                { $group: { _id: { userId: '$userId', userName: '$userName' }, count: { $sum: 1 } } },
                { $sort: { count: -1 } },
                { $limit: 10 }
            ]);

            // Get success/failure rate
            const successCount = await AuditLog.countDocuments({ ...filter, success: true });
            const failureCount = await AuditLog.countDocuments({ ...filter, success: false });

            res.json({
                success: true,
                data: {
                    actions: actionStats.map(s => ({ action: s._id, count: s.count })),
                    entities: entityStats.map(s => ({ entityType: s._id, count: s.count })),
                    topUsers: userStats.map(s => ({
                        userId: s._id.userId,
                        userName: s._id.userName,
                        count: s.count
                    })),
                    successRate: {
                        success: successCount,
                        failure: failureCount,
                        total: successCount + failureCount,
                        percentage: ((successCount / (successCount + failureCount)) * 100).toFixed(2)
                    }
                }
            });

        } catch (error) {
            console.error('Audit stats error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching audit statistics'
            });
        }
    });

    // Export audit logs to CSV
    app.get('/api/audit/logs/export', verifyToken, allowRoles(['Admin']), async (req, res) => {
        try {
            const { fromDate, toDate, userId, action, entityType } = req.query;

            // Build filter
            const filter = {};
            if (userId) filter.userId = userId;
            if (action) filter.action = action;
            if (entityType) filter.entityType = entityType;

            if (fromDate || toDate) {
                filter.timestamp = {};
                if (fromDate) filter.timestamp.$gte = new Date(fromDate);
                if (toDate) filter.timestamp.$lte = new Date(toDate);
            }

            // Get logs (limit to 10000 for export)
            const logs = await AuditLog.find(filter)
                .sort({ timestamp: -1 })
                .limit(10000)
                .lean();

            // Generate CSV
            const csvHeader = 'Timestamp,User ID,User Name,Action,Entity Type,Entity ID,Success,IP Address\n';
            const csvRows = logs.map(log => {
                return `${log.timestamp.toISOString()},${log.userId},"${log.userName}",${log.action},${log.entityType || ''},${log.entityId || ''},${log.success},${log.ipAddress || ''}`;
            }).join('\n');

            const csv = csvHeader + csvRows;

            res.setHeader('Content-Type', 'text/csv');
            res.setHeader('Content-Disposition', `attachment; filename="audit_logs_${Date.now()}.csv"`);
            res.send(csv);

        } catch (error) {
            console.error('Audit export error:', error);
            res.status(500).json({
                success: false,
                message: 'Error exporting audit logs'
            });
        }
    });
};
