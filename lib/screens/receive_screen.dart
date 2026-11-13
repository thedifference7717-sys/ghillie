// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/qr_view.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../wallet/amount.dart';
import '../wallet/payment_uri.dart';
import '../wallet/wallet_service.dart';

class ReceiveScreen extends StatefulWidget {
  final WalletService wallet;
  const ReceiveScreen({super.key, required this.wallet});
  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _req = TextEditingController();
  late ReceiveAddress _addr = widget.wallet.receiveAddresses.last;

  String get _link => PaymentUri(_addr.address, amount: CamoAmount.tryParse(_req.text)).build();

  Future<String?> _askLabel(String title, String initial) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: Gt.pixel(26)),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'Who is paying? e.g. "Freelance client"')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wallet;
    final reqError = _req.text.trim().isEmpty || CamoAmount.tryParse(_req.text) != null ? null : 'Enter an amount like 25 or 0.5';
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
          const ScreenHeader('RECEIVE CAMO'),
          Center(
            child: NotchBox(color: Gc.text, borderColor: Gc.text, padding: const EdgeInsets.all(18), child: QrView(_link)),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: ShieldLine('A fresh address for each payer · they can\'t link your payments'),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NotchBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text('ADDRESS #${_addr.index} · "${_addr.label}"'.toUpperCase(),
                        style: Gt.body(12, color: Gc.text3).copyWith(letterSpacing: 0.8), overflow: TextOverflow.ellipsis),
                  ),
                  TextButton(
                    onPressed: () async {
                      final l = await _askLabel('RENAME', _addr.label);
                      if (l == null || l.isEmpty) return;
                      await w.renameReceiveAddress(_addr.index, l);
                      setState(() => _addr = w.receiveAddresses.firstWhere((a) => a.index == _addr.index));
                    },
                    child: const Text('Rename'),
                  ),
                ]),
                const SizedBox(height: 4),
                SelectableText(_link, style: Gt.pixel(20).copyWith(height: 1.3)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _link));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment link copied')));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy link'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Request an amount (optional)', style: Gt.body(13, color: Gc.text2, weight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _req,
                onChanged: (_) => setState(() {}),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: Gt.mono(18),
                decoration: InputDecoration(
                  hintText: '0.00',
                  errorText: reqError,
                  suffixIcon: Padding(padding: const EdgeInsets.only(right: 14, top: 14), child: Text('CAMO', style: Gt.pixel(18, color: Gc.olive))),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.transparent),
                  onPressed: () async {
                    final l = await _askLabel('NEW ADDRESS', '');
                    if (l == null) return;
                    final a = await w.newReceiveAddress(l.isEmpty ? 'Payer ${w.receiveAddresses.length}' : l);
                    setState(() => _addr = a);
                  },
                  child: const Text('New address for another payer'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
