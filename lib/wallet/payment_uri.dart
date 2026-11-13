// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'amount.dart';

/// camo: payment links, the same format the CAMO CLI and Ghillie desktop use:
///   camo:<address>?tx_amount=25.5&tx_description=Coffee&recipient_name=Shop
/// "monero:" links are rejected on purpose (a Monero address can never receive CAMO).
class PaymentUri {
  final String address;
  final CamoAmount? amount;
  final String? description;
  final String? recipientName;
  const PaymentUri(this.address, {this.amount, this.description, this.recipientName});

  static const scheme = 'camo';

  String build() {
    final q = <String>[];
    if (amount != null && !amount!.isZero) q.add('tx_amount=${amount!.toPlain()}');
    if (description != null && description!.isNotEmpty) q.add('tx_description=${Uri.encodeComponent(description!)}');
    if (recipientName != null && recipientName!.isNotEmpty) {
      q.add('recipient_name=${Uri.encodeComponent(recipientName!)}');
    }
    return '$scheme:$address${q.isEmpty ? '' : '?${q.join('&')}'}';
  }

  /// Returns null for anything that is not a well-formed camo: link (including monero: links).
  static PaymentUri? tryParse(String input) {
    var s = input.trim();
    if (!s.toLowerCase().startsWith('$scheme:')) return null;
    s = s.substring(scheme.length + 1);
    if (s.startsWith('//')) s = s.substring(2);
    final qi = s.indexOf('?');
    final address = qi < 0 ? s : s.substring(0, qi);
    if (address.isEmpty) return null;
    CamoAmount? amount;
    String? desc, name;
    if (qi >= 0) {
      for (final part in s.substring(qi + 1).split('&')) {
        if (part.isEmpty) continue;
        final eq = part.indexOf('=');
        final k = eq < 0 ? part : part.substring(0, eq);
        final v = eq < 0 ? '' : Uri.decodeComponent(part.substring(eq + 1));
        switch (k) {
          case 'tx_amount':
            amount = CamoAmount.tryParse(v);
            if (amount == null) return null;
          case 'tx_description':
            desc = v;
          case 'recipient_name':
            name = v;
          default:
            break; // unknown parameters are ignored, as in wallet2's parse_uri
        }
      }
    }
    return PaymentUri(address, amount: amount, description: desc, recipientName: name);
  }
}
