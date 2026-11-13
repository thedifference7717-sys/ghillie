// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Draws a QR code for [data] (error correction M), dark modules on a light background.
class QrView extends StatelessWidget {
  final String data;
  final double size;
  const QrView(this.data, {super.key, this.size = 224});
  @override
  Widget build(BuildContext context) {
    final img = QrImage(QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M));
    return Semantics(
      label: 'QR code for the payment link',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _QrPainter(img)),
    );
  }
}

class _QrPainter extends CustomPainter {
  final QrImage img;
  _QrPainter(this.img);
  @override
  void paint(Canvas canvas, Size size) {
    final n = img.moduleCount;
    final cell = size.width / n;
    final p = Paint()..color = const Color(0xFF0B0F0C);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (img.isDark(y, x)) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell + 0.5, cell + 0.5), p);
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.img != img;
}
