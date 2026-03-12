const ExcelJS = require('exceljs');
const fs = require('fs');

async function run() {
    const textData = `ProductCode	Product Name	ProductShortName	DistributionChannel	Specie	Weight Packing	Weight 	Packing	MRP	GST%	HSNCODE	COUNTRY OF ORIGIN	Shelf Life in days	REMARKS	YC70	Processing charges
2004643	BREADED FISH FINGERS 200G	BREADED FISH FINGERS 200G	RETAIL/HD	BREADED	 200G PKTS 	  0.200 	PKTS	220	5%	16042000	INDIA	365			
2006332	ORANGE TOBIKO JAPAN 30 GM	ORANGE TOBIKO JAPAN 30 GM	RETAIL/HD	FISH EGG		  0.030 	PKTS	550	5%	16043200	JAPAN	365			
2006457	LAMB CHOPS AUS 200GM	LAMB CHOPS AUS 200GM	RETAIL/HD-PRD	Lamb		  0.200 	PKTS	1650	5%	2042200	Australia	365		  10 	  18 `;

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Sheet1');
    textData.split('\n').forEach(line => {
        worksheet.addRow(line.split('\t'));
    });
    await workbook.xlsx.writeFile('test_data.xlsx');

    const wb2 = new ExcelJS.Workbook();
    await wb2.xlsx.readFile('test_data.xlsx');
    const ws2 = wb2.getWorksheet(1);
    const headerRow = ws2.getRow(1);
    const colMap = {};

    headerRow.eachCell((cell, colNumber) => {
        const raw = (cell.value?.toString() ?? '').trim();
        const header = raw.toLowerCase().replace(/\s+/g, ' ');
        if (!header) return;
        if (['productcode', 'product code', 'sku', 'sku code', 'code'].includes(header)) colMap.skuCode = colNumber;
        else if (['product name', 'productname', 'name'].includes(header)) colMap.name = colNumber;
        else if (['productshortname', 'product short name', 'short name', 'shortname'].includes(header)) colMap.productShortName = colNumber;
        else if (['distributionchannel', 'distribution channel', 'channel'].includes(header) || header.startsWith('distributionchan')) colMap.distributionChannel = colNumber;
        else if (['specie', 'species'].includes(header)) colMap.specie = colNumber;
        else if (['weight packing', 'weightpacking', 'wt packing'].includes(header)) colMap.weightPacking = colNumber;
        else if (header === 'weight') colMap.productWeight = colNumber;
        else if (['packing', 'pack'].includes(header)) colMap.productPacking = colNumber;
        else if (header === 'mrp') colMap.mrp = colNumber;
        else if (['gst%', 'gst %', 'gst'].includes(header)) colMap.gst = colNumber;
        else if (['hsncode', 'hsn code', 'hsn'].includes(header)) colMap.hsnCode = colNumber;
        else if (['country of origin', 'countryoforigin', 'origin'].includes(header) || header.startsWith('country of ori')) colMap.countryOfOrigin = colNumber;
        else if (header.startsWith('shelf life') || header === 'shelflife') colMap.shelfLifeDays = colNumber;
        else if (['remarks', 'remark'].includes(header)) colMap.remarks = colNumber;
        else if (header === 'yc70') colMap.yc70 = colNumber;
        else if (header.startsWith('processing')) colMap.processingCharges = colNumber;
        else if (['price', 'rate', 'base rate'].includes(header)) colMap.price = colNumber;
        else if (['stock', 'qty', 'quantity'].includes(header)) colMap.stock = colNumber;
        else if (['category', 'cat'].includes(header)) colMap.category = colNumber;
    });

    console.log('📍 Header-detected map:', JSON.stringify(colMap));
    if (!colMap.skuCode)             colMap.skuCode = 1;
    if (!colMap.name)                colMap.name = 2;
    if (!colMap.productShortName)    colMap.productShortName = 3;
    if (!colMap.distributionChannel) colMap.distributionChannel = 4;
    if (!colMap.specie)              colMap.specie = 5;
    if (!colMap.weightPacking)       colMap.weightPacking = 6;
    if (!colMap.productWeight)       colMap.productWeight = 7;
    if (!colMap.productPacking)      colMap.productPacking = 8;
    if (!colMap.mrp)                 colMap.mrp = 9;
    if (!colMap.gst)                 colMap.gst = 10;
    if (!colMap.hsnCode)             colMap.hsnCode = 11;
    if (!colMap.countryOfOrigin)     colMap.countryOfOrigin = 12;
    if (!colMap.shelfLifeDays)       colMap.shelfLifeDays = 13;
    if (!colMap.remarks)             colMap.remarks = 14;
    if (!colMap.yc70)                colMap.yc70 = 15;
    if (!colMap.processingCharges)   colMap.processingCharges = 16;
    console.log('📍 Final map:', JSON.stringify(colMap));

    const products = [];
    const parseNum = (val) => {
        if (val === undefined || val === null || val === '') return null;
        if (typeof val === 'number') return val;
        const str = String(val).replace(/,/g, '').replace(/%/g, '').trim();
        const n = parseFloat(str);
        return isNaN(n) ? null : n;
    };
    const parseStr = (val) => (val === undefined || val === null) ? '' : String(val).trim();

    ws2.eachRow((row, rowNumber) => {
        if (rowNumber === 1) return; 
        const getCell = (col) => col ? row.getCell(col).value : null;

        const skuCode = parseStr(getCell(colMap.skuCode));
        const name    = parseStr(getCell(colMap.name));
        if (!name) return;

        const rowData = {
            skuCode, name, mrp: parseNum(getCell(colMap.mrp)),
            gst: parseNum(getCell(colMap.gst)),
            processingCharges: parseNum(getCell(colMap.processingCharges))
        };
        products.push(rowData);
    });

    console.log("Parsed Rows:", products);
}

run().catch(console.error);
