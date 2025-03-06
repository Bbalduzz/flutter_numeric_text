part of "./flutter_numeric_text.dart";

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

  (String, String) _data;
  set data((String, String) value) {
    if (_data == value) return;
    _data = value;
    _oldPainter.text = _span(_data.$1);
    _newPainter.text = _span(_data.$2);
    _sizes = _computeSize();
    _linesWPairs = _getCharPairs();
    markNeedsLayout();
  }

  TextStyle? _style;
  set style(TextStyle? value) {
    if (_style == value) return;
    _style = value;
    _oldPainter.text = _span(_data.$1);
    _newPainter.text = _span(_data.$2);
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

  _RB({
    required (String, String) data,
    TextStyle? style,
    required TextAlign textAlign,
    int? maxLines,
    required TextDirection textDirection,
    required double animation,
    required double delay,
    required double duration,
  }) : _data = data,
       _style = style,
       _textAlign = textAlign,
       _maxLines = maxLines,
       _textDirection = textDirection,
       _t = animation,
       _delay = delay,
       _duration = duration {
    _oldPainter = TextPainter(
      text: _span(_data.$1),
      textAlign: _textAlign,
      maxLines: _maxLines,
      textDirection: _textDirection,
    );
    _newPainter = TextPainter(
      text: _span(_data.$2),
      textAlign: _textAlign,
      maxLines: _maxLines,
      textDirection: _textDirection,
    );
    _charPainter = TextPainter(
      text: _span(""),
      textAlign: _textAlign,
      maxLines: _maxLines,
      textDirection: _textDirection,
    );
  }

  TextSpan _span(String text) {
    return TextSpan(text: text, style: _style);
  }

  (Size, Size) _computeSize() {
    final minWidth = constraints.minWidth;
    final maxWidth = constraints.maxWidth;
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
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_data.isEmpty) return;

    final staticCurve = Curves.fastOutSlowIn.transform(_t);

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
  }

  @override
  void dispose() {
    _oldPainter.dispose();
    _newPainter.dispose();
    _charPainter.dispose();
    super.dispose();
  }
}
