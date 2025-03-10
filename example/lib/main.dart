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

  String randomString(int length) {
    if (length <= 0) throw Exception("Length must be greater then 0");
    final len = (length * 0.5).ceil();
    final bytes = List<int>.generate(len, (i) => rng.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, "0")).join();
  }

  void randomize() {
    setState(() {
      text = randomString(max(1, rng.nextInt(10)));
      value = rng.nextInt(500_000);
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
    final style = theme.textTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: isLight ? const Color(0xFF000000) : const Color(0xFFCCCCED),
    );
    final subStyle = theme.textTheme.bodyLarge?.copyWith(
      color: isLight ? const Color(0xAF000000) : const Color(0xAFCCCCED),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 80.0,
      children: [
        // -> static random text
        Column(
          children: [
            NumericText(text, duration: Durations.medium1, style: style),
            Text("Static random text", style: subStyle),
          ],
        ),

        // -> static numeric text
        Column(
          children: [
            NumericText(
              "\$$valueDescription",
              duration: Durations.medium1,
              style: style,
            ),
            Text("Static numeric text", style: subStyle),
          ],
        ),

        // -> animated numeric text
        Column(
          children: [
            TweenAnimationBuilder(
              duration: Durations.long1,
              tween: ColorTween(
                begin: Colors.white,
                end: Color.fromARGB(
                  200,
                  rng.nextInt(255),
                  rng.nextInt(255),
                  rng.nextInt(255),
                ),
              ),
              builder: (context, color, child) {
                return TweenAnimationBuilder(
                  duration: Durations.long1,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  tween: IntTween(begin: 0, end: value),
                  builder: (context, v, child) {
                    return NumericText(
                      "\$${loc.formatDecimal(v)}",
                      duration: Durations.long4,
                      style: style?.copyWith(color: color),
                    );
                  },
                );
              },
            ),
            Text("Animated numeric text", style: subStyle),
          ],
        ),

        // -> button
        FilledButton(onPressed: randomize, child: Text("Randomize")),
      ],
    );
  }
}
