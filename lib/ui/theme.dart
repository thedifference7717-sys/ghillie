// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';

/// Night-ops palette from camocoin.org and the approved Ghillie mockups (Nov 4).
abstract final class Gc {
  static const bg = Color(0xFF0B0F0C);
  static const bgDeep = Color(0xFF080B09);
  static const panel = Color(0xFF121A15);
  static const panelDark = Color(0xFF0F1511);
  static const line = Color(0xFF24332A);
  static const line2 = Color(0xFF2E4034);
  static const line3 = Color(0xFF1C2820);
  static const text = Color(0xFFE7E9E2);
  static const text2 = Color(0xFFB9C2B1);
  static const text3 = Color(0xFF9AA593);
  static const link = Color(0xFFC9D6B8);
  static const olive = Color(0xFF8FA37A);
  static const amber = Color(0xFFE0A63A);
  static const danger = Color(0xFFE5704B);
}

/// VT323 pixel font for headings, labels, big numbers and addresses; Inter for body; JetBrains Mono for figures.
abstract final class Gt {
  static TextStyle pixel(double size, {Color color = Gc.text}) =>
      TextStyle(fontFamily: 'VT323', fontSize: size, color: color, height: 1.0);
  static TextStyle body(double size, {Color color = Gc.text, FontWeight weight = FontWeight.w400}) =>
      TextStyle(fontFamily: 'Inter', fontSize: size, color: color, fontWeight: weight);
  static TextStyle mono(double size, {Color color = Gc.text, FontWeight weight = FontWeight.w400}) =>
      TextStyle(fontFamily: 'JetBrainsMono', fontSize: size, color: color, fontWeight: weight);
}

/// Rectangle with 4 px square notches cut from each corner (the mockups' "notch" clip-path).
class NotchedBorder extends OutlinedBorder {
  final double notch;
  const NotchedBorder({this.notch = 4, super.side});

  Path _path(Rect r) {
    final n = notch;
    return Path()
      ..moveTo(r.left + n, r.top)
      ..lineTo(r.right - n, r.top)
      ..lineTo(r.right - n, r.top + n)
      ..lineTo(r.right, r.top + n)
      ..lineTo(r.right, r.bottom - n)
      ..lineTo(r.right - n, r.bottom - n)
      ..lineTo(r.right - n, r.bottom)
      ..lineTo(r.left + n, r.bottom)
      ..lineTo(r.left + n, r.bottom - n)
      ..lineTo(r.left, r.bottom - n)
      ..lineTo(r.left, r.top + n)
      ..lineTo(r.left + n, r.top + n)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _path(rect.deflate(side.width));
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);
  @override
  ShapeBorder scale(double t) => NotchedBorder(notch: notch * t, side: side.scale(t));
  @override
  NotchedBorder copyWith({BorderSide? side}) => NotchedBorder(notch: notch, side: side ?? this.side);
}

ThemeData ghillieTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  ButtonStyle btn(Color bg, Color fg, {BorderSide side = BorderSide.none}) => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? Gc.line : bg),
        foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? Gc.text3 : fg),
        shape: WidgetStatePropertyAll(NotchedBorder(side: side)),
        minimumSize: const WidgetStatePropertyAll(Size(44, 52)),
        textStyle: WidgetStatePropertyAll(Gt.body(15, weight: FontWeight.w600)),
        elevation: const WidgetStatePropertyAll(0),
      );
  return base.copyWith(
    scaffoldBackgroundColor: Gc.bg,
    colorScheme: base.colorScheme.copyWith(primary: Gc.amber, secondary: Gc.olive, surface: Gc.panel, error: Gc.danger),
    textTheme: base.textTheme.apply(fontFamily: 'Inter', bodyColor: Gc.text, displayColor: Gc.text),
    filledButtonTheme: FilledButtonThemeData(style: btn(Gc.amber, Gc.bg)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: btn(Gc.panel, Gc.text, side: const BorderSide(color: Gc.line2))),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Gc.link, textStyle: Gt.body(13, weight: FontWeight.w600))),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Gc.panel,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: _NotchInputBorder(BorderSide(color: Gc.line2)),
      focusedBorder: _NotchInputBorder(BorderSide(color: Gc.amber)),
      errorBorder: _NotchInputBorder(BorderSide(color: Gc.danger)),
      focusedErrorBorder: _NotchInputBorder(BorderSide(color: Gc.danger)),
      border: _NotchInputBorder(BorderSide(color: Gc.line2)),
    ),
    snackBarTheme: SnackBarThemeData(backgroundColor: Gc.panel, contentTextStyle: Gt.body(14), shape: const NotchedBorder(side: BorderSide(color: Gc.line2))),
    dialogTheme: const DialogThemeData(backgroundColor: Gc.bgDeep, shape: NotchedBorder(side: BorderSide(color: Gc.line2))),
  );
}

class _NotchInputBorder extends InputBorder {
  const _NotchInputBorder(BorderSide side) : super(borderSide: side);
  @override
  bool get isOutline => true;
  @override
  InputBorder copyWith({BorderSide? borderSide}) => _NotchInputBorder(borderSide ?? this.borderSide);
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => NotchedBorder(side: borderSide).getInnerPath(rect);
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => NotchedBorder(side: borderSide).getOuterPath(rect);
  @override
  void paint(Canvas canvas, Rect rect, {double? gapStart, double gapExtent = 0, double gapPercentage = 0, TextDirection? textDirection}) =>
      NotchedBorder(side: borderSide).paint(canvas, rect);
  @override
  ShapeBorder scale(double t) => _NotchInputBorder(borderSide.scale(t));
}
