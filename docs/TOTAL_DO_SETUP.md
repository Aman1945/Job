# 🌊 DigitalOcean All-In-One Setup: Server, DB & Photos

Aapko apna poora system (Server + Database + Photos) DigitalOcean pe chalane ke liye yeh 3 cheezein setup karni hongi. Yeh ek "Complete Package" ki tarah kaam karega.

## 💰 1. Total Kharcha (Monthly)

| Service | Price | Purpose |
| :--- | :--- | :--- |
| **Droplet** | $12 | Aapka Backend API (server.js) chalega. |
| **Spaces** | $5 | Saari Photos (POD, Products) idhar store hongi. |
| **Database** | $0 - $15 | Data (Orders, Users) ke liye. |
| **Total** | **$17 - $32** | ~₹1,500 se ₹2,800 per month. |

---

## 🏗️ 2. Teeno Cheezein Kaise Kaam Karengi?

### **A. Photos (DigitalOcean Spaces)**
- Yeh Google Drive jaisa hai. 
- **Setup:** DigitalOcean dashboard mein "Spaces" create karein (Bangalore region).
- **Benefit:** Agar server crash bhi ho jaye, photos humesha safe rahengi.
- **Link:** Iska "Access Key" aur "Secret Key" hum `.env` file mein daalenge.

### **B. Server (DigitalOcean Droplet)**
- Yeh aapka main computer (Linux) hoga cloud pe.
- **Setup:** Ubuntu 22.04 Droplet create karein.
- **Kaam:** Yeh aapki API ko 24/7 chalayega. Jab app se "Book Order" click hoga, toh request isi server pe aayegi.

### **C. Database (2 Options)**
1. **Option 1 (Paisa Bachane ke liye):** Droplet ke andar hi MongoDB install kar lo. ($0 extra cost).
2. **Option 2 (Safe Rehne ke liye):** DigitalOcean ka "Managed MongoDB" lo. ($15 extra). Yeh backup aur safety khud sambhalta hai.

---

## 🔗 3. Inko Connect Kaise Karein? (The `.env` File)

Server pe aapko ek `.env` file banani hogi jisme teeno ka address hoga:

```env
# 1. Server settings
PORT=3000

# 2. Database connection address (MongoDB)
MONGODB_URI=mongodb+srv://admin:pass@db-address.com/nexus-oms

# 3. Photo storage settings (Spaces)
DO_SPACES_ACCESS_KEY=YOUR_ACCESS_KEY
DO_SPACES_SECRET_KEY=YOUR_SECRET_KEY
DO_SPACES_BUCKET=nexus-oms-photos
DO_SPACES_ENDPOINT=blr1.digitaloceanspaces.com
```

---

## 🚀 4. Setup Karne Ka Sabse Aasan Tareeka

1. **GitHub se connect:** Apna code GitHub pe push karke server pe `git clone` kar lo.
2. **PM2 use karo:** `pm2 start server.js` command chalao taaki server band na ho.
3. **Nginx setup:** `https://` (SSL) ke liye Nginx configure kar lo.

Maine iske liye ek **Full Step-by-Step Guide** pehle hi aapke project folder mein bana di hai:
👉 **[DIGITALOCEAN_DEPLOYMENT_GUIDE.md](file:///C:/Users/Dell/Desktop/NEW%20JOB/DIGITALOCEAN_DEPLOYMENT_GUIDE.md)**

**Kya aap chahte hain ki main abhi live aapke server pe setup shuru karne mein help karun?**
