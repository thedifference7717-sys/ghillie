// Copyright (c) 2026, The CAMO Project. BSD-3-Clause, see LICENSE.
import 'package:flutter/material.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// Remote mining control is planned for 2027 (pair a computer running Ghillie desktop, then start, stop,
/// cap CPU and watch it from the phone). Phones never mine and can never spend or see keys through pairing.
class RigsScreen extends StatelessWidget {
  const RigsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
            const ScreenHeader('RIGS'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NotchBox(
                camo: true,
                borderColor: Gc.line2,
                borderWidth: 2,
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('REMOTE MINING · COMING 2027', style: Gt.pixel(24, color: Gc.amber)),
                  const SizedBox(height: 10),
                  Text('Pair the computers that run Ghillie desktop, then start, stop and watch their mining from here.',
                      style: Gt.body(14, color: Gc.text2).copyWith(height: 1.45)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            for (final line in const [
              'Your phone never mines: app stores don\'t allow it, and CPUs do it far better.',
              'Pairing is end-to-end encrypted, by QR code or pairing words.',
              'A paired phone can start, stop, cap CPU and watch. It can never spend, see keys or change where rewards go.',
            ])
              Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: ShieldLine(line)),
          ]),
        ),
      );
}
