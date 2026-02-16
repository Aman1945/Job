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
    total: { type: Number, default: 0 },
    salespersonId: { type: String },
    remarks: { type: String },
    sourceWarehouse: { type: String },
    destinationWarehouse: { type: String },
    partnerType: { type: String },
    intelligenceInsight: { type: String },
    podUrl: { type: String },
    statusHistory: [{
        status: { type: String },
        timestamp: { type: Date, default: Date.now }
    }],
    logistics: {
        deliveryAgentId: { type: String },
        vehicleNo: { type: String },
        vehicleProvider: { type: String },
        distanceKm: { type: Number },
        shippingCost: { type: Number, default: 0 },
        highCostAlert: { type: Boolean, default: false }
    },
    createdAt: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
