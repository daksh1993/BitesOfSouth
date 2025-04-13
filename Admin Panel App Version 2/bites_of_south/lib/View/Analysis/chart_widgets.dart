import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'models.dart';

// Builds a line chart for daily revenues and profits
Widget buildLineChart(Map<int, double> dailyRevenues, Map<int, double> dailyProfits,
    double screenWidth, double screenHeight, NumberFormat currencyFormat) {
  print('ChartWidgets: Building line chart - Revenues: ${dailyRevenues.length}, Profits: ${dailyProfits.length}');

  if (dailyRevenues.isEmpty || dailyProfits.isEmpty) {
    print('ChartWidgets: No data for line chart');
    return const Center(child: Text("No data available"));
  }

  final minDay = dailyRevenues.keys.reduce((a, b) => a < b ? a : b);
  final maxDay = dailyRevenues.keys.reduce((a, b) => a > b ? a : b);
  final rangeDays = maxDay - minDay + 1;
  print('ChartWidgets: Line chart range - Min: $minDay, Max: $maxDay, Days: $rangeDays');

  DateTimeIntervalType intervalType;
  int interval;
  List<ChartData> revenueData = [];
  List<ChartData> profitData = [];

  if (rangeDays > 365) {
    intervalType = DateTimeIntervalType.months;
    interval = 1;

    final startDate = DateTime.fromMillisecondsSinceEpoch(minDay * 24 * 60 * 60 * 1000);
    final endDate = DateTime.fromMillisecondsSinceEpoch(maxDay * 24 * 60 * 60 * 1000);
    final months = (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month +
        1;

    Map<DateTime, double> monthlyRevenues = {};
    Map<DateTime, double> monthlyProfits = {};

    dailyRevenues.forEach((day, revenue) {
      final date = DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000);
      final monthStart = DateTime(date.year, date.month, 1);
      monthlyRevenues[monthStart] = (monthlyRevenues[monthStart] ?? 0) + revenue;
    });

    dailyProfits.forEach((day, profit) {
      final date = DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000);
      final monthStart = DateTime(date.year, date.month, 1);
      monthlyProfits[monthStart] = (monthlyProfits[monthStart] ?? 0) + profit;
    });

    for (int i = 0; i < months; i++) {
      final date = DateTime(startDate.year, startDate.month + i, 1);
      revenueData.add(ChartData(
        DateFormat('MMM yyyy').format(date),
        monthlyRevenues[date] ?? 0.0,
        date,
      ));
      profitData.add(ChartData(
        DateFormat('MMM yyyy').format(date),
        monthlyProfits[date] ?? 0.0,
        date,
      ));
    }
  } else if (rangeDays > 60) {
    intervalType = DateTimeIntervalType.days;
    interval = 7;

    final startDate = DateTime.fromMillisecondsSinceEpoch(minDay * 24 * 60 * 60 * 1000);
    final weeks = (rangeDays / 7).ceil();

    Map<DateTime, double> weeklyRevenues = {};
    Map<DateTime, double> weeklyProfits = {};

    dailyRevenues.forEach((day, revenue) {
      final date = DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000);
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      weeklyRevenues[weekStart] = (weeklyRevenues[weekStart] ?? 0) + revenue;
    });

    dailyProfits.forEach((day, profit) {
      final date = DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000);
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      weeklyProfits[weekStart] = (weeklyProfits[weekStart] ?? 0) + profit;
    });

    for (int i = 0; i < weeks; i++) {
      final date = startDate.add(Duration(days: i * 7));
      revenueData.add(ChartData(
        DateFormat('MMM d').format(date),
        weeklyRevenues[date] ?? 0.0,
        date,
      ));
      profitData.add(ChartData(
        DateFormat('MMM d').format(date),
        weeklyProfits[date] ?? 0.0,
        date,
      ));
    }
  } else {
    intervalType = DateTimeIntervalType.days;
    interval = rangeDays > 30 ? 7 : (rangeDays > 10 ? 2 : 1);

    revenueData = List.generate(rangeDays, (index) {
      final day = minDay + index;
      return ChartData(
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000).toString(),
        dailyRevenues[day] ?? 0.0,
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000),
      );
    });

    profitData = List.generate(rangeDays, (index) {
      final day = minDay + index;
      return ChartData(
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000).toString(),
        dailyProfits[day] ?? 0.0,
        DateTime.fromMillisecondsSinceEpoch(day * 24 * 60 * 60 * 1000),
      );
    });
  }

  return SfCartesianChart(
    primaryXAxis: DateTimeAxis(
      intervalType: intervalType,
      interval: interval.toDouble(),
      majorGridLines: const MajorGridLines(width: 0),
      labelStyle: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey.shade700),
      dateFormat: intervalType == DateTimeIntervalType.months
          ? DateFormat('MMM yyyy')
          : DateFormat('MMM d'),
    ),
    primaryYAxis: NumericAxis(
      numberFormat: currencyFormat,
      labelStyle: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey.shade700),
    ),
    legend: Legend(
      isVisible: true,
      position: LegendPosition.bottom,
      textStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade800),
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

// Builds a bar chart for analysis data
Widget buildBarChart(List<ChartData> data, Color color, double screenWidth,
    double screenHeight, [NumberFormat? format]) {
  print('ChartWidgets: Building bar chart - Data length: ${data.length}');

  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      labelStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade700),
      majorGridLines: const MajorGridLines(width: 0),
    ),
    primaryYAxis: NumericAxis(
      numberFormat: format,
      labelStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade700),
    ),
    tooltipBehavior: TooltipBehavior(
        enable: true, format: 'point.x: point.y', color: Colors.grey.shade800),
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
            textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

// Builds a line chart with dots for trending or profit data
Widget buildLineChartWithDots(List<ChartData> data, double screenWidth,
    double screenHeight, String yAxisTitle, Color lineColor) {
  print('ChartWidgets: Building line chart with dots - Data length: ${data.length}');

  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      labelStyle: TextStyle(fontSize: screenWidth * 0.015, color: Colors.grey.shade700),
      majorGridLines: const MajorGridLines(width: 0),
      labelRotation: 45,
    ),
    primaryYAxis: NumericAxis(
      labelStyle: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey.shade700),
      title: AxisTitle(
          text: yAxisTitle,
          textStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade800)),
    ),
    tooltipBehavior: TooltipBehavior(
        enable: true, format: 'point.x: point.y', color: Colors.grey.shade800),
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
          textStyle: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

// Builds a pie chart for revenue share
Widget buildPieChart(List<ChartData> data, double screenWidth, double screenHeight,
    NumberFormat currencyFormat) {
  print('ChartWidgets: Building pie chart - Data length: ${data.length}');

  return SfCircularChart(
    legend: Legend(
      isVisible: true,
      position: LegendPosition.bottom,
      textStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade800),
    ),
    tooltipBehavior: TooltipBehavior(
        enable: true, format: 'point.x: point.y', color: Colors.grey.shade800),
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
            textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

// Explanation:
// This file contains reusable chart widgets using Syncfusion Flutter Charts. `buildLineChart` displays daily revenue and profit trends with adaptive intervals (months, weeks, or days). `buildBarChart` shows bar comparisons (e.g., revenue vs. profit for an item). `buildLineChartWithDots` visualizes trends with data points (e.g., top items by quantity or profit). `buildPieChart` shows revenue share in a pie format. Debugging statements log data availability and chart construction for troubleshooting.