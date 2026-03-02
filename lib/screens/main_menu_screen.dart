import 'package:flutter/material.dart';
import 'customer_management_screen.dart';
import 'supplier_management_screen.dart';
import 'preferences_screen.dart';
import 'sales_screen.dart';
import 'purchases_screen.dart';
import 'cashbox_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final String selectedDate;

  const MainMenuScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القائمة الرئيسية - $selectedDate'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // العمود الأيمن
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMenuButton(
                        context: context,
                        text: '  الزبائن',
                        icon: Icons.person_add_alt_1,
                        color: Colors.teal[600]!,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CustomerManagementScreen(
                                      selectedDate: selectedDate)));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildMenuButton(
                        context: context,
                        text: 'التفضيلات',
                        icon: Icons.person_search,
                        color: Colors.blueGrey[600]!,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PreferencesScreen(
                                      selectedDate: selectedDate)));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildMenuButton(
                        context: context,
                        text: 'الموردين',
                        icon: Icons.local_shipping,
                        color: Colors.brown[600]!,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SupplierManagementScreen(
                                      selectedDate: selectedDate)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // العمود الأيسر
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMenuButton(
                        context: context,
                        text: 'المبيعات',
                        icon: Icons.sell,
                        color: Colors.green[700]!,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      SalesScreen(selectedDate: selectedDate)));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildMenuButton(
                        context: context,
                        text: 'المشتريات',
                        icon: Icons.shopping_cart,
                        color: Colors.blue[700]!,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PurchasesScreen(
                                      selectedDate: selectedDate)));
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildMenuButton(
                        context: context,
                        text: 'الصندوق',
                        icon: Icons.account_balance_wallet,
                        color: Colors.purple[700]!,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CashboxScreen(
                                      selectedDate: selectedDate)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
