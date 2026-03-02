import 'package:flutter/material.dart';
import '../services/supplier_index_service.dart';
import '../services/purchases_storage_service.dart';

class SupplierPreferencesScreen extends StatefulWidget {
  final SupplierData supplier;
  final String selectedDate;

  const SupplierPreferencesScreen(
      {Key? key, required this.supplier, required this.selectedDate})
      : super(key: key);

  @override
  _SupplierPreferencesScreenState createState() =>
      _SupplierPreferencesScreenState();
}

class _SupplierPreferencesScreenState
    extends State<SupplierPreferencesScreen> {
  final PurchasesStorageService _purchasesService = PurchasesStorageService();

  bool _isLoading = true;
  List<Map<String, String>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final selectedDate = _parseDate(widget.selectedDate);
    final firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);

    List<Map<String, String>> transactions = [];

    for (int i = 0;
        i <= selectedDate.difference(firstDayOfMonth).inDays;
        i++) {
      final currentDate = firstDayOfMonth.add(Duration(days: i));
      final dateString =
          '${currentDate.year}/${currentDate.month}/${currentDate.day}';

      final doc = await _purchasesService.loadDocumentForDate(dateString);
      if (doc != null) {
        for (var t in doc.transactions) {
          if (t.workerName == widget.supplier.name &&
              t.paymentValue.isNotEmpty) {
            transactions.add({
              'date': dateString,
              'value': t.paymentValue,
              'notes': t.notes,
            });
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTransactions = _transactions.fold(
        0.0, (sum, p) => sum + (double.tryParse(p['value'] ?? '0') ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(
                                Icons.phone,
                                'الموبايل',
                                widget.supplier.mobile.isEmpty
                                    ? '—'
                                    : widget.supplier.mobile),
                            const Divider(),
                            _buildInfoRow(
                                Icons.account_balance_wallet,
                                'الرصيد النهائي',
                                widget.supplier.balance
                                    .toStringAsFixed(2)
                                    .replaceAll(RegExp(r'\.00$'), '')),
                            const Divider(),
                            _buildInfoRow(Icons.calendar_today, 'تاريخ البدء',
                                widget.supplier.startDate),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('قيمة المسحوبات',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.brown[700],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'المجموع: ${totalTransactions.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_transactions.isEmpty)
                              const Center(
                                  child: Text('لا توجد معاملات مسجلة',
                                      style: TextStyle(color: Colors.grey)))
                            else
                              Table(
                                border: TableBorder.all(
                                    color: Colors.grey.shade300),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(3),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200]),
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Text('التاريخ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Text('المبلغ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Text('البيان',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                  ..._transactions.map((p) => TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(p['date'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 11),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(p['value'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(p['notes'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 11),
                                                textAlign: TextAlign.center),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown[700], size: 20),
          const SizedBox(width: 10),
          Text('$label: ',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
