const mongoose = require('mongoose');

const distributorPriceSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    code: { type: String, required: true },           // SKU Code
    name: { type: String, required: true },           // Material/Product Name
    materialNumber: { type: String },                 // SAP Material Number
    inKg: { type: String },                           // Packing size e.g. "5 Kg"
    mrp: { type: Number, default: 0 },                // Max Retail Price
    gstPct: { type: Number, default: 5 },             // GST percentage
    retailerMarginOnMrp: { type: Number, default: 0 }, // Retailer margin % on MRP
    distMarginOnCost: { type: Number, default: 0 },   // Distributor margin % on cost
    distMarginOnMrp: { type: Number, default: 0 },    // Distributor margin % on MRP
    billingRate: { type: Number, default: 0 },         // Final billing rate to distributor
    category: { type: String },
    isActive: { type: Boolean, default: true },
}, { timestamps: true });

distributorPriceSchema.index({ code: 1 });
distributorPriceSchema.index({ name: 1 });

module.exports = mongoose.model('DistributorPrice', distributorPriceSchema);
