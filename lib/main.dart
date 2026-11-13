// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scope_intro.dart';
import 'ui/theme.dart';
import 'wallet/demo_wallet.dart';
import 'wallet/wallet_service.dart';

void main() => runApp(GhillieApp(wallet: DemoWallet()));

class GhillieApp extends StatefulWidget {
  final WalletService wallet;
  final bool showIntro;
  const GhillieApp({super.key, required this.wallet, this.showIntro = true});
  @override
  State<GhillieApp> createState() => _GhillieAppState();
}

class _GhillieAppState extends State<GhillieApp> {
  late bool _intro = widget.showIntro;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ghillie',
        debugShowCheckedModeBanner: false,
        theme: ghillieTheme(),
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _intro
              ? ScopeIntro(key: const ValueKey('intro'), onEnter: () => setState(() => _intro = false))
              : HomeScreen(key: const ValueKey('home'), wallet: widget.wallet),
        ),
      );
}
