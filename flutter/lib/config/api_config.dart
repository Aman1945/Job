/// API Configuration for Nexus OMS
/// 
/// This file contains all API keys and server configuration.
/// 
/// 🔑 TO GET YOUR OWN GEMINI API KEY:
/// 1. Visit: https://aistudio.google.com/app/apikey
/// 2. Sign in with your Google account
/// 3. Click "Create API Key"
/// 4. Copy the key and replace it below
/// 
/// For detailed instructions, see: GEMINI_SETUP.md
class ApiConfig {
  // ==================== GEMINI AI CONFIGURATION ====================
  // 🔑 Replace this with your own Gemini API key
  // Get your key from: https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'AIzSyBSRHNpNsgK_lshamksmQGulHHrN9BJEA';
  
  // ==================== SERVER CONFIGURATION ====================
  // Set to true ONLY when testing with local backend
  static const bool useLocalServer = false;
  
  // Local server IP (for Android Emulator use 10.0.2.2, for iOS Simulator use localhost)
  // 💡 FOR PHYSICAL PHONE: Run 'ipconfig' on your PC and use your IPv4 address (e.g., 192.168.1.5)
  static const String localIp = '192.168.0.123'; // Replace with your PC IP address
  
  // Production server address (Nexus OMS Backend on Render)
  static const String productionServer = 'nexus-oms-backend.onrender.com';
  
  // ==================== COMPUTED PROPERTIES ====================
  static String get serverAddress {
    if (useLocalServer) {
      return '$localIp:3000';
    }
    return productionServer;
  }
  
  static String get baseUrl => useLocalServer 
      ? 'http://$serverAddress/api' 
      : 'https://$serverAddress/api';
      
  static String get socketUrl => useLocalServer 
      ? 'http://$serverAddress' 
      : 'https://$serverAddress';
}
