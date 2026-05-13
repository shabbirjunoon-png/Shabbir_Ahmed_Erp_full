import 'package:flutter/material.dart';
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
    return CustomPaint(
      size: Size(size, size),
      painter: _GoldShieldPainter(size: size),
    );
  }
}

class _GoldShieldPainter extends CustomPainter {
  final double size;
  const _GoldShieldPainter({required this.size});

  static const _navy = AppColors.primary;      // #1E1B4B
  static const _gold = AppColors.accent;       // #F59E0B
  static const _goldLight = Color(0xFFFFD166); // lighter gold highlight
  static const _goldDark = Color(0xFFB45309);  // darker gold shadow

  Path _shieldPath(double w, double h) {
    final p = Path();
    // Classic pointed-bottom shield
    p.moveTo(w * 0.50, h * 0.03);
    p.lineTo(w * 0.96, h * 0.20);
    p.lineTo(w * 0.96, h * 0.56);
    p.cubicTo(w * 0.96, h * 0.80, w * 0.75, h * 0.93, w * 0.50, h * 0.99);
    p.cubicTo(w * 0.25, h * 0.93, w * 0.04, h * 0.80, w * 0.04, h * 0.56);
    p.lineTo(w * 0.04, h * 0.20);
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final shield = _shieldPath(w, h);
    final rect = Rect.fromLTWH(0, 0, w, h);

    // ── Drop shadow ──────────────────────────────────────────────────────────
    canvas.drawPath(
      shield.shift(const Offset(0, 2)),
      Paint()
        ..color = _goldDark.withOpacity(0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.06),
    );

    // ── Navy fill with subtle gradient ───────────────────────────────────────
    canvas.drawPath(
      shield,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D2A6E),
            _navy,
            const Color(0xFF13114A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // ── Gold outer border ────────────────────────────────────────────────────
    canvas.drawPath(
      shield,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055,
    );

    // ── Inner gold divider line (horizontal, upper-third) ────────────────────
    final divY = h * 0.34;
    canvas.drawLine(
      Offset(w * 0.12, divY),
      Offset(w * 0.88, divY),
      Paint()
        ..color = _gold.withOpacity(0.55)
        ..strokeWidth = w * 0.022,
    );

    // ── "S" initial (left, gold) ─────────────────────────────────────────────
    final stp = TextPainter(
      text: TextSpan(
        text: 'S',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          fontSize: w * 0.33,
          color: _goldLight,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    stp.paint(canvas, Offset(w * 0.08, divY + h * 0.04));

    // ── "A" initial (right, slightly offset, contrasting) ────────────────────
    final atp = TextPainter(
      text: TextSpan(
        text: 'A',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          fontSize: w * 0.30,
          color: Colors.white.withOpacity(0.92),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    atp.paint(canvas, Offset(w * 0.52, divY + h * 0.05));

    // ── Small gold gear dot at bottom-center ─────────────────────────────────
    final cx = w * 0.50;
    final cy = h * 0.88;
    final r = w * 0.06;
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = _gold);
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.52,
      Paint()..color = _navy,
    );

    // ── Top crown / chevron ───────────────────────────────────────────────────
    final crown = Path()
      ..moveTo(w * 0.30, h * 0.18)
      ..lineTo(w * 0.50, h * 0.07)
      ..lineTo(w * 0.70, h * 0.18);
    canvas.drawPath(
      crown,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.038
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
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
