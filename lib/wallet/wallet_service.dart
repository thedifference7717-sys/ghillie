// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/foundation.dart';
import 'amount.dart';
import 'network.dart';

enum TxDirection { incoming, outgoing }

class TxRecord {
  final TxDirection direction;
  final CamoAmount amount;
  final CamoAmount fee;
  final DateTime time;
  final int confirmations;
  final String label; // "Received", "Sent", "Mining reward"
  final String txid;
  const TxRecord({
    required this.direction,
    required this.amount,
    required this.fee,
    required this.time,
    required this.confirmations,
    required this.label,
    required this.txid,
  });
  bool get unlocked => confirmations >= 10;
}

class SyncState {
  final bool connected;
  final int walletHeight;
  final int chainHeight;
  final String nodeLabel; // "your own node", "community node 1.2.3.4"
  const SyncState({required this.connected, required this.walletHeight, required this.chainHeight, required this.nodeLabel});
  bool get synced => connected && chainHeight > 0 && walletHeight >= chainHeight;
  double get progress => chainHeight == 0 ? 0 : (walletHeight / chainHeight).clamp(0, 1).toDouble();
}

class ReceiveAddress {
  final int index; // subaddress index in account 0; 0 = primary address
  final String address;
  final String label;
  const ReceiveAddress(this.index, this.address, this.label);
}

enum Priority { low, normal, fast }

class SendDraft {
  final String address;
  final CamoAmount amount; // ignored when sweepAll
  final bool sweepAll;
  final Priority priority;
  final CamoAmount fee; // estimated by the wallet library
  const SendDraft({required this.address, required this.amount, required this.sweepAll, required this.priority, required this.fee});
}

/// Everything the screens need from a wallet. The real implementation calls CAMO's wallet library
/// (libwallet, src/wallet/api in the camo repository) through dart:ffi; all key handling, address
/// validation, ring/decoy selection and transaction building stay inside that audited code.
/// [DemoWallet] implements it with fixed sample data for screen work and tests.
abstract class WalletService extends ChangeNotifier {
  CamoNetwork get network;
  bool get isDemo;
  String get walletName;
  CamoAmount get balance;
  CamoAmount get unlockedBalance;
  SyncState get sync;
  List<TxRecord> get transactions; // newest first
  List<ReceiveAddress> get receiveAddresses;

  /// Creates the next subaddress ("a fresh address for each payer").
  Future<ReceiveAddress> newReceiveAddress(String label);
  Future<void> renameReceiveAddress(int index, String label);

  /// Full validation by the wallet library (checksum, network).
  bool isValidAddress(String address);

  /// Builds (but does not broadcast) a transaction and returns its real fee.
  Future<SendDraft> prepareSend({required String address, required CamoAmount amount, required bool sweepAll, required Priority priority});
  Future<String> commitSend(SendDraft draft); // returns txid
}
