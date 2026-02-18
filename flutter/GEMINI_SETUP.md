# 🤖 Gemini AI Setup Guide

This guide explains how to get your own Google Gemini API key and integrate it into the Nexus OMS application.

## 📋 Prerequisites

- A Google account
- Internet connection

## 🔑 Getting Your Gemini API Key

### Step 1: Visit Google AI Studio

1. Open your browser and go to: **[https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)**
   - Or visit: **[https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)**

2. Sign in with your Google account

### Step 2: Create API Key

1. Click on **"Create API Key"** button
2. Select an existing Google Cloud project or create a new one
3. Your API key will be generated instantly
4. **Important**: Copy the API key immediately and store it securely

### Step 3: API Key Security

> [!WARNING]
> - Never share your API key publicly
> - Don't commit it to version control (it's already in `.gitignore`)
> - Keep it secure like a password

## 🔧 Adding Your API Key to the App

### Method 1: Update Configuration File (Recommended)

1. Open the file: `lib/config/api_config.dart`

2. Replace the existing API key with your own:

```dart
class ApiConfig {
  // Gemini API Configuration
  static const String geminiApiKey = 'YOUR_API_KEY_HERE'; // 👈 Replace this
  
  // ... rest of the configuration
}
```

### Method 2: Environment Variables (Production)

For production deployments, it's better to use environment variables:

1. Create a `.env` file in the `flutter` directory:

```env
GEMINI_API_KEY=your_actual_api_key_here
```

2. Update `api_config.dart` to read from environment:

```dart
static const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'YOUR_FALLBACK_KEY',
);
```

3. Run the app with the environment variable:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_actual_api_key_here
```

## 📱 Using Gemini in the App

The app uses Gemini AI for:

1. **Credit Risk Assessment** - AI-powered credit insights for customer orders
2. **Smart Recommendations** - Intelligent suggestions for order management
3. **Data Analysis** - Automated insights from business data

### Example Usage

The `GeminiService` is already integrated. Here's how it's used:

```dart
import 'package:nexus_oms_mobile/services/gemini_service.dart';

final geminiService = GeminiService();

// Generate credit insight
final insight = await geminiService.generateCreditInsight(
  customerId: 'CUST-001',
  customerName: 'ABC Distributors',
  orderValue: 50000,
  outstandingBalance: 25000,
  creditLimit: 100000,
);

print(insight);
```

## 💰 Pricing & Limits

### Free Tier
- **60 requests per minute**
- **1,500 requests per day**
- **1 million tokens per month**

### Paid Tier
- Higher rate limits
- More tokens
- Priority support

For current pricing, visit: [Google AI Pricing](https://ai.google.dev/pricing)

## 🔍 Testing Your API Key

To verify your API key is working:

1. Run the Flutter app
2. Navigate to any order details screen
3. Check if the "AI Credit Intelligence" section loads
4. If you see AI-generated insights, your key is working! ✅

## ❌ Troubleshooting

### "API Key Invalid" Error

- Double-check you copied the entire key
- Ensure there are no extra spaces
- Verify the key hasn't been deleted from Google AI Studio

### "Quota Exceeded" Error

- You've hit the free tier limit
- Wait for the quota to reset (daily/monthly)
- Consider upgrading to a paid plan

### "Network Error"

- Check your internet connection
- Verify firewall settings aren't blocking Google AI APIs
- Try again after a few moments

## 🔗 Useful Links

- [Google AI Studio](https://aistudio.google.com/)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [API Key Management](https://aistudio.google.com/app/apikey)
- [Pricing Information](https://ai.google.dev/pricing)

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the [official documentation](https://ai.google.dev/docs)
3. Contact the development team

---

**Last Updated**: February 2026
