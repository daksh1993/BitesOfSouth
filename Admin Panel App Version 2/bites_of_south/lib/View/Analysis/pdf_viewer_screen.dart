import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // For displaying PDF
import 'package:share_plus/share_plus.dart'; // For sharing the PDF

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath; // Path to the PDF file

  const PDFViewerScreen({super.key, required this.pdfPath});

  // Shares the PDF file
  void _sharePdf(BuildContext context) async {
    try {
      print('PDFViewerScreen: Sharing PDF from path: $pdfPath');
      await Share.shareXFiles([XFile(pdfPath)]);
      print('PDFViewerScreen: PDF shared successfully');
    } catch (e) {
      print('PDFViewerScreen: Error sharing PDF - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PDFViewerScreen: Building screen with PDF path: $pdfPath');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // Match app theme
        foregroundColor: Colors.white,
        title: const Text('Analysis Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context), // Share button
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfPath, // Display the PDF from the file path
        onError: (error) {
          print('PDFViewerScreen: Error loading PDF - $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading PDF: $error')),
          );
        },
        onPageError: (page, error) {
          print('PDFViewerScreen: Page $page error - $error');
        },
        onRender: (pages) {
          print('PDFViewerScreen: PDF rendered with $pages pages');
        },
      ),
    );
  }
}

// Explanation:
// This file defines the PDFViewerScreen widget, which displays a PDF file using flutter_pdfview. It includes an AppBar with a share button that uses share_plus to share the PDF file. The PDF is loaded from a temporary file path passed via the constructor. Debugging statements track the rendering and sharing process, helping diagnose issues like file access or sharing failures.
