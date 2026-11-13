// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.

/// CAMO networks. Prefix letters follow src/cryptonote_config.h in the camo repository:
/// mainnet 69/70/71 -> "C", stagenet 140/141/142 -> "Q", testnet 112/113/114 -> "K"/"L".
enum CamoNetwork {
  mainnet('Mainnet', 19741, ['C'], 95),
  stagenet('Stagenet', 39741, ['Q'], 97),
  testnet('Testnet', 29741, ['K', 'L'], 95);

  const CamoNetwork(this.label, this.defaultRpcPort, this.addressPrefixes, this.standardAddressLength);
  final String label;
  final int defaultRpcPort;
  final List<String> addressPrefixes;
  final int standardAddressLength;
}

const _base58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// A quick, offline shape check for the address field while the user types. It is NOT the real
/// validation: the wallet library (libwallet) decodes the address and verifies its checksum
/// before anything is sent.
enum AddressHint { empty, looksValid, wrongNetwork, moneroAddress, malformed }

AddressHint addressHint(String raw, CamoNetwork net) {
  final s = raw.trim();
  if (s.isEmpty) return AddressHint.empty;
  if (s.split('').any((c) => !_base58.contains(c))) return AddressHint.malformed;
  if (s.startsWith('4') || s.startsWith('8') || s.startsWith('5') || s.startsWith('7') || s.startsWith('9') ||
      s.startsWith('A') || s.startsWith('B')) {
    return AddressHint.moneroAddress;
  }
  final other = CamoNetwork.values.where((n) => n != net);
  if (!net.addressPrefixes.any(s.startsWith)) {
    return other.any((n) => n.addressPrefixes.any(s.startsWith)) ? AddressHint.wrongNetwork : AddressHint.malformed;
  }
  // standard and subaddresses share a length; integrated addresses are 11 characters longer
  if (s.length != net.standardAddressLength && s.length != net.standardAddressLength + 11) {
    return AddressHint.malformed;
  }
  return AddressHint.looksValid;
}

String shortAddress(String a, {int head = 8, int tail = 6}) =>
    a.length <= head + tail + 1 ? a : '${a.substring(0, head)}…${a.substring(a.length - tail)}';
