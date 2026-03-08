import 'package:flutter/material.dart';
import 'customer_preferences_screen.dart';
import 'supplier_preferences_screen.dart';
import '../services/customer_index_service.dart';
import '../services/supplier_index_service.dart';
import '../services/sales_storage_service.dart';
import '../services/purchases_storage_service.dart';
import '../services/box_storage_service.dart';

class PreferencesScreen extends StatefulWidget {
  final String selectedDate;
  const PreferencesScreen({super.key, required this.selectedDate});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final CustomerIndexService _customerIndexService = CustomerIndexService();
  final SupplierIndexService _supplierIndexService = SupplierIndexService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التفصيلات'),
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final customers =
                      await _customerIndexService.getAllCustomersWithData();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerPreferencesListScreen(
                        selectedDate: widget.selectedDate,
                        customers: customers,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('تفصيلات الزبائن',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final suppliers =
                      await _supplierIndexService.getAllSuppliersWithData();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupplierPreferencesListScreen(
                        selectedDate: widget.selectedDate,
                        suppliers: suppliers,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('تفصيلات الموردين',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountSummaryScreen(
                        selectedDate: widget.selectedDate,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('تفصيلات الحساب',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- قائمة اختيار الزبون ----
class CustomerPreferencesListScreen extends StatelessWidget {
  final String selectedDate;
  final Map<int, CustomerData> customers;

  const CustomerPreferencesListScreen(
      {super.key, required this.selectedDate, required this.customers});

  @override
  Widget build(BuildContext context) {
    final list = customers.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفضيلات الزبائن'),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: list.isEmpty
            ? const Center(
                child: Text('لا يوجد زبائن مسجلين.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)))
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final customer = list[index];
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerPreferencesScreen(
                              customer: customer,
                              selectedDate: selectedDate,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Text(
                        customer.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

// ---- قائمة اختيار المورد ----
class SupplierPreferencesListScreen extends StatelessWidget {
  final String selectedDate;
  final Map<int, SupplierData> suppliers;

  const SupplierPreferencesListScreen(
      {super.key, required this.selectedDate, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final list = suppliers.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفضيلات الموردين'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: list.isEmpty
            ? const Center(
                child: Text('لا يوجد موردين مسجلين.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)))
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final supplier = list[index];
                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SupplierPreferencesScreen(
                              supplier: supplier,
                              selectedDate: selectedDate,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Text(
                        supplier.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

// ---- شاشة تفصيلات الحساب ----
class AccountSummaryScreen extends StatefulWidget {
  final String selectedDate;
  const AccountSummaryScreen({super.key, required this.selectedDate});

  @override
  State<AccountSummaryScreen> createState() => _AccountSummaryScreenState();
}

class _AccountSummaryScreenState extends State<AccountSummaryScreen> {
  final CustomerIndexService _customerIndexService = CustomerIndexService();
  final SupplierIndexService _supplierIndexService = SupplierIndexService();
  final SalesStorageService _salesStorageService = SalesStorageService();
  final PurchasesStorageService _purchasesStorageService =
      PurchasesStorageService();
  final BoxStorageService _boxStorageService = BoxStorageService();

  double _salesTotal = 0;
  double _purchasesTotal = 0;
  double _boxReceived = 0;
  double _boxPaid = 0;
  double _customersBalance = 0;
  double _suppliersBalance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final salesDoc =
        await _salesStorageService.loadDocumentForDate(widget.selectedDate);
    final purchasesDoc =
        await _purchasesStorageService.loadDocumentForDate(widget.selectedDate);
    final boxDoc =
        await _boxStorageService.loadBoxDocumentForDate(widget.selectedDate);
    final customers = await _customerIndexService.getAllCustomersWithData();
    final suppliers = await _supplierIndexService.getAllSuppliersWithData();

    double sales = 0, purchases = 0, boxRec = 0, boxPaid = 0;

    if (salesDoc != null) {
      sales = double.tryParse(salesDoc.totals['totalPayments'] ?? '0') ?? 0;
    }
    if (purchasesDoc != null) {
      purchases =
          double.tryParse(purchasesDoc.totals['totalPayments'] ?? '0') ?? 0;
    }
    if (boxDoc != null) {
      boxRec = double.tryParse(boxDoc.totals['totalReceived'] ?? '0') ?? 0;
      boxPaid = double.tryParse(boxDoc.totals['totalPaid'] ?? '0') ?? 0;
    }

    final custBalance = customers.values.fold(0.0, (s, c) => s + c.balance);
    final suppBalance = suppliers.values.fold(0.0, (s, c) => s + c.balance);

    if (mounted) {
      setState(() {
        _salesTotal = sales;
        _purchasesTotal = purchases;
        _boxReceived = boxRec;
        _boxPaid = boxPaid;
        _customersBalance = custBalance;
        _suppliersBalance = suppBalance;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double tradingAccountResult = _salesTotal - _purchasesTotal;
    final bool isTradingProfit = tradingAccountResult >= 0;

    final double expenseOrProfit = _boxPaid;
    final double commercialResult = tradingAccountResult - expenseOrProfit;
    final bool isCommercialProfit = commercialResult >= 0;

    final double netResult = commercialResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفصيلات الحساب'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // حساب المتاجرة
                    _buildSectionHeader('حساب المتاجرة'),
                    _buildAccountBox(children: [
                      _buildRow('المشتريات', _purchasesTotal, isDebit: true),
                      _buildRow('المبيعات', _salesTotal, isDebit: false),
                      Divider(color: Colors.grey[300]),
                      _buildRow(
                        isTradingProfit ? 'ربح المتاجرة' : 'خسارة المتاجرة',
                        tradingAccountResult.abs(),
                        isDebit: !isTradingProfit,
                        isBold: true,
                        color: isTradingProfit
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // حساب الأرباح والخسائر
                    _buildSectionHeader('حساب الأرباح والخسائر'),
                    _buildAccountBox(children: [
                      _buildRow('المصروف', _boxPaid, isDebit: true),
                      _buildRow(
                        isTradingProfit ? 'الربح التجاري' : 'الخسارة التجارية',
                        tradingAccountResult.abs(),
                        isDebit: !isTradingProfit,
                      ),
                      Divider(color: Colors.grey[300]),
                      _buildRow(
                        isCommercialProfit ? 'صافي الربح' : 'صافي الخسارة',
                        netResult.abs(),
                        isDebit: !isCommercialProfit,
                        isBold: true,
                        color: isCommercialProfit
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // الميزانية
                    _buildSectionHeader('الميزانية'),
                    _buildAccountBox(children: [
                      _buildRow('الزبائن', _customersBalance, isDebit: false),
                      _buildRow('الصندوق', _boxReceived, isDebit: false),
                      _buildRow('الموردون', _suppliersBalance, isDebit: true),
                      Divider(color: Colors.grey[300]),
                      if (isCommercialProfit)
                        _buildRow('صافي الربح', netResult.abs(),
                            isDebit: false,
                            isBold: true,
                            color: Colors.green[700])
                      else
                        _buildRow('صافي الخسارة', netResult.abs(),
                            isDebit: true,
                            isBold: true,
                            color: Colors.red[700]),
                      _buildRow(
                          'رأس المال',
                          _customersBalance +
                              _boxReceived -
                              _suppliersBalance -
                              (isCommercialProfit ? netResult : -netResult),
                          isDebit: true,
                          isBold: true,
                          color: Colors.indigo[700]),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.indigo[700],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAccountBox({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.shade200),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String label, double amount,
      {required bool isDebit, bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
