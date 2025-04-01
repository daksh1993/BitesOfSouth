import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  @override
  void initState() {
    super.initState();
    _analysisData = _fetchAnalysisData();
  }

  Future<Map<String, dynamic>> _fetchAnalysisData() async {
    try {
      final ordersSnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      final menuSnapshot =
          await FirebaseFirestore.instance.collection('menu').get();

      Map<String, Map<String, dynamic>> menuItems = {
        for (var doc in menuSnapshot.docs) doc.id: doc.data()
      };
      double netSales = 0.0;
      double netProfit = 0.0;
      Map<String, int> itemQuantities = {};
      Map<String, double> itemRevenues = {};
      Map<String, double> itemProfits = {};
      Map<String, int> trendingItems = {};
      Map<int, double> dailyRevenues = {};
      Map<int, double> dailyProfits = {};

      final now = DateTime.now();
      final thirtyDaysAgo =
          now.subtract(const Duration(days: 30)).millisecondsSinceEpoch;

      for (var order in ordersSnapshot.docs) {
        final orderData = order.data();
        final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
        final totalAmount =
            (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final timestamp = (orderData['timestamp'] as num?)?.toInt() ?? 0;
        final orderDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final daysSinceEpoch =
            orderDate.difference(DateTime(1970, 1, 1)).inDays;

        netSales += totalAmount;

        if (timestamp >= thirtyDaysAgo) {
          dailyRevenues[daysSinceEpoch] =
              (dailyRevenues[daysSinceEpoch] ?? 0) + totalAmount;
        }

        for (var item in items) {
          if (item['isRedeemed'] == true) continue;

          final itemId = item['itemId'] as String? ?? '';
          final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
          final price = double.tryParse(item['price'] ?? '0') ?? 0.0;
          final menuItem = menuItems[itemId];
          final makingPrice =
              (menuItem?['makingPrice'] as num?)?.toDouble() ?? 0.0;

          itemQuantities[itemId] = (itemQuantities[itemId] ?? 0) + quantity;
          itemRevenues[itemId] =
              (itemRevenues[itemId] ?? 0) + (price * quantity);
          itemProfits[itemId] =
              (itemProfits[itemId] ?? 0) + ((price - makingPrice) * quantity);
          netProfit += (price - makingPrice) * quantity;

          if (timestamp >= thirtyDaysAgo) {
            dailyProfits[daysSinceEpoch] = (dailyProfits[daysSinceEpoch] ?? 0) +
                ((price - makingPrice) * quantity);
          }

          final thirtyDaysInMillis = 30 * 24 * 60 * 60 * 1000;
          if (now.millisecondsSinceEpoch - timestamp <= thirtyDaysInMillis) {
            trendingItems[itemId] = (trendingItems[itemId] ?? 0) + quantity;
          }
        }
      }

      return {
        'netSales': netSales,
        'netProfit': netProfit,
        'itemQuantities': itemQuantities,
        'itemRevenues': itemRevenues,
        'itemProfits': itemProfits,
        'trendingItems': trendingItems,
        'menuItems': menuItems,
        'dailyRevenues': dailyRevenues,
        'dailyProfits': dailyProfits,
      };
    } catch (e) {
      print("Error fetching analysis data: $e");
      return {
        'netSales': 0.0,
        'netProfit': 0.0,
        'itemQuantities': <String, int>{},
        'itemRevenues': <String, double>{},
        'itemProfits': <String, double>{},
        'trendingItems': <String, int>{},
        'menuItems': <String, Map<String, dynamic>>{},
        'dailyRevenues': <int, double>{},
        'dailyProfits': <int, double>{},
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white, // Change the color of the back button
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Analysis Dashboard",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _analysisData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.green));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red, fontSize: 18)));
            }
            if (!snapshot.hasData) {
              return const Center(
                  child: Text("No data available",
                      style: TextStyle(fontSize: 18, color: Colors.grey)));
            }

            final data = snapshot.data!;
            final menuItems =
                data['menuItems'] as Map<String, Map<String, dynamic>>? ?? {};
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
                      Expanded(
                          child: _buildNetSalesCard(data['netSales'] ?? 0.0,
                              currencyFormat, screenWidth)),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                          child: _buildNetProfitCard(data['netProfit'] ?? 0.0,
                              currencyFormat, screenWidth)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: screenHeight * 0.35,
                        child: _buildLineChart(dailyRevenues, dailyProfits,
                            screenWidth, screenHeight, currencyFormat),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ...selectedAnalyses
                      .where((analysis) =>
                          analysis != 'Net Sales' && analysis != 'Net Profit')
                      .map((analysis) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: _buildAnalysisCard(
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
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnalysisBottomSheet(context),
        backgroundColor: Colors.green.shade700,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildNetSalesCard(
      double netSales, NumberFormat currencyFormat, double screenWidth) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Net Sales",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    currencyFormat.format(netSales),
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetProfitCard(
      double netProfit, NumberFormat currencyFormat, double screenWidth) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Net Profit",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    currencyFormat.format(netProfit),
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
      Map<int, double> dailyRevenues,
      Map<int, double> dailyProfits,
      double screenWidth,
      double screenHeight,
      NumberFormat currencyFormat) {
    final minDay = dailyRevenues.keys.isNotEmpty
        ? dailyRevenues.keys.reduce((a, b) => a < b ? a : b)
        : 0;
    final maxDay = dailyRevenues.keys.isNotEmpty
        ? dailyRevenues.keys.reduce((a, b) => a > b ? a : b)
        : 0;
    final range = maxDay - minDay + 1;

    List<ChartData> revenueData = List.generate(range, (index) {
      final day = minDay + index;
      return ChartData(
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000)
            .toString(),
        dailyRevenues[day] ?? 0.0,
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000),
      );
    });

    List<ChartData> profitData = List.generate(range, (index) {
      final day = minDay + index;
      return ChartData(
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000)
            .toString(),
        dailyProfits[day] ?? 0.0,
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000),
      );
    });

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        interval: 5,
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
            fontSize: screenWidth * 0.03, color: Colors.grey.shade700),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: currencyFormat,
        labelStyle: TextStyle(
            fontSize: screenWidth * 0.03, color: Colors.grey.shade700),
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: TextStyle(
            fontSize: screenWidth * 0.035, color: Colors.grey.shade800),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x : point.y',
        color: Colors.grey.shade800,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries>[
        SplineSeries<ChartData, DateTime>(
          dataSource: revenueData,
          xValueMapper: (ChartData data, _) => data.date!,
          yValueMapper: (ChartData data, _) => data.value,
          name: 'Revenue',
          color: Colors.blue.shade600,
          width: 2.5,
          animationDuration: 1000,
          splineType: SplineType.cardinal,
        ),
        SplineSeries<ChartData, DateTime>(
          dataSource: profitData,
          xValueMapper: (ChartData data, _) => data.date!,
          yValueMapper: (ChartData data, _) => data.value,
          name: 'Profit',
          color: Colors.green.shade600,
          width: 2.5,
          animationDuration: 1000,
          splineType: SplineType.cardinal,
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(
      String title,
      Map<String, dynamic> data,
      Map<String, Map<String, dynamic>> menuItems,
      Map<String, int> itemQuantities,
      Map<String, double> itemRevenues,
      Map<String, double> itemProfits,
      Map<String, int> trendingItems,
      NumberFormat currencyFormat,
      double screenWidth,
      double screenHeight) {
    String itemName = '';
    String? revenue;
    String? profit;
    String? value;
    Widget? chart;

    switch (title) {
      case 'Top Selling Item':
        if (itemQuantities.isNotEmpty) {
          final topItem = itemQuantities.entries
              .reduce((a, b) => a.value > b.value ? a : b);
          itemName = menuItems[topItem.key]?['title'] ?? 'Unknown';
          revenue = currencyFormat.format(itemRevenues[topItem.key] ?? 0);
          profit = currencyFormat.format(itemProfits[topItem.key] ?? 0);
          chart = _buildBarChart(
            [
              ChartData('Revenue', itemRevenues[topItem.key] ?? 0.0),
              ChartData('Profit', itemProfits[topItem.key] ?? 0.0)
            ],
            Colors.blue,
            screenWidth,
            screenHeight,
            currencyFormat,
          );
        }
        break;
      case 'Highest Revenue Item':
        if (itemRevenues.isNotEmpty) {
          final topRevenue =
              itemRevenues.entries.reduce((a, b) => a.value > b.value ? a : b);
          itemName = menuItems[topRevenue.key]?['title'] ?? 'Unknown';
          revenue = currencyFormat.format(topRevenue.value);
          profit = currencyFormat.format(itemProfits[topRevenue.key] ?? 0);
          chart = _buildBarChart(
            [
              ChartData('Revenue', topRevenue.value),
              ChartData('Profit', itemProfits[topRevenue.key] ?? 0.0)
            ],
            Colors.blue,
            screenWidth,
            screenHeight,
            currencyFormat,
          );
        }
        break;
      case 'Least Selling Item':
        if (itemQuantities.isNotEmpty) {
          final bottomItem = itemQuantities.entries
              .reduce((a, b) => a.value < b.value ? a : b);
          itemName = menuItems[bottomItem.key]?['title'] ?? 'Unknown';
          revenue = currencyFormat.format(itemRevenues[bottomItem.key] ?? 0);
          profit = currencyFormat.format(itemProfits[bottomItem.key] ?? 0);
          chart = _buildBarChart(
            [
              ChartData('Revenue', itemRevenues[bottomItem.key] ?? 0.0),
              ChartData('Profit', itemProfits[bottomItem.key] ?? 0.0)
            ],
            Colors.blue,
            screenWidth,
            screenHeight,
            currencyFormat,
          );
        }
        break;
      case 'Lowest Revenue Item':
        if (itemRevenues.isNotEmpty) {
          final bottomRevenue =
              itemRevenues.entries.reduce((a, b) => a.value < b.value ? a : b);
          itemName = menuItems[bottomRevenue.key]?['title'] ?? 'Unknown';
          revenue = currencyFormat.format(bottomRevenue.value);
          profit = currencyFormat.format(itemProfits[bottomRevenue.key] ?? 0);
          chart = _buildBarChart(
            [
              ChartData('Revenue', bottomRevenue.value),
              ChartData('Profit', itemProfits[bottomRevenue.key] ?? 0.0)
            ],
            Colors.blue,
            screenWidth,
            screenHeight,
            currencyFormat,
          );
        }
        break;
      case 'Trending Item':
        if (trendingItems.isNotEmpty) {
          final sortedTrending = trendingItems.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final top5Trending = sortedTrending.take(5).toList();
          itemName = menuItems[top5Trending.first.key]?['title'] ?? 'Unknown';
          revenue =
              currencyFormat.format(itemRevenues[top5Trending.first.key] ?? 0);
          profit =
              currencyFormat.format(itemProfits[top5Trending.first.key] ?? 0);
          List<ChartData> trendingData = top5Trending.map((entry) {
            return ChartData(menuItems[entry.key]?['title'] ?? 'Unknown',
                entry.value.toDouble());
          }).toList();
          chart = _buildLineChartWithDots(trendingData, screenWidth,
              screenHeight, 'Quantity Sold', Colors.blue.shade600);
        }
        break;
      case 'Total Items Sold':
        value = itemQuantities.values.fold(0, (a, b) => a + b).toString();
        break;
      case 'Avg Revenue per Item':
        final avgRevenue = itemRevenues.values.fold(0.0, (a, b) => a + b) /
            (itemRevenues.length > 0 ? itemRevenues.length : 1);
        revenue = currencyFormat.format(avgRevenue);
        break;
      case 'Most Profitable Item':
        if (itemProfits.isNotEmpty) {
          final sortedProfits = itemProfits.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final top5Profits = sortedProfits.take(5).toList();
          itemName = menuItems[top5Profits.first.key]?['title'] ?? 'Unknown';
          revenue =
              currencyFormat.format(itemRevenues[top5Profits.first.key] ?? 0);
          profit = currencyFormat.format(top5Profits.first.value);
          List<ChartData> profitData = top5Profits.map((entry) {
            return ChartData(
                menuItems[entry.key]?['title'] ?? 'Unknown', entry.value);
          }).toList();
          chart = _buildLineChartWithDots(profitData, screenWidth, screenHeight,
              'Profit (₹)', Colors.green.shade600);
        }
        break;
      case 'Top 3 Items Revenue Share':
        final sortedRevenues = itemRevenues.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top3Total =
            sortedRevenues.take(3).fold(0.0, (sum, e) => sum + e.value);
        final top3Profit = sortedRevenues
            .take(3)
            .fold(0.0, (sum, e) => sum + (itemProfits[e.key] ?? 0));
        revenue = currencyFormat.format(top3Total);
        profit = currencyFormat.format(top3Profit);
        chart = _buildPieChart(
          sortedRevenues
              .take(3)
              .map((e) =>
                  ChartData(menuItems[e.key]?['title'] ?? 'Unknown', e.value))
              .toList(),
          screenWidth,
          screenHeight,
          currencyFormat,
        );
        break;
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            if (itemName.isNotEmpty) ...[
              SizedBox(height: screenWidth * 0.02),
              Text(
                itemName,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
            if (revenue != null) ...[
              SizedBox(height: screenWidth * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Revenue",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade700),
                  ),
                  Flexible(
                    child: Text(
                      revenue,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (profit != null) ...[
              SizedBox(height: screenWidth * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profit",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade700),
                  ),
                  Flexible(
                    child: Text(
                      profit,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (value != null) ...[
              SizedBox(height: screenWidth * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Value",
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey.shade700),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ],
            if (chart != null) ...[
              SizedBox(height: screenWidth * 0.03),
              SizedBox(
                height: screenHeight * 0.3,
                child: chart,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<ChartData> data, Color color, double screenWidth,
      double screenHeight,
      [NumberFormat? format]) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
            fontSize: screenWidth * 0.035, color: Colors.grey.shade700),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: format,
        labelStyle: TextStyle(
            fontSize: screenWidth * 0.035, color: Colors.grey.shade700),
      ),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y',
          color: Colors.grey.shade800),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.label == 'Revenue'
              ? Colors.blue.shade600
              : Colors.green.shade600,
          animationDuration: 800,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLineChartWithDots(List<ChartData> data, double screenWidth,
      double screenHeight, String yAxisTitle, Color lineColor) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
            fontSize: screenWidth * 0.015, color: Colors.grey.shade700),
        majorGridLines: const MajorGridLines(width: 0),
        labelRotation: 45,
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(
            fontSize: screenWidth * 0.03, color: Colors.grey.shade700),
        title: AxisTitle(
            text: yAxisTitle,
            textStyle: TextStyle(
                fontSize: screenWidth * 0.035, color: Colors.grey.shade800)),
      ),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y',
          color: Colors.grey.shade800),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          color: lineColor,
          width: 2.5,
          animationDuration: 800,
          markerSettings: MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            color: lineColor,
            width: 8,
            height: 8,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(List<ChartData> data, double screenWidth,
      double screenHeight, NumberFormat currencyFormat) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: TextStyle(
            fontSize: screenWidth * 0.035, color: Colors.grey.shade800),
      ),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y',
          color: Colors.grey.shade800),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          animationDuration: 800,
          radius: '70%',
          explode: true,
          explodeIndex: 0,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showAddAnalysisBottomSheet(BuildContext context) {
    final availableAnalyses = [
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
    String? selectedAnalysis;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add New Analysis",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Analysis",
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: availableAnalyses
                        .where(
                            (analysis) => !selectedAnalyses.contains(analysis))
                        .map((analysis) {
                      return DropdownMenuItem(
                          value: analysis,
                          child: Text(analysis,
                              style: const TextStyle(fontSize: 16)));
                    }).toList(),
                    onChanged: (value) =>
                        setModalState(() => selectedAnalysis = value),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedAnalysis != null) {
                        setState(() => selectedAnalyses.add(selectedAnalysis!));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      elevation: 4,
                    ),
                    child: const Text("Add Analysis",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ChartData {
  ChartData(this.label, this.value, [this.date]);
  final String label;
  final double value;
  final DateTime? date;
}
