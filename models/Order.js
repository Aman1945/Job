const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    customerId: { type: String, required: true },
    customerName: { type: String },
    items: [{
        productId: { type: String },
        productName: { type: String },
        skuCode: { type: String },
        quantity: { type: Number },
        price: { type: Number },
        barcode: { type: String },
        unit: { type: String },
        baseRate: { type: Number }
    }],
    status: { type: String, default: 'Pending' },
    salespersonId: { type: String },
    statusHistory: [{
        status: { type: String },
        timestamp: { type: Date, default: Date.now }
    }],
    createdAt: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
