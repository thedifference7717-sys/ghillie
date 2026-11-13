import 'package:flutter_test/flutter_test.dart';
import 'package:ghillie/wallet/amount.dart';
import 'package:ghillie/wallet/network.dart';
import 'package:ghillie/wallet/payment_uri.dart';

const q = 'QRDxe3VEFdw3pgkqkDJwy8BCzRJxf49EwC7xCPBGchvF55si1tj45rreWb1bU1MoZp9iWaKHHQHV4gHutjkxuQrR1PN3Lxcb9';
const c = 'Cfbe7EfJzZW4H6Li6bvsmfTvjdQE5gsGvTf1PhS9MvnnEHpQUwgxVvFJd79u6KsgibPht4u2PRyj2fU7awZCoaPc6FaAtK4';

void main() {
  group('CamoAmount', () {
    test('parses and prints exactly', () {
      expect(CamoAmount.tryParse('25')!.atomic, BigInt.from(25) * CamoAmount.unitsPerCamo);
      expect(CamoAmount.tryParse('0.000000000001')!.atomic, BigInt.one);
      expect(CamoAmount.tryParse('.5')!.toPlain(), '0.5');
      expect(CamoAmount.tryParse('1239.630000')!.toPlain(), '1239.63');
      expect(CamoAmount.tryParse('16.980554531455')!.toPlain(), '16.980554531455');
    });
    test('rejects bad input', () {
      for (final s in ['', '-1', '1e3', '1,000', '0.0000000000001', 'abc', '1.2.3', ' . ']) {
        expect(CamoAmount.tryParse(s), isNull, reason: s);
      }
    });
    test('formats with grouping and truncates (never rounds up)', () {
      expect(CamoAmount.tryParse('1239.639')!.format(maxDecimals: 2), '1,239.63');
      expect(CamoAmount.tryParse('5')!.format(), '5.00');
      expect(CamoAmount.tryParse('18132000')!.format(maxDecimals: 0, minDecimals: 0), '18,132,000');
    });
    test('handles more than int64 atomic units', () {
      final big = CamoAmount.tryParse('18446744.073709551616')!; // 2^64 picocamo
      expect(big.atomic, BigInt.two.pow(64));
    });
  });

  group('addresses', () {
    test('network prefixes', () {
      expect(addressHint(q, CamoNetwork.stagenet), AddressHint.looksValid);
      expect(addressHint(c, CamoNetwork.mainnet), AddressHint.looksValid);
      expect(addressHint(q, CamoNetwork.mainnet), AddressHint.wrongNetwork);
      expect(addressHint(c, CamoNetwork.stagenet), AddressHint.wrongNetwork);
    });
    test('monero and junk', () {
      expect(addressHint('44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A', CamoNetwork.mainnet),
          AddressHint.moneroAddress);
      expect(addressHint('C0OIl', CamoNetwork.mainnet), AddressHint.malformed);
      expect(addressHint(c.substring(0, 60), CamoNetwork.mainnet), AddressHint.malformed);
      expect(addressHint('', CamoNetwork.mainnet), AddressHint.empty);
    });
  });

  group('camo: links', () {
    test('round trip', () {
      final u = PaymentUri(c, amount: CamoAmount.tryParse('25.5'), description: 'Coffee & cake');
      final s = u.build();
      expect(s, 'camo:$c?tx_amount=25.5&tx_description=Coffee%20%26%20cake');
      final p = PaymentUri.tryParse(s)!;
      expect(p.address, c);
      expect(p.amount!.toPlain(), '25.5');
      expect(p.description, 'Coffee & cake');
    });
    test('accepts camo:// and plain address, rejects monero: and bad amounts', () {
      expect(PaymentUri.tryParse('camo://$c')!.address, c);
      expect(PaymentUri.tryParse('camo:$c')!.amount, isNull);
      expect(PaymentUri.tryParse('monero:$c'), isNull);
      expect(PaymentUri.tryParse('camo:$c?tx_amount=abc'), isNull);
      expect(PaymentUri.tryParse(c), isNull);
    });
  });
}
