import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';
import '../widgets/portfolio_image.dart';

class ReferencesSection extends StatelessWidget {
  const ReferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;
    final isDark = controller.isDarkMode.value;
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Obx(() {
      final referencesList = controller.references;
      if (referencesList.isEmpty) return const SizedBox();

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
                  'Client Reviews',
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
              "What tech leads and clients say about collaborating with me:",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),

            // Responsive testimonial cards list/grid
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                int crossAxisCount = 1;
                if (width >= 900) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: referencesList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    mainAxisExtent: 220, // fixed height for review cards
                  ),
                  itemBuilder: (context, index) {
                    final ref = referencesList[index];
                    return _TestimonialCard(
                      name: ref.clientName,
                      company: ref.clientCompany,
                      comment: ref.clientComment,
                      rating: ref.clientRating,
                      image: ref.clientImage,
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

class _TestimonialCard extends StatefulWidget {
  final String name;
  final String company;
  final String comment;
  final double rating;
  final String image;
  final bool isDark;

  const _TestimonialCard({
    required this.name,
    required this.company,
    required this.comment,
    required this.rating,
    required this.image,
    required this.isDark,
  });

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Comment / Testimonial text
            Expanded(
              child: Text(
                '"${widget.comment}"',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  height: 1.45,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            
            // 2. Client Profile Details Row
            Row(
              children: [
                // Avatar image (decodes base64/network/asset)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PortfolioTheme.accent,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: PortfolioImage(
                      imageSource: widget.image,
                      fallbackIcon: Icons.person_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Name & company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : PortfolioTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.company,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Rating stars
                Row(
                  children: List.generate(5, (index) {
                    final starVal = index + 1;
                    if (widget.rating >= starVal) {
                      return const Icon(Icons.star_rounded, color: Colors.amber, size: 16);
                    } else if (widget.rating >= starVal - 0.5) {
                      return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 16);
                    } else {
                      return Icon(Icons.star_border_rounded, color: Colors.grey.shade400, size: 16);
                    }
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
