import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Placeholder wristband cartridge illustration with S1/S2/S3, refs and QR area.
class CartridgePainter extends CustomPainter {
  final bool showLabels;
  final bool highlightRoi;
  final double scanProgress;

  CartridgePainter({
    this.showLabels = true,
    this.highlightRoi = false,
    this.scanProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.28, size.width * 0.84, size.height * 0.44),
      const Radius.circular(28),
    );
    final bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1C2430), Color(0xFF0E141C), Color(0xFF1A222C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(band.outerRect);
    canvas.drawRRect(band, bandPaint);
    canvas.drawRRect(
      band,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.borderStrong,
    );

    // Cartridge insert
    final insert = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.34, size.width * 0.64, size.height * 0.32),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      insert,
      Paint()..color = const Color(0xFF243040),
    );

    void channel(Rect r, Color c, String label) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()..color = c,
      );
      if (highlightRoi) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(r.inflate(3), const Radius.circular(5)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = AppColors.scanLine,
        );
      }
      if (showLabels) {
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(r.left, r.top - 12));
      }
    }

    final y = size.height * 0.42;
    final h = size.height * 0.08;
    final gap = size.width * 0.02;
    final x0 = size.width * 0.22;
    final w = size.width * 0.12;
    channel(Rect.fromLTWH(x0, y, w * 0.55, h), const Color(0xFF2DD4BF), 'S1');
    channel(Rect.fromLTWH(x0 + w * 0.7 + gap, y, w * 0.9, h), const Color(0xFF34D399), 'S2');
    channel(Rect.fromLTWH(x0 + w * 1.85 + gap * 2, y, w * 1.35, h), const Color(0xFF60A5FA), 'S3');

    // Refs
    final rx = size.width * 0.68;
    final refs = [
      (const Color(0xFFF5F5F5), 'W'),
      (const Color(0xFF22C55E), 'G'),
      (const Color(0xFF111111), 'D'),
    ];
    for (var i = 0; i < refs.length; i++) {
      final r = Rect.fromLTWH(rx + i * 18, size.height * 0.52, 14, 14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        Paint()..color = refs[i].$1,
      );
      if (showLabels) {
        final tp = TextPainter(
          text: TextSpan(
            text: 'REF ${refs[i].$2}',
            style: const TextStyle(color: Colors.white54, fontSize: 7, fontFamily: 'monospace'),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(r.left - 4, r.bottom + 2));
      }
    }

    // QR block
    final qr = Rect.fromLTWH(size.width * 0.24, size.height * 0.52, size.width * 0.14, size.width * 0.14);
    _drawQr(canvas, qr);
    if (showLabels) {
      final tp = TextPainter(
        text: const TextSpan(
          text: 'QR',
          style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(qr.left, qr.top - 12));
    }

    // Brand mark
    final tp = TextPainter(
      text: const TextSpan(
        text: 'H2S-ECHO',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width * 0.42, size.height * 0.36));

    if (scanProgress > 0) {
      final ly = insert.top + insert.height * scanProgress;
      canvas.drawLine(
        Offset(insert.left + 4, ly),
        Offset(insert.right - 4, ly),
        Paint()
          ..color = AppColors.scanLine.withValues(alpha: 0.9)
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawQr(Canvas canvas, Rect r) {
    canvas.drawRect(r, Paint()..color = Colors.white);
    final cell = r.width / 7;
    final paint = Paint()..color = Colors.black;
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        final on = ((x + y * 3) % 2 == 0) || (x < 2 && y < 2) || (x > 4 && y < 2) || (x < 2 && y > 4);
        if (on) {
          canvas.drawRect(
            Rect.fromLTWH(r.left + x * cell, r.top + y * cell, cell, cell),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CartridgePainter oldDelegate) =>
      oldDelegate.scanProgress != scanProgress ||
      oldDelegate.highlightRoi != highlightRoi ||
      oldDelegate.showLabels != showLabels;
}

class AccuracyGaugePainter extends CustomPainter {
  final double value;
  final double threshold;
  final double anim;

  AccuracyGaugePainter({
    required this.value,
    required this.threshold,
    required this.anim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.62);
    final radius = math.min(size.width, size.height) * 0.42;
    const start = math.pi * 0.85;
    const sweep = math.pi * 1.3;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = AppColors.border;
    canvas.drawArc(Rect.fromCircle(center: c, radius: radius), start, sweep, false, bg);

    final passSweep = sweep * (threshold / 100);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      start,
      passSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..color = AppColors.valid.withValues(alpha: 0.25),
    );

    final v = (value * anim).clamp(0, 100);
    final color = v >= threshold ? AppColors.valid : AppColors.invalid;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      start,
      sweep * (v / 100),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // Threshold tick
    final tickAngle = start + passSweep;
    final t1 = Offset(
      c.dx + (radius - 14) * math.cos(tickAngle),
      c.dy + (radius - 14) * math.sin(tickAngle),
    );
    final t2 = Offset(
      c.dx + (radius + 14) * math.cos(tickAngle),
      c.dy + (radius + 14) * math.sin(tickAngle),
    );
    canvas.drawLine(
      t1,
      t2,
      Paint()
        ..color = AppColors.textSecondary
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant AccuracyGaugePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.anim != anim ||
      oldDelegate.threshold != threshold;
}

class ViewfinderOverlay extends StatelessWidget {
  final double scanProgress;
  final bool locked;
  final bool showRoiLabels;
  final Widget? child;

  const ViewfinderOverlay({
    super.key,
    this.scanProgress = 0,
    this.locked = false,
    this.showRoiLabels = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.viewfinder),
        Center(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: CustomPaint(
              painter: CartridgePainter(
                showLabels: showRoiLabels,
                highlightRoi: showRoiLabels,
                scanProgress: scanProgress,
              ),
              child: child,
            ),
          ),
        ),
        CustomPaint(
          painter: _BracketPainter(locked: locked),
        ),
        if (!locked)
          Align(
            alignment: Alignment(0, -1 + scanProgress * 2),
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                color: AppColors.scanLine,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.scanLine.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        if (locked)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.valid.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.valid),
              ),
              child: Text(
                'LOCK-ON',
                style: mono(context, size: 12, weight: FontWeight.w800, color: AppColors.valid),
              ),
            ),
          ),
      ],
    );
  }
}

class _BracketPainter extends CustomPainter {
  final bool locked;
  _BracketPainter({required this.locked});

  @override
  void paint(Canvas canvas, Size size) {
    final color = locked ? AppColors.valid : AppColors.scanLine;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final inset = size.width * 0.12;
    final top = size.height * 0.22;
    final bottom = size.height * 0.78;
    final left = inset;
    final right = size.width - inset;
    const len = 28.0;

    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * len, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * len), paint);
    }

    corner(left, top, 1, 1);
    corner(right, top, -1, 1);
    corner(left, bottom, 1, -1);
    corner(right, bottom, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) =>
      oldDelegate.locked != locked;
}
