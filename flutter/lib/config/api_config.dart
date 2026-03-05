class ApiConfig {
  // ==================== SERVER ====================
  static const String _server = '168.144.31.254';

  static String get baseUrl => 'http://$_server/api';
  static String get socketUrl => 'http://$_server';

  // ==================== GEMINI AI ====================
  static const String geminiApiKey = 'AIzSyBSRHNpNsgK_lshamksmQGulHHrN9BJEA';
}
