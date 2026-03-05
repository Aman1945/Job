# Step-by-Step: Unlock MongoDB Atlas for Migration

Follow these steps to allow me to pull data from your old database:

### 1. Project Select karein
- Screenshot mein jo **"Project 0"** blue color ka link hai center mein, uspar click karein.

### 2. Network Access (IP Whitelist)
- Project ke andar jaane ke baad, left sidebar mein **"Security"** section dhundho.
- Usme **"Network Access"** par click karo.
- **"Add IP Address"** button dabao.
- **"Allow Access from Anywhere"** (0.0.0.0/0) select karke confirm karo. (Yeh temporary hai, migration ke baad band kar denge).

### 3. Connection String (URI) nikaalein - Final Step!
- Left sidebar mein top par **"Database"** (under Deployment) par click karo.
- Aapka cluster (`Cluster0` ya `Project 0`) dikhega. Uske paas **"Connect"** button hoga.
- **"Drivers"** select karein.
- Jo link (URI) wahan dikhega, woh copy karke mujhe yahan paste kar do!

**Password Note**: Agar aapne password naya reset kiya hai, toh woh bhi bata dena.


**Bas ye URI milte hi main migration start kar dunga!** 🚀
