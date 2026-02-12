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
        const prompt = `You are a credit risk analyst for NexusOMS, a B2B order management system. Analyze this order approval request and provide a concise credit risk assessment.

**Customer Details:**
- Name: ${customer.name}
- Outstanding Balance: ₹${customer.outstanding || 0}
- Overdue Amount: ₹${customer.overdue || 0}
- Ageing Days: ${customer.ageingDays || 0} days
- Credit Limit: ₹${customer.creditLimit || 'Not set'}
- Payment History: ${customer.paymentHistory || 'No history'}

**Order Details:**
- Order ID: ${order.id}
- Order Value: ₹${order.total}
- Items: ${order.items?.length || 0} products
- Salesperson: ${order.salespersonId || 'Unknown'}

**Task:**
Provide a 2-3 sentence risk assessment and recommendation. Include:
1. Risk level (Low/Medium/High)
2. Key concern (if any)
3. Recommendation (Approve/Flag for Review/Reject)

Keep it professional and concise.`;

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
