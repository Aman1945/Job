module.exports = {
    apps: [
        // ==================== PRODUCTION ====================
        {
            name: 'nexus-production',
            script: './server.js',
            cwd: '/root/Job/backend',
            instances: 2,
            exec_mode: 'cluster',
            watch: false,
            env: {
                NODE_ENV: 'production',
                PORT: 3000
            },
            error_file: '/root/logs/prod-err.log',
            out_file: '/root/logs/prod-out.log',
            log_date_format: 'YYYY-MM-DD HH:mm:ss',
            restart_delay: 3000,
            max_restarts: 10,
        },
        // ==================== UAT (Testing) ====================
        {
            name: 'nexus-uat',
            script: './server.js',
            cwd: '/root/Job-uat/backend',
            instances: 1,
            exec_mode: 'fork',
            watch: false,
            env: {
                NODE_ENV: 'uat',
                PORT: 3001          // Different port to avoid conflict
            },
            error_file: '/root/logs/uat-err.log',
            out_file: '/root/logs/uat-out.log',
            log_date_format: 'YYYY-MM-DD HH:mm:ss',
            restart_delay: 3000,
            max_restarts: 10,
        }
    ]
};
