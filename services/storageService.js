/**
 * NexusOMS - Cloudflare R2 Storage Service
 * File upload service using Cloudflare R2 (S3-compatible)
 */

const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');

// Initialize R2 client
let s3Client;
let isConfigured = false;

if (process.env.R2_ACCOUNT_ID && process.env.R2_ACCESS_KEY_ID && process.env.R2_SECRET_ACCESS_KEY) {
    s3Client = new S3Client({
        region: 'auto',
        endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
        credentials: {
            accessKeyId: process.env.R2_ACCESS_KEY_ID,
            secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
        }
    });
    isConfigured = true;
    console.log('✅ Cloudflare R2 storage initialized');
} else {
    console.warn('⚠️  Cloudflare R2 not configured. Files will be stored as base64 in database.');
}

/**
 * Upload file to Cloudflare R2
 * @param {string} base64Data - Base64 encoded file data
 * @param {string} fileName - Original file name
 * @param {string} folder - Folder path (e.g., 'pod', 'invoices', 'procurement')
 * @returns {Promise<string>} Public URL of uploaded file
 */
async function uploadFile(base64Data, fileName, folder = 'uploads') {
    // If R2 not configured, return base64 (fallback)
    if (!isConfigured) {
        console.warn('⚠️  R2 not configured, storing as base64');
        return base64Data; // Return base64 as-is
    }

    try {
        // Remove data URL prefix if present
        const base64Content = base64Data.includes(',')
            ? base64Data.split(',')[1]
            : base64Data;

        // Convert base64 to buffer
        const buffer = Buffer.from(base64Content, 'base64');

        // Generate unique key
        const timestamp = Date.now();
        const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
        const key = `${folder}/${timestamp}-${sanitizedFileName}`;

        // Determine content type
        const contentType = getContentType(fileName);

        // Upload to R2
        const command = new PutObjectCommand({
            Bucket: process.env.R2_BUCKET_NAME || 'nexusoms',
            Key: key,
            Body: buffer,
            ContentType: contentType,
        });

        await s3Client.send(command);

        // Generate public URL
        const publicUrl = process.env.R2_PUBLIC_URL
            ? `${process.env.R2_PUBLIC_URL}/${key}`
            : `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${process.env.R2_BUCKET_NAME}/${key}`;

        console.log(`✅ File uploaded to R2: ${key}`);
        return publicUrl;

    } catch (error) {
        console.error('R2 upload error:', error.message);

        // Fallback to base64 if upload fails
        console.warn('⚠️  R2 upload failed, falling back to base64 storage');
        return base64Data;
    }
}

/**
 * Delete file from Cloudflare R2
 * @param {string} fileUrl - Public URL or key of file to delete
 * @returns {Promise<boolean>} Success status
 */
async function deleteFile(fileUrl) {
    if (!isConfigured) {
        console.warn('⚠️  R2 not configured, skipping delete');
        return true;
    }

    try {
        // Extract key from URL
        const key = fileUrl.includes('/')
            ? fileUrl.split('/').slice(-2).join('/') // Get last two segments (folder/filename)
            : fileUrl;

        const command = new DeleteObjectCommand({
            Bucket: process.env.R2_BUCKET_NAME || 'nexusoms',
            Key: key,
        });

        await s3Client.send(command);
        console.log(`✅ File deleted from R2: ${key}`);
        return true;

    } catch (error) {
        console.error('R2 delete error:', error.message);
        return false;
    }
}

/**
 * Get content type from file name
 * @param {string} fileName - File name
 * @returns {string} MIME type
 */
function getContentType(fileName) {
    const ext = fileName.split('.').pop().toLowerCase();

    const mimeTypes = {
        'pdf': 'application/pdf',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
        'doc': 'application/msword',
        'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'xls': 'application/vnd.ms-excel',
        'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'txt': 'text/plain',
        'csv': 'text/csv',
    };

    return mimeTypes[ext] || 'application/octet-stream';
}

/**
 * Check if R2 is configured
 * @returns {boolean} Configuration status
 */
function isR2Configured() {
    return isConfigured;
}

module.exports = {
    uploadFile,
    deleteFile,
    isR2Configured
};
