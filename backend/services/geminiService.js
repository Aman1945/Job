/**
 * NexusOMS - Gemini AI Service
 * AI-powered credit approval insights using Google Gemini
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');
const NodeCache = require('node-cache');

// Initialize cache (5 minutes TTL)
const insightCache = new NodeCache({ stdTTL: 300 });

// Initialize Gemini AI
let genAI;
let model;

if (process.env.GEMINI_API_KEY && !process.env.GEMINI_API_KEY.includes('your-gemini')) {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });
    console.log('✅ Gemini AI initialized');
} else {
    console.warn('⚠️  Gemini API key not configured. AI insights will use fallback logic.');
}

/**
 * Get credit approval insight for an order
 * @param {Object} order - Order object
 * @param {Object} customer - Customer object
 * @returns {Promise<string>} AI-generated insight
 */
async function getCreditInsight(order, customer) {
    const cacheKey = `credit-${order.id}-${customer.id}`;

    // Check cache first
    if (insightCache.has(cacheKey)) {
        console.log(`📦 Cache hit for ${cacheKey}`);
        return insightCache.get(cacheKey);
    }

    // If Gemini not configured, use fallback logic
    if (!model) {
        return getFallbackInsight(order, customer);
    }

    try {
        const prompt = `You are a Senior Credit Risk Analyst for NexusOMS. Analyze the following credit approval request and provide a sophisticated, data-driven risk assessment.

### DATA INPUTS:

**Customer Portfolio:**
- Name: ${customer.name}
- Current Outstanding: ₹${customer.outstanding || 0}
- Overdue Amount: ₹${customer.overdue || 0}
- Ageing Profile: ${customer.ageingDays || 0} days (Bucket: ${customer.ageingDays > 60 ? 'CRITICAL' : customer.ageingDays > 30 ? 'WATCHLIST' : 'HEALTHY'})
- Credit Limit: ₹${customer.creditLimit || 'No limit set'}
- Payment Reliability: ${customer.paymentHistory || 'New Account'}

**Inbound Order Details:**
- Order ID: ${order.id}
- Order Value: ₹${order.total}
- Exposure Ratio: ${customer.creditLimit ? (((customer.outstanding || 0) + (order.total || 0)) / customer.creditLimit * 100).toFixed(1) + '%' : 'N/A'}
- SKU Count: ${order.items?.length || 0} unique lines 

### TASK:
Provide a critical, concise (maximum 3-4 sentences) analytical assessment. 

Structure your response exactly as follows:
1. **RISK SCORE:** [LOW / MEDIUM / HIGH / CRITICAL]
2. **CORE ANALYSIS:** One sentence on why this score was assigned (focus on exposure vs. limit or ageing).
3. **DECISION:** [APPROVE / FLAG FOR FINANCE REVIEW / REJECT]
4. **JUSTIFICATION:** A brief reason for the final decision.

Be precise, professional, and avoid generic filler text.`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const insight = response.text();

        // Cache the result
        insightCache.set(cacheKey, insight);

        console.log(`✅ AI insight generated for ${order.id}`);
        return insight;

    } catch (error) {
        console.error('Gemini AI error:', error.message);

        // Handle rate limiting
        if (error.status === 429 || error.message.includes('quota')) {
            return 'AI service rate limit reached. Standard credit protocols recommended. Please review customer payment history and outstanding balance manually.';
        }

        // Handle other errors
        if (error.status === 503) {
            return 'AI service temporarily unavailable. Proceed with manual credit check based on customer history and credit limit.';
        }

        // Fallback for any other error
        return getFallbackInsight(order, customer);
    }
}

/**
 * Fallback insight when AI is not available
 * @param {Object} order - Order object
 * @param {Object} customer - Customer object
 * @returns {string} Rule-based insight
 */
function getFallbackInsight(order, customer) {
    const outstanding = customer.outstanding || 0;
    const overdue = customer.overdue || 0;
    const ageingDays = customer.ageingDays || 0;
    const creditLimit = customer.creditLimit || 0;
    const orderValue = order.total || 0;

    let riskLevel = 'Low';
    let recommendation = 'Approve';
    let concerns = [];

    // Check overdue
    if (overdue > 0) {
        concerns.push(`₹${overdue} overdue`);
        riskLevel = 'Medium';
    }

    // Check ageing
    if (ageingDays > 60) {
        concerns.push(`${ageingDays} days ageing`);
        riskLevel = 'High';
        recommendation = 'Flag for Review';
    }

    // Check credit limit
    if (creditLimit > 0 && (outstanding + orderValue) > creditLimit) {
        concerns.push('Exceeds credit limit');
        riskLevel = 'High';
        recommendation = 'Reject';
    }

    // Check outstanding ratio
    const outstandingRatio = creditLimit > 0 ? (outstanding / creditLimit) * 100 : 0;
    if (outstandingRatio > 80) {
        concerns.push(`${outstandingRatio.toFixed(0)}% credit utilized`);
        if (riskLevel === 'Low') riskLevel = 'Medium';
    }

    // Generate insight
    let insight = `**Risk Level:** ${riskLevel}\n\n`;

    if (concerns.length > 0) {
        insight += `**Concerns:** ${concerns.join(', ')}.\n\n`;
    } else {
        insight += `**Status:** Customer has good payment history with no outstanding concerns.\n\n`;
    }

    insight += `**Recommendation:** ${recommendation}`;

    if (recommendation === 'Flag for Review') {
        insight += ' - Manual review recommended due to payment delays.';
    } else if (recommendation === 'Reject') {
        insight += ' - Credit limit exceeded or significant overdue amount.';
    } else {
        insight += ' - Customer is in good standing.';
    }

    return insight;
}

/**
 * Get product recommendation based on customer history
 * @param {Object} customer - Customer object
 * @param {Array} orderHistory - Customer's order history
 * @returns {Promise<string>} AI-generated recommendations
 */
async function getProductRecommendations(customer, orderHistory) {
    if (!model) {
        return 'AI recommendations not available. Please review customer order history manually.';
    }

    try {
        const recentOrders = orderHistory.slice(0, 5).map(o =>
            `${o.items.map(i => i.productName).join(', ')} (₹${o.total})`
        ).join('\n');

        const prompt = `Based on this customer's recent order history, suggest 3-5 products they might be interested in ordering next:

**Customer:** ${customer.name}
**Recent Orders:**
${recentOrders}

Provide a brief, bulleted list of product recommendations with reasoning.`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        return response.text();

    } catch (error) {
        console.error('Product recommendation error:', error.message);
        return 'Unable to generate recommendations at this time.';
    }
}

module.exports = {
    getCreditInsight,
    getProductRecommendations,
    getFallbackInsight
};
