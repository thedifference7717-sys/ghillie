// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
//
// Opening screen, ported from camocoin.org (website/intro.js): a living pixel-camo field with the word
// CAMO hidden in it. Drag the scope onto the word; when it reads TARGET ACQUIRED, tap to enter.
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../ui/theme.dart';

class ScopeIntro extends StatefulWidget {
  final VoidCallback onEnter;
  const ScopeIntro({super.key, required this.onEnter});
  @override
  State<ScopeIntro> createState() => _ScopeIntroState();
}

class _ScopeIntroState extends State<ScopeIntro> with SingleTickerProviderStateMixin {
  static const double cell = 11;
  late final Ticker _ticker = createTicker(_tick);
  final _field = _Field();
  Offset _scope = Offset.zero, _target = Offset.zero;
  double _r = 90, _baseR = 90;
  Duration _now = Duration.zero, _lastInput = const Duration(seconds: -2);
  bool _entering = false, _placed = false;
  Size _size = Size.zero;
  Duration? _enterStart;

  bool get _still => MediaQuery.of(context).disableAnimations;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _layout(Size size) async {
    if (size == _size || size.isEmpty) return;
    _size = size;
    _baseR = _r = max(70.0, min(150.0, size.shortestSide * 0.22));
    await _field.build(size, cell);
    if (!_placed) {
      _placed = true;
      _scope = _target = Offset(size.width * 0.2, size.height * 0.28);
    }
    if (!mounted) return;
    if (!_still && !_ticker.isActive) _ticker.start();
    setState(() {});
  }

  void _tick(Duration now) {
    _now = now;
    if (_entering) {
      _enterStart ??= now;
      final k = min(1.0, (now - _enterStart!).inMilliseconds / 650);
      final e = k * k * (3 - 2 * k);
      _r = _baseR + (_size.longestSide * 1.1 - _baseR) * e;
      setState(() {});
      if (k >= 1) {
        _ticker.stop();
        widget.onEnter();
      }
      return;
    }
    if (now - _lastInput > const Duration(seconds: 3) && _field.wordN > 0) {
      // idle: sweep across the word so people see what's hiding
      final t = now.inMilliseconds / 1000;
      final b = _field.wordBox;
      _target = Offset(b.center.dx + sin(t * 0.4 - 1.2) * max(b.width * 0.55, _r),
          b.center.dy + sin(t * 0.8) * min(b.height * 0.45, _r * 0.6));
    }
    _scope += (_target - _scope) * 0.14;
    setState(() {});
  }

  void _aim(Offset p) {
    _target = p;
    _lastInput = _now;
    if (_still) setState(() => _scope = p);
  }

  void _tap(Offset p) {
    if (_locked && (p - _scope).distance <= _r) {
      if (_still) {
        widget.onEnter();
      } else {
        _entering = true;
      }
      return;
    }
    _aim(p);
    if (!_still) _scope += (_target - _scope) * 0.6;
  }

  bool get _locked => _entering || _field.seenFraction(_scope, _r) > 0.18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Gc.bg,
      body: LayoutBuilder(builder: (context, c) {
        _layout(c.biggest);
        final locked = _locked;
        return Stack(children: [
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (d) => _aim(d.localPosition),
              onPanUpdate: (d) => _aim(d.localPosition),
              onTapUp: (d) => _tap(d.localPosition),
              child: Semantics(
                label: 'Camouflage field with the word CAMO hidden in it. Drag the scope onto the word, then tap.',
                child: CustomPaint(
                  painter: _IntroPainter(_field, _still ? 0 : _now.inMilliseconds / 1000, _scope, _r, locked, _entering),
                ),
              ),
            ),
          ),
          if (!_entering)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Text('GHILLIE', style: Gt.pixel(28)),
                        Text(locked ? 'TARGET ACQUIRED · TAP THE SCOPE' : 'FIND WHAT\'S HIDDEN · DRAG THE SCOPE',
                            style: Gt.mono(11, color: locked ? Gc.amber : Gc.text3, weight: FontWeight.w700)),
                      ]),
                    ),
                    TextButton(onPressed: widget.onEnter, child: const Text('Skip')),
                  ]),
                ),
              ),
            ),
        ]);
      }),
    );
  }
}

/// The camo field: noise levels per cell, and a mask of the cells that spell CAMO.
class _Field {
  int cols = 0, rows = 0, wordN = 0;
  double cell = 11;
  Uint8List mask = Uint8List(0);
  Rect wordBox = Rect.zero;

  Future<void> build(Size size, double c) async {
    // compute into locals and publish at the end, so painting never sees a half-built field
    final cols = (size.width / c).ceil(), rows = (size.height / c).ceil();
    // draw CAMO into a cols x rows picture, then read which cells it covers
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    final tp = TextPainter(
      text: TextSpan(text: 'CAMO', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: max(6.0, cols * 0.84 / 2.9), color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((cols - tp.width) / 2, (rows - tp.height) / 2));
    final img = await rec.endRecording().toImage(cols, rows);
    final data = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final mask = Uint8List(cols * rows);
    var minX = cols, maxX = 0, minY = rows, maxY = 0, n = 0;
    for (var i = 0; i < cols * rows; i++) {
      if (data.getUint8(i * 4 + 3) > 110) {
        mask[i] = 1;
        n++;
        final x = i % cols, y = i ~/ cols;
        minX = min(minX, x);
        maxX = max(maxX, x);
        minY = min(minY, y);
        maxY = max(maxY, y);
      }
    }
    wordBox = n == 0 ? Offset.zero & size : Rect.fromLTRB(minX * c, minY * c, (maxX + 1) * c, (maxY + 1) * c);
    this.mask = mask;
    wordN = n;
    cell = c;
    this.rows = rows;
    this.cols = cols;
  }

  double seenFraction(Offset s, double r) {
    if (wordN == 0) return 0;
    var seen = 0;
    final x0 = max(0, ((s.dx - r) / cell).floor()), x1 = min(cols - 1, ((s.dx + r) / cell).floor());
    final y0 = max(0, ((s.dy - r) / cell).floor()), y1 = min(rows - 1, ((s.dy + r) / cell).floor());
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        if (mask[y * cols + x] == 0) continue;
        final d = Offset((x + 0.5) * cell, (y + 0.5) * cell) - s;
        if (d.distanceSquared < r * r) seen++;
      }
    }
    return seen / wordN;
  }

  static double _hash(int x, int y) {
    final h = sin(x * 127.1 + y * 311.7) * 43758.5453;
    return h - h.floorToDouble();
  }

  static double _noise(double x, double y) {
    final ix = x.floor(), iy = y.floor();
    var fx = x - ix, fy = y - iy;
    fx = fx * fx * (3 - 2 * fx);
    fy = fy * fy * (3 - 2 * fy);
    final a = _hash(ix, iy), b = _hash(ix + 1, iy), c = _hash(ix, iy + 1), d = _hash(ix + 1, iy + 1);
    return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy;
  }

  int level(int x, int y, double t) {
    final n = 0.65 * _noise(x * 0.085 + t * 0.35, y * 0.085) + 0.35 * _noise(x * 0.21 - 40, y * 0.21 - t * 0.5);
    return n < 0.4 ? 0 : n < 0.5 ? 1 : n < 0.6 ? 2 : 3;
  }
}

class _IntroPainter extends CustomPainter {
  final _Field f;
  final double t, r;
  final Offset s;
  final bool locked, entering;
  _IntroPainter(this.f, this.t, this.s, this.r, this.locked, this.entering);

  static const _bg = Color(0xFF0B0F0C);
  static const _pal = [Color(0xFF2E472C), Color(0xFF3E5B3A), Color(0xFF56744C), Color(0xFF6F8A5E)]; // logo greens
  static final _dim = _pal.map((c) => Color.lerp(c, _bg, 0.42)!).toList();
  static final _bright = _pal.map((c) => Color.lerp(c, Colors.white, 0.06)!).toList();
  static final _glow = [Color.lerp(Gc.amber, _bg, 0.25)!, Color.lerp(Gc.amber, _bg, 0.05)!];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    if (f.cols == 0) return;
    final c = f.cell, p = Paint();
    final lv = List<int>.filled(f.cols * f.rows, 0);
    for (var y = 0; y < f.rows; y++) {
      for (var x = 0; x < f.cols; x++) {
        final i = y * f.cols + x;
        var l = lv[i] = f.level(x, y, t);
        if (f.mask[i] == 1) l = min(3, l + 1); // the word sits one shade lighter: there, if you look for it
        p.color = _dim[l];
        canvas.drawRect(Rect.fromLTWH(x * c, y * c, c, c), p);
      }
    }
    // inside the scope: brighter field, the word glows amber
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: s, radius: r)));
    final x0 = max(0, ((s.dx - r) / c).floor()), x1 = min(f.cols - 1, ((s.dx + r) / c).floor());
    final y0 = max(0, ((s.dy - r) / c).floor()), y1 = min(f.rows - 1, ((s.dy + r) / c).floor());
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final i = y * f.cols + x;
        p.color = f.mask[i] == 1 ? _glow[lv[i] & 1] : _bright[lv[i]];
        canvas.drawRect(Rect.fromLTWH(x * c, y * c, c, c), p);
      }
    }
    final scan = Paint()..color = const Color(0x38080B09);
    final off = (t * 12).floor() % 4;
    for (var y = s.dy - r + off; y < s.dy + r; y += 4) {
      canvas.drawRect(Rect.fromLTWH(s.dx - r, y, r * 2, 1.5), scan);
    }
    canvas.drawCircle(s, r, Paint()..shader = ui.Gradient.radial(s, r, [const Color(0x00080B09), const Color(0x8C080B09)], [0.55, 1]));
    canvas.restore();
    if (entering) return;

    // reticle
    final ink = Paint()
      ..color = locked ? const Color(0xF2E0A63A) : const Color(0xCCC9D6B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(s, r, ink);
    canvas.drawArc(Rect.fromCircle(center: s, radius: r + 6), -0.35, 0.7, false, ink);
    canvas.drawArc(Rect.fromCircle(center: s, radius: r + 6), pi - 0.35, 0.7, false, ink);
    const gap = 10.0;
    canvas.drawLine(Offset(s.dx - r, s.dy), Offset(s.dx - gap, s.dy), ink);
    canvas.drawLine(Offset(s.dx + gap, s.dy), Offset(s.dx + r, s.dy), ink);
    canvas.drawLine(Offset(s.dx, s.dy - r), Offset(s.dx, s.dy - gap), ink);
    canvas.drawLine(Offset(s.dx, s.dy + gap), Offset(s.dx, s.dy + r), ink);
    for (var k = 1; k <= 3; k++) {
      final m = r / 4 * k;
      canvas.drawLine(Offset(s.dx - m, s.dy - 4), Offset(s.dx - m, s.dy + 4), ink);
      canvas.drawLine(Offset(s.dx + m, s.dy - 4), Offset(s.dx + m, s.dy + 4), ink);
      canvas.drawLine(Offset(s.dx - 4, s.dy + m), Offset(s.dx + 4, s.dy + m), ink);
    }
    canvas.drawRect(Rect.fromCenter(center: s, width: 3, height: 3), Paint()..color = ink.color);
    // label beside the scope
    final label = TextPainter(
      text: TextSpan(children: [
        TextSpan(text: locked ? 'TARGET ACQUIRED\n' : 'SCANNING…\n', style: Gt.mono(11, color: ink.color, weight: FontWeight.w700)),
        TextSpan(
            text: locked ? 'TAP TO ENTER' : 'X${s.dx.round().toString().padLeft(4, '0')} Y${s.dy.round().toString().padLeft(4, '0')}',
            style: Gt.mono(11, color: const Color(0xE69AA593), weight: FontWeight.w700)),
      ]),
      textDirection: TextDirection.ltr,
    )..layout();
    var lx = s.dx + r * 0.72, ly = s.dy - r * 0.72 - label.height;
    if (lx + label.width > size.width - 8) lx = s.dx - r * 0.72 - label.width;
    if (lx < 8) lx = 8;
    if (ly < 8) ly = s.dy + r + 10;
    label.paint(canvas, Offset(lx, ly));
  }

  @override
  bool shouldRepaint(_IntroPainter o) => true;
}
