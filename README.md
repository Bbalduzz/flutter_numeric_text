<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

This widget allows you to animate text. The animation is reminiscent of the text animation in SwiftUI's `.numericText(value:)`. The widget is easy to use and allows you to seamlessly replace `Text(data)` with `NumericText(data)`.

## Features

<img width="200" src="https://raw.githubusercontent.com/strash/flutter_numeric_text/refs/heads/main/resources/demo.gif"/>
<!--<video width="402" height="874" controls>-->
<!--  <source src="https://github.com/user-attachments/assets/d2b13c59-30c8-45e5-8d4b-eadce09c7ef5" type="video/mp4">-->
<!--</video>-->

- Automatic text animation
- Minimal configuration required to get started
- Supports most parameters of the `Text(data)` widget
- No external dependencies required

## Usage

```dart
import 'package:flutter_numeric_text/flutter_numeric_text.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply add the widget, and when its value changes, it will automatically
    // trigger the animation. To use the widget, you only need to provide
    // a text value, other fields are optional.

    return NumericText(
      "\$1,234.56",
      textAlign: TextAlign.center,
      duration: Durations.medium1,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.greenAccent,
      ),
    );
  }
}
```

## Installation

To use this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_numeric_text: ^1.0.0 # Replace with the latest version
```

## Contributing

Contributions are welcome! If you have suggestions for improvements or find bugs, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/strash/flutter_numeric_text/blob/main/LICENSE) file for details.

