import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Obx(() {
      final experienceList = controller.experience;
      final isDark = controller.isDarkMode.value;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? size.width * 0.08 : 24.0,
          vertical: 80.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                Expanded(
                  child: Text(
                    'Work Experience',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : PortfolioTheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "My professional journey and agency contributions:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 50),

            // Vertical Timeline Layout
            Column(
              children: experienceList.asMap().entries.map((entry) {
                final index = entry.key;
                final exp = entry.value;
                return _TimelineItem(
                  role: exp.role,
                  company: exp.company,
                  duration: exp.duration,
                  achievements: exp.achievements,
                  isDark: isDark,
                  isLast: index == experienceList.length - 1,
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _TimelineItem extends StatelessWidget {
  final String role;
  final String company;
  final String duration;
  final List<String> achievements;
  final bool isDark;
  final bool isLast;

  const _TimelineItem({
    required this.role,
    required this.company,
    required this.duration,
    required this.achievements,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Timeline line
        if (!isLast)
          Positioned(
            left: 7, // Center of the 16px circle
            top: 16,
            bottom: 0,
            child: Container(
              width: 2,
              color: isDark ? PortfolioTheme.borderDark : Colors.black12,
            ),
          ),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator (circle)
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                gradient: PortfolioTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PortfolioTheme.primary.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Timeline Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: _ExperienceCard(
                  role: role,
                  company: company,
                  duration: duration,
                  achievements: achievements,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final String role;
  final String company;
  final String duration;
  final List<String> achievements;
  final bool isDark;

  const _ExperienceCard({
    required this.role,
    required this.company,
    required this.duration,
    required this.achievements,
    required this.isDark,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
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
                : (widget.isDark
                      ? PortfolioTheme.borderDark
                      : PortfolioTheme.borderLight),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? PortfolioTheme.hoverGlowShadow
              : (widget.isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Role and Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.role,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? Colors.white
                              : PortfolioTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.company,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PortfolioTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: PortfolioTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.duration,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: PortfolioTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Achievement Bullet Points
            ...widget.achievements.map((achievement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // Emerald bullet point dot
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        achievement,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
