part of "./flutter_numeric_text.dart";

const String _kEllipsis = "\u2026";

final class _Line {
  final LineMetrics? oldLineMetrics;
  final LineMetrics? newLineMetrics;
  final List<(String?, String?)> pairs = [];

  _Line({this.oldLineMetrics, this.newLineMetrics});
}

final class _RB extends RenderBox {
  late final TextPainter _oldPainter;
  late final TextPainter _newPainter;
  late final TextPainter _charPainter;

  (Size, Size) _sizes = (Size.zero, Size.zero);
  List<_Line> _linesWPairs = const [];

  bool _needsClipping = false;
  ui.Shader? _overflowShader;

  _RB({
    required (String, String) data,
    required double animation,
    required double delay,
    required double duration,

    TextStyle? style,
    StrutStyle? strutStyle,
    required TextAlign textAlign,
    required TextDirection textDirection,
    required Locale locale,
    required bool softWrap,
    required TextOverflow overflow,
    required TextScaler textScaler,
    int? maxLines,
    required TextWidthBasis textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) : _data = data,
       _t = animation,
       _delay = delay,
       _duration = duration,

       _style = style,
       _strutStyle = strutStyle,
       _textAlign = textAlign,
       _textDirection = textDirection,
       _locale = locale,
       _softWrap = softWrap,
       _overflow = overflow,
       _textScaler = textScaler,
       _maxLines = maxLines,
       _textWidthBasis = textWidthBasis,
       _textHeightBehavior = textHeightBehavior {
    _oldPainter = TextPainter(
      text: _span(_data.$1),
      strutStyle: _strutStyle,
      textAlign: _textAlign,
      textDirection: _textDirection,
      locale: _locale,
      ellipsis: _overflow == TextOverflow.ellipsis ? _kEllipsis : null,
      textScaler: _textScaler,
      maxLines: _maxLines,
      textWidthBasis: _textWidthBasis,
      textHeightBehavior: _textHeightBehavior,
    );
    _newPainter = TextPainter(
      text: _span(_data.$2),
      strutStyle: _strutStyle,
      textAlign: _textAlign,
      textDirection: _textDirection,
      locale: _locale,
      ellipsis: _overflow == TextOverflow.ellipsis ? _kEllipsis : null,
      textScaler: _textScaler,
      maxLines: _maxLines,
      textWidthBasis: _textWidthBasis,
      textHeightBehavior: _textHeightBehavior,
    );
    _charPainter = TextPainter(
      text: _span(""),
      strutStyle: _strutStyle,
      textAlign: _textAlign,
      textDirection: _textDirection,
      locale: _locale,
      ellipsis: null,
      textScaler: _textScaler,
      maxLines: _maxLines,
      textWidthBasis: _textWidthBasis,
      textHeightBehavior: _textHeightBehavior,
    );
  }

  (String, String) _data;
  set data((String, String) value) {
    if (_data == value) return;
    _data = value;
    _oldPainter.text = _span(_data.$1);
    _newPainter.text = _span(_data.$2);
    _charPainter.text = _span("");
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  double _t;
  set t(double value) {
    if (_t == value) return;
    _t = value;
    markNeedsLayout();
  }

  double _delay;
  set delay(double value) {
    if (_delay == value) return;
    _delay = value;
  }

  double _duration;
  set duration(double value) {
    if (_duration == value) return;
    _duration = value;
  }

  TextStyle? _style;
  set style(TextStyle? value) {
    if (_style == value) return;
    _style = value;
    _oldPainter.text = _span(_data.$1);
    _newPainter.text = _span(_data.$2);
    _charPainter.text = _span("");
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  StrutStyle? _strutStyle;
  set strutStyle(StrutStyle? value) {
    if (_strutStyle == value) return;
    _strutStyle = value;
    _oldPainter.strutStyle = value;
    _newPainter.strutStyle = value;
    _charPainter.strutStyle = value;
    _overflowShader = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextAlign _textAlign;
  set textAlign(TextAlign value) {
    if (_textAlign == value) return;
    _textAlign = value;
    _oldPainter.textAlign = value;
    _newPainter.textAlign = value;
    _charPainter.textAlign = value;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _oldPainter.textDirection = value;
    _newPainter.textDirection = value;
    _charPainter.textDirection = value;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  Locale _locale;
  set locale(Locale value) {
    if (_locale == value) return;
    _locale = value;
    _oldPainter.locale = value;
    _newPainter.locale = value;
    _charPainter.locale = value;
    _overflowShader = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  bool _softWrap;
  set softWrap(bool value) {
    if (_softWrap == value) return;
    _softWrap = value;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextOverflow _overflow;
  set overflow(TextOverflow value) {
    if (_overflow == value) return;
    _overflow = value;
    _oldPainter.ellipsis = value == TextOverflow.ellipsis ? _kEllipsis : null;
    _newPainter.ellipsis = value == TextOverflow.ellipsis ? _kEllipsis : null;
    _charPainter.ellipsis = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextScaler _textScaler;
  set textScaler(TextScaler value) {
    if (_textScaler == value) return;
    _textScaler = value;
    _oldPainter.textScaler = value;
    _newPainter.textScaler = value;
    _charPainter.textScaler = value;
    _overflowShader = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextWidthBasis _textWidthBasis;
  set textWidthBasis(TextWidthBasis value) {
    if (_textWidthBasis == value) return;
    _textWidthBasis = value;
    _oldPainter.textWidthBasis = value;
    _newPainter.textWidthBasis = value;
    _charPainter.textWidthBasis = value;
    _overflowShader = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextHeightBehavior? _textHeightBehavior;
  set textHeightBehavior(TextHeightBehavior? value) {
    if (_textHeightBehavior == value) return;
    _textHeightBehavior = value;
    _oldPainter.textHeightBehavior = value;
    _newPainter.textHeightBehavior = value;
    _charPainter.textHeightBehavior = value;
    _overflowShader = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  int? _maxLines;
  set maxLines(int? value) {
    if (_maxLines == value) return;
    _maxLines = value;
    _oldPainter.maxLines = value;
    _newPainter.maxLines = value;
    _overflowShader = null;
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextSpan _span(String text) {
    return TextSpan(text: text, style: _style, locale: _locale);
  }

  double _adjustMaxWidth(double maxWidth) {
    return _softWrap || _overflow == TextOverflow.ellipsis
        ? maxWidth
        : double.infinity;
  }

  (Size, Size) _computeSize() {
    final minWidth = constraints.minWidth;
    final maxWidth = _adjustMaxWidth(constraints.maxWidth);
    _oldPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    _newPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return (_oldPainter.size, _newPainter.size);
  }

  List<_Line> _getCharPairs() {
    final oldChars = _data.$1.characters;
    final oldMetrics = _oldPainter.computeLineMetrics();
    final newChars = _data.$2.characters;
    final newMetrics = _newPainter.computeLineMetrics();

    int lineIdx = 0;
    int oldLineTextPosOffset = 0;
    int newLineTextPosOffset = 0;
    final List<_Line> pairs = [];

    while (oldMetrics.elementAtOrNull(lineIdx) != null &&
        newMetrics.elementAtOrNull(lineIdx) != null) {
      final line = _Line(
        oldLineMetrics: oldMetrics.elementAtOrNull(lineIdx),
        newLineMetrics: newMetrics.elementAtOrNull(lineIdx),
      );

      final oldLineBoundary = _oldPainter.getLineBoundary(
        TextPosition(offset: oldLineTextPosOffset),
      );
      final oldLineChars = oldChars
          .skip(oldLineBoundary.start)
          .take(oldLineBoundary.end - oldLineBoundary.start);
      oldLineTextPosOffset = oldLineBoundary.end + 1;

      final newLineBoundary = _newPainter.getLineBoundary(
        TextPosition(offset: newLineTextPosOffset),
      );
      final newLineChars = newChars
          .skip(newLineBoundary.start)
          .take(newLineBoundary.end - newLineBoundary.start);
      newLineTextPosOffset = newLineBoundary.end + 1;

      final count = max(oldLineChars.length, newLineChars.length);
      for (int i = 0; i < count; i++) {
        line.pairs.add((
          oldLineChars.elementAtOrNull(i),
          newLineChars.elementAtOrNull(i),
        ));
      }

      pairs.add(line);
      lineIdx++;
    }
    return pairs;
  }

  @override
  void performLayout() {
    if (_data.isEmpty) {
      size = Size.zero;
    } else {
      if (_sizes.isEmpty) _sizes = _computeSize();
      if (_linesWPairs.isEmpty) _linesWPairs = _getCharPairs();

      final curve = Curves.easeInOut.transform(_t);
      size = constraints.constrain(_sizes.lerp(curve));
      final oldSize = constraints.constrain(_sizes.$1);
      final newSize = constraints.constrain(_sizes.$2);

      final bool didOverflowHeight =
          (oldSize.height < _oldPainter.size.height ||
              _oldPainter.didExceedMaxLines) ||
          (newSize.height < _newPainter.size.height ||
              _newPainter.didExceedMaxLines);
      final bool didOverflowWidth =
          oldSize.width < _oldPainter.size.width ||
          newSize.width < _newPainter.size.width;
      final bool hasVisualOverflow = didOverflowWidth || didOverflowHeight;
      if (hasVisualOverflow) {
        switch (_overflow) {
          case TextOverflow.visible:
            _needsClipping = false;
            _overflowShader = null;
          case TextOverflow.clip:
            _needsClipping = true;
            _overflowShader = null;
          case TextOverflow.ellipsis:
            _needsClipping = true;
            _overflowShader = null;
            // replase last pair with ellipsis
            if (_linesWPairs.isNotEmpty) {
              var line = _linesWPairs.elementAt(_linesWPairs.length - 1);
              if (line.pairs.isNotEmpty) {
                final pairIdx = line.pairs.length - 1;
                var ellipsisPair = (_kEllipsis, _kEllipsis);
                line.pairs[pairIdx] = ellipsisPair;
              }
            }
          case TextOverflow.fade:
            _needsClipping = true;
            _charPainter.text = _span(_kEllipsis);
            _charPainter.layout();
            if (didOverflowWidth) {
              final (
                double fadeStart,
                double fadeEnd,
              ) = switch (_textDirection) {
                TextDirection.rtl => (_charPainter.width, 0.0),
                TextDirection.ltr => (
                  size.width - _charPainter.width,
                  size.width,
                ),
              };
              _overflowShader = ui.Gradient.linear(
                Offset(fadeStart, 0.0),
                Offset(fadeEnd, 0.0),
                const <Color>[Color(0xFFFFFFFF), Color(0x00FFFFFF)],
              );
            } else {
              final double fadeEnd = size.height;
              final double fadeStart = fadeEnd - _charPainter.height / 2.0;
              _overflowShader = ui.Gradient.linear(
                Offset(0.0, fadeStart),
                Offset(0.0, fadeEnd),
                const <Color>[Color(0xFFFFFFFF), Color(0x00FFFFFF)],
              );
            }
            _charPainter.text = _span("");
        }
      } else {
        _needsClipping = false;
        _overflowShader = null;
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_data.isEmpty) return;

    final staticCurve = Curves.fastOutSlowIn.transform(_t);

    if (_needsClipping) {
      final Rect bounds = offset & size;
      if (_overflowShader != null) {
        context.canvas.saveLayer(bounds, Paint());
      } else {
        context.canvas.save();
      }
      context.canvas.clipRect(bounds);
    }

    for (final line in _linesWPairs) {
      double oldCharWidths = .0;
      double newCharWidths = .0;

      final oldMetrics = line.oldLineMetrics;
      final newMetrics = line.newLineMetrics;

      final oldOffstageOffset = (oldMetrics?.height ?? .0) * .16;
      final newOffstageOffset = (newMetrics?.height ?? .0) * .14;

      int changeIdx = 0;

      for (final pair in line.pairs) {
        if (pair.isEqual) {
          // draw unchanged data
          final metrics = newMetrics ?? oldMetrics;
          _charPainter.text = TextSpan(text: pair.$2, style: _style);
          _charPainter.layout();
          final lineOffset = staticCurve.lerp(
            oldMetrics?.left ?? .0,
            newMetrics?.left ?? .0,
          );
          final dx =
              lineOffset + staticCurve.lerp(oldCharWidths, newCharWidths);
          final dy = (metrics?.lineNumber ?? 0) * (metrics?.height ?? 1.0);
          _charPainter.paint(context.canvas, offset + Offset(dx, dy));
          oldCharWidths += _charPainter.width;
          newCharWidths += _charPainter.width;
        } else {
          final start = changeIdx * _delay.clamp(.0, 1.0);
          final dur = _duration > .0 ? _duration : 1.0;
          final locT = ((_t - start) / dur).clamp(.0, 1.0);
          changeIdx++;
          // draw old data
          if (oldMetrics != null) {
            final oldACurve = Curves.easeOutQuart
                .transform(locT)
                .clamp(.0, 1.0);
            final oldYCurve = Curves.fastEaseInToSlowEaseOut.transform(locT);

            final yOffset =
                oldMetrics.lineNumber * oldMetrics.height -
                oldYCurve * oldOffstageOffset;
            final oldStyle = _style?.copyWith(
              color: _style?.color?.withValues(alpha: (1.0 - oldACurve) * .8),
            );
            _charPainter.text = TextSpan(text: pair.$1, style: oldStyle);
            _charPainter.layout();
            final oldOffset =
                offset + Offset(oldMetrics.left + oldCharWidths, yOffset);
            _charPainter.paint(context.canvas, oldOffset);

            var oldPA = (-4.0 * pow(locT - .5, 2) + 1.0).clamp(.0, 1.0);
            final painter = _Painter(
              offset: oldOffset,
              color: _style?.color?.withValues(alpha: oldPA * .24),
              t: oldYCurve,
            );
            painter.paint(context.canvas, _charPainter.size);
            oldCharWidths += _charPainter.width;
          }

          // draw new data
          if (newMetrics != null) {
            final newACurve = Curves.easeOutExpo.transform(locT).clamp(.0, 1.0);
            final newYCurve = Curves.easeOutBack.transform(locT);
            final yOffset =
                newMetrics.lineNumber * newMetrics.height -
                newOffstageOffset +
                newYCurve * newOffstageOffset;
            var newStyle = _style?.copyWith(
              color: _style?.color?.withValues(alpha: newACurve),
            );
            _charPainter.text = TextSpan(text: pair.$2, style: newStyle);
            _charPainter.layout();
            _charPainter.paint(
              context.canvas,
              offset + Offset(newMetrics.left + newCharWidths, yOffset),
            );
            newCharWidths += _charPainter.width;
          }
        }
      }
    }

    if (_needsClipping) {
      if (_overflowShader != null) {
        context.canvas.translate(offset.dx, offset.dy);
        final Paint paint =
            Paint()
              ..blendMode = BlendMode.modulate
              ..shader = _overflowShader;
        context.canvas.drawRect(Offset.zero & size, paint);
      }
      context.canvas.restore();
    }
  }

  @override
  void dispose() {
    _oldPainter.dispose();
    _newPainter.dispose();
    _charPainter.dispose();
    super.dispose();
  }
}
