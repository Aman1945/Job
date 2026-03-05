/**
 * NexusOMS - Audit Log Routes
 * ISO 27001:2022 Control A.8.16 - Monitoring Activities
 * Admin-only access to audit logs
 */

const express = require('express');
const router = express.Router();
const AuditLog = require('../models/AuditLog');
const User = require('../models/User'); // Added User model
const { verifyToken } = require('../middleware/auth');
const { allowRoles } = require('../middleware/rbac');

module.exports = (app) => {
    // Get audit logs for a specific user (Accessible by Admin, NSM, RSM)
    app.get('/api/audit/logs/user/:userId', verifyToken, allowRoles(['Admin', 'NSM', 'RSM']), async (req, res) => {
        try {
            const { userId } = req.params;
            const { limit = 100 } = req.query;

            const logs = await AuditLog.find({ userId })
                .sort({ timestamp: -1 })
                .limit(parseInt(limit))
                .lean();

            res.json({
                success: true,
                data: logs
            });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    });

    // Get audit logs with filters and pagination
    // Accessible by Admin (all logs), NSM (all), RSM/ASM (their team only), Sales/Sales Executive (own only)
    app.get('/api/audit/logs', verifyToken, allowRoles(['Admin', 'NSM', 'RSM', 'ASM', 'Sales', 'Sales Executive']), async (req, res) => {
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

            // --- Hierarchy-aware filtering ---
            // RSM and ASM can only see logs of their own team members
            const requestingRole = req.user.role;
            if (requestingRole === 'RSM' || requestingRole === 'ASM') {
                // Find all subordinate users under this manager
                const subordinates = await User.find({ managerId: req.user.userId }).select('id').lean();
                const allowedIds = [req.user.userId, ...subordinates.map(u => u.id)];
                filter.userId = { $in: allowedIds };
            } else if (requestingRole === 'Sales' || requestingRole === 'Sales Executive') {
                // Sales executives can only see their own logs
                filter.userId = req.user.userId;
            }

            // Apply explicit userId filter (must still be within hierarchy)
            if (userId) {
                const requestedIds = userId.includes(',')
                    ? userId.split(',').map(id => id.trim())
                    : [userId];

                if (filter.userId) {
                    // Intersect with hierarchy-allowed IDs
                    const hierarchyAllowed = filter.userId.$in;
                    filter.userId = { $in: requestedIds.filter(id => hierarchyAllowed.includes(id)) };
                } else {
                    filter.userId = requestedIds.length === 1 ? requestedIds[0] : { $in: requestedIds };
                }
            }

            // Role-based user filter (Admin/NSM only, since RSM/ASM already restricted)
            if (req.query.role && (requestingRole === 'Admin' || requestingRole === 'NSM')) {
                const usersWithRole = await User.find({ role: req.query.role }).select('id').lean();
                const userIds = usersWithRole.map(u => u.id);
                if (filter.userId && filter.userId.$in) {
                    filter.userId = { $in: filter.userId.$in.filter(id => userIds.includes(id)) };
                } else if (filter.userId && typeof filter.userId === 'string') {
                    filter.userId = userIds.includes(filter.userId) ? filter.userId : { $in: [] };
                } else {
                    filter.userId = { $in: userIds };
                }
            }

            if (action) filter.action = action;
            if (entityType) filter.entityType = entityType;
            if (entityId) filter.entityId = entityId;
            if (success !== undefined) filter.success = success === 'true';

            if (fromDate || toDate) {
                filter.timestamp = {};
                if (fromDate) filter.timestamp.$gte = new Date(fromDate);
                if (toDate) {
                    const end = new Date(toDate);
                    end.setHours(23, 59, 59, 999);
                    filter.timestamp.$lte = end;
                }
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
                if (toDate) {
                    const end = new Date(toDate);
                    end.setHours(23, 59, 59, 999);
                    filter.timestamp.$lte = end;
                }
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
