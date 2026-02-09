const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    skuCode: { type: String },
    name: { type: String, required: true },
    productShortName: { type: String },
    distributionChannel: { type: String },
    specie: { type: String },
    productWeight: { type: String },
    productPacking: { type: String },
    mrp: { type: Number },
    price: { type: Number },
    baseRate: { type: Number },
    gst: { type: Number },
    hsnCode: { type: String },
    countryOfOrigin: { type: String },
    category: { type: String },
    unit: { type: String },
    stock: { type: Number, default: 0 },
    barcode: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
