const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    role: { type: String, required: true },
    status: { type: String, default: 'Active' },
    isApprover: { type: Boolean, default: false },
    password: { type: String, required: true },
    monthlyTarget: { type: Number },
    monthlyQtyTarget: { type: Number }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
