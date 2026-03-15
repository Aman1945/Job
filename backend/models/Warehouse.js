const mongoose = require('mongoose');

const warehouseSchema = new mongoose.Schema({
    name: { type: String, required: true },
    location: { type: String, required: true },
    capacityTotal: { type: Number, default: 50000 }, // in kg/units
    capacityUsed: { type: Number, default: 0 },
    temperature: {
        current: Number,
        min: Number,
        max: Number
    },
    inventory: [{
        skuCode: String,
        barcode: String,
        name: String,
        qty: { type: Number, default: 0 },
        batches: [{
            batchNumber: String,
            qty: Number,
            expiry: Date,
            receivedAt: { type: Date, default: Date.now }
        }]
    }]
}, { timestamps: true });

warehouseSchema.methods.recalculateCapacity = function() {
    let total = 0;
    this.inventory.forEach(item => {
        total += item.qty;
    });
    this.capacityUsed = total;
};

module.exports = mongoose.model('Warehouse', warehouseSchema);
