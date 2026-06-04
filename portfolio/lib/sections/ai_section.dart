import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';

class AiSection extends StatelessWidget {
  const AiSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    IconData getIconData(String iconName) {
      switch (iconName.toLowerCase()) {
        case 'code':
          return Icons.code_rounded;
        case 'psychology':
          return Icons.psychology_rounded;
        case 'bolt':
          return Icons.bolt_rounded;
        case 'analytics':
          return Icons.analytics_rounded;
        case 'auto_awesome':
          return Icons.auto_awesome_rounded;
        case 'bug_report':
          return Icons.bug_report_rounded;
        default:
          return Icons.auto_awesome_rounded;
      }
    }

    return Obx(() {
      final isDark = controller.isDarkMode.value;
      final aiWorkflowList = controller.aiWorkflow;

      if (aiWorkflowList.isEmpty) {
        return const SizedBox();
      }

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
                  'AI Development Workflow',
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
              "How I leverage advanced AI agents and Large Language Models professionally to supercharge productivity:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),

            // Grid Layout
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
                  itemCount: aiWorkflowList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 160,
                  ),
                  itemBuilder: (context, index) {
                    final point = aiWorkflowList[index];
                    return _AiPointCard(
                      title: point.title,
                      description: point.description,
                      icon: getIconData(point.icon),
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

class _AiPointCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;

  const _AiPointCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
  });

  @override
  State<_AiPointCard> createState() => _AiPointCardState();
}

class _AiPointCardState extends State<_AiPointCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDark
              ? (_isHovered 
                  ? PortfolioTheme.primary.withOpacity(0.06) 
                  : PortfolioTheme.surfaceDark.withOpacity(0.4))
              : (_isHovered 
                  ? PortfolioTheme.primary.withOpacity(0.02) 
                  : PortfolioTheme.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? PortfolioTheme.primary.withOpacity(0.5)
                : (widget.isDark ? PortfolioTheme.borderDark : PortfolioTheme.borderLight),
            width: 1.5,
          ),
          boxShadow: _isHovered ? PortfolioTheme.hoverGlowShadow : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isHovered 
                    ? PortfolioTheme.accent.withOpacity(0.2) 
                    : PortfolioTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: _isHovered ? PortfolioTheme.accent : PortfolioTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : PortfolioTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
