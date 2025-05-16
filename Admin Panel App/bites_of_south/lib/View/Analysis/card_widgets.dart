import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chart_widgets.dart';
import 'models.dart';

// Builds a card for net sales
Widget buildNetSalesCard(
    double netSales, NumberFormat currencyFormat, double screenWidth) {
  print('CardWidgets: Building Net Sales card - Value: $netSales');

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
          Text(
            currencyFormat.format(netSales),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            softWrap: true,
          ),
        ],
      ),
    ),
  );
}

// Builds a card for net profit
Widget buildNetProfitCard(
    double netProfit, NumberFormat currencyFormat, double screenWidth) {
  print('CardWidgets: Building Net Profit card - Value: $netProfit');

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

// Builds a card for various analysis types
Widget buildAnalysisCard(
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
  print('CardWidgets: Building analysis card - Title: $title');

  String itemName = '';
  String? revenue;
  String? profit;
  String? value;
  Widget? chart;

  switch (title) {
    case 'Top Selling Item':
      if (itemQuantities.isNotEmpty) {
        final topItem =
            itemQuantities.entries.reduce((a, b) => a.value > b.value ? a : b);
        itemName = menuItems[topItem.key]?['title'] ?? 'Unknown';
        revenue = currencyFormat.format(itemRevenues[topItem.key] ?? 0);
        profit = currencyFormat.format(itemProfits[topItem.key] ?? 0);
        chart = buildBarChart(
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
        chart = buildBarChart(
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
        final bottomItem =
            itemQuantities.entries.reduce((a, b) => a.value < b.value ? a : b);
        itemName = menuItems[bottomItem.key]?['title'] ?? 'Unknown';
        revenue = currencyFormat.format(itemRevenues[bottomItem.key] ?? 0);
        profit = currencyFormat.format(itemProfits[bottomItem.key] ?? 0);
        chart = buildBarChart(
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
        chart = buildBarChart(
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
        chart = buildLineChartWithDots(trendingData, screenWidth, screenHeight,
            'Quantity Sold', Colors.blue.shade600);
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
        chart = buildLineChartWithDots(profitData, screenWidth, screenHeight,
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
      chart = buildPieChart(
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
            SizedBox(height: screenHeight * 0.3, child: chart),
          ],
        ],
      ),
    ),
  );
}

// Explanation:
// This file defines card widgets for displaying analysis data. `buildNetSalesCard` and `buildNetProfitCard` create simple cards for net sales and profit with gradient backgrounds. `buildAnalysisCard` is a versatile widget that handles various analysis types (e.g., top selling item, trending item) by dynamically generating content and charts based on the title. Debugging statements log the values being displayed to ensure data integrity.
