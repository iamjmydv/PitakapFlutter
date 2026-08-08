import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.statsTitle)),
      body: const Center(child: Text(Strings.statsTitle)),
    );
  }
}
