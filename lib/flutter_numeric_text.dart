import "dart:math";
import "dart:ui" as ui;

import "package:flutter/widgets.dart";

part "./extensions.dart";
part "./painter.dart";
part "./renderbox.dart";

class NumericText extends StatefulWidget {
  /// The text to display.
  final String data;

  /// The duration of the transition from the old [data] value to the new one
  /// for each character. This duration determines how long the animation
  /// takes for each character to transition individually, creating a dynamic
  /// effect as the text updates. The overall duration of the transition
  /// will vary depending on the number of characters being animated.
  final Duration? duration;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with
  /// `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  final bool? softWrap;

  /// How visual overflow should be handled.
  ///
  /// If this is null [TextStyle.overflow] will be used, otherwise the value
  /// from the nearest [DefaultTextStyle] ancestor will be used.
  final TextOverflow? overflow;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  /// If the text exceeds the given number of lines, it will be truncated
  /// according to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  /// {@template flutter.widgets.Text.semanticsLabel}
  /// An alternative semantics label for this text.
  ///
  /// If present, the semantics of this widget will contain this value instead
  /// of the actual text. This will overwrite any of the semantics labels
  /// applied directly to the [TextSpan]s.
  ///
  /// This is useful for replacing abbreviations or shorthands with the full
  /// text value:
  ///
  /// ```dart
  /// const Text(r'$$', semanticsLabel: 'Double dollars')
  /// ```
  /// {@endtemplate}
  final String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro dart.ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// A widget that displays any text with individual character animations.
  ///
  /// This class serves as the entry point for users of the plugin. It renders
  /// the provided text as a standard [Text] widget, while additionally
  /// animating each character separately whenever the data changes. This can be
  /// useful for creating dynamic and visually engaging text displays, such as
  /// counters or animated labels.
  ///
  /// The [data] parameter specifies the text to be displayed. The optional
  /// [duration] parameter defines the transition duration from the old value
  /// to the new one for each character. This duration determines how long the
  /// animation takes for each character to transition individually, creating a
  /// dynamic effect as the text updates. The overall duration of the transition
  /// will vary depending on the number of characters being animated. The
  /// [style] parameter allows customization of the text appearance, merging
  /// with the closest enclosing [DefaultTextStyle] if its "inherit" property is
  /// set to true. The [strutStyle] parameter can be used to control the spacing
  /// of the text. The [textAlign] parameter controls the horizontal alignment
  /// of the text, while [maxLines] can be used to limit the number of lines the
  /// text spans, enabling wrapping if necessary. The [textDirection] parameter
  /// determines the directionality of the text, affecting how alignment values
  /// like [TextAlign.start] and [TextAlign.end] are interpreted. The [locale]
  /// parameter is used to select a font when the same Unicode character can be
  /// rendered differently, depending on the locale. The [softWrap] parameter
  /// specifies whether the text should break at soft line breaks. The
  /// [overflow] parameter defines how visual overflow should be handled. The
  /// [textScaler] parameter allows for scaling the text based on the device's
  /// text scaling factor. The [semanticsLabel] provides an alternative
  /// semantics label for this text, which can be useful for accessibilit
  /// purposes. The [textWidthBasis] parameter determines how the text width is
  /// calculated, and the [textHeightBehavior] parameter controls the behavior
  /// of text height adjustments.
  ///
  /// Example usage:
  /// ```dart
  /// NumericText(
  ///   "12345 or text",
  ///   duration: const Duration(milliseconds: 300),
  ///   style: const TextStyle(fontSize: 24, color: Colors.black),
  ///   textAlign: TextAlign.center,
  ///   textDirection: TextDirection.ltr,
  ///   locale: const Locale("en", "US"),
  ///   softWrap: true,
  ///   overflow: TextOverflow.ellipsis,
  ///   maxLines: 1,
  ///   semanticsLabel: "Numeric value",
  /// )
  /// ```
  const NumericText(
    this.data, {
    super.key,
    this.duration,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
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
          Widget result = _Text(
            oldData: _oldData,
            data: widget.data,
            animation: _controller,
            delay: delay,
            duration: dur,
            style: widget.style,
            strutStyle: widget.strutStyle,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            locale: widget.locale,
            softWrap: widget.softWrap,
            overflow: widget.overflow,
            textScaler: widget.textScaler,
            maxLines: widget.maxLines,
            textWidthBasis: widget.textWidthBasis,
            textHeightBehavior: widget.textHeightBehavior,
          );

          if (widget.semanticsLabel != null) {
            result = Semantics(
              textDirection: widget.textDirection ?? Directionality.of(context),
              label: widget.semanticsLabel,
              child: ExcludeSemantics(child: result),
            );
          }

          return result;
        },
      ),
    );
  }
}

final class _Text extends LeafRenderObjectWidget {
  final String oldData;
  final String data;
  final Animation<double> animation;
  final double delay;
  final double duration;

  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const _Text({
    required this.oldData,
    required this.data,
    required this.animation,
    required this.delay,
    required this.duration,

    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.textWidthBasis,
    this.textHeightBehavior,
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

  TextAlign _textAlign(BuildContext context) {
    return textAlign ??
        DefaultTextStyle.of(context).textAlign ??
        TextAlign.start;
  }

  TextDirection _textDirection(BuildContext context) {
    return textDirection ?? Directionality.of(context);
  }

  Locale _locale(BuildContext context) {
    return locale ?? Localizations.localeOf(context);
  }

  bool _softWrap(BuildContext context) {
    return softWrap ?? DefaultTextStyle.of(context).softWrap;
  }

  TextOverflow _textOverflow(BuildContext context, TextStyle? style) {
    return overflow ?? style?.overflow ?? DefaultTextStyle.of(context).overflow;
  }

  TextScaler _textScaler(BuildContext context) {
    return textScaler ?? MediaQuery.textScalerOf(context);
  }

  int? _maxLines(BuildContext context) {
    return maxLines ?? DefaultTextStyle.of(context).maxLines;
  }

  TextWidthBasis _textWidthBasis(BuildContext context) {
    return textWidthBasis ?? DefaultTextStyle.of(context).textWidthBasis;
  }

  TextHeightBehavior? _textHeightBehavior(BuildContext context) {
    return textHeightBehavior ??
        DefaultTextStyle.of(context).textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    final textStyle = _style(context);

    return _RB(
      data: (oldData, data),
      animation: animation.value,
      delay: delay,
      duration: duration,

      style: textStyle,
      strutStyle: strutStyle,
      textAlign: _textAlign(context),
      textDirection: _textDirection(context),
      locale: _locale(context),
      softWrap: _softWrap(context),
      overflow: _textOverflow(context, textStyle),
      textScaler: _textScaler(context),
      maxLines: _maxLines(context),
      textWidthBasis: _textWidthBasis(context),
      textHeightBehavior: _textHeightBehavior(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RB renderObject) {
    final textStyle = _style(context);

    renderObject.data = (oldData, data);
    renderObject.t = animation.value;
    renderObject.delay = delay;
    renderObject.duration = duration;

    renderObject.style = textStyle;
    renderObject.strutStyle = strutStyle;
    renderObject.textAlign = _textAlign(context);
    renderObject.textDirection = _textDirection(context);
    renderObject.locale = _locale(context);
    renderObject.softWrap = _softWrap(context);
    renderObject.overflow = _textOverflow(context, textStyle);
    renderObject.textScaler = _textScaler(context);
    renderObject.maxLines = _maxLines(context);
    renderObject.textWidthBasis = _textWidthBasis(context);
    renderObject.textHeightBehavior = _textHeightBehavior(context);
  }
}
