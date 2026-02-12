const mongoose = require('mongoose');

const performanceRecordSchema = new mongoose.Schema({
    userId: { type: String, required: true },
    userName: { type: String, required: true },
    month: { type: String, required: true }, // Format: "Feb'26"
    grossMonthlySalary: { type: Number, default: 0 },
    odBalances: {
        chennai: { type: Number, default: 0 },
        self: { type: Number, default: 0 },
        hyd: { type: Number, default: 0 }
    },
    kras: [{
        id: { type: Number, required: true },
        name: { type: String, required: true },
        criteria: { type: String },
        target: { type: Number, default: 0 },
        achieved: { type: Number, default: 0 },
        weightage: { type: Number, default: 0 },
        type: {
            type: String,
            enum: ['Unrestricted', 'Restricted', 'As per slab'],
            default: 'Unrestricted'
        },
        finalScore: { type: Number, default: 0 }
    }],
    totalScore: { type: Number, default: 0 },
    incentiveAmount: { type: Number, default: 0 },
    incentivePercentage: { type: Number, default: 0 }
}, { timestamps: true });

// Compound index for userId + month (unique combination)
performanceRecordSchema.index({ userId: 1, month: 1 }, { unique: true });

// Method to calculate KRA final score
performanceRecordSchema.methods.calculateKRAScore = function (kra) {
    const achievementRatio = kra.target > 0 ? kra.achieved / kra.target : 0;

    switch (kra.type) {
        case 'Unrestricted':
            return achievementRatio * kra.weightage;

        case 'Restricted':
            return Math.min(achievementRatio * kra.weightage, kra.weightage);

        case 'As per slab':
            // OD balance slab logic
            return this.calculateODSlab(kra.achieved);

        default:
            return 0;
    }
};

// Method to calculate OD slab score
performanceRecordSchema.methods.calculateODSlab = function (odBalance) {
    if (odBalance <= 363459) return 30;
    if (odBalance <= 1250000) return 24;
    if (odBalance <= 1900000) return 18;
    if (odBalance <= 2550000) return 12;
    if (odBalance <= 3200000) return 6;
    if (odBalance <= 4000000) return 0;
    return 0;
};

// Method to calculate total score and incentive
performanceRecordSchema.methods.calculateTotalScore = function () {
    this.totalScore = this.kras.reduce((sum, kra) => {
        kra.finalScore = this.calculateKRAScore(kra);
        return sum + kra.finalScore;
    }, 0);

    // Calculate incentive based on total score percentage
    const scorePercentage = this.totalScore;

    if (scorePercentage >= 90 && scorePercentage < 96) {
        this.incentivePercentage = 10;
    } else if (scorePercentage >= 96 && scorePercentage < 101) {
        this.incentivePercentage = 15;
    } else if (scorePercentage >= 101 && scorePercentage < 106) {
        this.incentivePercentage = 20;
    } else if (scorePercentage >= 106 && scorePercentage < 111) {
        this.incentivePercentage = 25;
    } else if (scorePercentage > 110) {
        const excess = scorePercentage - 110;
        this.incentivePercentage = 25 + Math.floor(excess / 5) * 5;
    } else {
        this.incentivePercentage = 0;
    }

    this.incentiveAmount = (this.grossMonthlySalary * this.incentivePercentage) / 100;

    return this.totalScore;
};

module.exports = mongoose.model('PerformanceRecord', performanceRecordSchema);
