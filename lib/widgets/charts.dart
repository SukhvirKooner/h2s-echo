import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class FingerprintBars extends StatelessWidget {
  final Fingerprint fingerprint;
  final double anim;

  const FingerprintBars({
    super.key,
    required this.fingerprint,
    this.anim = 1,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('FAST', fingerprint.fast, AppColors.accent),
      ('MEDIUM', fingerprint.medium, AppColors.cyan),
      ('SLOW', fingerprint.slow, AppColors.medium),
    ];
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 1,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  if (i < 0 || i >= items.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      items[i].$1,
                      style: mono(context, size: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < items.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: items[i].$2 * anim,
                    width: 28,
                    borderRadius: BorderRadius.circular(6),
                    color: items[i].$3,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class BaselineMiniChart extends StatelessWidget {
  final List<BaselinePoint> points;
  final double bandLow;
  final double bandHigh;

  const BaselineMiniChart({
    super.key,
    required this.points,
    this.bandLow = 0.88,
    this.bandHigh = 1.02,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(height: 100);
    }
    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          minY: 0.8,
          maxY: 1.1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: AppColors.border.withValues(alpha: 0.6),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, m) => Text(
                  v.toStringAsFixed(2),
                  style: mono(context, size: 9, color: AppColors.textMuted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) => Text(
                  'C${v.toInt()}',
                  style: mono(context, size: 9, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(y: bandLow, color: AppColors.valid.withValues(alpha: 0.35), strokeWidth: 1),
              HorizontalLine(y: bandHigh, color: AppColors.valid.withValues(alpha: 0.35), strokeWidth: 1),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (final p in points) FlSpot(p.cycle.toDouble(), p.signal),
              ],
              isCurved: true,
              color: AppColors.cyan,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.cyan.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoseTrendChart extends StatelessWidget {
  final List<ExposureRecord> records;

  const DoseTrendChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final valid = records
        .where((r) => r.dosePpmH != null)
        .toList()
        .reversed
        .take(12)
        .toList()
        .reversed
        .toList();
    if (valid.isEmpty) {
      return const SizedBox(height: 140, child: Center(child: Text('No dose data')));
    }
    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: AppColors.border.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: mono(context, size: 9, color: AppColors.textMuted),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < valid.length; i++)
                  FlSpot(i.toDouble(), valid[i].dosePpmH!),
              ],
              isCurved: true,
              color: AppColors.accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accent,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalibrationDomainPlot extends StatelessWidget {
  final bool inside;
  final double anim;

  const CalibrationDomainPlot({
    super.key,
    required this.inside,
    this.anim = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _DomainPainter(inside: inside, anim: anim),
        child: Center(
          child: Text(
            inside ? 'INSIDE DOMAIN' : 'OUT OF DOMAIN',
            style: mono(
              context,
              size: 11,
              weight: FontWeight.w700,
              color: inside ? AppColors.valid : AppColors.invalid,
            ),
          ),
        ),
      ),
    );
  }
}

class _DomainPainter extends CustomPainter {
  final bool inside;
  final double anim;
  _DomainPainter({required this.inside, required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final domain = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.2, size.width * 0.55, size.height * 0.55),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      domain,
      Paint()..color = AppColors.valid.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      domain,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.valid
        ..strokeWidth = 1.5,
    );
    final pt = Offset(
      inside ? size.width * 0.38 : size.width * 0.82,
      inside ? size.height * 0.45 : size.height * 0.28,
    );
    canvas.drawCircle(
      pt,
      6 * anim,
      Paint()..color = inside ? AppColors.cyan : AppColors.invalid,
    );
  }

  @override
  bool shouldRepaint(covariant _DomainPainter oldDelegate) =>
      oldDelegate.inside != inside || oldDelegate.anim != anim;
}
