# 👥 User Access Management Guide (Multiple Logo Ko Access Dene Ka Tarika)

Yeh guide aapko sikhayegi ki kaise logo ko system mein add karein aur unhe roles assign karein.

---

## 📱 Method 1: App Se (Admin User Management) ✅ RECOMMENDED

**Yeh sabse aasan tarika hai!** Maine abhi yeh feature add kiya hai.

### Step-by-Step:

1. **Animesh ke login se app kholein**
   - Email: `animesh.jamuar@bigsams.in`
   - Password: `password123`

2. **Dashboard → Utilities → "User Management" pe click karein**
   - Yeh button sirf Admin ko dikhta hai

3. **User List Dikhega**
   - Sab current users ka naam, email, aur role dikhega
   - Har user ke aage ek "Edit" icon hoga

4. **Role Change Karne Ke Liye:**
   - Jis user ka role change karna hai, uske aage **edit icon** pe tap karein
   - Dropdown se naya role select karein (15 roles available hain)
   - Select karte hi role turant update ho jayega

### ⚠️ Important Notes:
- Yeh method **existing users ke roles change** karta hai
- **Naye users add nahi** kar sakte (abhi sirf backend se)
- Sirf **Admin** yeh kar sakta hai

---

## 🖥️ Method 2: Backend Se (Naye Users Add Karna)

Agar aapko **naya user add** karna hai, toh backend script use karni hogi.

### Step 1: Backend Folder Mein Jaiye
```bash
cd C:\Users\Dell\Desktop\NEW JOB\backend
```

### Step 2: User Data File Dekhe Ya Create Karein

Backend mein ek folder hai: `data/users.json`

**Example Format:**
```json
{
  "id": "user.email@bigsams.in",
  "name": "User Name",
  "role": "Sales",
  "password": "password123",
  "status": "active",
  "location": "Mumbai"
}
```

### Step 3: Database Mein Add Karein

**Option A: MongoDB Compass (GUI)**
1. MongoDB Compass open karein
2. Database connect karein (connection string .env file mein hai)
3. `nexus_oms` database → `users` collection
4. "Add Data" → "Insert Document"
5. JSON paste karke "Insert"

**Option B: Script Se (Bulk Users)**

Agar bahut saare users ek saath add karne hain:

1. `backend/seed_users_temp.js` file banayein:
```javascript
const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./models/User');

async function addUsers() {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        const newUsers = [
            {
                id: 'rahul.sharma@bigsams.in',
                name: 'Rahul Sharma',
                role: 'Sales',
                password: 'password123',
                status: 'active',
                location: 'Delhi'
            },
            {
                id: 'priya.patel@bigsams.in',
                name: 'Priya Patel',
                role: 'Credit Control',
                password: 'password123',
                status: 'active',
                location: 'Mumbai'
            }
            // Add more users here...
        ];

        for (const userData of newUsers) {
            const user = new User(userData);
            await user.save();
            console.log(`✅ Added: ${userData.name}`);
        }

        console.log('🎉 All users added!');
        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err.message);
        process.exit(1);
    }
}

addUsers();
```

2. Run karein:
```bash
node seed_users_temp.js
```

---

## 🎭 Available Roles (15 Total)

Yeh sab roles hain jo aap assign kar sakte hain:

| Role | Access | Dashboard Items Visible |
|:-----|:-------|:------------------------|
| **Admin** | EVERYTHING | Sab kuch + User Management + Admin Bypass |
| **Sales** | Order creation, customers | New Customer, Book Order, Stock Transfer |
| **Credit Control** | Credit approval | Credit Control, Credit Alerts |
| **WH Manager** | Warehouse oversight | Warehouse Operations |
| **WH House** | Warehouse operations | Warehouse Operations |
| **Warehouse** | Packing, inventory | Warehouse Operations |
| **QC Head** | Quality control | Quality Control (QC) |
| **Logistics Lead** | Logistics costing | Logistics Costing |
| **Logistics Team** | Logistics support | Logistics Costing |
| **Billing** | Billing operations | Invoicing |
| **ATL Executive** | Invoicing | Invoicing |
| **Hub Lead** | Fleet loading | Fleet Loading (Hub) |
| **Delivery Team** | Delivery execution | Delivery Execution |
| **Procurement** | Inbound materials | Procurement Gate |
| **Procurement Head** | Procurement approval | Procurement Gate |

---

## 🔄 Complete Workflow Example

### Scenario: Ek naye Sales person ko access dena

**Step 1: Backend se user add karein**
```json
{
  "id": "neha.singh@bigsams.in",
  "name": "Neha Singh",
  "role": "Sales",
  "password": "password123",
  "status": "active",
  "location": "Pune"
}
```

**Step 2: User ko credentials share karein**
- Email: `neha.singh@bigsams.in`
- Password: `password123`
- Unhe bolein pehli login pe password change karein

**Step 3: Agar role change karna ho**
- Animesh login → User Management
- Neha Singh ke aage edit icon
- Naya role select karein

**Step 4: Testing**
- Neha ke credentials se login karein
- Verify karein ki sahi screens dikh rahe hain
- Test order book karke dekho

---

## 🛡️ Security Best Practices

1. **Default Password:** Har naye user ko `password123` se start karein, phir unhe change karne bolein
2. **Admin Access:** Sirf trusted logo ko Admin role dein
3. **Regular Audit:** User Management screen se check karte raho ki kaun active hai
4. **Inactive Users:** Jo log kaam nahi karte, unka status "inactive" kar dein

---

## 🔧 Troubleshooting

### Problem: User login nahi ho paa raha
**Solution:**
```bash
cd backend
node debug-login.js
# Check if user exists and password is correct
```

### Problem: User ko galat screens dikh rahe hain
**Solution:**
- Admin → User Management → Role check karein
- Logout karke phir se login karein (refresh ke liye)

### Problem: Admin bypass panel nahi dikh raha
**Solution:**
- Verify karein user ka role exactly "Admin" hai (case-sensitive)

---

## 📊 Quick Reference: Role Assignment Strategy

**Essential Team:**
- 1 Admin (Animesh)
- 2-3 Sales (Order booking)
- 1 Credit Control (Approvals)
- 1-2 Warehouse (Operations)
- 1 Logistics Lead (Costing)
- 1 Hub Lead (Dispatch)

**Expansion:**
- More Sales reps based on regions
- QC Head for quality checks
- Procurement team for supplies

---

## 💡 Pro Tips

1. **Role Hierarchy:** Admin > Heads > Teams
2. **Regional Access:** Location field use karke region-wise access control
3. **Testing:** Har naye user ko add karne ke baad test login zaroor karein
4. **Documentation:** Ek Excel sheet banayein jismein sab users ka naam, email, role, aur access date ho

---

**Koi doubt hai toh bolo! Main aur detail mein samjha sakta hoon. 🚀**
