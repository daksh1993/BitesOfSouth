import 'dart:io';
import 'dart:typed_data';
import 'package:bites_of_south/View/Analysis/bottom_sheet.dart';
import 'package:bites_of_south/View/Analysis/card_widgets.dart';
import 'package:bites_of_south/View/Analysis/chart_widgets.dart';
import 'package:bites_of_south/View/Analysis/data_fetcher.dart';
import 'package:bites_of_south/View/Analysis/date_range_section.dart';
import 'package:bites_of_south/View/Analysis/pdf_generator.dart';
import 'package:bites_of_south/View/Analysis/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:lottie/lottie.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late Future<Map<String, dynamic>> _analysisData;
  List<String> selectedAnalyses = [
    'Net Sales',
    'Net Profit',
    'Top Selling Item',
    'Highest Revenue Item',
    'Least Selling Item',
    'Lowest Revenue Item',
    'Trending Item',
    'Total Items Sold',
    'Avg Revenue per Item',
    'Most Profitable Item',
    'Top 3 Items Revenue Share'
  ];
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRange;

  final GlobalKey _dailyChartKey = GlobalKey();
  final Map<String, GlobalKey> _analysisChartKeys = {
    'Top Selling Item': GlobalKey(),
    'Highest Revenue Item': GlobalKey(),
    'Least Selling Item': GlobalKey(),
    'Lowest Revenue Item': GlobalKey(),
    'Trending Item': GlobalKey(),
    'Most Profitable Item': GlobalKey(),
    'Top 3 Items Revenue Share': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _analysisData = fetchAnalysisData(_startDate, _endDate);
  }

  void _updateDateRange(DateTime? start, DateTime? end, {String? range}) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedRange = range;
      _analysisData = fetchAnalysisData(_startDate, _endDate);
    });
  }

  Future<Uint8List?> _captureChart(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  void _showLoadingDialog(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final ValueNotifier<String> status = ValueNotifier('Fetching data...');
    bool hasError = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        content: ValueListenableBuilder<String>(
          valueListenable: status,
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/loadin.json',
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (hasError) ...[
                SizedBox(height: screenWidth * 0.04),
                Text(
                  errorMessage ?? 'An error occurred',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    try {
      status.value = 'Fetching analysis data...';
      final data = await _analysisData;

      status.value = 'Capturing charts...';
      Map<String, Uint8List> chartImages = {};
      if (data['dailyRevenues']?.isNotEmpty == true) {
        final chartImage = await _captureChart(_dailyChartKey);
        if (chartImage != null) {
          chartImages['dailyChart'] = chartImage;
        }
      }
      for (var analysis in selectedAnalyses
          .where((a) => a != 'Net Sales' && a != 'Net Profit')) {
        if (_analysisChartKeys[analysis] != null &&
            data['itemQuantities']?.isNotEmpty == true) {
          final chartImage = await _captureChart(_analysisChartKeys[analysis]!);
          if (chartImage != null) {
            chartImages['${analysis.toLowerCase().replaceAll(' ', '')}Chart'] =
                chartImage;
          }
        }
      }

      status.value = 'Generating PDF report...';
      final pdfBytes = await generatePdf(
        data,
        startDate: _startDate,
        endDate: _endDate,
        selectedAnalyses: selectedAnalyses,
        chartImages: chartImages,
      );

      status.value = 'Saving PDF...';
      final pdfPath = await savePdfToTemp(pdfBytes);

      status.value = 'Opening PDF viewer...';
      await Future.delayed(Duration(milliseconds: 500)); // Brief pause for UX
      Navigator.pop(context); // Close dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: pdfPath),
        ),
      );
    } catch (e) {
      hasError = true;
      errorMessage = 'Failed to generate PDF: $e';
      status.value = 'Error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: Text(
          "Analysis Dashboard",
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.print, size: screenWidth * 0.06),
            onPressed: () => _showLoadingDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            DateRangeSection(
              screenWidth: screenWidth,
              onDateRangeChanged: _updateDateRange,
              selectedRange: _selectedRange,
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _analysisData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(
                        'assets/loadin.json',
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading data",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics,
                            size: screenWidth * 0.15,
                            color: Colors.green[300],
                          ),
                          SizedBox(height: spacing),
                          Text(
                            "No analysis data available",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final menuItems =
                      data['menuItems'] as Map<String, Map<String, dynamic>>? ??
                          {};
                  final itemQuantities =
                      data['itemQuantities'] as Map<String, int>? ?? {};
                  final itemRevenues =
                      data['itemRevenues'] as Map<String, double>? ?? {};
                  final itemProfits =
                      data['itemProfits'] as Map<String, double>? ?? {};
                  final trendingItems =
                      data['trendingItems'] as Map<String, int>? ?? {};
                  final dailyRevenues =
                      data['dailyRevenues'] as Map<int, double>? ?? {};
                  final dailyProfits =
                      data['dailyProfits'] as Map<int, double>? ?? {};
                  final currencyFormat =
                      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (selectedAnalyses.contains('Net Sales'))
                              Expanded(
                                child: buildNetSalesCard(
                                  data['netSales'] ?? 0.0,
                                  currencyFormat,
                                  screenWidth,
                                ),
                              ),
                            if (selectedAnalyses.contains('Net Sales') &&
                                selectedAnalyses.contains('Net Profit'))
                              SizedBox(width: spacing),
                            if (selectedAnalyses.contains('Net Profit'))
                              Expanded(
                                child: buildNetProfitCard(
                                  data['netProfit'] ?? 0.0,
                                  currencyFormat,
                                  screenWidth,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: spacing),
                        if (dailyRevenues.isNotEmpty || dailyProfits.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(spacing),
                            child: RepaintBoundary(
                              key: _dailyChartKey,
                              child: SizedBox(
                                height: screenHeight * 0.35,
                                child: buildLineChart(
                                  dailyRevenues,
                                  dailyProfits,
                                  screenWidth,
                                  screenHeight,
                                  currencyFormat,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: spacing),
                        ...selectedAnalyses
                            .where((analysis) =>
                                analysis != 'Net Sales' &&
                                analysis != 'Net Profit')
                            .map((analysis) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: RepaintBoundary(
                              key: _analysisChartKeys[analysis],
                              child: buildAnalysisCard(
                                analysis,
                                data,
                                menuItems,
                                itemQuantities,
                                itemRevenues,
                                itemProfits,
                                trendingItems,
                                currencyFormat,
                                screenWidth,
                                screenHeight,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddAnalysisBottomSheet(context, selectedAnalyses, (newAnalyses) {
            setState(() {
              selectedAnalyses = newAnalyses;
              _analysisData = fetchAnalysisData(_startDate, _endDate);
            });
          });
        },
        backgroundColor: Colors.green[700],
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, size: screenWidth * 0.07, color: Colors.white),
      ),
    );
  }
}
