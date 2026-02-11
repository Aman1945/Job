const mongoose = require('mongoose');

const procurementSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    supplierName: { type: String, required: true },
    skuName: { type: String, required: true },
    skuCode: { type: String, required: true },
    sipChecked: { type: Boolean, default: false },
    labelsChecked: { type: Boolean, default: false },
    docsChecked: { type: Boolean, default: false },
    status: { type: String, default: 'Pending' }, // Pending, Awaiting Head Approval, Approved
    attachment: { type: String },
    attachmentName: { type: String },
    clearedBy: { type: String },
    approvedBy: { type: String },
    createdAt: { type: Date, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Procurement', procurementSchema);
