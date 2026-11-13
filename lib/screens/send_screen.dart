// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../wallet/amount.dart';
import '../wallet/network.dart';
import '../wallet/payment_uri.dart';
import '../wallet/wallet_service.dart';

class SendScreen extends StatefulWidget {
  final WalletService wallet;
  final PaymentUri? prefill;
  const SendScreen({super.key, required this.wallet, this.prefill});
  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _to = TextEditingController();
  final _amount = TextEditingController();
  Priority _priority = Priority.normal;
  bool _sweepAll = false;
  bool _busy = false;
  String? _feeText;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    if (p != null) {
      _to.text = p.address;
      if (p.amount != null) _amount.text = p.amount!.toPlain();
    }
    _to.addListener(_onTo);
    _amount.addListener(() => setState(() => _sweepAll = false));
    _estimate();
  }

  String? _amountFromLink;

  /// The field keeps exactly what was typed or pasted; a camo: link in it supplies the address and,
  /// if the amount field is empty or was filled by an earlier link, the amount too.
  void _onTo() {
    final a = PaymentUri.tryParse(_to.text)?.amount?.toPlain();
    if (a != null && (_amount.text.isEmpty || _amount.text == _amountFromLink)) {
      _amountFromLink = a;
      _amount.text = a;
    }
    setState(() {});
  }

  String get _address => PaymentUri.tryParse(_to.text)?.address ?? _to.text.trim();

  Future<void> _estimate() async {
    final d = await widget.wallet.prepareSend(
        address: _address, amount: CamoAmount.tryParse(_amount.text) ?? CamoAmount.zero, sweepAll: _sweepAll, priority: _priority);
    if (mounted) setState(() => _feeText = '~${d.fee.toPlain()}');
  }

  String? get _addressError => switch (addressHint(_address, widget.wallet.network)) {
        AddressHint.empty || AddressHint.looksValid => null,
        AddressHint.moneroAddress => 'That is a Monero address. CAMO can only be sent to CAMO addresses.',
        AddressHint.wrongNetwork => 'That address is for a different CAMO network (${widget.wallet.network.label} wallet).',
        AddressHint.malformed => 'This doesn\'t look like a complete CAMO address.',
      };

  String? get _amountError {
    if (_sweepAll || _amount.text.trim().isEmpty) return null;
    final a = CamoAmount.tryParse(_amount.text);
    if (a == null || a.isZero) return 'Enter an amount like 25 or 0.5';
    if (a > widget.wallet.unlockedBalance) return 'More than your unlocked balance';
    return null;
  }

  bool get _ready =>
      !_busy && widget.wallet.isValidAddress(_address) && _amountError == null && (_sweepAll || _amount.text.trim().isNotEmpty);

  Future<void> _review() async {
    setState(() => _busy = true);
    final w = widget.wallet;
    try {
      final draft = await w.prepareSend(address: _address, amount: CamoAmount.tryParse(_amount.text) ?? CamoAmount.zero, sweepAll: _sweepAll, priority: _priority);
      if (!mounted) return;
      final ok = await showDialog<bool>(context: context, builder: (c) => _ConfirmDialog(draft));
      if (ok != true || !mounted) return;
      final txid = await w.commitSend(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent. Transaction $txid')));
      Navigator.of(context).pop();
    } on UnsupportedError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Not supported')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wallet;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const ScreenHeader('SEND CAMO'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), children: [
              _label('To'),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: TextField(
                    controller: _to,
                    style: Gt.pixel(22),
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(hintText: '${w.network.addressPrefixes.first}… or camo: link', errorText: _addressError, errorMaxLines: 3),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () async {
                      final d = await Clipboard.getData(Clipboard.kTextPlain);
                      if (d?.text != null) _to.text = d!.text!.trim();
                    },
                    child: const Icon(Icons.content_paste, size: 20, color: Gc.text2, semanticLabel: 'Paste'),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              Text('Paste an address, or a camo: link to fill the amount too. QR scanning comes next.', style: Gt.body(12, color: Gc.text3)),
              const SizedBox(height: 18),
              _label('Amount'),
              TextField(
                controller: _amount,
                enabled: !_sweepAll,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: Gt.mono(26, weight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: _sweepAll ? 'Everything unlocked' : '0.00',
                  errorText: _amountError,
                  suffixIcon: Padding(padding: const EdgeInsets.only(right: 14, top: 14), child: Text('CAMO', style: Gt.pixel(20, color: Gc.olive))),
                ),
              ),
              Row(children: [
                Text('Unlocked: ', style: Gt.body(12, color: Gc.text3)),
                Text(w.unlockedBalance.format(), style: Gt.mono(12, color: Gc.text3)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _sweepAll = !_sweepAll;
                    if (_sweepAll) _amount.clear();
                    _estimate();
                  }),
                  child: Text(_sweepAll ? 'Enter an amount' : 'Send max'),
                ),
              ]),
              const SizedBox(height: 8),
              _label('Speed'),
              Row(children: [
                for (final (p, name, hint) in [
                  (Priority.normal, 'Normal', '~2 min'),
                  (Priority.fast, 'Fast', 'next block'),
                  (Priority.low, 'Low', 'when quiet'),
                ]) ...[
                  Expanded(
                    child: Semantics(
                      selected: _priority == p,
                      button: true,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: _priority == p ? const Color(0xFF1A1F14) : Colors.transparent,
                          shape: NotchedBorder(side: BorderSide(color: _priority == p ? Gc.amber : Gc.line)),
                        ),
                        onPressed: () => setState(() {
                          _priority = p;
                          _estimate();
                        }),
                        child: Column(children: [Text(name, style: Gt.body(13)), Text(hint, style: Gt.body(11, color: Gc.text3))]),
                      ),
                    ),
                  ),
                  if (p != Priority.low) const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 18),
              NotchBox(
                color: Gc.panelDark,
                child: Column(children: [
                  _costRow('Network fee (to miners)', _feeText ?? '…'),
                  const SizedBox(height: 10),
                  _costRow('Ghillie fee', '0 · never', color: Gc.olive),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Gc.line3)),
                  const ShieldLine('Hidden among 15 other possible senders. The amount and the receiver never appear on chain.'),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(onPressed: _ready ? _review : null, child: Text('REVIEW SEND', style: Gt.pixel(24, color: _ready ? Gc.bg : Gc.text3))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: Gt.body(13, color: Gc.text2, weight: FontWeight.w500)));
  Widget _costRow(String a, String b, {Color color = Gc.text}) =>
      Row(children: [Expanded(child: Text(a, style: Gt.body(13, color: Gc.text2))), Text(b, style: Gt.mono(13, color: color))]);
}

class _ConfirmDialog extends StatelessWidget {
  final SendDraft d;
  const _ConfirmDialog(this.d);
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('CONFIRM SEND', style: Gt.pixel(28)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${d.amount.format()} CAMO', style: Gt.pixel(40)),
          const SizedBox(height: 12),
          Text('To', style: Gt.body(12, color: Gc.text3)),
          SelectableText(d.address, style: Gt.mono(12)),
          const SizedBox(height: 12),
          Text('Network fee ${d.fee.toPlain()} CAMO · Ghillie fee 0', style: Gt.body(13, color: Gc.text2)),
          const SizedBox(height: 8),
          Text('Payments can\'t be reversed. Check the first and last characters of the address.', style: Gt.body(12, color: Gc.text3)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
        ],
      );
}
