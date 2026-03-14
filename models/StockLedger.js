const mongoose = require('mongoose');

const stockLedgerSchema = new mongoose.Schema({
    timestamp: { type: Date, default: Date.now },
    productId: String,
    warehouseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Warehouse' },
    orderId: String,
    type: { type: String, enum: ['ADD', 'DEDUCT', 'RESTORE'] },
    qty: Number,
    details: String
});

module.exports = mongoose.model('StockLedger', stockLedgerSchema);
