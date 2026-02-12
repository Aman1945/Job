const mongoose = require('mongoose');

const packagingMaterialSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    unit: {
        type: String,
        enum: ['PCS', 'KG', 'ROLLS'],
        required: true
    },
    moq: { type: Number, default: 0 }, // Minimum Order Quantity
    balance: { type: Number, default: 0 }, // Current stock
    category: {
        type: String,
        enum: ['Poly Pkts', 'Vacuum Pouches', 'Cartons', 'Tape/Labels'],
        required: true
    },
    lastMovementDate: { type: Date }
}, { timestamps: true });

// Method to check if low stock
packagingMaterialSchema.methods.isLowStock = function () {
    return this.balance <= this.moq;
};

// Index for faster queries
packagingMaterialSchema.index({ id: 1, category: 1 });

module.exports = mongoose.model('PackagingMaterial', packagingMaterialSchema);
