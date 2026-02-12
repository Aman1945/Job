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
    stock: { type: Number, default: 0 }, // Derived from batches
    barcode: { type: String },
    batches: [{
        batchId: { type: String, required: true },
        batchNumber: { type: String, required: true },
        mfgDate: { type: String }, // YYYY-MM-DD
        expDate: { type: String }, // YYYY-MM-DD
        quantity: { type: Number, required: true, min: 0 },
        weight: { type: String }, // e.g., "0.5 KG"
        isActive: { type: Boolean, default: true },
        createdAt: { type: Date, default: Date.now }
    }]
}, { timestamps: true });

// Method to calculate total stock from active batches
productSchema.methods.calculateStock = function () {
    this.stock = this.batches
        .filter(batch => batch.isActive)
        .reduce((sum, batch) => sum + batch.quantity, 0);
    return this.stock;
};

// Method to get expiring batches
productSchema.methods.getExpiringBatches = function (days = 90) {
    const today = new Date();
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + days);

    return this.batches.filter(batch => {
        if (!batch.expDate || !batch.isActive) return false;
        const expDate = new Date(batch.expDate);
        return expDate >= today && expDate <= futureDate;
    });
};

// Method to reduce batch quantity
productSchema.methods.reduceBatchQuantity = function (batchNumber, quantity) {
    const batch = this.batches.find(b => b.batchNumber === batchNumber && b.isActive);

    if (!batch) {
        throw new Error(`Batch ${batchNumber} not found or inactive`);
    }

    if (batch.quantity < quantity) {
        throw new Error(`Insufficient quantity in batch ${batchNumber}. Available: ${batch.quantity}, Requested: ${quantity}`);
    }

    batch.quantity -= quantity;

    // Deactivate batch if quantity reaches 0
    if (batch.quantity === 0) {
        batch.isActive = false;
    }

    this.calculateStock();
    return batch;
};

// Index for faster queries
productSchema.index({ skuCode: 1, category: 1 });
productSchema.index({ 'batches.expDate': 1, 'batches.isActive': 1 });

module.exports = mongoose.model('Product', productSchema);
