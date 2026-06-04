import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    final portfolioController = Get.find<PortfolioController>();
    
    final success = await portfolioController.sendContactMessage(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _messageController.text.trim(),
    );

    setState(() => _isSending = false);

    if (success) {
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      
      Get.snackbar(
        'Success',
        'Thank you! Your message was sent successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        maxWidth: 400,
        margin: const EdgeInsets.all(20),
      );
    } else {
      Get.snackbar(
        'Submission Failed',
        'Could not deliver message. Please check connection or try again.',
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
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final isDesktop = ResponsiveWidget.isDesktop(context);
      final profile = controller.profile.value;
      final phone = profile?.phone ?? "+880 1700-000000";

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? size.width * 0.08 : 24.0,
          vertical: 80.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: PortfolioTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Contact Me',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : PortfolioTheme.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Let's work together! Leave a message below or reach out directly:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 50),

            ResponsiveWidget(
              mobile: Column(
                children: [
                  _buildContactDetails(isDark, phone),
                  const SizedBox(height: 40),
                  _buildContactForm(isDark),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildContactDetails(isDark, phone),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 3,
                    child: _buildContactForm(isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContactDetails(bool isDark, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Get in Touch",
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : PortfolioTheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Feel free to ask any questions, request project estimates, or simply connect. I look forward to working with you!",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        
        _ContactInfoTile(
          icon: Icons.alternate_email_rounded,
          label: "Email",
          value: "sakil@example.com",
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _ContactInfoTile(
          icon: Icons.phone_android_rounded,
          label: "Phone",
          value: phone,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _ContactInfoTile(
          icon: Icons.location_on_rounded,
          label: "Location",
          value: "Dhaka, Bangladesh",
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildContactForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? PortfolioTheme.surfaceDark.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? PortfolioTheme.borderDark : PortfolioTheme.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Send Message",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : PortfolioTheme.secondary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Your full name",
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Your email address",
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Message Field
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Message",
                hintText: "Write your message here...",
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: PortfolioTheme.primaryGradient,
                  boxShadow: _isSending ? [] : PortfolioTheme.hoverGlowShadow,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSending ? null : _submitForm,
                  child: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "Send Message",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _ContactInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PortfolioTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: PortfolioTheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : PortfolioTheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
