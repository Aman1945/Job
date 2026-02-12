/**
 * NexusOMS - GDPR Compliance Routes
 * ISO 27001:2022 Control A.8.10 - Information Deletion
 * Right to be Forgotten & Data Portability
 */

const express = require('express');
const crypto = require('crypto');
const { verifyToken } = require('../middleware/auth');
const { allowRoles } = require('../middleware/rbac');
const { createAuditLog } = require('../middleware/auditLogger');

const User = require('../models/User');
const Customer = require('../models/Customer');
const Order = require('../models/Order');
const AuditLog = require('../models/AuditLog');

module.exports = (app) => {

    // ==================== RIGHT TO BE FORGOTTEN ====================

    /**
     * Anonymize user data (GDPR Article 17)
     * Keeps audit trail but removes PII
     */
    app.post('/api/gdpr/forget/:userId', verifyToken, allowRoles(['Admin']), async (req, res) => {
        try {
            const { userId } = req.params;
            const { reason } = req.body;

            // Find user
            const user = await User.findOne({ id: userId });
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Generate anonymized hash
            const hash = crypto.createHash('sha256').update(userId + Date.now()).digest('hex').substring(0, 8);
            const anonymizedName = `Deleted User ${hash}`;
            const anonymizedEmail = `deleted_${hash}@anonymized.local`;

            // Store original data for audit
            const originalData = {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role
            };

            // Anonymize user
            user.name = anonymizedName;
            user.email = anonymizedEmail;
            user.password = null; // Remove password
            user.status = 'Deleted';
            user.deletedAt = new Date();
            user.deletionReason = reason || 'User requested deletion';

            await user.save();

            // Anonymize related customer data (if user is a customer)
            const customer = await Customer.findOne({ email: originalData.email });
            if (customer) {
                customer.name = anonymizedName;
                customer.email = anonymizedEmail;
                customer.phone = 'DELETED';
                customer.address = 'DELETED';
                await customer.save();
            }

            // Keep orders for audit but mark as deleted user
            await Order.updateMany(
                { salespersonId: userId },
                { $set: { salespersonName: anonymizedName } }
            );

            // Create audit log
            await createAuditLog({
                userId: req.user.userId,
                userName: req.user.name,
                action: 'DELETE',
                entityType: 'USER',
                entityId: userId,
                oldData: originalData,
                newData: { anonymized: true, reason },
                ipAddress: req.ip || req.connection.remoteAddress,
                userAgent: req.get('user-agent')
            });

            console.log(`🗑️  GDPR: User ${userId} anonymized by ${req.user.name}`);

            res.json({
                success: true,
                message: 'User data anonymized successfully',
                data: {
                    userId,
                    anonymizedName,
                    deletedAt: user.deletedAt,
                    reason: user.deletionReason
                }
            });

        } catch (error) {
            console.error('GDPR forget error:', error);
            res.status(500).json({
                success: false,
                message: 'Error anonymizing user data',
                error: error.message
            });
        }
    });

    // ==================== DATA PORTABILITY ====================

    /**
     * Export all user data (GDPR Article 20)
     * Returns comprehensive JSON of all user-related data
     */
    app.get('/api/gdpr/export/:userId', verifyToken, allowRoles(['Admin']), async (req, res) => {
        try {
            const { userId } = req.params;

            // Find user
            const user = await User.findOne({ id: userId }).lean();
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Gather all user data
            const userData = {
                profile: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: user.role,
                    status: user.status,
                    isApprover: user.isApprover,
                    createdAt: user.createdAt,
                    lastLogin: user.lastLogin
                },
                orders: [],
                customers: [],
                auditLogs: []
            };

            // Get user's orders
            const orders = await Order.find({ salespersonId: userId })
                .select('-__v')
                .lean();
            userData.orders = orders;

            // Get customers created by user (if applicable)
            const customers = await Customer.find({ createdBy: userId })
                .select('-__v')
                .lean();
            userData.customers = customers;

            // Get user's audit logs (last 1000 entries)
            const auditLogs = await AuditLog.find({ userId })
                .sort({ timestamp: -1 })
                .limit(1000)
                .select('-__v')
                .lean();
            userData.auditLogs = auditLogs;

            // Create audit log for export
            await createAuditLog({
                userId: req.user.userId,
                userName: req.user.name,
                action: 'EXPORT',
                entityType: 'USER',
                entityId: userId,
                newData: { format: 'JSON', recordCount: orders.length + customers.length + auditLogs.length },
                ipAddress: req.ip || req.connection.remoteAddress,
                userAgent: req.get('user-agent')
            });

            console.log(`📤 GDPR: User ${userId} data exported by ${req.user.name}`);

            // Set headers for download
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Content-Disposition', `attachment; filename="user_data_${userId}_${Date.now()}.json"`);

            res.json({
                success: true,
                exportDate: new Date().toISOString(),
                userId,
                data: userData,
                summary: {
                    orders: orders.length,
                    customers: customers.length,
                    auditLogs: auditLogs.length
                }
            });

        } catch (error) {
            console.error('GDPR export error:', error);
            res.status(500).json({
                success: false,
                message: 'Error exporting user data',
                error: error.message
            });
        }
    });

    // ==================== DATA RETENTION POLICY ====================

    /**
     * Get data retention policy information
     */
    app.get('/api/gdpr/retention-policy', verifyToken, async (req, res) => {
        try {
            const policy = {
                dataTypes: [
                    {
                        type: 'User Accounts',
                        retention: 'Active accounts: Indefinite. Deleted accounts: Anonymized immediately.',
                        purpose: 'System access and authentication'
                    },
                    {
                        type: 'Orders',
                        retention: '7 years (as per tax regulations)',
                        purpose: 'Financial records and audit trail'
                    },
                    {
                        type: 'Customer Data',
                        retention: 'Active customers: Indefinite. Inactive: 3 years after last transaction.',
                        purpose: 'Business relationship management'
                    },
                    {
                        type: 'Audit Logs',
                        retention: '2 years (ISO 27001 compliance)',
                        purpose: 'Security monitoring and compliance'
                    },
                    {
                        type: 'Performance Records',
                        retention: '5 years (HR regulations)',
                        purpose: 'Employee performance management'
                    }
                ],
                rights: [
                    'Right to Access (Article 15)',
                    'Right to Rectification (Article 16)',
                    'Right to Erasure (Article 17)',
                    'Right to Data Portability (Article 20)',
                    'Right to Object (Article 21)'
                ],
                contact: {
                    dpo: 'Data Protection Officer',
                    email: 'dpo@nexusoms.com',
                    phone: '+91-XXXXXXXXXX'
                }
            };

            res.json({
                success: true,
                policy
            });

        } catch (error) {
            console.error('Retention policy error:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching retention policy'
            });
        }
    });

    // ==================== CONSENT MANAGEMENT ====================

    /**
     * Record user consent
     */
    app.post('/api/gdpr/consent', verifyToken, async (req, res) => {
        try {
            const { userId, consentType, granted } = req.body;

            // Find user
            const user = await User.findOne({ id: userId });
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Initialize consents array if not exists
            if (!user.consents) {
                user.consents = [];
            }

            // Add consent record
            user.consents.push({
                type: consentType,
                granted,
                timestamp: new Date(),
                ipAddress: req.ip || req.connection.remoteAddress
            });

            await user.save();

            // Create audit log
            await createAuditLog({
                userId: req.user.userId,
                userName: req.user.name,
                action: 'UPDATE',
                entityType: 'USER',
                entityId: userId,
                newData: { consentType, granted },
                ipAddress: req.ip || req.connection.remoteAddress,
                userAgent: req.get('user-agent')
            });

            res.json({
                success: true,
                message: 'Consent recorded successfully'
            });

        } catch (error) {
            console.error('Consent error:', error);
            res.status(500).json({
                success: false,
                message: 'Error recording consent'
            });
        }
    });
};
