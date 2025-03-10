part of "./flutter_numeric_text.dart";

const String _kEllipsis = "\u2026";

final class _NumericTextConfig {
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  _NumericTextConfig({
    required this.style,
    required this.strutStyle,
    required this.textAlign,
    required this.textDirection,
    required this.locale,
    required this.softWrap,
    required this.overflow,
    required this.textScaler,
    required this.maxLines,
    required this.semanticsLabel,
    required this.textWidthBasis,
    required this.textHeightBehavior,
  });

  _NumericTextConfig copyWith({
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return _NumericTextConfig(
      style: style ?? this.style,
      strutStyle: strutStyle ?? this.strutStyle,
      textAlign: textAlign ?? this.textAlign,
      textDirection: textDirection ?? this.textDirection,
      locale: locale ?? this.locale,
      softWrap: softWrap ?? this.softWrap,
      overflow: overflow ?? this.overflow,
      textScaler: textScaler ?? this.textScaler,
      maxLines: maxLines ?? this.maxLines,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      textWidthBasis: textWidthBasis ?? this.textWidthBasis,
      textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
    );
  }

  _NumericTextConfig inferData(BuildContext context) {
    final textStyle = getStyle(context);

    return copyWith(
      style: textStyle,
      textAlign: getTextAlign(context),
      textDirection: getTextDirection(context),
      locale: getLocale(context),
      softWrap: getSoftWrap(context),
      overflow: getTextOverflow(context, textStyle),
      textScaler: getTextScaler(context),
      maxLines: getMaxLines(context),
      textWidthBasis: getTextWidthBasis(context),
      textHeightBehavior: getTextHeightBehavior(context),
    );
  }

  void update(BuildContext context, String text, TextPainter painter) {
    painter.text = getSpan(context, text);
    painter.strutStyle = strutStyle;
    painter.textAlign = getTextAlign(context);
    painter.textDirection = getTextDirection(context);
    painter.locale = getLocale(context);
    painter.ellipsis = overflow == TextOverflow.ellipsis ? _kEllipsis : null;
    painter.textScaler = getTextScaler(context);
    painter.maxLines = getMaxLines(context);
    painter.textWidthBasis = getTextWidthBasis(context);
    painter.textHeightBehavior = getTextHeightBehavior(context);
  }

  TextSpan getSpan(BuildContext context, String text) {
    return TextSpan(text: text, style: style, locale: getLocale(context));
  }

  TextStyle? getStyle(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    TextStyle? resStyle = style;
    if (resStyle == null || resStyle.inherit) {
      resStyle = defaultStyle.style.merge(style);
    }
    if (MediaQuery.boldTextOf(context)) {
      resStyle = resStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return resStyle;
  }

  TextAlign getTextAlign(BuildContext context) {
    return textAlign ??
        DefaultTextStyle.of(context).textAlign ??
        TextAlign.start;
  }

  TextDirection getTextDirection(BuildContext context) {
    return textDirection ?? Directionality.of(context);
  }

  Locale getLocale(BuildContext context) {
    return locale ?? Localizations.localeOf(context);
  }

  bool getSoftWrap(BuildContext context) {
    return softWrap ?? DefaultTextStyle.of(context).softWrap;
  }

  TextOverflow getTextOverflow(BuildContext context, TextStyle? style) {
    return overflow ?? style?.overflow ?? DefaultTextStyle.of(context).overflow;
  }

  TextScaler getTextScaler(BuildContext context) {
    return textScaler ?? MediaQuery.textScalerOf(context);
  }

  int? getMaxLines(BuildContext context) {
    return maxLines ?? DefaultTextStyle.of(context).maxLines;
  }

  TextWidthBasis getTextWidthBasis(BuildContext context) {
    return textWidthBasis ?? DefaultTextStyle.of(context).textWidthBasis;
  }

  TextHeightBehavior? getTextHeightBehavior(BuildContext context) {
    return textHeightBehavior ??
        DefaultTextStyle.of(context).textHeightBehavior ??
        DefaultTextHeightBehavior.maybeOf(context);
  }

  @override
  operator ==(covariant _NumericTextConfig other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode {
    return style.hashCode +
        strutStyle.hashCode +
        textAlign.hashCode +
        textDirection.hashCode +
        locale.hashCode +
        softWrap.hashCode +
        overflow.hashCode +
        textScaler.hashCode +
        maxLines.hashCode +
        semanticsLabel.hashCode +
        textWidthBasis.hashCode +
        textHeightBehavior.hashCode;
  }
}
