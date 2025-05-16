// Model for chart data
class ChartData {
  ChartData(this.label, this.value, [this.date]);
  final String label; // Label for the data point (e.g., date or item name)
  final double value; // Numeric value (e.g., revenue, profit)
  final DateTime? date; // Optional date for time-based charts

  @override
  String toString() => 'ChartData(label: $label, value: $value, date: $date)';
}

// Explanation:
// This file defines a simple ChartData model used by chart widgets to represent data points. It includes a label, value, and optional date, with a toString override for debugging. This model ensures consistent data structure across different chart types.