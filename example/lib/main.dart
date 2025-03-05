import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_numeric_text/flutter_numeric_text.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var isLight = MediaQuery.platformBrightnessOf(context) == Brightness.light;
    const bgLigth = Color(0xFFFFFFFF);
    const bgDark = Color(0xFF050505);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: isLight ? bgLigth : bgDark,
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Align(alignment: Alignment.center, child: MyWidget()),
        ),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _rng = Random();
  int _iValue = 0;

  void _randomize() {
    setState(() {
      _iValue += _rng.nextInt(150) + 1;
    });
  }

  String get _description {
    var loc = MaterialLocalizations.of(context);
    return loc.formatDecimal(_iValue);
  }

  @override
  void initState() {
    super.initState();
    _randomize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isLight = MediaQuery.platformBrightnessOf(context) == Brightness.light;
    var style = theme.textTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: isLight ? const Color(0xFF000000) : const Color(0xFFCCCCED),
    );

    final description = _description;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 20.0,
      children: [
        NumericText(
          "\$$description\nStart",
          duration: Durations.short4,
          style: style,
        ),

        NumericText(
          "\$$description\nCenter",
          duration: Durations.medium4,
          textAlign: TextAlign.center,
          style: style,
        ),

        NumericText(
          "\$$description\nEnd",
          duration: Durations.long4,
          textAlign: TextAlign.end,
          style: style,
        ),

        FilledButton(onPressed: _randomize, child: Text("Randomize")),
      ],
    );
  }
}
