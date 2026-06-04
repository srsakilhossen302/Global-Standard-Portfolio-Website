import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Obx(() {
      final skills = controller.skills;
      if (skills.isEmpty) return const SizedBox();
      final isDark = controller.isDarkMode.value;

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
                  'Technical Skills',
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
              "My professional technical toolbox categorized by domain:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),

            // Dynamic grid layout for skills
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                int crossAxisCount = 1;
                if (width >= 1000) {
                  crossAxisCount = 3;
                } else if (width >= 600) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: skills.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 210, // fixed height for skill cards to maintain uniformity
                  ),
                  itemBuilder: (context, index) {
                    final skillCat = skills[index];
                    return _SkillCategoryCard(
                      title: skillCat.category,
                      skills: skillCat.items,
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _SkillCategoryCard extends StatefulWidget {
  final String title;
  final List<String> skills;
  final bool isDark;

  const _SkillCategoryCard({
    required this.title,
    required this.skills,
    required this.isDark,
  });

  @override
  State<_SkillCategoryCard> createState() => _SkillCategoryCardState();
}

class _SkillCategoryCardState extends State<_SkillCategoryCard> {
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
                  ? PortfolioTheme.primary.withOpacity(0.06) 
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
            // Category title
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : PortfolioTheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Skills list wrap
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.skills.map((skill) {
                    return _SkillBadge(name: skill, isDark: widget.isDark);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBadge extends StatefulWidget {
  final String name;
  final bool isDark;

  const _SkillBadge({
    required this.name,
    required this.isDark,
  });

  @override
  State<_SkillBadge> createState() => _SkillBadgeState();
}

class _SkillBadgeState extends State<_SkillBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? PortfolioTheme.primary.withOpacity(0.15)
              : (widget.isDark ? const Color(0x0CFFFFFF) : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? PortfolioTheme.primary.withOpacity(0.5)
                : (widget.isDark ? PortfolioTheme.borderDark : PortfolioTheme.borderLight),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: _isHovered ? PortfolioTheme.accent : (widget.isDark ? Colors.white70 : PortfolioTheme.secondary),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
                color: _isHovered 
                    ? (widget.isDark ? Colors.white : PortfolioTheme.primary)
                    : (widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
