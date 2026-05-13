import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppHeaderAction {
  final IconData icon;
  final VoidCallback onPress;
  final bool destructive;
  const AppHeaderAction(
      {required this.icon, required this.onPress, this.destructive = false});
}

class ShabbirLogo extends StatelessWidget {
  final double size;
  final Color bgColor;
  final Color textColor;
  final Color badgeColor;
  final bool showBadge;

  const ShabbirLogo({
    super.key,
    this.size = 36,
    this.bgColor = AppColors.primary,
    this.textColor = AppColors.accent,
    this.badgeColor = AppColors.accent,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: rootBundle.load('assets/logo.png').then((d) => d.buffer.asUint8List()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        }
        return SizedBox(width: size, height: size);
      },
    );
  }
}

class _ShieldLogoPainter extends CustomPainter {
  final Color bgColor;
  final Color textColor;
  final double size;

  _ShieldLogoPainter({
    required this.bgColor,
    required this.textColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;

    // Shield path
    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.95, h * 0.18);
    path.lineTo(w * 0.95, h * 0.55);
    path.cubicTo(w * 0.95, h * 0.82, w * 0.72, h * 0.95, w * 0.5, h);
    path.cubicTo(w * 0.28, h * 0.95, w * 0.05, h * 0.82, w * 0.05, h * 0.55);
    path.lineTo(w * 0.05, h * 0.18);
    path.close();

    // Outer shield shadow/border (metallic depth)
    final borderPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
    canvas.drawPath(path, borderPaint);

    // Main shield fill — gradient (navy deep to slightly lighter)
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        bgColor,
        Color.lerp(bgColor, Colors.white, 0.12)!,
        bgColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final rect = Rect.fromLTWH(0, 0, w, h);
    final fillPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Metallic border ring
    final strokePaint = Paint()
      ..color = AppColors.accent.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    canvas.drawPath(path, strokePaint);

    // Inner highlight line (3D emboss feel)
    final innerPath = Path();
    final inset = w * 0.08;
    innerPath.moveTo(w * 0.5, inset * 0.6);
    innerPath.lineTo(w - inset, h * 0.22);
    innerPath.lineTo(w - inset, h * 0.53);
    innerPath.cubicTo(w - inset, h * 0.78, w * 0.7, h * 0.9, w * 0.5, h * 0.94);
    innerPath.cubicTo(w * 0.3, h * 0.9, inset, h * 0.78, inset, h * 0.53);
    innerPath.lineTo(inset, h * 0.22);
    innerPath.close();
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawPath(innerPath, innerPaint);

    // Bar chart icon (bottom portion of shield)
    final barPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.45)
      ..style = PaintingStyle.fill;
    final barW = w * 0.08;
    final barBottomY = h * 0.80;
    final barData = [0.25, 0.45, 0.35];
    final barStartX = w * 0.27;
    final barGap = w * 0.12;
    for (int i = 0; i < barData.length; i++) {
      final bh = h * 0.28 * barData[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barStartX + i * (barW + barGap), barBottomY - bh, barW, bh),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }

    // "SA" monogram — intertwined initials
    // Draw "S" slightly left, "A" slightly right, overlapping in the center
    final sPainter = TextPainter(
      text: TextSpan(
        text: 'S',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          fontSize: w * 0.36,
          color: textColor.withOpacity(0.95),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    sPainter.layout();
    sPainter.paint(canvas, Offset(w * 0.11, h * 0.22));

    final aPainter = TextPainter(
      text: TextSpan(
        text: 'A',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          fontSize: w * 0.32,
          color: AppColors.accent.withOpacity(0.80),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    aPainter.layout();
    aPainter.paint(canvas, Offset(w * 0.42, h * 0.24));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<AppHeaderAction>? actions;

  const AppHeader(
      {super.key,
      required this.title,
      this.subtitle,
      this.onBack,
      this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 20,
          right: 20,
          bottom: 14),
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.foreground),
              ),
            )
          else
            const ShabbirLogo(size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: -0.4,
                          color: AppColors.foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ]),
          ),
          if (actions != null)
            Row(
                children: actions!
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: action.onPress,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                  color: action.destructive
                                      ? const Color(0xFFFEE2E2)
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(action.icon,
                                  size: 18,
                                  color: action.destructive
                                      ? AppColors.destructive
                                      : AppColors.foreground),
                            ),
                          ),
                        ))
                    .toList()),
        ],
      ),
    );
  }
}
