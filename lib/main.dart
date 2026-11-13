// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'ui/theme.dart';
import 'wallet/demo_wallet.dart';
import 'wallet/wallet_service.dart';

void main() => runApp(GhillieApp(wallet: DemoWallet()));

class GhillieApp extends StatelessWidget {
  final WalletService wallet;
  const GhillieApp({super.key, required this.wallet});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ghillie',
        debugShowCheckedModeBanner: false,
        theme: ghillieTheme(),
        home: HomeScreen(wallet: wallet),
      );
}
