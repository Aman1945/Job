const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    type: { type: String },
    outstanding: { type: Number, default: 0 },
    overdue: { type: Number, default: 0 },
    ageingDays: { type: Number },
    creditLimit: { type: Number },
    securityChqStatus: { type: String },
    creditDays: { type: String },
    assignedSalespersonId: { type: String },
    salesManager: { type: String },
    employeeResponsible: { type: String },
    status: { type: String, default: 'Active' },
    distributionChannel: { type: String },
    customerClass: { type: String },
    location: { type: String },
    email: { type: String },
    address: { type: String },
    postalCode: { type: String },
    agingBuckets: {
        "0 to 7": { type: Number, default: 0 },
        "7 to 15": { type: Number, default: 0 },
        "15 to 30": { type: Number, default: 0 },
        "30 to 45": { type: Number, default: 0 },
        "45 to 90": { type: Number, default: 0 },
        "90 to 120": { type: Number, default: 0 },
        "120 to 150": { type: Number, default: 0 },
        "150 to 180": { type: Number, default: 0 },
        ">180": { type: Number, default: 0 }
    }
}, { timestamps: true });

module.exports = mongoose.model('Customer', customerSchema);
