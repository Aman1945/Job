/**
 * NexusOMS - DigitalOcean Spaces Storage Service
 * File upload service using DigitalOcean Spaces (S3-compatible)
 */

const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');

// Initialize DigitalOcean Spaces client
let s3Client;
let isConfigured = false;

if (process.env.DO_SPACES_KEY && process.env.DO_SPACES_SECRET && process.env.DO_SPACES_REGION) {
    s3Client = new S3Client({
        region: process.env.DO_SPACES_REGION,
        endpoint: `https://${process.env.DO_SPACES_REGION}.digitaloceanspaces.com`,
        credentials: {
            accessKeyId: process.env.DO_SPACES_KEY,
            secretAccessKey: process.env.DO_SPACES_SECRET,
        },
        forcePathStyle: false, // Required for DO Spaces
    });
    isConfigured = true;
    console.log('✅ DigitalOcean Spaces storage initialized');
} else {
    console.warn('⚠️  DigitalOcean Spaces not configured. Files will be stored as base64 in database.');
}

/**
 * Upload file to DigitalOcean Spaces
 * @param {string} base64Data - Base64 encoded file data
 * @param {string} fileName - Original file name
 * @param {string} folder - Folder path (e.g., 'pod', 'invoices', 'procurement')
 * @returns {Promise<string>} Public URL of uploaded file
 */
async function uploadFile(base64Data, fileName, folder = 'uploads') {
    // If Spaces not configured, return base64 (fallback)
    if (!isConfigured) {
        console.warn('⚠️  DO Spaces not configured, storing as base64');
        return base64Data;
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

        // Upload to DO Spaces
        const command = new PutObjectCommand({
            Bucket: process.env.DO_SPACES_BUCKET,
            Key: key,
            Body: buffer,
            ContentType: contentType,
            ACL: 'public-read', // Make files publicly accessible via CDN
        });

        await s3Client.send(command);

        // Generate public URL (CDN URL if available, otherwise direct URL)
        const bucket = process.env.DO_SPACES_BUCKET;
        const region = process.env.DO_SPACES_REGION;
        const publicUrl = process.env.DO_SPACES_CDN_URL
            ? `${process.env.DO_SPACES_CDN_URL}/${key}`
            : `https://${bucket}.${region}.digitaloceanspaces.com/${key}`;

        console.log(`✅ File uploaded to DO Spaces: ${key}`);
        return publicUrl;

    } catch (error) {
        console.error('DO Spaces upload error:', error.message);
        // Fallback to base64 if upload fails
        console.warn('⚠️  Spaces upload failed, falling back to base64 storage');
        return base64Data;
    }
}

/**
 * Delete file from DigitalOcean Spaces
 * @param {string} fileUrl - Public URL or key of file to delete
 * @returns {Promise<boolean>} Success status
 */
async function deleteFile(fileUrl) {
    if (!isConfigured) {
        console.warn('⚠️  DO Spaces not configured, skipping delete');
        return true;
    }

    try {
        // Extract key from URL
        const urlParts = fileUrl.split('/');
        // Key is everything after the bucket domain (last segments)
        const key = urlParts.slice(-2).join('/'); // folder/filename

        const command = new DeleteObjectCommand({
            Bucket: process.env.DO_SPACES_BUCKET,
            Key: key,
        });

        await s3Client.send(command);
        console.log(`✅ File deleted from DO Spaces: ${key}`);
        return true;

    } catch (error) {
        console.error('DO Spaces delete error:', error.message);
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
 * Check if Spaces is configured
 * @returns {boolean} Configuration status
 */
function isSpacesConfigured() {
    return isConfigured;
}

module.exports = {
    uploadFile,
    deleteFile,
    isSpacesConfigured,
};
