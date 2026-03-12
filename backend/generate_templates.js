const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

async function createTemplates() {
    const outputDir = path.join(__dirname, '..'); // project root

    // 1. MATERIAL MASTER TEMPLATE
    const productData = {
        name: 'Template_Material_Master.xlsx',
        headers: [
            'ProductCode', 'Product Name', 'ProductShortName', 'DistributionChannel', 
            'Specie', 'Weight Packing', 'Weight', 'Packing', 'MRP', 'GST%', 'HSNCODE', 
            'COUNTRY OF ORIGIN', 'Shelf Life in days', 'REMARKS', 'YC70', 'Processing Charges'
        ],
        sample: [
            '2004643', 'BREADED FISH FINGERS 200G', 'BREADED FISH FINGERS', 'RETAIL/HD', 
            'BREADED', '200G PKTS', '0.200', 'PKTS', '220', '5%', '16042000', 
            'INDIA', '365', '', '', ''
        ]
    };

    // 2. DISTRIBUTOR PRICE TEMPLATE
    const priceData = {
        name: 'Template_Distributor_Price.xlsx',
        headers: [
            'Code', 'Name', 'Material', 'Material Number', 'MRP', 'in Kg', 
            '% GST', 'Retailer Margin On MRP', 'Dist Margin On Cost', 
            'Dist Margin On MRP', 'Billing Rate'
        ],
        sample: [
            'D001', 'Distributor A', '2004643', 'BREADED FISH FINGERS 200G', '220', '0.2', 
            '5', '10', '5', '5', '180'
        ]
    };

    // 3. CUSTOMER / OD MASTER TEMPLATE
    const customerData = {
        name: 'Template_Customer_OD_Master.xlsx',
        headers: [
            'CustomerID', 'CustomerName', 'Dist', 'SalesManager', 'Class', 
            'EmpResponsible', 'CreditDays', 'CreditLimit', 'SecurityChq', 
            'DistChannel', 'OsAmt', 'OdAmt', 'Diff', '0 to 7', '7 to 15', 
            '15 to 30', '30 to 45', '45 to 90', '90 to 120', '120 to 150', 
            '150 to 180', '>180'
        ],
        sample: [
            'CUST001', 'Customer XYZ', 'Mumbai', 'Sales Manager A', 'A+', 
            'Employee 1', '30', '500000', 'Yes', 'Retail', '150000', '25000', 
            '0', '10000', '5000', '5000', '5000', '0', '0', '0', '0', '0'
        ]
    };

    const templates = [productData, priceData, customerData];

    for (const t of templates) {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Sheet1');
        
        // Style headers
        const headerRow = worksheet.addRow(t.headers);
        headerRow.eachCell((cell) => {
            cell.font = { bold: true };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFE0E0E0' }
            };
        });

        // Add sample row
        worksheet.addRow(t.sample);

        // Auto-fit columns
        worksheet.columns.forEach((column, i) => {
            let maxLength = 0;
            column.eachCell({ includeEmpty: true }, (cell) => {
                const columnLength = cell.value ? cell.value.toString().length : 10;
                if (columnLength > maxLength) {
                    maxLength = columnLength;
                }
            });
            column.width = maxLength < 12 ? 12 : maxLength + 2;
        });

        const fullPath = path.join(outputDir, t.name);
        await workbook.xlsx.writeFile(fullPath);
        console.log(`✅ Created ${t.name}`);
    }
}

createTemplates().catch(console.error);
