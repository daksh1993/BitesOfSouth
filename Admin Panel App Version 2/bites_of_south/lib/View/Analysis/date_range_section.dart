import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSection extends StatefulWidget {
  final double screenWidth;
  final Function(DateTime?, DateTime?, {String? range}) onDateRangeChanged;
  final String? selectedRange;

  const DateRangeSection({
    required this.screenWidth,
    required this.onDateRangeChanged,
    this.selectedRange,
    super.key,
  });

  @override
  _DateRangeSectionState createState() => _DateRangeSectionState();
}

class _DateRangeSectionState extends State<DateRangeSection> {
  DateTime? _startDate;
  DateTime? _endDate;

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
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

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
        start = now.subtract(Duration(days: 3));
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
    final spacing = widget.screenWidth * 0.03;

    return Container(
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Date',
            style: TextStyle(
              fontSize: widget.screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context: context,
                  label: 'From',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildDateButton(
                  context: context,
                  label: 'To',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRangeChip('Today'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('Past 2 Days'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('This Week'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('This Month'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('All'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.green[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(
          vertical: widget.screenWidth * 0.03,
          horizontal: widget.screenWidth * 0.03,
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: widget.screenWidth * 0.045,
            color: Colors.green[700],
          ),
          SizedBox(width: widget.screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.035,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  date == null
                      ? 'Select Date'
                      : DateFormat.yMMMd().format(date),
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String range) {
    final isSelected = widget.selectedRange == range;
    return GestureDetector(
      onTap: () => _selectPredefinedRange(range),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.04,
          vertical: widget.screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.green[200]!,
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green[800],
            fontSize: widget.screenWidth * 0.035,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
