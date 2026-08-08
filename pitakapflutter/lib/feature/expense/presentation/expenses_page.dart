import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.expensesTitle)),
      body: const Center(child: Text(Strings.expensesTitle)),
    );
  }
}
