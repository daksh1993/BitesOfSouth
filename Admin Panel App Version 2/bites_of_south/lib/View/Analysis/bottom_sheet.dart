import 'package:flutter/material.dart';

// Shows a bottom sheet for selecting analyses
void showAddAnalysisBottomSheet(
    BuildContext context, List<String> selectedAnalyses, Function(List<String>) onApply) {
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
    for (var analysis in availableAnalyses) analysis: selectedAnalyses.contains(analysis)
  };
  print('BottomSheet: Showing analysis selection - Initial selections: $selectedAnalyses');

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
                  "Select Analyses",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Expanded(
                  child: ListView(
                    children: availableAnalyses.map((analysis) {
                      return CheckboxListTile(
                        title: Text(analysis, style: const TextStyle(fontSize: 16)),
                        value: checkboxStates[analysis],
                        onChanged: (bool? value) {
                          setModalState(() {
                            checkboxStates[analysis] = value ?? false;
                            print('BottomSheet: Checkbox changed - $analysis: ${checkboxStates[analysis]}');
                          });
                        },
                        activeColor: Colors.green.shade700,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                    print('BottomSheet: Apply pressed - New analyses: $newAnalyses');
                    onApply(newAnalyses);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Explanation:
// This file defines a utility function to show a bottom sheet for selecting analysis types. It uses a StatefulBuilder to manage checkbox states dynamically and ensures 'Net Sales' and 'Net Profit' are always included in the final selection. The selected analyses are passed back to the parent via a callback. Debugging statements track checkbox changes and final selections.