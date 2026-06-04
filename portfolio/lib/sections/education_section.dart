import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;
    final isDark = controller.isDarkMode.value;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Obx(() {
      final educationList = controller.education;
      if (educationList.isEmpty) return const SizedBox();

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
                  'Education & Training',
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
              "My academic qualifications and industrial training credentials:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),

            // Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                if (width >= 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: educationList.map((edu) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _EducationCard(
                            institution: edu.institution,
                            degree: edu.degree,
                            duration: edu.duration,
                            details: edu.details,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    children: educationList.map((edu) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: _EducationCard(
                          institution: edu.institution,
                          degree: edu.degree,
                          duration: edu.duration,
                          details: edu.details,
                          isDark: isDark,
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      );
    });
  }
}

class _EducationCard extends StatefulWidget {
  final String institution;
  final String degree;
  final String duration;
  final String details;
  final bool isDark;

  const _EducationCard({
    required this.institution,
    required this.degree,
    required this.duration,
    required this.details,
    required this.isDark,
  });

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark
              ? (_isHovered 
                  ? PortfolioTheme.primary.withOpacity(0.05) 
                  : PortfolioTheme.surfaceDark.withOpacity(0.4))
              : (_isHovered 
                  ? PortfolioTheme.primary.withOpacity(0.02) 
                  : PortfolioTheme.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? PortfolioTheme.primary.withOpacity(0.5)
                : (widget.isDark ? PortfolioTheme.borderDark : PortfolioTheme.borderLight),
            width: 1.5,
          ),
          boxShadow: _isHovered 
              ? PortfolioTheme.hoverGlowShadow 
              : (widget.isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: PortfolioTheme.accent,
                  size: 28,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PortfolioTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.duration,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PortfolioTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Degree / Title
            Text(
              widget.degree,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : PortfolioTheme.secondary,
              ),
            ),
            const SizedBox(height: 6),
            
            // Institution
            Text(
              widget.institution,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            
            // Details
            Text(
              widget.details,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
