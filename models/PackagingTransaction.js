const mongoose = require('mongoose');

const packagingTransactionSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    materialId: { type: String, required: true }, // Reference to PackagingMaterial.id
    type: {
        type: String,
        enum: ['IN', 'OUT'],
        required: true
    },
    qty: { type: Number, required: true },
    batch: { type: String },
    mfgDate: { type: Date },
    expDate: { type: Date },
    vendorName: { type: String },
    referenceNo: { type: String }, // Challan/Invoice number
    attachment: { type: String }, // Base64 or URL
    date: { type: Date, default: Date.now },
    createdBy: { type: String, required: true } // User ID
}, { timestamps: true });

// Index for faster queries
packagingTransactionSchema.index({ materialId: 1, type: 1, date: -1 });

module.exports = mongoose.model('PackagingTransaction', packagingTransactionSchema);
