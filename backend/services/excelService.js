/**
 * NexusOMS - Excel Service
 * Handles Excel template generation and parsing for bulk order upload
 */

const ExcelJS = require('exceljs');

/**
 * Generate Excel template for bulk order upload
 * @returns {Promise<Buffer>} Excel file buffer
 */
async function generateBulkOrderTemplate() {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Bulk Orders');

    // Define columns
    worksheet.columns = [
        { header: 'Customer ID', key: 'customerId', width: 15 },
        { header: 'SKU Code', key: 'skuCode', width: 15 },
        { header: 'Quantity', key: 'quantity', width: 12 },
        { header: 'Applied Rate (Optional)', key: 'appliedRate', width: 20 },
        { header: 'Remarks (Optional)', key: 'remarks', width: 30 }
    ];

    // Style header row
    worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    worksheet.getRow(1).fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF10B981' }
    };
    worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' };
    worksheet.getRow(1).height = 25;

    // Add sample data
    worksheet.addRow({
        customerId: 'CUST-001',
        skuCode: 'SKU-001',
        quantity: 10,
        appliedRate: 150.00,
        remarks: 'Sample order'
    });

    worksheet.addRow({
        customerId: 'CUST-002',
        skuCode: 'SKU-002',
        quantity: 25,
        appliedRate: '',
        remarks: ''
    });

    // Add instructions sheet
    const instructionsSheet = workbook.addWorksheet('Instructions');
    instructionsSheet.columns = [
        { header: 'Field', key: 'field', width: 25 },
        { header: 'Description', key: 'description', width: 60 },
        { header: 'Required', key: 'required', width: 12 }
    ];

    instructionsSheet.getRow(1).font = { bold: true };
    instructionsSheet.getRow(1).fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFE5E7EB' }
    };

    const instructions = [
        { field: 'Customer ID', description: 'The unique customer ID (e.g., CUST-001)', required: 'Yes' },
        { field: 'SKU Code', description: 'The product SKU code (e.g., SKU-001)', required: 'Yes' },
        { field: 'Quantity', description: 'Order quantity (must be greater than 0)', required: 'Yes' },
        { field: 'Applied Rate', description: 'Custom price per unit (leave empty to use base rate)', required: 'No' },
        { field: 'Remarks', description: 'Any additional notes for this order', required: 'No' }
    ];

    instructions.forEach(inst => instructionsSheet.addRow(inst));

    // Add notes
    instructionsSheet.addRow({});
    instructionsSheet.addRow({ field: 'IMPORTANT NOTES:', description: '', required: '' });
    instructionsSheet.addRow({ field: '', description: '1. Do not modify the header row', required: '' });
    instructionsSheet.addRow({ field: '', description: '2. Customer ID and SKU Code must exist in the system', required: '' });
    instructionsSheet.addRow({ field: '', description: '3. Quantity must be a positive number', required: '' });
    instructionsSheet.addRow({ field: '', description: '4. Delete sample rows before uploading', required: '' });
    instructionsSheet.addRow({ field: '', description: '5. Maximum 100 orders per upload', required: '' });

    // Generate buffer
    const buffer = await workbook.xlsx.writeBuffer();
    return buffer;
}

/**
 * Parse uploaded Excel file and extract order data
 * @param {Buffer} fileBuffer - Excel file buffer
 * @returns {Promise<Array>} Array of order objects
 */
async function parseBulkOrderExcel(fileBuffer) {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(fileBuffer);

    const worksheet = workbook.getWorksheet('Bulk Orders');
    if (!worksheet) {
        throw new Error('Invalid template: "Bulk Orders" sheet not found');
    }

    const orders = [];
    const errors = [];

    // Skip header row, start from row 2
    worksheet.eachRow((row, rowNumber) => {
        if (rowNumber === 1) return; // Skip header

        const customerId = row.getCell(1).value;
        const skuCode = row.getCell(2).value;
        const quantity = row.getCell(3).value;
        const appliedRate = row.getCell(4).value;
        const remarks = row.getCell(5).value;

        // Skip empty rows
        if (!customerId && !skuCode && !quantity) return;

        // Validate required fields
        if (!customerId) {
            errors.push({ row: rowNumber, field: 'Customer ID', message: 'Customer ID is required' });
            return;
        }

        if (!skuCode) {
            errors.push({ row: rowNumber, field: 'SKU Code', message: 'SKU Code is required' });
            return;
        }

        if (!quantity || isNaN(quantity) || quantity <= 0) {
            errors.push({ row: rowNumber, field: 'Quantity', message: 'Quantity must be a positive number' });
            return;
        }

        orders.push({
            customerId: String(customerId).trim(),
            skuCode: String(skuCode).trim(),
            quantity: parseInt(quantity),
            appliedRate: appliedRate ? parseFloat(appliedRate) : null,
            remarks: remarks ? String(remarks).trim() : '',
            rowNumber
        });
    });

    if (errors.length > 0) {
        throw new Error(JSON.stringify({ type: 'VALIDATION_ERROR', errors }));
    }

    if (orders.length === 0) {
        throw new Error('No valid orders found in the Excel file');
    }

    if (orders.length > 100) {
        throw new Error('Maximum 100 orders allowed per upload. Please split into multiple files.');
    }

    return orders;
}

module.exports = {
    generateBulkOrderTemplate,
    parseBulkOrderExcel
};
