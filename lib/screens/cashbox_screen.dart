import 'package:flutter/material.dart';

class CashboxScreen extends StatelessWidget {
  final String selectedDate;

  const CashboxScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصندوق - $selectedDate'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Text(
            'شاشة الصندوق',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
