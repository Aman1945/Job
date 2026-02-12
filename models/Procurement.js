const mongoose = require('mongoose');

const procurementSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    supplierName: { type: String, required: true },
    skuName: { type: String, required: true },
    skuCode: { type: String, required: true },
    sipChecked: { type: Boolean, default: false },
    labelsChecked: { type: Boolean, default: false },
    docsChecked: { type: Boolean, default: false },
    status: {
        type: String,
        default: 'Pending',
        enum: ['Pending', 'Awaiting Head Approval', 'Approved']
    },
    attachment: {
        type: String,
        required: function () {
            return this.status === 'Awaiting Head Approval';
        }
    }, // Base64 or URL
    attachmentName: { type: String },
    clearedBy: { type: String }, // User ID who cleared
    approvedBy: { type: String }, // User ID who approved
    updatedBy: { type: String }, // Last updated by user ID
    statusHistory: [{
        status: String,
        changedBy: String,
        changedAt: { type: Date, default: Date.now },
        remarks: String
    }],
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

// Method to check if ready for head approval
procurementSchema.methods.isReadyForHeadApproval = function () {
    return this.sipChecked &&
        this.labelsChecked &&
        this.docsChecked &&
        this.attachment;
};

// Method to check if checks are locked
procurementSchema.methods.areChecksLocked = function () {
    return this.status !== 'Pending';
};

// Index for faster queries
procurementSchema.index({ id: 1, status: 1, createdAt: -1 });

module.exports = mongoose.model('Procurement', procurementSchema);
