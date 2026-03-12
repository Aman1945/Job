require('dotenv').config({ path: '.env.production' });
const mongoose = require('mongoose');
const fs = require('fs');

const Product = require('./models/Product');

async function seed() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connected to MongoDB');

        const data = fs.readFileSync('raw_data.txt', 'utf8');
        const lines = data.split('\n');
        // skip header if any
        let count = 0;
        for (let i = 1; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line) continue;
            const cols = line.split('\t');
            if (cols.length < 2) continue;

            const skuCode = cols[0] ? cols[0].trim() : '';
            const name = cols[1] ? cols[1].trim() : '';
            if (!name) continue;

            const shortName = cols[2] ? cols[2].trim() : '';
            
            const num = (v) => {
                if(!v) return null;
                const str = v.replace(/,/g, '').replace(/%/g, '').trim();
                const n = parseFloat(str);
                return isNaN(n) ? null : n;
            };

            const product = {
                skuCode,
                name,
                productShortName: shortName,
                shortName,
                distributionChannel: cols[3] ? cols[3].trim() : '',
                specie: cols[4] ? cols[4].trim() : '',
                weightPacking: cols[5] ? cols[5].trim() : '',
                productWeight: cols[6] ? cols[6].trim() : '',
                productPacking: cols[7] ? cols[7].trim() : '',
                mrp: num(cols[8]),
                gst: num(cols[9]),
                hsnCode: cols[10] ? cols[10].trim() : '',
                countryOfOrigin: cols[11] ? cols[11].trim() : '',
                shelfLifeDays: num(cols[12]),
                remarks: cols[13] ? cols[13].trim() : '',
                yc70: num(cols[14]),
                processingCharges: num(cols[15])
            };
            
            // if we have price / rate mappings... just default empty
            product.price = product.price || 0;
            product.stock = product.stock || 0;
            product.category = product.category || 'General';

            const id = product.skuCode || new mongoose.Types.ObjectId().toString();
            product.id = id;

            await Product.findOneAndUpdate({ id }, product, { upsert: true, new: true });
            count++;
        }
        console.log(`Successfully merged ${count} products manually.`);
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

seed();
