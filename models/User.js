const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    email: { type: String, unique: true, sparse: true }, // Optional email field
    role: {
        type: String,
        required: true,
        enum: [
            'Admin',
            'Sales',
            'Credit Control',
            'WH Manager',
            'Warehouse',
            'QC Head',
            'Logistics Lead',
            'Logistics Team',
            'ATL Executive',
            'Hub Lead',
            'Delivery Team'
        ]
    },
    status: { type: String, default: 'Active', enum: ['Active', 'Inactive', 'Suspended'] },
    isApprover: {
        type: Boolean,
        default: function () {
            // Auto-set isApprover for specific roles
            return ['Admin', 'Credit Control', 'Procurement Head'].includes(this.role);
        }
    },
    password: { type: String, required: true },
    monthlyTarget: { type: Number, default: 0 },
    monthlyQtyTarget: { type: Number, default: 0 },
    lastLogin: { type: Date }
}, { timestamps: true });

// Pre-save hook: Hash password before saving
userSchema.pre('save', async function () {
    // Only hash if password is modified or new
    if (!this.isModified('password')) {
        return;
    }

    // Generate salt and hash password
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

// Method to compare password for login
userSchema.methods.comparePassword = async function (candidatePassword) {
    try {
        return await bcrypt.compare(candidatePassword, this.password);
    } catch (error) {
        throw error;
    }
};

// Method to generate JWT payload
userSchema.methods.getJWTPayload = function () {
    return {
        userId: this.id,
        name: this.name,
        role: this.role,
        isApprover: this.isApprover
    };
};

// Index for faster queries
userSchema.index({ id: 1, email: 1, role: 1 });

module.exports = mongoose.model('User', userSchema);
