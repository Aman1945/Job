
import { User, Customer } from '../types';

/**
 * Simulates sending a WhatsApp message.
 * In production, this would call an API like Twilio or Meta WhatsApp Business API.
 */
export async function sendWhatsAppNotification(recipient: { name: string, whatsappNumber?: string }, message: string) {
  const number = recipient.whatsappNumber;
  
  if (!number) {
    console.warn(`Attempted to send WhatsApp to ${recipient.name}, but no mobile number is configured.`);
    return;
  }

  // Simulate API latency
  await new Promise(r => setTimeout(r, 1000));

  console.log(`%c[WHATSAPP SENT TO ${number}]`, 'background: #25D366; color: white; font-weight: bold; padding: 2px 5px;', message);
  
  // Create a visual indicator in the UI (simulated via an event or global toast system)
  const event = new CustomEvent('whatsapp-dispatched', {
    detail: {
      recipient: recipient.name,
      number: number,
      message: message,
      timestamp: new Date().toLocaleTimeString()
    }
  });
  window.dispatchEvent(event);
}

export const WHATSAPP_MESSAGES = {
  CONSUMABLE_RAISED: (id: string, item: string, qty: number) => 
    `Animesh - OMS: Your purchase request ${id} for ${qty}x ${item} has been logged and sent to Animesh for approval.`,
  
  CONSUMABLE_APPROVED: (id: string, approver: string) => 
    `Animesh - OMS: ✅ Your request ${id} has been APPROVED by ${approver}. You may proceed with the vendor.`,
  
  CONSUMABLE_REJECTED: (id: string, approver: string, reason?: string) => 
    `Animesh - OMS: ❌ Your request ${id} was REJECTED by ${approver}.${reason ? ` Reason: ${reason}` : ''}`,
  
  SALES_ORDER_BOOKED: (id: string, customer: string, value: number) => 
    `Animesh - OMS: New Sales Order ${id} booked for ${customer}. Total Value: ₹${value.toLocaleString()}. Currently: Pending Credit Approval.`,

  CUSTOMER_OVERDUE_ALERT: (customerName: string, amount: number, aging: string) => 
    `Animesh - OMS Payment Reminder: Dear ${customerName}, your account shows an outstanding balance of ₹${amount.toLocaleString()} which is overdue in the ${aging} bucket. Please find invoice details attached for early settlement. Thank you.`
};
