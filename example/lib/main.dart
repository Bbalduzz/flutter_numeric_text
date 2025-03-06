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
    final isLight =
        MediaQuery.platformBrightnessOf(context) == Brightness.light;
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
  late final loc = MaterialLocalizations.of(context);
  final rng = Random();
  String text = "";
  int value = 0;
  int count = 1;

  String randomString(int length) {
    if (length <= 0) throw Exception("Length must be greater then 0");
    final len = (length * 0.5).ceil();
    final bytes = List<int>.generate(len, (i) => rng.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, "0")).join();
  }

  void randomize() {
    setState(() {
      text = randomString(max(1, rng.nextInt(10)));
      value = rng.nextInt(5000);
      count++;
    });
  }

  String get valueDescription {
    return loc.formatDecimal(value);
  }

  @override
  void initState() {
    super.initState();
    randomize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight =
        MediaQuery.platformBrightnessOf(context) == Brightness.light;
    final style = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: isLight ? const Color(0xFF000000) : const Color(0xFFCCCCED),
    );
    final subStyle = theme.textTheme.bodyLarge?.copyWith(
      color: isLight ? const Color(0xAF000000) : const Color(0xAFCCCCED),
      height: 1.25,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 20.0,
      children: [
        Column(
          children: [
            NumericText(
              text,
              duration: Durations.medium1,
              textAlign: TextAlign.center,
              style: style,
            ),
            Text(
              "Some random text",
              textAlign: TextAlign.center,
              style: subStyle,
            ),
          ],
        ),
        const SizedBox(height: 20.0),

        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NumericText("\$$valueDescription", style: style),
              Text(
                "Duration Default\nTextAlign Start",
                textAlign: TextAlign.start,
                style: subStyle,
              ),
            ],
          ),
        ),

        Column(
          children: [
            NumericText(
              "\$$valueDescription",
              duration: Durations.medium1,
              textAlign: TextAlign.center,
              style: style,
            ),
            Text(
              "Duration Medium1\nTextAlign Center",
              textAlign: TextAlign.center,
              style: subStyle,
            ),
          ],
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NumericText(
                "\$$valueDescription",
                duration: Durations.long1,
                textAlign: TextAlign.end,
                style: style,
              ),
              Text(
                "Duration Long1\nTextAlign End",
                textAlign: TextAlign.end,
                style: subStyle,
              ),
            ],
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                duration: Durations.long4,
                curve: Curves.fastEaseInToSlowEaseOut,
                tween: IntTween(begin: 0, end: value),
                builder: (context, v, child) {
                  return NumericText("\$${loc.formatDecimal(v)}", style: style);
                },
              ),
              Text(
                "Animated text",
                textAlign: TextAlign.start,
                style: subStyle,
              ),
            ],
          ),
        ),

        Column(
          spacing: 5.0,
          children: [
            FilledButton(onPressed: randomize, child: Text("Randomize")),
            NumericText(
              "Randomized\n$count times",
              duration: Durations.medium2,
              textAlign: TextAlign.center,
              style: subStyle,
            ),
          ],
        ),
      ],
    );
  }
}
