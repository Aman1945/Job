const fs = require('fs');
const ExcelJS = require('exceljs');

async function processData() {
    try {
        console.log('Reading raw_data.txt...');
        const rawContent = fs.readFileSync('raw_data.txt', 'ucs2');
        const lines = rawContent.split(/\r?\n/);
        
        console.log(`Found ${lines.length} lines. Creating Excel...`);
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('SKU Master');
        
        for (const line of lines) {
            if (!line.trim()) continue;
            const cols = line.split('\t');
            worksheet.addRow(cols);
        }
        
        const filePath = 'seed.xlsx';
        await workbook.xlsx.writeFile(filePath);
        console.log('✅ Created seed.xlsx locally');
        
        // Now upload to VPS
        console.log('Logging in to VPS...');
        const loginRes = await fetch('http://168.144.31.254/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'animesh.jamuar@bigsams.in', password: 'password123' })
        });
        const loginData = await loginRes.json();
        if (!loginData.token) throw new Error('Failed to get token: ' + JSON.stringify(loginData));
        console.log('✅ Logged in successfully');
        
        console.log('Uploading Excel to VPS...');
        const formData = new FormData();
        const buffer = fs.readFileSync(filePath);
        const fileBlob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        formData.append('file', fileBlob, 'seed.xlsx');

        const uploadRes = await fetch('http://168.144.31.254/api/products/bulk-import', {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${loginData.token}` },
            body: formData
        });
        
        const uploadData = await uploadRes.json();
        console.log('Upload Response:', uploadData);
        
        if (uploadRes.ok) {
            console.log('🎉 SUCCESSFULLY UPLOADED MANUAL DATA!');
        } else {
            console.log('❌ UPLOAD FAILED');
        }
        
    } catch (e) {
        console.error('Error:', e);
    }
}
processData();
