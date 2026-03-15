
import { Customer, ODMaster, Order } from '../types';

/**
 * Simulates sending an Email.
 * In production, this would use a service like SendGrid, Mailgun, or AWS SES.
 */
export async function sendEmailNotification(
  recipient: { name: string, email: string }, 
  subject: string, 
  body: string, 
  attachments: { name: string }[]
) {
  // Simulate API latency
  await new Promise(r => setTimeout(r, 1800));

  console.log(`%c[EMAIL SENT TO ${recipient.email}]`, 'background: #3b82f6; color: white; font-weight: bold; padding: 2px 5px;', {
    subject,
    body,
    attachments: attachments.map(a => a.name)
  });
  
  // Create a visual indicator in the UI
  const event = new CustomEvent('email-dispatched', {
    detail: {
      recipient: recipient.name,
      email: recipient.email,
      subject: subject,
      attachmentCount: attachments.length,
      timestamp: new Date().toLocaleTimeString()
    }
  });
  window.dispatchEvent(event);
}

export const EMAIL_TEMPLATES = {
  OVERDUE_NOTICE: (customerName: string, amount: number, invoices: Order[]) => ({
    subject: `Urgent: Payment Reminder - Animesh - OMS - ${customerName}`,
    body: `Dear ${customerName},\n\nThis is a formal reminder regarding the outstanding balance on your account totaling ₹${amount.toLocaleString()}.\n\nPlease find the detailed invoice ledger and PDF copies attached to this email for your immediate review and settlement.\n\nThank you,\nAnimesh - OMS Credit Control Team`,
    attachments: invoices.map(inv => ({ name: `Invoice_${inv.invoiceNo || inv.id}.pdf` }))
  })
};
