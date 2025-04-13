import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget for selecting date range
class DateRangeSection extends StatefulWidget {
  final double screenWidth; // Screen width for responsive design
  final Function(DateTime?, DateTime?, {String? range})
      onDateRangeChanged; // Callback for date range changes
  final String? selectedRange; // Currently selected predefined range

  const DateRangeSection({
    required this.screenWidth,
    required this.onDateRangeChanged,
    this.selectedRange,
  });

  @override
  _DateRangeSectionState createState() => _DateRangeSectionState();
}

class _DateRangeSectionState extends State<DateRangeSection> {
  DateTime? _startDate; // Selected start date
  DateTime? _endDate; // Selected end date

  // Shows date picker and updates state
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        print(
            'DateRangeSection: Date selected - Start: $_startDate, End: $_endDate');
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  // Applies predefined date range
  void _selectPredefinedRange(String range) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (range) {
      case 'Today':
        start = now.subtract(Duration(days: 1));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Past 2 Days':
        start = now.subtract(Duration(days: 2));
        break;
      case 'This Week':
        start = now.subtract(Duration(days: 6));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        break;
      case 'This Month':
        start = now.subtract(Duration(days: 29));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        break;
      case 'All':
        start = null;
        end = null;
        break;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
      print(
          'DateRangeSection: Predefined range selected - $range, Start: $_startDate, End: $_endDate');
    });
    widget.onDateRangeChanged(start, end, range: range);
  }

  @override
  Widget build(BuildContext context) {
    print('DateRangeSection: Building widget');

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.screenWidth * 0.03,
        horizontal: widget.screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: 'From',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              SizedBox(width: widget.screenWidth * 0.03),
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: 'To',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenWidth * 0.03),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRangeChip('Today'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('Past 2 Days'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('This Week'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('This Month'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('All'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds a date field widget
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: widget.screenWidth * 0.03,
          horizontal: widget.screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: widget.screenWidth * 0.045, color: Colors.green),
            SizedBox(width: widget.screenWidth * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    date == null
                        ? 'Select Date'
                        : '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a range chip widget
  Widget _buildRangeChip(String range) {
    final isSelected = widget.selectedRange == range;
    return GestureDetector(
      onTap: () => _selectPredefinedRange(range),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.04,
          vertical: widget.screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: widget.screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Explanation:
// This file defines the DateRangeSection widget, a standalone component for selecting date ranges. It includes a custom date picker for manual selection and predefined range chips (e.g., Today, This Week). The widget updates its state and notifies the parent via a callback when the range changes. Debugging statements track date selections and range changes for troubleshooting.
