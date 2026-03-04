import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../services/customer_index_service.dart';
import '../services/sales_storage_service.dart';

class CustomerPreferencesScreen extends StatefulWidget {
  final CustomerData customer;
  final String selectedDate;

  const CustomerPreferencesScreen(
      {Key? key, required this.customer, required this.selectedDate})
      : super(key: key);

  @override
  _CustomerPreferencesScreenState createState() =>
      _CustomerPreferencesScreenState();
}

class _CustomerPreferencesScreenState extends State<CustomerPreferencesScreen> {
  final SalesStorageService _salesService = SalesStorageService();

  bool _isLoading = true;

  /// القائمة الكاملة من السجلات — لا تُمسّ أبداً
  // تهيئة فارغة مضمونة منذ البداية لتجنب null في build
  List<Map<String, String>> _allTransactions = <Map<String, String>>[];

  /// القائمة المعروضة — تتحكم بها قاعدة الرصيد فقط
  List<Map<String, String>> _visibleTransactions = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  /// مستمع: يُستدعى عند تغيّر بيانات الزبون من الوالد
  @override
  void didUpdateWidget(CustomerPreferencesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customer.balance != widget.customer.balance) {
      _applyVisibilityRule(widget.customer.balance);
    }
  }

  /// ─────────────────────────────────────────────────────────────────
  /// الخوارزمية: إخفاء/إظهار من الواجهة فقط — لا حذف من السجلات
  ///   رصيد = 0  →  _visibleTransactions = []   (إخفاء)
  ///   رصيد ≠ 0  →  _visibleTransactions = نسخة من _allTransactions
  /// ─────────────────────────────────────────────────────────────────
  void _applyVisibilityRule(double balance) {
    if (!mounted) return;
    final bool shouldHide = balance == 0.0;
    setState(() {
      _visibleTransactions = shouldHide
          ? <Map<String, String>>[]
          : List<Map<String, String>>.from(_allTransactions);
    });
    if (shouldHide && _allTransactions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('الرصيد أصبح صفراً — تم إخفاء سجلات المسحوبات من العرض'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadDetails() async {
    final selectedDate = _parseDate(widget.selectedDate);
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);

    final List<Map<String, String>> transactions = <Map<String, String>>[];

    for (int i = 0; i <= selectedDate.difference(firstDayOfMonth).inDays; i++) {
      final currentDate = firstDayOfMonth.add(Duration(days: i));
      final dateString =
          '${currentDate.year}/${currentDate.month}/${currentDate.day}';

      final doc = await _salesService.loadDocumentForDate(dateString);
      if (doc != null) {
        for (var t in doc.transactions) {
          if (t.workerName == widget.customer.name &&
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

    if (!mounted) return;

    // نحدّث _allTransactions و_isLoading ثم نطبّق قاعدة الإخفاء داخل setState واحدة
    setState(() {
      _allTransactions = transactions;
      _isLoading = false;
      // تطبيق القاعدة مباشرة داخل نفس setState لضمان التزامن
      _visibleTransactions = (widget.customer.balance == 0.0)
          ? <Map<String, String>>[]
          : List<Map<String, String>>.from(transactions);
    });

    // إشعار المستخدم إن كان الرصيد صفراً وتوجد سجلات
    if (widget.customer.balance == 0.0 && transactions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('الرصيد أصبح صفراً — تم إخفاء سجلات المسحوبات من العرض'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ─── PDF ──────────────────────────────────────────────────────────

  Future<void> _generateAndSharePdf() async {
    try {
      final pdf = pw.Document();

      var arabicFont;
      try {
        final fontData =
            await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
        arabicFont = pw.Font.ttf(fontData);
      } catch (e) {
        arabicFont = pw.Font.courier();
      }

      final PdfColor headerColor = PdfColor.fromInt(0xFF00796B);
      final PdfColor headerTextColor = PdfColors.white;
      final PdfColor rowEvenColor = PdfColors.white;
      final PdfColor rowOddColor = PdfColor.fromInt(0xFFB2DFDB);
      final PdfColor borderColor = PdfColor.fromInt(0xFFE0E0E0);

      final displayList = List<Map<String, String>>.from(_visibleTransactions);

      final double totalTransactions = displayList.fold<double>(
          0.0, (sum, p) => sum + (double.tryParse(p['value'] ?? '0') ?? 0));

      final balanceStr = widget.customer.balance
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'\.00$'), '');
      final totalStr =
          totalTransactions.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          build: (pw.Context context) {
            return [
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        'تفاصيل الزبون: ${widget.customer.name}',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Center(
                      child: pw.Text(
                        'حتى تاريخ ${widget.selectedDate}',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey700),
                      ),
                    ),
                    pw.SizedBox(height: 14),
                    // بطاقة المعلومات — بدون إيموجي لتجنب مشاكل الخط
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: borderColor, width: 0.8),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Column(
                        children: [
                          _buildPdfInfoRow(
                              'الموبايل',
                              widget.customer.mobile.isEmpty
                                  ? '—'
                                  : widget.customer.mobile),
                          pw.Divider(color: borderColor),
                          _buildPdfInfoRow('الرصيد النهائي', balanceStr),
                          pw.Divider(color: borderColor),
                          _buildPdfInfoRow(
                              'تاريخ البدء', widget.customer.startDate),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 14),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('قيمة المسحوبات',
                            style: pw.TextStyle(
                                fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: headerColor,
                            borderRadius: pw.BorderRadius.circular(20),
                          ),
                          child: pw.Text(
                            'المجموع: $totalStr',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    if (displayList.isEmpty)
                      pw.Center(
                        child: pw.Text('لا توجد معاملات مسجلة',
                            style: const pw.TextStyle(color: PdfColors.grey)),
                      )
                    else
                      pw.Table(
                        border:
                            pw.TableBorder.all(color: borderColor, width: 0.5),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(2),
                          2: pw.FlexColumnWidth(3),
                        },
                        children: [
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: headerColor),
                            children: [
                              _buildPdfHeaderCell('التاريخ', headerTextColor),
                              _buildPdfHeaderCell('المبلغ', headerTextColor),
                              _buildPdfHeaderCell('البيان', headerTextColor),
                            ],
                          ),
                          ...displayList.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final p = entry.value;
                            final color =
                                idx % 2 == 0 ? rowEvenColor : rowOddColor;
                            return pw.TableRow(
                              decoration: pw.BoxDecoration(color: color),
                              children: [
                                _buildPdfCell(p['date'] ?? ''),
                                _buildPdfCell(p['value'] ?? '', isBold: true),
                                _buildPdfCell(p['notes'] ?? ''),
                              ],
                            );
                          }).toList(),
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFF80CBC4)),
                            children: [
                              _buildPdfCell('المجموع', isBold: true),
                              _buildPdfCell(totalStr, isBold: true),
                              _buildPdfCell(''),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final safeDate = widget.selectedDate.replaceAll('/', '-');
      final safeName = widget.customer.name.replaceAll(' ', '_');
      final file = File("${output.path}/تفاصيل_زبون_${safeName}_$safeDate.pdf");

      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)],
          text:
              'تفاصيل الزبون ${widget.customer.name} - ${widget.selectedDate}');
    } catch (e) {
      debugPrint("PDF Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('حدث خطأ أثناء تصدير PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Text('$label: ',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfHeaderCell(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              color: color, fontSize: 10, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // حساب آمن — _visibleTransactions مضمون التهيئة دائماً
    final double totalVisible = _visibleTransactions.fold<double>(
        0.0, (sum, p) => sum + (double.tryParse(p['value'] ?? '0') ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: _isLoading ? null : _generateAndSharePdf,
          ),
        ],
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
                                widget.customer.mobile.isEmpty
                                    ? '—'
                                    : widget.customer.mobile),
                            const Divider(),
                            _buildInfoRow(
                                Icons.account_balance_wallet,
                                'الرصيد النهائي',
                                widget.customer.balance
                                    .toStringAsFixed(2)
                                    .replaceAll(RegExp(r'\.00$'), '')),
                            const Divider(),
                            _buildInfoRow(Icons.calendar_today, 'تاريخ البدء',
                                widget.customer.startDate),
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
                                    color: Colors.teal[700],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'المجموع: ${totalVisible.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_visibleTransactions.isEmpty)
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
                                    decoration:
                                        BoxDecoration(color: Colors.grey[200]),
                                    children: const [
                                      Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Text('التاريخ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              textAlign: TextAlign.center)),
                                      Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Text('المبلغ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              textAlign: TextAlign.center)),
                                      Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Text('البيان',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              textAlign: TextAlign.center)),
                                    ],
                                  ),
                                  ..._visibleTransactions.map((p) =>
                                      TableRow(children: [
                                        Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(p['date'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 11),
                                                textAlign: TextAlign.center)),
                                        Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(p['value'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center)),
                                        Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Text(p['notes'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 11),
                                                textAlign: TextAlign.center)),
                                      ])),
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
          Icon(icon, color: Colors.teal[700], size: 20),
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
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
