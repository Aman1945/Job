# 🖥️ Server Access & Code Push Guide

Yeh guide aapko batayegi ki kaise aap apne Windows PC se DigitalOcean server ko control karenge aur apna backend code wahan bhejenge.

---

## 1. Computer se Server ko Kaise Access Karein?

Aap apne server ko "Remote Control" kar sakte hain in 2 tareekon se:

### Option A: Windows (PuTTY) - Recommended 🪟
1.  **Download:** [PuTTY download](https://www.putty.org/) karke install karein.
2.  **Connect:**
    - PuTTY kholiye.
    - **Host Name:** Mein apne Droplet ka IP daaliye (e.g., `143.198.x.x`).
    - **Port:** `22` (default).
    - **Open** pe click karein.
3.  **Login:**
    - Ek kaali screen khulegi. Wahana type karein: `root`
    - Phir apna Droplet ka **Password** daaliye. (⚠️ Password type karte waqt screen pe dikhega nahi, bas type karke Enter daba dein).
4.  ✅ **Ab aap server ke andar hain!**

---

## 2. Backend Code Ko Server Pe Kaise Bheinjein?

Hum "Push-Pull" method use karenge jo sabse professional hai:

### Step 1: Local PC se GitHub pe (Push)
1.  Apne PC ke terminal mein backend folder mein jaiye.
2.  Yeh commands chalaiye:
    ```bash
    git add .
    git commit -m "Production Update"
    git push origin main
    ```

### Step 2: Server pe GitHub se (Pull)
1.  PuTTY se server connect karein.
2.  Backend folder mein jaiye:
    ```bash
    cd /var/www/nexus-oms/backend
    ```
3.  GitHub se naya code khinch lijiye:
    ```bash
    git pull origin main
    ```
4.  Server ko restart karein taaki naya code chalu ho jaye:
    ```bash
    pm2 restart nexus-oms
    ```

---

## 🚀 Deployment Checklist

| Task | Command | Purpose |
| :--- | :--- | :--- |
| **Server Status** | `pm2 status` | Dekhne ke liye ki API chal rahi hai ya nahi. |
| **Logs Check** | `pm2 logs` | Agar koi error aa raha hai server pe. |
| **Dependencies** | `npm install` | Agar naya package add kiya hai code mein. |

**Maine detail guide yahan save kar di hai:**
👉 [SERVER_ACCESS_GUIDE.md](file:///C:/Users/Dell/Desktop/NEW%20JOB/docs/SERVER_ACCESS_GUIDE.md)

**Kya aap chahte hain ki main aapko PuTTY configure karne ka screenshot dikhaun ya command samjhaun?**
