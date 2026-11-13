// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.

/// CAMO amounts are whole numbers of piconero-sized units ("picocamo"): 1 CAMO = 10^12.
/// BigInt because the total supply in atomic units does not fit a signed 64-bit int.
class CamoAmount implements Comparable<CamoAmount> {
  static final BigInt unitsPerCamo = BigInt.from(10).pow(12);
  static const int decimals = 12;

  final BigInt atomic;
  const CamoAmount._(this.atomic);

  factory CamoAmount.atomic(BigInt units) {
    if (units.isNegative) throw ArgumentError('negative amount');
    return CamoAmount._(units);
  }
  static final CamoAmount zero = CamoAmount._(BigInt.zero);

  /// Parses user input such as "25", "25.5", "0.000000000001". Returns null for anything else
  /// (more than 12 decimals, signs, exponents, grouping separators, empty).
  static CamoAmount? tryParse(String input) {
    final s = input.trim();
    final m = RegExp(r'^(\d+)(?:\.(\d{1,12}))?$').firstMatch(s) ??
        RegExp(r'^()\.(\d{1,12})$').firstMatch(s);
    if (m == null) return null;
    final whole = m.group(1)!.isEmpty ? BigInt.zero : BigInt.parse(m.group(1)!);
    final frac = (m.group(2) ?? '').padRight(decimals, '0');
    return CamoAmount._(whole * unitsPerCamo + BigInt.parse(frac.isEmpty ? '0' : frac));
  }

  bool get isZero => atomic == BigInt.zero;
  CamoAmount operator +(CamoAmount o) => CamoAmount._(atomic + o.atomic);
  CamoAmount operator -(CamoAmount o) => CamoAmount.atomic(atomic - o.atomic);
  bool operator >(CamoAmount o) => atomic > o.atomic;
  @override
  int compareTo(CamoAmount o) => atomic.compareTo(o.atomic);
  @override
  bool operator ==(Object other) => other is CamoAmount && other.atomic == atomic;
  @override
  int get hashCode => atomic.hashCode;

  /// Exact decimal form without trailing zeros: "25", "0.00086", "1239.63".
  String toPlain() {
    final whole = atomic ~/ unitsPerCamo;
    final frac = (atomic % unitsPerCamo).toString().padLeft(decimals, '0').replaceFirst(RegExp(r'0+$'), '');
    return frac.isEmpty ? whole.toString() : '$whole.$frac';
  }

  /// For display: thousands separators, at least [minDecimals] and at most [maxDecimals] decimals
  /// (truncated, never rounded up, so a balance is never shown higher than it is).
  String format({int minDecimals = 2, int maxDecimals = 12}) {
    final whole = (atomic ~/ unitsPerCamo).toString();
    var frac = (atomic % unitsPerCamo).toString().padLeft(decimals, '0').substring(0, maxDecimals);
    frac = frac.replaceFirst(RegExp(r'0+$'), '');
    if (frac.length < minDecimals) frac = frac.padRight(minDecimals, '0');
    final grouped = whole.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return frac.isEmpty ? grouped : '$grouped.$frac';
  }

  @override
  String toString() => '${toPlain()} CAMO';
}
