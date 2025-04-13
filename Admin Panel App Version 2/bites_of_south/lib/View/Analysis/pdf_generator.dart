import 'dart:io';
import 'dart:typed_data';
import 'package:bites_of_south/View/Analysis/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'data_fetcher.dart';

Future<Uint8List> generatePdf(
  Map<String, dynamic> data, {
  DateTime? startDate,
  DateTime? endDate,
  required List<String> selectedAnalyses,
  Map<String, Uint8List> chartImages = const {},
}) async {
  try {
    final pdf = pw.Document();
    final logoBytes = await fetchLogo();
    final userData = await fetchUserData();
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final now = DateTime.now();
    final timestamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

    print('PdfGenerator: Starting PDF generation - Data keys: ${data.keys}');

    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final boldFontData =
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    final boldTtf = pw.Font.ttf(boldFontData);
    print('PdfGenerator: Fonts loaded successfully');

    final logoImage = logoBytes.isNotEmpty ? pw.MemoryImage(logoBytes) : null;

    final menuItems =
        data['menuItems'] as Map<String, Map<String, dynamic>>? ?? {};
    final itemQuantities = data['itemQuantities'] as Map<String, int>? ?? {};
    final itemRevenues = data['itemRevenues'] as Map<String, double>? ?? {};
    final itemProfits = data['itemProfits'] as Map<String, double>? ?? {};
    final trendingItems = data['trendingItems'] as Map<String, int>? ?? {};

    final sortedTrending = trendingItems.isNotEmpty
        ? (trendingItems.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        : <MapEntry<String, int>>[];
    final sortedProfits = itemProfits.isNotEmpty
        ? (itemProfits.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        : <MapEntry<String, double>>[];
    final sortedRevenues = itemRevenues.isNotEmpty
        ? (itemRevenues.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        : <MapEntry<String, double>>[];
    final sortedQuantities = itemQuantities.isNotEmpty
        ? (itemQuantities.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        : <MapEntry<String, int>>[];

    final greenColor = PdfColor.fromInt(0xFF4CAF50);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          buildBackground: (pw.Context context) {
            if (logoImage != null) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Opacity(
                  opacity: 0.05,
                  child: pw.Image(
                    logoImage,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              );
            }
            return pw.SizedBox();
          },
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: pw.EdgeInsets.only(bottom: 20),
          child: pw.Column(
            children: [
              if (logoImage != null)
                pw.Image(
                  logoImage,
                  width: 80,
                  height: 80,
                ),
              pw.Text(
                'BitesOfSouth',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: boldTtf,
                  color: greenColor,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Analysis Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  font: ttf,
                  color: PdfColor.fromInt(0xFF388E3C),
                ),
              ),
              pw.Divider(color: greenColor, thickness: 2),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Generated at: $timestamp by ${userData['name']} (${userData['role']})',
            style:
                pw.TextStyle(fontSize: 12, font: ttf, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.Text(
            'Period: ${startDate != null ? DateFormat('dd MMM yyyy').format(startDate) : 'All Time'} - ${endDate != null ? DateFormat('dd MMM yyyy').format(endDate) : 'Now'}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              font: boldTtf,
              color: greenColor,
            ),
          ),
          pw.SizedBox(height: 20),
          if (selectedAnalyses.contains('Net Sales') ||
              selectedAnalyses.contains('Net Profit'))
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (selectedAnalyses.contains('Net Sales'))
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: greenColor),
                        borderRadius: pw.BorderRadius.circular(8),
                        color: PdfColors.white,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Net Sales',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              font: boldTtf,
                              color: greenColor,
                            ),
                          ),
                          pw.Text(
                            'Total revenue from all sales.',
                            style: pw.TextStyle(fontSize: 14, font: ttf),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Value: ${currencyFormat.format(data['netSales'] ?? 0.0)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: greenColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (selectedAnalyses.contains('Net Sales') &&
                    selectedAnalyses.contains('Net Profit'))
                  pw.SizedBox(width: 16),
                if (selectedAnalyses.contains('Net Profit'))
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: greenColor),
                        borderRadius: pw.BorderRadius.circular(8),
                        color: PdfColors.white,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Net Profit',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              font: boldTtf,
                              color: greenColor,
                            ),
                          ),
                          pw.Text(
                            'Total profit after costs.',
                            style: pw.TextStyle(fontSize: 14, font: ttf),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Value: ${currencyFormat.format(data['netProfit'] ?? 0.0)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                              color: greenColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          if (selectedAnalyses.contains('Net Sales') ||
              selectedAnalyses.contains('Net Profit'))
            pw.SizedBox(height: 16),
          if (chartImages.containsKey('dailyChart')) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              'Daily Revenue & Profit',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                font: boldTtf,
                color: greenColor,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Image(
              pw.MemoryImage(chartImages['dailyChart']!),
              width: 400,
              height: 200,
              fit: pw.BoxFit.contain,
            ),
          ],
          if (chartImages.containsKey('dailyChart')) pw.SizedBox(height: 16),
          ...selectedAnalyses
              .where((analysis) =>
                  analysis != 'Net Sales' && analysis != 'Net Profit')
              .map((analysis) {
            String title;
            String description;
            List<pw.Widget> content = [];
            pw.Image? chart;

            switch (analysis) {
              case 'Top Selling Item':
                title = 'Top Selling Item';
                description = 'Item with the highest quantity sold.';
                if (itemQuantities.isNotEmpty) {
                  content = [
                    pw.Text(
                      'Item: ${menuItems[sortedQuantities.first.key]?['title'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Quantity: ${sortedQuantities.first.value}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Revenue: ${currencyFormat.format(itemRevenues[sortedQuantities.first.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Profit: ${currencyFormat.format(itemProfits[sortedQuantities.first.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('topsellingitemChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(chartImages['topsellingitemChart']!),
                      width: 200,
                      height: 100,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              case 'Highest Revenue Item':
                title = 'Highest Revenue Item';
                description = 'Item generating the highest revenue.';
                if (itemRevenues.isNotEmpty) {
                  content = [
                    pw.Text(
                      'Item: ${menuItems[sortedRevenues.first.key]?['title'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Revenue: ${currencyFormat.format(sortedRevenues.first.value)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Profit: ${currencyFormat.format(itemProfits[sortedRevenues.first.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('highestrevenueitemChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(chartImages['highestrevenueitemChart']!),
                      width: 200,
                      height: 100,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              case 'Least Selling Item':
                title = 'Least Selling Item';
                description = 'Item with the lowest quantity sold.';
                if (itemQuantities.isNotEmpty) {
                  content = [
                    pw.Text(
                      'Item: ${menuItems[sortedQuantities.last.key]?['title'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Quantity: ${sortedQuantities.last.value}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Revenue: ${currencyFormat.format(itemRevenues[sortedQuantities.last.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Profit: ${currencyFormat.format(itemProfits[sortedQuantities.last.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('leastsellingitemChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(chartImages['leastsellingitemChart']!),
                      width: 200,
                      height: 100,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              case 'Lowest Revenue Item':
                title = 'Lowest Revenue Item';
                description = 'Item generating the lowest revenue.';
                if (itemRevenues.isNotEmpty) {
                  content = [
                    pw.Text(
                      'Item: ${menuItems[sortedRevenues.last.key]?['title'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Revenue: ${currencyFormat.format(sortedRevenues.last.value)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Profit: ${currencyFormat.format(itemProfits[sortedRevenues.last.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('lowestrevenueitemChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(chartImages['lowestrevenueitemChart']!),
                      width: 200,
                      height: 100,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              case 'Trending Item':
                title = 'Trending Item';
                description = 'Top trending item by sales volume.';
                if (trendingItems.isNotEmpty) {
                  content = [
                    pw.Text(
                      'Item: ${menuItems[sortedTrending.first.key]?['title'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Quantity: ${sortedTrending.first.value}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Revenue: ${currencyFormat.format(itemRevenues[sortedTrending.first.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Profit: ${currencyFormat.format(itemProfits[sortedTrending.first.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('trendingitemChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(chartImages['trendingitemChart']!),
                      width: 300,
                      height: 150,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              case 'Total Items Sold':
                title = 'Total Items Sold';
                description = 'Total number of items sold.';
                content = [
                  pw.Text(
                    'Value: ${itemQuantities.values.fold(0, (a, b) => a + b)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: greenColor,
                    ),
                  ),
                ];
                break;
              case 'Avg Revenue per Item':
                title = 'Average Revenue per Item';
                description = 'Average revenue per unique item.';
                content = [
                  pw.Text(
                    'Value: ${currencyFormat.format(itemRevenues.values.fold(0.0, (a, b) => a + b) / (itemRevenues.length > 0 ? itemRevenues.length : 1))}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      color: greenColor,
                    ),
                  ),
                ];
                break;
              case 'Most Profitable Item':
                title = 'Most Profitable Item';
                description = 'Item with the highest profit margin.';
                if (itemProfits.isNotEmpty) {
                  content = [
                    pw.Text(
                      'Item: ${menuItems[sortedProfits.first.key]?['title'] ?? 'Unknown'}',
                      style: pw.TextStyle(fontSize: 14, font: ttf),
                    ),
                    pw.Text(
                      'Profit: ${currencyFormat.format(sortedProfits.first.value)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Revenue: ${currencyFormat.format(itemRevenues[sortedProfits.first.key] ?? 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('mostprofitableitemChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(chartImages['mostprofitableitemChart']!),
                      width: 300,
                      height: 150,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              case 'Top 3 Items Revenue Share':
                title = 'Top 3 Items Revenue Share';
                description = 'Revenue contribution of top 3 items.';
                if (sortedRevenues.isNotEmpty) {
                  content = [
                    pw.Text('Top 3 Items:',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                    ...sortedRevenues.take(3).map((entry) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '- ${menuItems[entry.key]?['title'] ?? 'Unknown'}',
                              style: pw.TextStyle(fontSize: 14, font: ttf),
                            ),
                            pw.Text(
                              '  Revenue: ${currencyFormat.format(entry.value)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                                color: greenColor,
                              ),
                            ),
                            pw.Text(
                              '  Profit: ${currencyFormat.format(itemProfits[entry.key] ?? 0)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                                color: greenColor,
                              ),
                            ),
                          ],
                        )),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Total Revenue: ${currencyFormat.format(sortedRevenues.take(3).fold(0.0, (sum, e) => sum + e.value))}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                    pw.Text(
                      'Total Profit: ${currencyFormat.format(sortedRevenues.take(3).fold(0.0, (sum, e) => sum + (itemProfits[e.key] ?? 0)))}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                        color: greenColor,
                      ),
                    ),
                  ];
                  if (chartImages.containsKey('top3itemsrevenueshareChart')) {
                    chart = pw.Image(
                      pw.MemoryImage(
                          chartImages['top3itemsrevenueshareChart']!),
                      width: 200,
                      height: 200,
                      fit: pw.BoxFit.contain,
                    );
                  }
                } else {
                  content = [
                    pw.Text('No data available.',
                        style: pw.TextStyle(fontSize: 14, font: ttf)),
                  ];
                }
                break;
              default:
                return pw.SizedBox();
            }

            return pw.Container(
              margin: pw.EdgeInsets.only(bottom: 16),
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: greenColor),
                borderRadius: pw.BorderRadius.circular(8),
                color: PdfColors.white,
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            font: boldTtf,
                            color: greenColor,
                          ),
                        ),
                        pw.Text(
                          description,
                          style: pw.TextStyle(fontSize: 14, font: ttf),
                        ),
                        pw.SizedBox(height: 8),
                        ...content,
                      ],
                    ),
                  ),
                  if (chart != null)
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        margin: pw.EdgeInsets.only(left: 15),
                        alignment: pw.Alignment.topRight,
                        child: chart,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    final pdfBytes = await pdf.save();
    print(
        'PdfGenerator: PDF generated successfully, bytes length: ${pdfBytes.length}');
    return pdfBytes;
  } catch (e) {
    print('PdfGenerator: Error generating PDF - $e');
    rethrow;
  }
}

Future<String> savePdfToTemp(Uint8List pdfBytes) async {
  try {
    if (pdfBytes.isEmpty) {
      throw Exception('PDF bytes are empty');
    }
    print(
        'PdfGenerator: Saving PDF to temporary location, bytes length: ${pdfBytes.length}');

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'Analysis_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final filePath = '${tempDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    print('PdfGenerator: PDF saved to temporary location - $filePath');
    return filePath;
  } catch (e) {
    print('PdfGenerator: Error saving PDF to temp - $e');
    rethrow;
  }
}

void showPdfViewer(
  BuildContext context,
  Map<String, dynamic> data,
  DateTime? startDate,
  DateTime? endDate,
  List<String> selectedAnalyses,
) async {
  try {
    final pdfBytes = await generatePdf(
      data,
      startDate: startDate,
      endDate: endDate,
      selectedAnalyses: selectedAnalyses,
    );
    final pdfPath = await savePdfToTemp(pdfBytes);

    print('PdfGenerator: Navigating to PDF viewer screen with path: $pdfPath');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfPath: pdfPath),
      ),
    );
  } catch (e) {
    print('PdfGenerator: Error showing PDF viewer - $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to display PDF: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
