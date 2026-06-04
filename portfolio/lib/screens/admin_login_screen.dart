import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/admin_controller.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final adminController = Get.find<AdminController>();
    final success = await adminController.login(_passwordController.text.trim());

    if (success) {
      Get.offNamed('/admin/dashboard');
    } else {
      Get.snackbar(
        'Login Failed',
        'Incorrect password. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        maxWidth: 400,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolioController = Get.find<PortfolioController>();
    final isDark = portfolioController.isDarkMode.value;

    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Positioned.fill(
            child: Container(
              color: isDark ? PortfolioTheme.bgDark : PortfolioTheme.bgLight,
            ),
          ),
          // Glow Circles in Background
          if (isDark)
            Positioned(
              top: Get.height * 0.2,
              left: Get.width * 0.2,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PortfolioTheme.primary.withOpacity(0.05),
                ),
              ),
            ),
          
          // Login Form Card
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? PortfolioTheme.surfaceDark.withOpacity(0.4) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? PortfolioTheme.borderDark : PortfolioTheme.borderLight,
                    width: 1.5,
                  ),
                  boxShadow: PortfolioTheme.premiumShadow(isDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Logo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sakil Hossen",
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : PortfolioTheme.secondary,
                                ),
                              ),
                              Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.only(left: 4, top: 12),
                                decoration: const BoxDecoration(
                                  color: PortfolioTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Admin Authentication Panel",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Password input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter admin password",
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                ),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 28),
                          
                          // Submit button
                          Obx(() {
                            final isSaving = Get.find<AdminController>().isSaving.value;
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: PortfolioTheme.primaryGradient,
                                  boxShadow: isSaving ? [] : PortfolioTheme.hoverGlowShadow,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: isSaving ? null : _handleLogin,
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          "Login",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                          
                          // Back to Public Site
                          TextButton.icon(
                            icon: const Icon(Icons.arrow_back_rounded, size: 16),
                            label: const Text("Back to Website"),
                            style: TextButton.styleFrom(
                              foregroundColor: PortfolioTheme.accent,
                            ),
                            onPressed: () => Get.offNamed('/'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
