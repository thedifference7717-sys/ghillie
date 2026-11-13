// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'amount.dart';
import 'network.dart';
import 'wallet_service.dart';

CamoAmount _c(String s) => CamoAmount.tryParse(s)!;

/// Sample data only. No keys, no network: shows the screens without a wallet behind them.
/// The app shows a "DEMO" badge whenever this is in use.
class DemoWallet extends WalletService {
  @override
  final CamoNetwork network = CamoNetwork.stagenet;
  @override
  final bool isDemo = true;
  @override
  final String walletName = 'Demo wallet';

  final List<ReceiveAddress> _addrs = [
    const ReceiveAddress(0, 'QRDxe3VEFdw3pgkqkDJwy8BCzRJxf49EwC7xCPBGchvF55si1tj45rreWb1bU1MoZp9iWaKHHQHV4gHutjkxuQrR1PN3Lxcb9', 'Primary address'),
  ];
  late final List<TxRecord> _txs = [
    TxRecord(direction: TxDirection.incoming, amount: _c('5'), fee: CamoAmount.zero, time: DateTime.now().subtract(const Duration(minutes: 2)), confirmations: 3, label: 'Received', txid: 'demo1'),
    TxRecord(direction: TxDirection.incoming, amount: _c('16.980554531455'), fee: CamoAmount.zero, time: DateTime.now().subtract(const Duration(hours: 3)), confirmations: 180, label: 'Mining reward', txid: 'demo2'),
    TxRecord(direction: TxDirection.outgoing, amount: _c('12.345'), fee: _c('0.00123462'), time: DateTime.now().subtract(const Duration(days: 1)), confirmations: 1440, label: 'Sent', txid: 'demo3'),
  ];

  @override
  CamoAmount get balance => _c('1239.63');
  @override
  CamoAmount get unlockedBalance => _c('1002.10');
  @override
  SyncState get sync => const SyncState(connected: true, walletHeight: 2658, chainHeight: 2658, nodeLabel: 'demo node');
  @override
  List<TxRecord> get transactions => List.unmodifiable(_txs);
  @override
  List<ReceiveAddress> get receiveAddresses => List.unmodifiable(_addrs);

  @override
  Future<ReceiveAddress> newReceiveAddress(String label) async {
    // Demo only: not a real subaddress (it reuses the primary address with a different label).
    final a = ReceiveAddress(_addrs.length, _addrs.first.address, label);
    _addrs.add(a);
    notifyListeners();
    return a;
  }

  @override
  Future<void> renameReceiveAddress(int index, String label) async {
    final i = _addrs.indexWhere((a) => a.index == index);
    if (i >= 0) _addrs[i] = ReceiveAddress(index, _addrs[i].address, label);
    notifyListeners();
  }

  @override
  bool isValidAddress(String address) => addressHint(address, network) == AddressHint.looksValid;

  @override
  Future<SendDraft> prepareSend({required String address, required CamoAmount amount, required bool sweepAll, required Priority priority}) async {
    final fee = switch (priority) { Priority.low => _c('0.0003'), Priority.normal => _c('0.00123462'), Priority.fast => _c('0.006') };
    return SendDraft(address: address, amount: sweepAll ? unlockedBalance - fee : amount, sweepAll: sweepAll, priority: priority, fee: fee);
  }

  @override
  Future<String> commitSend(SendDraft draft) async => throw UnsupportedError('The demo wallet cannot send.');
}
