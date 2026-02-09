
import { GoogleGenAI } from "@google/genai";
import { Order, Customer } from "../types";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

// Simple cache to prevent redundant calls and save quota
const insightCache: Record<string, string> = {};

export async function getApprovalInsight(order: Order, customer: Customer) {
  const cacheKey = `${order.id}-${order.status}-${customer.outstanding}-${customer.overdue}`;
  
  if (insightCache[cacheKey]) {
    return insightCache[cacheKey];
  }

  try {
    const prompt = `
      Analyze this order approval request for NexusOMS:
      Customer: ${customer.name}
      Type: ${customer.type}
      Outstanding Balance: ₹${customer.outstanding}
      Overdue Amount: ₹${customer.overdue}
      Ageing: ${customer.ageingDays} days
      
      Order Details:
      Total Items: ${order.items.length}
      Order Value: ₹${order.items.reduce((sum, item) => sum + (item.price * (item.packedQuantity || item.quantity)), 0)}
      
      Provide a concise summary (max 2 sentences) of the risk factor and a recommendation (Approve/Flag/Reject).
    `;

    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: prompt,
    });

    const result = response.text || "Insight analysis complete.";
    insightCache[cacheKey] = result;
    return result;
  } catch (error: any) {
    console.error("Gemini Error:", error);
    if (error?.status === 429 || error?.code === 429) {
      return "Rate limit reached. Standard financial protocols recommended based on overdue status.";
    }
    return "Intelligence server busy. Proceed with manual credit review.";
  }
}
