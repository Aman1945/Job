# 🛠️ DigitalOcean Setup Step-by-Step Guide

Follow these steps to set up your production environment. 

---

## 1. Setup Photo Storage (DigitalOcean Spaces)
This will replace your local `uploads` folder.

1.  **Go to Dashboard** -> Click **Create** (top right) -> **Spaces**.
2.  **Choose a Region**: Select your nearest region (e.g., **Bangalore - blr1**).
3.  **CDN**: Leave "Enable CDN" **ON** (checked).
4.  **Choose a Name**: Give it a unique name like `nexus-storage-prod`.
5.  **Create Space**: Click the button at the bottom.
6.  **Access Keys**:
    - Go to **Settings** in the sidebar -> **API** -> **Spaces Access Keys**.
    - Click **Generate New Key**.
    - **COPY BOTH**: You will get a **Key** and a **Secret**. *Save them immediately!*

---

## 2. Setup Database (Managed MongoDB)
This is for your professional, backed-up database.

1.  **Click Create** -> **Databases**.
2.  **Choose Engine**: Select **MongoDB**.
3.  **Choose a Cluster Name**: Something like `nexus-db-prod`.
4.  **Database Configuration**:
    - **Single Node** (Self-managed) is fine for now (~$15/mo).
    - Select your **Region** (same as Spaces).
5.  **Wait for provision**: It will take 5-10 minutes to become "Active".
6.  **Connection Details**:
    - Once active, click on the DB name.
    - Go to **Overview** -> **Connection Details**.
    - Select **Connection String (URI)** from the dropdown. 
    - **COPY THIS**: It looks like `mongodb+srv://...`

---

## 3. Setup Application Server (Droplet)
This is where the actual code will run.

1.  **Click Create** -> **Droplets**.
2.  **Choose an Image**: **Ubuntu 22.04 (LTS)**.
3.  **Choose a Plan**: **Basic** -> **Regular**. 
    - Select the **$12/mo** plan (2GB RAM / 1 vCPU) for smooth performance.
4.  **Choose a Region**: (Same as others, e.g., Bangalore).
5.  **Authentication**:
    - Select **Password**.
    - Set a strong password (minimum 8 characters, numbers, symbols). **SAVE THIS.**
6.  **Choose a Hostname**: `nexus-oms-server`.
7.  **Create Droplet**: Click the button.
8.  **Get IP**: Once red circle turns green, copy the **IP Address** (e.g., `128.199.x.x`).

---

## 📝 Final Checklist for Me
Once you are done, send me these values:

1.  **Spaces**: Name, Key, and Secret.
2.  **MongoDB**: Connection String (URI).
3.  **Droplet**: IP Address and Password.

---

**Tip**: Don't worry about the $94 charge, it's just a test. Your $200 credits will cover everything for the next 2 months!
