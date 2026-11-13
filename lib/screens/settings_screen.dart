// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../wallet/wallet_service.dart';

const ghillieMobileVersion = '0.1.0';

class SettingsScreen extends StatelessWidget {
  final WalletService wallet;
  const SettingsScreen({super.key, required this.wallet});
  @override
  Widget build(BuildContext context) {
    Widget row(String a, String b) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [Expanded(child: Text(a, style: Gt.body(14, color: Gc.text2))), Text(b, style: Gt.mono(13))]),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
          const ScreenHeader('SETTINGS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NotchBox(
              child: Column(children: [
                row('Network', wallet.network.label),
                row('Node', wallet.sync.nodeLabel),
                row('Ghillie fee', '0 · never'),
                row('Price lookups', 'off'),
                row('Version', 'Ghillie $ghillieMobileVersion${wallet.isDemo ? ' (demo)' : ''}'),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShieldLine('Ghillie talks only to the CAMO node you choose. No analytics, no price services, no update checks. '
                'Download it only from camocoin.org or the official app stores.'),
          ),
        ]),
      ),
    );
  }
}
