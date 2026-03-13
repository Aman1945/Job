import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isOtpLogin = false;
  bool _otpSent = false;

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      bool success = false;
      if (_isOtpLogin) {
        if (!_otpSent) {
          // Send OTP logic
          await authProvider.sendOtp(_phoneController.text.trim());
          setState(() => _otpSent = true);
          return;
        } else {
          // Verify OTP logic
          success = await authProvider.verifyOtp(_phoneController.text.trim(), _otpController.text.trim());
        }
      } else {
        success = await authProvider.login(
          _emailController.text.trim(), 
          _passwordController.text.trim()
        );
      }
      
      if (success && mounted) {
        final nexusProvider = Provider.of<NexusProvider>(context, listen: false);
        nexusProvider.setCurrentUser(authProvider.currentUser);
        nexusProvider.setToken(authProvider.token);
        nexusProvider.refreshData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Left side - Branding (Hidden on mobile if needed, but keeping simple for now)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [NexusTheme.indigo900, NexusTheme.indigo700],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(Icons.shield_outlined, size: 100, color: Colors.white),
                    ),
                    const SizedBox(height: 48),
                    const Text('NEXUS OMS', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    const SizedBox(height: 16),
                    Text('Enterprise Resource Orchestration', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          
          // Right side - Login Form
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nexus OMS', style: TextStyle(color: NexusTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Text(
                    _isOtpLogin ? 'Biometric / OTP Access' : 'Secure Authentication',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOtpLogin ? 'Enter your registered mobile to receive a secure code.' : 'Access your enterprise dashboard with credentials.',
                    style: const TextStyle(color: NexusTheme.slate500, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  
                  if (!_isOtpLogin) ...[
                    _buildField('USER IDENTIFIER', Icons.person_outline, _emailController, 'Enter employee ID or email'),
                    const SizedBox(height: 24),
                    _buildField('PASSWORD', Icons.lock_outline, _passwordController, '••••••••', isPassword: true),
                  ] else ...[
                    if (!_otpSent)
                      _buildField('MOBILE NUMBER', Icons.phone_android_rounded, _phoneController, '+91 00000-00000')
                    else
                      _buildField('6-DIGIT OTP', Icons.sms_outlined, _otpController, '000 000'),
                  ],
                  
                  const SizedBox(height: 40),
                  
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NexusTheme.indigo600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: auth.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_isOtpLogin && !_otpSent ? 'SEND SECURE OTP' : 'ENTER TERMINAL', 
                                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _isOtpLogin = !_isOtpLogin;
                        _otpSent = false;
                      }),
                      child: Text(
                        _isOtpLogin ? 'BACK TO PASSWORD LOGIN' : 'USE OTP AUTHENTICATION',
                        style: const TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: NexusTheme.slate900, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              icon: Icon(icon, color: NexusTheme.slate400, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: NexusTheme.slate300, fontWeight: FontWeight.w500),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
