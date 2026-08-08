import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class SubscriptionsListPage extends StatelessWidget {
  const SubscriptionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.subscriptionsTitle)),
      body: const Center(child: Text(Strings.subscriptionsTitle)),
    );
  }
}
