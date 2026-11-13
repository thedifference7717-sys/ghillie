import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghillie/main.dart';
import 'package:ghillie/wallet/demo_wallet.dart';

void main() {
  testWidgets('home shows balance, demo badge and actions; send shows the zero Ghillie fee', (t) async {
    t.view.physicalSize = const Size(390, 844) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(GhillieApp(wallet: DemoWallet(), showIntro: false));
    expect(find.text('1,239.63'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
    expect(find.text('Receive'), findsOneWidget);

    await t.tap(find.text('Send'));
    await t.pumpAndSettle();
    expect(find.text('SEND CAMO'), findsOneWidget);
    expect(find.text('0 · never'), findsOneWidget);

    // a Monero address is refused with a clear message
    await t.enterText(find.byType(TextField).first, '44AFFq5kSiGBoZ4NMDwYtN18obc8AemS33DBLWs3H7otXft3XjrpDtQGv7SqSsaBYBb98uNbr2VBBEt7f2wfn3RVGQBEP3A');
    await t.pump();
    expect(find.textContaining('Monero address'), findsOneWidget);

    // a pasted camo: link fills the amount
    await t.enterText(find.byType(TextField).first,
        'camo:QRDxe3VEFdw3pgkqkDJwy8BCzRJxf49EwC7xCPBGchvF55si1tj45rreWb1bU1MoZp9iWaKHHQHV4gHutjkxuQrR1PN3Lxcb9?tx_amount=5');
    await t.pump();
    expect(find.text('5'), findsOneWidget);
    expect(find.textContaining('complete CAMO address'), findsNothing);
  });

  testWidgets('receive shows a camo: link and makes a new labelled address', (t) async {
    t.view.physicalSize = const Size(390, 844) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(GhillieApp(wallet: DemoWallet(), showIntro: false));
    await t.tap(find.text('Receive'));
    await t.pumpAndSettle();
    expect(find.textContaining('camo:Q'), findsOneWidget);
    final btn = find.text('New address for another payer');
    await t.ensureVisible(btn);
    await t.pumpAndSettle();
    await t.tap(btn);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, 'Bob');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.textContaining('"BOB"'), findsOneWidget);
  });

  testWidgets('opening scope: Skip enters the wallet', (t) async {
    t.view.physicalSize = const Size(390, 844) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(GhillieApp(wallet: DemoWallet()));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('DRAG THE SCOPE'), findsOneWidget);
    await t.tap(find.text('Skip'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('1,239.63'), findsOneWidget);
  });
}
