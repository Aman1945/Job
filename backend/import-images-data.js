require('dotenv').config();
const mongoose = require('mongoose');
const DistributorPrice = require('./models/DistributorPrice');

const data = [
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004643', name: 'FISH FINGERS RETAIL PACK 200GIND-Branded', mrp: 220, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 116.29, materialNumber: '2004643' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004620', name: 'PNGS WHT TRIMED CHUNKS VN 250G-Branded', mrp: 275, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 145.36, materialNumber: '2004620' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004621', name: 'PNGS FLT TRIMED 220+ RETL 500G-Branded', mrp: 445, inKg: '0.5', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 235.21, materialNumber: '2004621' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2005180', name: 'PNGS FLT TRIM 3P PLAT RETAIL 1KG-Branded', mrp: 675, inKg: '1', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 356.79, materialNumber: '2005180' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004519', name: 'SALMON PRTN SL NOR 1X200G -Branded', mrp: 1250, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 660.71, materialNumber: '2004519' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004520', name: 'SALMON DBL PRTN SL NOR 2X150G-Branded', mrp: 2150, inKg: '0.3', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 1136.43, materialNumber: '2004520' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004521', name: 'SALMON SMOKED PRESLICE NOR 100G-Branded', mrp: 995, inKg: '0.1', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 525.93, materialNumber: '2004521' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004608', name: 'SALMON SMOKED PRESLICE NOR 200G Branded', mrp: 1675, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 885.36, materialNumber: '2004608' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004518', name: 'SLMN DBL PRTN SKIN ON NOR 2X125G-Branded', mrp: 1750, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 925, materialNumber: '2004518' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004140', name: 'SHRIMPS MED IND 250GX24 6KG PD-Branded', mrp: 295, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 155.93, materialNumber: '2004140' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004151', name: 'SHRIMPS SMALL IND 250GX40 PUD-Branded', mrp: 275, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 145.36, materialNumber: '2004151' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004150', name: 'SHRIMPS LRG IND 250GX36 9KG PD-Branded', mrp: 345, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 182.36, materialNumber: '2004150' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004344', name: 'TILAPIA 4-5 VN 40X250G IQF-Branded', mrp: 275, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 145.36, materialNumber: '2004344' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2005114', name: 'PNGS FLT 220+ IND RETAIL 10X1KG-Branded', mrp: 645, inKg: '1', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 340.93, materialNumber: '2005114' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2004149', name: 'SHRIMPS JUMBO IND 250GX36 9KG PD-Branded', mrp: 395, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 208.79, materialNumber: '2004149' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006378', name: 'SALMON SKIN ON PORTION NOR 500G FAMILY PACK', mrp: 3350, inKg: '0.5', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 1770.71, materialNumber: '2006378' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006399', name: 'FROZEN SALMON MINCE 250G', mrp: 925, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 488.93, materialNumber: '2006399' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006332', name: 'orange tobiko Japan 30 gm-branded', mrp: 550, inKg: '0.03', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 290.71, materialNumber: '2006332' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006404', name: 'PORK STREAKY BACON INDIA 150G', mrp: 345, inKg: '0.15', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 182.36, materialNumber: '2006404' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006405', name: 'PORK BACK BACON INDIA 150GM', mrp: 345, inKg: '0.15', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 182.36, materialNumber: '2006405' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006498', name: 'FROZEN SALMON POKE CUBES 200G', mrp: 1295, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 684.5, materialNumber: '2006498' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006425', name: 'FROZEN YELLOWFIN TUNA POKE CUBES SL 200G', mrp: 1295, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 684.5, materialNumber: '2006425' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006453', name: 'YF TUNA MINI STEAK SRILANKA 100G', mrp: 575, inKg: '0.1', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 303.93, materialNumber: '2006453' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006386', name: 'CHILEAN SEABASS PRTN AUS 150 GM', mrp: 2295, inKg: '0.15', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 1213.07, materialNumber: '2006386' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006457', name: 'LAMB CHOPS AUS 200GM', mrp: 1650, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 872.14, materialNumber: '2006457' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006481', name: 'Salmon Steaks 250 g', mrp: 1250, inKg: '0.25', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 660.71, materialNumber: '2006481' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006442', name: 'SQUID RINGS 200G', mrp: 375, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 198.21, materialNumber: '2006442' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006553', name: 'SHRIMPS MEDIUM PD IND 500 GM', mrp: 595, inKg: '0.5', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 314.5, materialNumber: '2006553' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006554', name: 'SHRIMPS LARGE PD IND 500 GM', mrp: 695, inKg: '0.5', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 367.36, materialNumber: '2006554' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006350', name: 'EDAMAME JAPAN 300 GM', mrp: 395, inKg: '0.3', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 208.79, materialNumber: '2006350' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006558', name: 'SILVER SALMON SKIN ON PORTION CHL 200 GM', mrp: 895, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 473.07, materialNumber: '2006558' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006629', name: 'SALMON PORTION SKINLESS NOR 150 GM', mrp: 1250, inKg: '0.15', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 660.71, materialNumber: '2006629' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006634', name: 'PACIFIC SMOKE SALMON 100 GM', mrp: 750, inKg: '0.1', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 396.43, materialNumber: '2006634' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006633', name: 'MUTTON CURRY CUT IND 500 GM', mrp: 550, inKg: '0.5', gstPct: 5, retailerMarginOnMrp: 25, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 337.86, materialNumber: '2006633' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006974', name: 'SHRIMPS MEDIUM 200 GM PDTO', mrp: 295, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 155.93, materialNumber: '2006974' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006976', name: 'SHRIMPS JUMBO 200 GM PDTO', mrp: 395, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 208.79, materialNumber: '2006976' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006977', name: 'SHRIMPS LARGE 200 GM PDTO', mrp: 345, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 182.36, materialNumber: '2006977' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006978', name: 'SHRIMPS SMALL 200 GM PUD', mrp: 275, inKg: '0.2', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 145.36, materialNumber: '2006978' },
  { distributorCode: '197362', distributorName: 'MULTIPRODUCTS CORPORATION', code: '2006650', name: 'WILD SOCKEYE SALMON SKIN ON USA 150 GM', mrp: 1695, inKg: '0.15', gstPct: 5, retailerMarginOnMrp: 34, distMarginOnCost: 10, distMarginOnMrp: 0, billingRate: 895.93, materialNumber: '2006650' }
];

async function run() {
  await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/nexus_db');
  console.log('Connected to DB');
  
  for (const row of data) {
    const id = `DP-${row.code}`;
    const doc = {
        ...row,
        id
    };
    await DistributorPrice.findOneAndUpdate({ code: row.code }, doc, { upsert: true, new: true });
    console.log(`Saved ${row.name}`);
  }
  
  console.log('Done inserting 39 rows.');
  process.exit(0);
}

run().catch(console.error);
