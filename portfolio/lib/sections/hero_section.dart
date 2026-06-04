import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/portfolio_controller.dart';
import '../theme/portfolio_theme.dart';
import '../widgets/responsive_widget.dart';
import '../widgets/portfolio_image.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onContactTap;

  const HeroSection({
    super.key,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final size = MediaQuery.of(context).size;
    final isMobile = ResponsiveWidget.isMobile(context);
    final isDesktop = ResponsiveWidget.isDesktop(context);

    return Obx(() {
      final profile = controller.profile.value;
      final isDark = controller.isDarkMode.value;
      
      final name = profile?.name ?? "Sakil Hossen";
      final title = profile?.title ?? "Flutter Mobile Application Developer";
      final tagline = profile?.tagline ?? "Available for Hire & Projects";
      final bio = profile?.bio ?? "I design and build ultra-premium, high-performance, and responsive applications across Android, iOS, and Web. Passionate about beautiful UI/UX, micro-animations, and clean architecture.";
      final cvUrl = profile?.cvUrl ?? "https://github.com/sakil";

      return Container(
        constraints: BoxConstraints(
          minHeight: isMobile ? size.height * 0.75 : size.height * 0.85,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? size.width * 0.08 : 24.0,
          vertical: 60.0,
        ),
        child: ResponsiveWidget(
          mobile: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeroGraphic(size: isMobile ? 180 : 260),
              const SizedBox(height: 40),
              _HeroTextContent(
                name: name,
                title: title,
                tagline: tagline,
                bio: bio,
                cvUrl: cvUrl,
                onContactTap: onContactTap,
                alignCenter: true,
                isDark: isDark,
              ),
            ],
          ),
          desktop: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: _HeroTextContent(
                  name: name,
                  title: title,
                  tagline: tagline,
                  bio: bio,
                  cvUrl: cvUrl,
                  onContactTap: onContactTap,
                  alignCenter: false,
                  isDark: isDark,
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: HeroGraphic(size: size.width * 0.22 > 320 ? size.width * 0.22 : 320),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _HeroTextContent extends StatelessWidget {
  final String name;
  final String title;
  final String tagline;
  final String bio;
  final String cvUrl;
  final VoidCallback onContactTap;
  final bool alignCenter;
  final bool isDark;

  const _HeroTextContent({
    required this.name,
    required this.title,
    required this.tagline,
    required this.bio,
    required this.cvUrl,
    required this.onContactTap,
    required this.alignCenter,
    required this.isDark,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final alignment = alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = alignCenter ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      children: [
        // Welcome Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: PortfolioTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: PortfolioTheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981), // Emerald indicator
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tagline,
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF10B981) : PortfolioTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Name Header
        Text(
          "Hey, I am",
          style: GoogleFonts.outfit(
            fontSize: alignCenter ? 24 : 32,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => PortfolioTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            name,
            textAlign: textAlign,
            style: GoogleFonts.outfit(
              fontSize: alignCenter ? 46 : 64,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Subtitle / Profession
        Text(
          title,
          textAlign: textAlign,
          style: GoogleFonts.outfit(
            fontSize: alignCenter ? 20 : 24,
            fontWeight: FontWeight.w600,
            color: PortfolioTheme.accent,
          ),
        ),
        const SizedBox(height: 20),
        
        // Short bio
        SizedBox(
          width: 540,
          child: Text(
            bio,
            textAlign: textAlign,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 36),
        
        // Action Buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: alignCenter ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _AnimatedHeroButton(
              text: 'Contact Me',
              isPrimary: true,
              onPressed: onContactTap,
            ),
            _AnimatedHeroButton(
              text: 'View Projects',
              isPrimary: false,
              onPressed: () => controller.scrollToSection(4),
            ),
            _AnimatedHeroButton(
              text: 'Download CV',
              isPrimary: false,
              onPressed: () => _launchUrl(cvUrl),
            ),
          ],
        ),
        const SizedBox(height: 40),
        
        // Social Media Icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SocialIcon(icon: Icons.code_rounded, url: 'https://github.com/sakil', tooltip: 'GitHub'),
            const SizedBox(width: 16),
            _SocialIcon(icon: Icons.chat_bubble_outline_rounded, url: 'https://linkedin.com', tooltip: 'LinkedIn'),
            const SizedBox(width: 16),
            _SocialIcon(icon: Icons.alternate_email_rounded, url: 'mailto:sakil@example.com', tooltip: 'Email'),
          ],
        ),
      ],
    );
  }
}

class _AnimatedHeroButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _AnimatedHeroButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_AnimatedHeroButton> createState() => _AnimatedHeroButtonState();
}

class _AnimatedHeroButtonState extends State<_AnimatedHeroButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final isDark = controller.isDarkMode.value;

    final gradient = widget.isPrimary 
        ? PortfolioTheme.primaryGradient 
        : const LinearGradient(colors: [Colors.transparent, Colors.transparent]);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: gradient,
          border: widget.isPrimary 
              ? null 
              : Border.all(
                  color: _isHovered 
                      ? PortfolioTheme.primary 
                      : (isDark ? PortfolioTheme.borderDark : Colors.black26),
                  width: 1.5,
                ),
          boxShadow: widget.isPrimary && _isHovered 
              ? PortfolioTheme.hoverGlowShadow 
              : [],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: widget.isPrimary 
                ? Colors.white 
                : (isDark ? Colors.white : PortfolioTheme.secondary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String url;
  final String tooltip;

  const _SocialIcon({
    required this.icon,
    required this.url,
    required this.tooltip,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final isDark = controller.isDarkMode.value;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _launchUrl,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isHovered 
                  ? PortfolioTheme.primary.withOpacity(0.15) 
                  : (isDark ? const Color(0x0CFFFFFF) : Colors.black.withOpacity(0.04)),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isHovered 
                    ? PortfolioTheme.primary 
                    : (isDark ? PortfolioTheme.borderDark : Colors.black12),
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon,
              color: _isHovered 
                  ? PortfolioTheme.primary 
                  : (isDark ? Colors.white : PortfolioTheme.secondary),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class HeroGraphic extends StatefulWidget {
  final double size;

  const HeroGraphic({
    super.key,
    required this.size,
  });

  @override
  State<HeroGraphic> createState() => _HeroGraphicState();
}

class _HeroGraphicState extends State<HeroGraphic> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Pulsating Glow
            Container(
              width: widget.size * 0.8,
              height: widget.size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PortfolioTheme.primary.withOpacity(0.08),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
            // Custom Painter Drawing Cyber Orb
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CyberOrbPainter(
                rotationValue: _controller.value,
                primaryColor: PortfolioTheme.primary,
                accentColor: PortfolioTheme.accent,
                secondaryColor: const Color(0xFF10B981),
              ),
            ),
            // Center Element / Icon / Profile Image
            Obx(() {
              final profile = controller.profile.value;
              final hasProfileImage = profile != null && profile.profileImage.trim().isNotEmpty;

              return Container(
                width: widget.size * 0.35,
                height: widget.size * 0.35,
                decoration: BoxDecoration(
                  color: PortfolioTheme.surfaceDark.withOpacity(0.85),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PortfolioTheme.primary.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: hasProfileImage
                    ? ClipOval(
                        child: PortfolioImage(
                          imageSource: profile.profileImage,
                          width: widget.size * 0.35,
                          height: widget.size * 0.35,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.terminal_rounded,
                        color: Color(0xFF10B981),
                        size: 32,
                      ),
              );
            }),
          ],
        );
      },
    );
  }
}

class CyberOrbPainter extends CustomPainter {
  final double rotationValue;
  final Color primaryColor;
  final Color accentColor;
  final Color secondaryColor;

  CyberOrbPainter({
    required this.rotationValue,
    required this.primaryColor,
    required this.accentColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 1. Draw outer rotating dashed circles
    paintLine.color = primaryColor.withOpacity(0.15);
    canvas.drawCircle(center, radius * 0.95, paintLine);

    // 2. Draw rotating constellation nodes
    final double baseAngle = rotationValue * 2 * math.pi;
    final int nodesCount = 6;
    
    // Outer Node Ring
    paintLine.color = primaryColor.withOpacity(0.35);
    paintLine.strokeWidth = 1.0;
    
    final List<Offset> outerNodes = [];
    for (int i = 0; i < nodesCount; i++) {
      final double angle = baseAngle + (i * 2 * math.pi / nodesCount);
      final double nodeRadius = radius * 0.8;
      final double x = center.dx + nodeRadius * math.cos(angle);
      final double y = center.dy + nodeRadius * math.sin(angle);
      final nodePos = Offset(x, y);
      outerNodes.add(nodePos);
      
      // Draw glow ring node
      final nodePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePos, 4, nodePaint);
      canvas.drawCircle(nodePos, 8, Paint()..color = primaryColor.withOpacity(0.15)..style = PaintingStyle.fill);
    }

    // Inner Node Ring (rotates in opposite direction)
    paintLine.color = accentColor.withOpacity(0.35);
    final double innerAngle = -baseAngle * 1.5;
    final List<Offset> innerNodes = [];
    for (int i = 0; i < nodesCount; i++) {
      final double angle = innerAngle + (i * 2 * math.pi / nodesCount);
      final double nodeRadius = radius * 0.55;
      final double x = center.dx + nodeRadius * math.cos(angle);
      final double y = center.dy + nodeRadius * math.sin(angle);
      final nodePos = Offset(x, y);
      innerNodes.add(nodePos);

      final nodePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePos, 3, nodePaint);
      canvas.drawCircle(nodePos, 6, Paint()..color = accentColor.withOpacity(0.15)..style = PaintingStyle.fill);
    }

    // Connect nodes with thin network lines
    final linePaint = Paint()
      ..color = primaryColor.withOpacity(0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    
    for (var outer in outerNodes) {
      for (var inner in innerNodes) {
        final dist = (outer - inner).distance;
        if (dist < radius * 0.8) {
          canvas.drawLine(outer, inner, linePaint);
        }
      }
    }

    // 3. Draw orbital sweep ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.7);
    final gradient = SweepGradient(
      colors: [primaryColor, accentColor, secondaryColor, primaryColor],
      stops: const [0.0, 0.35, 0.7, 1.0],
      transform: GradientRotation(baseAngle),
    );
    
    ringPaint.shader = gradient.createShader(rect);
    canvas.drawArc(rect, 0, 2 * math.pi, false, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CyberOrbPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue;
  }
}
