import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {
  Future<List<int>> generateReportPdf({
    required DateTime startDate,
    required DateTime endDate,
    required double totalSales,
    required double totalProfits,
    required double totalInventory,
    required int totalQuantitySold,
    required int totalStockValue,
    required int lowStockAlert,
    required double salesGrowth,
    required double profitMargin,
    required double cogs, // Cost of Goods Sold
    required double averageOrderValue,
    required int totalCustomers,
    required List<Map<String, dynamic>> productDetails,
    required List<Map<String, dynamic>> salesByCategory,
    required List<Map<String, dynamic>> customerMetrics,
  }) async {
    try {
      final pdf = pw.Document();

      // Load logo image
      final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/a.png')).buffer.asUint8List(),
      );

      // Await the page theme
      final pageTheme = await _buildPageTheme(PdfPageFormat.a4);

      // Cover Page
      pdf.addPage(
        pw.Page(
          pageTheme: pageTheme,
          build: (pw.Context context) =>
              _buildCoverPage(startDate, endDate, logoImage),
        ),
      );

      // Executive Summary Page
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          build: (pw.Context context) => [
            _buildExecutiveSummary(
                totalSales, totalProfits, salesGrowth, totalCustomers),
            _buildDivider(),
            _buildDetailedMetricsSection(
              totalSales: totalSales,
              totalProfits: totalProfits,
              totalInventory: totalInventory,
              totalQuantitySold: totalQuantitySold,
              totalStockValue: totalStockValue,
              lowStockAlert: lowStockAlert,
              salesGrowth: salesGrowth,
              profitMargin: profitMargin,
              cogs: cogs,
              averageOrderValue: averageOrderValue,
              totalCustomers: totalCustomers,
            ),
            _buildChartsAndGraphs(),
            _buildComparisonSection(),
            _buildRecommendations(),
          ],
          footer: (pw.Context context) => _buildFooter(context),
        ),
      );

      // Product Details and Appendix
      _addProductDetailsPages(pdf, productDetails);
      _addAppendix(pdf, salesByCategory, customerMetrics);

      return pdf.save();
    } catch (e) {
      print("Error generating PDF: $e");
      rethrow;
    }
  }

  // Cover Page
  pw.Widget _buildCoverPage(
      DateTime startDate, DateTime endDate, pw.ImageProvider logoImage) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Image(logoImage, width: 100, height: 100),
          pw.SizedBox(height: 40),
          pw.Text(
            'VendorPal Sales Report',
            style: pw.TextStyle(
                fontSize: 40,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueAccent),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'For the period: ${DateFormat.yMMMd().format(startDate)} - ${DateFormat.yMMMd().format(endDate)}',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  // Executive Summary
  pw.Widget _buildExecutiveSummary(double totalSales, double totalProfits,
      double salesGrowth, int totalCustomers) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Executive Summary',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text(
          'The total sales for this period were \$${totalSales.toStringAsFixed(2)}, with a profit of \$${totalProfits.toStringAsFixed(2)}. '
          'Sales growth is ${salesGrowth.toStringAsFixed(2)}% compared to the previous period. '
          'The business served a total of $totalCustomers customers, showcasing steady performance.',
          style: pw.TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Detailed Metrics Section
  pw.Widget _buildDetailedMetricsSection({
    required double totalSales,
    required double totalProfits,
    required double totalInventory,
    required int totalQuantitySold,
    required int totalStockValue,
    required int lowStockAlert,
    required double salesGrowth,
    required double profitMargin,
    required double cogs,
    required double averageOrderValue,
    required int totalCustomers,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.blueAccent),
      children: [
        _buildSummaryRow('Metric', 'Value', header: true),
        _buildSummaryRow('Total Sales', '\$${totalSales.toStringAsFixed(2)}'),
        _buildSummaryRow(
            'Total Profit', '\$${totalProfits.toStringAsFixed(2)}'),
        _buildSummaryRow('Sales Growth', '${salesGrowth.toStringAsFixed(2)}%'),
        _buildSummaryRow(
            'Profit Margin', '${profitMargin.toStringAsFixed(2)}%'),
        _buildSummaryRow('Total Stock Value', '\$$totalStockValue'),
        _buildSummaryRow('Low Stock Alert', '$lowStockAlert items'),
        _buildSummaryRow(
            'Cost of Goods Sold (COGS)', '\$${cogs.toStringAsFixed(2)}'),
        _buildSummaryRow(
            'Average Order Value', '\$${averageOrderValue.toStringAsFixed(2)}'),
        _buildSummaryRow('Total Customers', '$totalCustomers'),
        _buildSummaryRow('Total Quantity Sold', '$totalQuantitySold units'),
      ],
    );
  }

  // Method to build a summary row in the table
  pw.TableRow _buildSummaryRow(String label, String value,
      {bool header = false}) {
    return pw.TableRow(
      decoration:
          header ? const pw.BoxDecoration(color: PdfColors.blueAccent) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: header ? PdfColors.white : PdfColors.black,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: header ? PdfColors.white : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  // Charts and Graphs Section
  pw.Widget _buildChartsAndGraphs() {
    // Placeholder for chart implementation using external packages or manually drawing
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Sales Growth Over Time',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        // Include chart here (e.g., a line chart showing sales growth)
        pw.Container(height: 150, color: PdfColors.grey300), // Placeholder
        pw.SizedBox(height: 20),
        pw.Text('Profit Margin Trends',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        // Include chart here (e.g., a bar chart showing profit margins)
        pw.Container(height: 150, color: PdfColors.grey300), // Placeholder
      ],
    );
  }

  // Comparison Section
  pw.Widget _buildComparisonSection() {
    // Placeholder for comparisons
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Comparison with Previous Period',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        // Comparison data (e.g., comparing this period's metrics to the previous period)
        pw.Container(height: 100, color: PdfColors.grey300), // Placeholder
      ],
    );
  }

  // Recommendations Section
  pw.Widget _buildRecommendations() {
    // Placeholder for strategic recommendations
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Strategic Recommendations',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text(
          '1. Increase marketing spend to capitalize on positive sales growth.\n'
          '2. Review cost structures to improve profit margins.\n'
          '3. Focus on restocking low inventory items to avoid stockouts.\n'
          '4. Explore opportunities to increase average order value.',
          style: pw.TextStyle(fontSize: 14),
        ),
      ],
    );
  }

// Method to add product details pages
  Future<void> _addProductDetailsPages(
      pw.Document pdf, List<Map<String, dynamic>> productDetails) async {
    // Await the page theme
    final pageTheme = await _buildPageTheme(PdfPageFormat.a4);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) => [
          pw.Text('Product Details',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueAccent),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueAccent),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Product Name',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Quantity Sold',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Sales Revenue',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                ],
              ),
              for (var product in productDetails)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(product['name'],
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(product['quantity'].toString(),
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                          '\$${product['revenue'].toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

// Method to add appendix section
  Future<void> _addAppendix(
      pw.Document pdf,
      List<Map<String, dynamic>> salesByCategory,
      List<Map<String, dynamic>> customerMetrics) async {
    // Await the page theme
    final pageTheme = await _buildPageTheme(PdfPageFormat.a4);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) => [
          pw.Text('Appendix',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Sales by Category',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueAccent),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueAccent),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Category',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Sales Revenue',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                ],
              ),
              for (var category in salesByCategory)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(category['name'],
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                          '\$${category['revenue'].toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Customer Metrics',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueAccent),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueAccent),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Metric',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Value',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ),
                ],
              ),
              for (var metric in customerMetrics)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(metric['name'],
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(metric['value'].toString(),
                          style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Divider
  pw.Widget _buildDivider() {
    return pw.Divider(color: PdfColors.blueAccent, thickness: 1.5);
  }

  // Footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Center(
      child: pw.Text('VendorPal - Confidential Report',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
    );
  }

  /// Page Theme
  Future<pw.PageTheme> _buildPageTheme(PdfPageFormat format) async {
    final baseFontData =
        await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");

    final baseFont = pw.Font.ttf(baseFontData.buffer.asByteData());
    final boldFont = pw.Font.ttf(boldFontData.buffer.asByteData());

    return pw.PageTheme(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
    );
  }
}
