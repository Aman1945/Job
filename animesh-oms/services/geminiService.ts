
import { GoogleGenAI } from "@google/genai";
import { Order, Customer, Product, ProcurementItem } from "../types";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

const insightCache: Record<string, string> = {};

export async function getExecutiveBriefing(data: { 
  orders: Order[], 
  customers: Customer[], 
  products: Product[],
  procurement: ProcurementItem[] 
}) {
  const cacheKey = `exec-brief-${data.orders.length}-${data.customers.length}`;
  if (insightCache[cacheKey]) return insightCache[cacheKey];

  try {
    const revenue = data.orders.reduce((s, o) => s + o.items.reduce((is, i) => is + (i.price * i.quantity), 0), 0);
    const overdue = data.customers.reduce((s, c) => s + c.overdue, 0);
    const lowStock = data.products.filter(p => p.stock < 100).length;

    const prompt = `
      You are the AI Chief of Staff for Animesh - OMS. 
      Analyze this enterprise data:
      - Total Booked Revenue: ₹${revenue.toLocaleString()}
      - Total Outstanding Overdue: ₹${overdue.toLocaleString()}
      - Critical Stockouts: ${lowStock} items
      - Open Procurement Missions: ${data.procurement.filter(p => p.status !== 'Approved').length}
      
      Provide a 3-sentence executive brief for the CEO. 
      Sentence 1: Overall financial health. 
      Sentence 2: Biggest operational risk. 
      Sentence 3: Immediate recommended action for today.
      Keep the tone professional, urgent, and concise.
    `;

    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: prompt,
    });

    const result = response.text || "Strategic analysis complete. Systems nominal.";
    insightCache[cacheKey] = result;
    return result;
  } catch (error) {
    return "Strategic intelligence engine offline. Manual audit of financial and inventory levels recommended.";
  }
}

export async function getApprovalInsight(order: Order, customer: Customer) {
  const cacheKey = `${order.id}-${order.status}-${customer.outstanding}-${customer.overdue}`;
  if (insightCache[cacheKey]) return insightCache[cacheKey];

  try {
    const prompt = `
      Analyze this order approval request for Animesh - OMS:
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
