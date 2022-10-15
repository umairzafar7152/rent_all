import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class TermsConditions extends StatelessWidget {
  TermsConditions({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acquired Items',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: TermsConditionsPage(),
    );
  }
}

class TermsConditionsPage extends StatefulWidget {
  TermsConditionsPage({
    Key key,
  }) : super(key: key);

  @override
  _TermsConditionsPageState createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0467), // status bar color
        brightness: Brightness.dark,
        title: Text('Acquired Items'),
      ),
      body: PDFView(
        filePath: 'assets/terms_services/EULA.pdf',
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _controller.complete(pdfViewController);
        },
        onPageChanged: (int page, int total) {
          print('page change: $page/$total');
        },
      ),
    );
  }
}
