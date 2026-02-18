# 📧 Gemini API Setup - Complete Step-by-Step Guide

---

**Subject:** How to Get Your Own Google Gemini API Key for Nexus OMS

**To:** Development Team / Users

**Date:** February 17, 2026

---

## 🎯 Purpose

This email provides complete step-by-step instructions on how to obtain your own Google Gemini API key and integrate it into the Nexus OMS Flutter application.

---

## 📋 Prerequisites

Before you begin, ensure you have:
- ✅ A Google account (Gmail)
- ✅ Internet connection
- ✅ Access to the Nexus OMS Flutter project

---

## 🔑 Step-by-Step Guide to Get Gemini API Key

### **STEP 1: Visit Google AI Studio**

1. Open your web browser (Chrome, Firefox, Edge, etc.)
2. Navigate to one of these URLs:
   - **Primary:** https://aistudio.google.com/app/apikey
   - **Alternative:** https://makersuite.google.com/app/apikey

3. You will see the Google AI Studio homepage

---

### **STEP 2: Sign In to Your Google Account**

1. Click on **"Sign In"** button (top right corner)
2. Enter your **Gmail email address**
3. Enter your **password**
4. Complete any 2-factor authentication if enabled
5. You should now be logged into Google AI Studio

---

### **STEP 3: Create Your API Key**

1. Once logged in, you'll see the **API Keys** page
2. Click on the blue **"Create API Key"** button
3. A dialog box will appear with two options:
   - **Create API key in new project** (recommended for first-time users)
   - **Create API key in existing project** (if you already have a Google Cloud project)

4. Select **"Create API key in new project"**
5. Wait 5-10 seconds while Google creates your key

---

### **STEP 4: Copy Your API Key**

1. Your API key will be displayed in a popup
2. It will look something like this:
   ```
   AIzaSyBXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

3. Click the **"Copy"** icon next to the key
4. **IMPORTANT:** Store this key safely! You won't be able to see it again in the same way

---

### **STEP 5: Add API Key to Nexus OMS Project**

#### **Option A: Direct Configuration (Quick Method)**

1. Open your Nexus OMS Flutter project in VS Code or Android Studio

2. Navigate to the file:
   ```
   lib/config/api_config.dart
   ```

3. Find this line (around line 15):
   ```dart
   static const String geminiApiKey = 'AIzSyBSRHNpNsgK_lshamksmQGulHHrN9BJEA';
   ```

4. Replace the existing key with YOUR key:
   ```dart
   static const String geminiApiKey = 'YOUR_API_KEY_HERE';
   ```

5. Save the file (Ctrl+S or Cmd+S)

#### **Option B: Environment Variables (Recommended for Production)**

1. In the `flutter` folder, create a new file named `.env`

2. Add this line to the `.env` file:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```

3. Save the file

4. The `.env` file is already in `.gitignore`, so your key won't be committed to Git

---

### **STEP 6: Verify Installation**

1. Open terminal in your Flutter project directory

2. Run the following command to get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. Navigate to any **Order Details** screen in the app

5. Look for the **"AI Credit Intelligence"** section

6. If you see AI-generated insights, your API key is working! ✅

---

## 🔒 Security Best Practices

### ⚠️ **IMPORTANT - DO NOT:**
- ❌ Share your API key publicly
- ❌ Commit it to GitHub/GitLab (it's in `.gitignore`)
- ❌ Post it in Slack/Discord/WhatsApp
- ❌ Email it in plain text

### ✅ **DO:**
- ✅ Store it securely like a password
- ✅ Use environment variables for production
- ✅ Regenerate if accidentally exposed
- ✅ Monitor usage in Google AI Studio

---

## 💰 Pricing & Limits

### **Free Tier (No Credit Card Required)**
- **60 requests per minute**
- **1,500 requests per day**
- **1 million tokens per month**
- Perfect for development and testing

### **When You Need More**
- Visit: https://ai.google.dev/pricing
- Paid plans available with higher limits
- Pay-as-you-go pricing

---

## 🔧 Troubleshooting

### **Problem 1: "API Key Invalid" Error**

**Solution:**
1. Double-check you copied the entire key (no spaces)
2. Verify the key in Google AI Studio hasn't been deleted
3. Try regenerating a new key

---

### **Problem 2: "Quota Exceeded" Error**

**Solution:**
1. You've hit the free tier limit (1,500/day or 60/minute)
2. Wait for the quota to reset (resets daily at midnight PST)
3. Consider upgrading to a paid plan if needed

---

### **Problem 3: "Network Error"**

**Solution:**
1. Check your internet connection
2. Verify firewall isn't blocking `generativelanguage.googleapis.com`
3. Try again after a few minutes

---

### **Problem 4: API Key Not Working in App**

**Solution:**
1. Ensure you saved the `api_config.dart` file
2. Run `flutter pub get` again
3. Restart the app completely (stop and run again)
4. Check for typos in the API key

---

## 📱 How Gemini AI is Used in Nexus OMS

The app uses Gemini AI for:

1. **Credit Risk Assessment**
   - Analyzes customer payment history
   - Provides AI-powered credit recommendations
   - Helps approve/reject orders intelligently

2. **Smart Insights**
   - Generates business insights from data
   - Provides recommendations for order management
   - Helps identify trends and patterns

3. **Automated Analysis**
   - Processes large datasets quickly
   - Generates reports and summaries
   - Assists in decision-making

---

## 🔗 Useful Links

| Resource | URL |
|----------|-----|
| Google AI Studio | https://aistudio.google.com/ |
| Get API Key | https://aistudio.google.com/app/apikey |
| Documentation | https://ai.google.dev/docs |
| Pricing | https://ai.google.dev/pricing |
| Gemini Models | https://ai.google.dev/models/gemini |

---

## 📞 Support & Help

If you encounter any issues:

1. **Check the detailed guide:** `flutter/GEMINI_SETUP.md` in the project
2. **Review troubleshooting section** above
3. **Check Google AI documentation:** https://ai.google.dev/docs
4. **Contact the development team** with:
   - Screenshot of the error
   - Steps you followed
   - Your Flutter version (`flutter --version`)

---

## 📝 Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│  QUICK STEPS TO GET GEMINI API KEY                     │
├─────────────────────────────────────────────────────────┤
│  1. Visit: https://aistudio.google.com/app/apikey      │
│  2. Sign in with Google account                        │
│  3. Click "Create API Key"                             │
│  4. Copy the generated key                             │
│  5. Paste in: lib/config/api_config.dart               │
│  6. Save file and run: flutter pub get                 │
│  7. Test in app's Order Details screen                 │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Checklist

Before you finish, ensure:

- [ ] I have a Google account
- [ ] I visited Google AI Studio
- [ ] I created an API key
- [ ] I copied the API key safely
- [ ] I added the key to `api_config.dart`
- [ ] I saved the file
- [ ] I ran `flutter pub get`
- [ ] I tested the app
- [ ] The AI features are working

---

## 🎉 Congratulations!

You've successfully integrated Google Gemini AI into your Nexus OMS application!

Your app now has powerful AI capabilities for:
- Credit risk analysis
- Smart business insights
- Automated decision support

---

**Questions?** Reply to this email or check the documentation.

**Happy Coding!** 🚀

---

*This guide was created on February 17, 2026*  
*Nexus OMS Development Team*
