import "dart:math";

import "package:flutter/widgets.dart";

part "./extensions.dart";
part "./painter.dart";
part "./renderbox.dart";

class NumericText extends StatefulWidget {
  /// The text to display.
  final String data;

  /// The duration of the transition from the old [data] value to the new one
  final Duration? duration;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// A widget that displays numeric text with individual character animations.
  ///
  /// This class serves as the entry point for users of the package. It renders
  /// the provided text as a standard [Text] widget, while additionally
  /// animating each character separately whenever the data changes. This can
  /// be useful for creating dynamic and visually engaging text displays, such
  /// as counters or animated labels.
  ///
  /// The [data] parameter specifies the text to be displayed. The optional
  /// [style] parameter allows customization of the text appearance, merging
  /// with the closest enclosing [DefaultTextStyle] if its "inherit" property
  /// is set to true. The [textAlign] parameter controls the horizontal
  /// alignment of the text, while [maxLines] can be used to limit the number
  /// of lines the text spans, enabling wrapping if necessary. The
  /// [textDirection] parameter determines the directionality of the text,
  /// affecting how alignment values like [TextAlign.start] and [TextAlign.end]
  /// are interpreted.
  ///
  /// Example usage:
  /// ```dart
  /// NumericText(
  ///   '12345',
  ///   style: TextStyle(fontSize: 24, color: Colors.black),
  ///   textAlign: TextAlign.center,
  ///   maxLines: 1,
  ///   textDirection: TextDirection.ltr,
  /// )
  /// ```
  const NumericText(
    this.data, {
    super.key,
    this.duration,
    this.style,
    this.textAlign,
    this.maxLines,
    this.textDirection,
  });

  @override
  State<NumericText> createState() => _NumericTextState();
}

class _NumericTextState extends State<NumericText>
    with SingleTickerProviderStateMixin {
  late String _oldData = widget.data;
  Duration _delay = Duration.zero;
  Duration _duration = Duration.zero;

  late final _controller = AnimationController(
    vsync: this,
    lowerBound: .0,
    upperBound: 1.0,
    duration: widget.duration ?? _defaultDurationPerChange,
  )..addStatusListener(_statusListener);

  Duration get _defaultDurationPerChange {
    return const Duration(milliseconds: 150);
  }

  void _statusListener(status) {
    if (status == AnimationStatus.completed) {
      _oldData = widget.data;
    }
  }

  int get _diffCount {
    final (oldLines, newLines) = (
      _oldData.split("\n"),
      widget.data.split("\n"),
    );
    int lineIdx = 0;
    int diffCount = 0;
    while (oldLines.elementAtOrNull(lineIdx) != null &&
        newLines.elementAtOrNull(lineIdx) != null) {
      final oldLineChars = oldLines.elementAtOrNull(lineIdx)?.characters;
      final newLineChars = newLines.elementAtOrNull(lineIdx)?.characters;
      final count = max(oldLineChars?.length ?? 0, newLineChars?.length ?? 0);
      for (var i = 0; i < count; i++) {
        final pair = (
          oldLineChars?.elementAtOrNull(i),
          newLineChars?.elementAtOrNull(i),
        );
        if (!pair.isEqual) diffCount++;
      }
      lineIdx++;
    }
    return diffCount;
  }

  @override
  void didUpdateWidget(covariant NumericText oldWidget) {
    _oldData = oldWidget.data;

    _duration = widget.duration ?? _defaultDurationPerChange;
    _delay = _duration * .2;
    _controller.duration = _duration + _delay * max(0, _diffCount - 1);
    _controller.reset();
    _controller.forward();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_statusListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imax = _controller.duration!.inMicroseconds.toDouble();
    final delay = _delay.inMicroseconds.toDouble().remap(.0, imax, .0, 1.0);
    final dur = _duration.inMicroseconds.toDouble().remap(.0, imax, .0, 1.0);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return _Text(
            oldData: _oldData,
            data: widget.data,
            style: widget.style,
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            textDirection: widget.textDirection,
            animation: _controller,
            delay: delay,
            duration: dur,
          );
        },
      ),
    );
  }
}

final class _Text extends LeafRenderObjectWidget {
  final String oldData;
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextDirection? textDirection;
  final Animation<double> animation;
  final double delay;
  final double duration;

  const _Text({
    required this.oldData,
    required this.data,
    this.style,
    this.textAlign,
    this.maxLines,
    this.textDirection,
    required this.animation,
    required this.delay,
    required this.duration,
  });

  TextStyle? _style(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    TextStyle? resStyle = style;
    if (style == null || style!.inherit) {
      resStyle = defaultStyle.style.merge(style);
    }
    if (MediaQuery.boldTextOf(context)) {
      resStyle = resStyle!.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return resStyle;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    return _RB(
      data: (oldData, data),
      style: _style(context),
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      textDirection: textDirection ?? Directionality.of(context),
      animation: animation.value,
      delay: delay,
      duration: duration,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RB renderObject) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    renderObject.data = (oldData, data);
    renderObject.style = _style(context);
    renderObject.textAlign =
        textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    renderObject.maxLines = maxLines ?? defaultTextStyle.maxLines;
    renderObject.textDirection = textDirection ?? Directionality.of(context);
    renderObject.t = animation.value;
    renderObject.delay = delay;
    renderObject.duration = duration;
  }
}
