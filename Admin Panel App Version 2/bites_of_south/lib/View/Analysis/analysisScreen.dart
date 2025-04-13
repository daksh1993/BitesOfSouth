import 'dart:io';
import 'dart:typed_data';
import 'package:bites_of_south/View/Analysis/bottom_sheet.dart';
import 'package:bites_of_south/View/Analysis/card_widgets.dart';
import 'package:bites_of_south/View/Analysis/chart_widgets.dart';
import 'package:bites_of_south/View/Analysis/data_fetcher.dart';
import 'package:bites_of_south/View/Analysis/date_range_section.dart';
import 'package:bites_of_south/View/Analysis/pdf_generator.dart'; // Importing PDF utilities
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'dart:ui' as ui; // For image rendering

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

  // Global keys for chart widgets
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
    print('AnalysisScreen initState: Fetching initial data');
  }

  void _updateDateRange(DateTime? start, DateTime? end, {String? range}) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedRange = range;
      _analysisData = fetchAnalysisData(_startDate, _endDate);
      print(
          'AnalysisScreen: Date range updated - Start: $_startDate, End: $_endDate, Range: $_selectedRange');
    });
  }

  // Method to capture chart as image
  Future<Uint8List?> _captureChart(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 2.0); // Higher resolution
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('AnalysisScreen: Error capturing chart - $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    print(
        'AnalysisScreen build: Building UI with screenWidth: $screenWidth, screenHeight: $screenHeight');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          "Analysis Dashboard",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final data = await _analysisData;
              print('AnalysisScreen: Print button pressed, capturing charts');

              // Capture all chart images
              Map<String, Uint8List> chartImages = {};
              if (data['dailyRevenues']?.isNotEmpty == true) {
                chartImages['dailyChart'] =
                    (await _captureChart(_dailyChartKey))!;
              }
              for (var analysis in selectedAnalyses
                  .where((a) => a != 'Net Sales' && a != 'Net Profit')) {
                if (_analysisChartKeys[analysis] != null &&
                    data['itemQuantities']?.isNotEmpty == true) {
                  final chartImage =
                      await _captureChart(_analysisChartKeys[analysis]!);
                  if (chartImage != null) {
                    chartImages[
                            '${analysis.toLowerCase().replaceAll(' ', '')}Chart'] =
                        chartImage;
                  }
                }
              }

              showPdfViewer(
                context,
                data,
                _startDate,
                _endDate,
                selectedAnalyses,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
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
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (snapshot.hasError) {
                    print(
                        'AnalysisScreen: Error fetching data - ${snapshot.error}');
                    return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 18)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Text("No data available",
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey)));
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
                    padding: EdgeInsets.all(screenWidth * 0.05),
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
                                      screenWidth)),
                            if (selectedAnalyses.contains('Net Sales') &&
                                selectedAnalyses.contains('Net Profit'))
                              SizedBox(width: screenWidth * 0.03),
                            if (selectedAnalyses.contains('Net Profit'))
                              Expanded(
                                  child: buildNetProfitCard(
                                      data['netProfit'] ?? 0.0,
                                      currencyFormat,
                                      screenWidth)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: RepaintBoundary(
                              key: _dailyChartKey,
                              child: SizedBox(
                                height: screenHeight * 0.35,
                                child: buildLineChart(
                                    dailyRevenues,
                                    dailyProfits,
                                    screenWidth,
                                    screenHeight,
                                    currencyFormat),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        ...selectedAnalyses
                            .where((analysis) =>
                                analysis != 'Net Sales' &&
                                analysis != 'Net Profit')
                            .map((analysis) {
                          return Padding(
                            padding:
                                EdgeInsets.only(bottom: screenHeight * 0.02),
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
          print('AnalysisScreen: FAB pressed, showing bottom sheet');
          showAddAnalysisBottomSheet(context, selectedAnalyses, (newAnalyses) {
            setState(() {
              selectedAnalyses = newAnalyses;
              _analysisData = fetchAnalysisData(_startDate, _endDate);
              print(
                  'AnalysisScreen: Selected analyses updated - $selectedAnalyses');
            });
          });
        },
        backgroundColor: Colors.green.shade700,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

// Explanation:
// This file defines the main AnalysisScreen widget and its state management. It serves as the entry point for the analysis dashboard, handling the UI layout, state updates, and interactions like date range changes and PDF generation. It uses FutureBuilder to display data fetched from Firestore, renders cards and charts based on selected analyses, and provides a floating action button to modify analysis options. The file imports utilities from other modules to keep the code modular and focused on UI and state logic.
