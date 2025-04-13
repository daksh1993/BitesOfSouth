import 'package:flutter/material.dart';

void showAddAnalysisBottomSheet(BuildContext context,
    List<String> selectedAnalyses, Function(List<String>) onApply) {
  final availableAnalyses = [
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

  Map<String, bool> checkboxStates = {
    for (var analysis in availableAnalyses)
      analysis: selectedAnalyses.contains(analysis)
  };

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final spacing = screenWidth * 0.04;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.all(spacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Analyses",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: ListView(
                    children: availableAnalyses.map((analysis) {
                      return CheckboxListTile(
                        title: Text(
                          analysis,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.grey[800],
                          ),
                        ),
                        value: checkboxStates[analysis],
                        onChanged: (bool? value) {
                          setModalState(() {
                            checkboxStates[analysis] = value ?? false;
                          });
                        },
                        activeColor: Colors.green[700],
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: spacing),
                ElevatedButton(
                  onPressed: () {
                    final newAnalyses = checkboxStates.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();
                    if (!newAnalyses.contains('Net Sales')) {
                      newAnalyses.add('Net Sales');
                    }
                    if (!newAnalyses.contains('Net Profit')) {
                      newAnalyses.add('Net Profit');
                    }
                    onApply(newAnalyses);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Analyses updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing * 2,
                      vertical: spacing,
                    ),
                    elevation: 4,
                    textStyle: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text("Apply"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
