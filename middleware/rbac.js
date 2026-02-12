/**
 * Role-Based Access Control (RBAC) Middleware
 * Restricts route access based on user roles
 */

/**
 * Allow only specific roles to access a route
 * @param {Array<string>} allowedRoles - Array of role names
 * @returns {Function} Express middleware function
 */
const allowRoles = (allowedRoles) => {
    return (req, res, next) => {
        // Check if user is authenticated
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required.'
            });
        }

        // Check if user's role is in the allowed list
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: `Access denied. This action requires one of the following roles: ${allowedRoles.join(', ')}`,
                requiredRoles: allowedRoles,
                userRole: req.user.role
            });
        }

        next();
    };
};

/**
 * Require user to be an approver
 */
const requireApprover = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            success: false,
            message: 'Authentication required.'
        });
    }

    if (!req.user.isApprover) {
        return res.status(403).json({
            success: false,
            message: 'Access denied. Approver privileges required.'
        });
    }

    next();
};

/**
 * Check if user owns the resource or is an admin
 * @param {Function} getOwnerId - Function to extract owner ID from request
 */
const requireOwnerOrAdmin = (getOwnerId) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required.'
            });
        }

        const ownerId = getOwnerId(req);

        if (req.user.role === 'Admin' || req.user.userId === ownerId) {
            return next();
        }

        return res.status(403).json({
            success: false,
            message: 'Access denied. You can only access your own resources.'
        });
    };
};

module.exports = {
    allowRoles,
    requireApprover,
    requireOwnerOrAdmin
};
