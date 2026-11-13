// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import '../ui/format.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../wallet/wallet_service.dart';
import 'receive_screen.dart';
import 'rigs_screen.dart';
import 'send_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final WalletService wallet;
  const HomeScreen({super.key, required this.wallet});

  void _go(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wallet,
      builder: (context, _) {
        final s = wallet.sync;
        final whole = wallet.balance.format(minDecimals: 2, maxDecimals: 2);
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), children: [
                  Row(children: [
                    Image.asset('assets/images/ghillie-icon.png', width: 36, height: 36, filterQuality: FilterQuality.high),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                          Text('GHILLIE', style: Gt.pixel(26)),
                          if (wallet.isDemo) const DemoBadge(),
                        ]),
                        Text('${wallet.walletName} · ${wallet.network.label}', style: Gt.body(12, color: Gc.text3), overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(44, 44)),
                        onPressed: () => _go(context, SettingsScreen(wallet: wallet)),
                        child: const Icon(Icons.settings_outlined, size: 20, color: Gc.text2, semanticLabel: 'Settings'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: NotchBox(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: Gc.bg,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        SquareDot(color: s.synced ? Gc.olive : Gc.amber),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text.rich(
                            TextSpan(style: Gt.body(12, color: Gc.text2), children: [
                              TextSpan(text: s.synced ? 'Synced · ${s.nodeLabel} · block ' : 'Syncing · ${(s.progress * 100).floor()}% · block '),
                              TextSpan(text: groupInt(s.chainHeight), style: Gt.mono(12, color: Gc.text2)),
                            ]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NotchBox(
                    camo: true,
                    borderColor: Gc.line2,
                    borderWidth: 2,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('BALANCE', style: Gt.body(13, color: Gc.text3).copyWith(letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 8, children: [
                        Text(whole, style: Gt.pixel(58)),
                        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('CAMO', style: Gt.pixel(26, color: Gc.olive))),
                      ]),
                      const SizedBox(height: 6),
                      Text.rich(TextSpan(style: Gt.body(13, color: Gc.text2), children: [
                        const TextSpan(text: 'Unlocked '),
                        TextSpan(text: wallet.unlockedBalance.format(maxDecimals: 2), style: Gt.mono(13, color: Gc.text2)),
                        TextSpan(text: ' · ${(wallet.balance - wallet.unlockedBalance).format(maxDecimals: 2)} unlocking'),
                      ])),
                      const SizedBox(height: 14),
                      const ShieldLine('Sender, receiver and amount hidden on every payment'),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _Action(icon: Icons.north_east, label: 'Send', primary: true, onTap: () => _go(context, SendScreen(wallet: wallet)))),
                    const SizedBox(width: 10),
                    Expanded(child: _Action(icon: Icons.south_west, label: 'Receive', onTap: () => _go(context, ReceiveScreen(wallet: wallet)))),
                    const SizedBox(width: 10),
                    Expanded(child: _Action(icon: Icons.desktop_windows_outlined, label: 'Rigs', onTap: () => _go(context, const RigsScreen()))),
                  ]),
                  const SizedBox(height: 18),
                  Text('RECENT', style: Gt.pixel(20, color: Gc.text2)),
                  const SizedBox(height: 4),
                  if (wallet.transactions.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('No payments yet.', style: Gt.body(14, color: Gc.text3))),
                  for (final (i, t) in wallet.transactions.indexed) _TxRow(t, last: i == wallet.transactions.length - 1),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap, this.primary = false});
  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(children: [Icon(icon, size: 22), const SizedBox(height: 6), Text(label)]),
    );
    return primary
        ? FilledButton(onPressed: onTap, style: FilledButton.styleFrom(padding: EdgeInsets.zero), child: child)
        : OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(padding: EdgeInsets.zero), child: child);
  }
}

class _TxRow extends StatelessWidget {
  final TxRecord t;
  final bool last;
  const _TxRow(this.t, {this.last = false});
  @override
  Widget build(BuildContext context) {
    final inc = t.direction == TxDirection.incoming;
    final status = t.confirmations < 10 ? '${t.confirmations} of 10 confirmations' : (inc ? 'Confirmed' : 'fee ${t.fee.toPlain()}');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: Gc.line3))),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.label, style: Gt.body(14)),
            Text('${ago(t.time)} · $status', style: Gt.body(12, color: Gc.text3)),
          ]),
        ),
        Text('${inc ? '+' : '−'}${t.amount.format(minDecimals: 2, maxDecimals: 4)}',
            style: Gt.mono(14, color: inc ? Gc.olive : Gc.text)),
      ]),
    );
  }
}
