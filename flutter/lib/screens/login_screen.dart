import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    try {
      await provider.login(_emailController.text, _passwordController.text);
    } catch (e) {
      if (!mounted) return;
      String error = e.toString().replaceFirst('Exception: ', '').trim();
      
      String displayMessage;
      bool isTop = false;

      if (error == 'EMAIL_NOT_FOUND') {
        displayMessage = 'Email not registered. Please contact Admin';
      } else if (error == 'WRONG_PASSWORD' || error == 'Invalid credentials') {
        displayMessage = 'Password wrong';
      } else {
        displayMessage = error;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20), // Always show at bottom
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.emerald950,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 80, color: NexusTheme.emerald400),
                const SizedBox(height: 16),
                Text(
                  'NEXUS OMS',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enterprise Order Terminal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NexusTheme.emerald300),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'User ID / Email',
                    labelStyle: const TextStyle(color: NexusTheme.emerald300),
                    prefixIcon: const Icon(Icons.person_outline, color: NexusTheme.emerald400),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: NexusTheme.emerald400),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: NexusTheme.emerald300),
                    prefixIcon: const Icon(Icons.lock_outline, color: NexusTheme.emerald400),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: NexusTheme.emerald400),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<NexusProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50, // Slightly taller for better feel
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NexusTheme.emerald500,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: NexusTheme.emerald500.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: provider.isLoading ? 0 : 10,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('AUTHENTICATE', 
                                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
