// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

/// Panel with notched corners.
class NotchBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool camo;
  const NotchBox({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = Gc.panel,
      this.borderColor = Gc.line, this.borderWidth = 1, this.camo = false});
  @override
  Widget build(BuildContext context) {
    final shape = NotchedBorder(side: BorderSide(color: borderColor, width: borderWidth));
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: CustomPaint(
        painter: camo ? const PixelCamoPainter() : null,
        child: DecoratedBox(
          decoration: ShapeDecoration(shape: shape, color: camo ? null : color),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Dark pixel-camo texture for key cards, drawn in code (deterministic, so it looks the same everywhere).
class PixelCamoPainter extends CustomPainter {
  const PixelCamoPainter({this.cell = 8, this.seed = 7});
  final double cell;
  final int seed;
  static const _tones = [Color(0xFF0E1410), Color(0xFF141E17), Color(0xFF1B281F), Color(0xFF223127)];
  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / cell).ceil() + 1, rows = (size.height / cell).ceil() + 1;
    // coarse random grid, smoothed by bilinear interpolation -> blob shapes, then quantized per cell
    final rnd = Random(seed);
    const g = 6;
    final gw = cols ~/ g + 2, gh = rows ~/ g + 2;
    final grid = List.generate(gh, (_) => List.generate(gw, (_) => rnd.nextDouble()));
    final p = Paint();
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final fx = x / g, fy = y / g;
        final x0 = fx.floor(), y0 = fy.floor(), tx = fx - x0, ty = fy - y0;
        final v = grid[y0][x0] * (1 - tx) * (1 - ty) + grid[y0][x0 + 1] * tx * (1 - ty) +
            grid[y0 + 1][x0] * (1 - tx) * ty + grid[y0 + 1][x0 + 1] * tx * ty;
        p.color = _tones[min(_tones.length - 1, (v * _tones.length).floor())];
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
  }

  @override
  bool shouldRepaint(PixelCamoPainter old) => old.cell != cell || old.seed != seed;
}

class SquareDot extends StatelessWidget {
  final Color color;
  const SquareDot({super.key, this.color = Gc.olive});
  @override
  Widget build(BuildContext context) => Container(width: 8, height: 8, color: color);
}

class ShieldLine extends StatelessWidget {
  final String text;
  const ShieldLine(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.shield_outlined, size: 15, color: Gc.olive)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Gt.body(12, color: Gc.text3).copyWith(height: 1.45))),
      ]);
}

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});
  @override
  Widget build(BuildContext context) => NotchBox(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: Gc.amber,
        borderColor: Gc.amber,
        child: Text('DEMO', style: Gt.pixel(16, color: Gc.bg)),
      );
}

/// Screen header with a back button and a pixel-font title.
class ScreenHeader extends StatelessWidget {
  final String title;
  const ScreenHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(children: [
          Semantics(
            button: true,
            label: 'Back',
            child: SizedBox(
              width: 44,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(44, 44)),
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(Icons.chevron_left, color: Gc.text2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Gt.pixel(30))),
        ]),
      );
}
