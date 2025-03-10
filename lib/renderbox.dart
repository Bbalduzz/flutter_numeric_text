part of "./flutter_numeric_text.dart";

final class _RB extends RenderBox {
  _RB({
    required List<_Line> data,
    required double animation,
    required double delay,
    required double duration,
    required _NumericTextConfig config,
    required (Size, Size) sizes,
    required TextPainter oldPainter,
    required TextPainter newPainter,
  }) : _data = data,
       _t = animation,
       _delay = delay,
       _duration = duration,
       _config = config,
       _sizes = sizes,
       _oldPainter = oldPainter,
       _newPainter = newPainter {
    _charPainter = TextPainter(
      text: _span(""),
      strutStyle: _config.strutStyle,
      textAlign: _config.textAlign!,
      textDirection: _config.textDirection,
      locale: _config.locale,
      ellipsis: null,
      textScaler: _config.textScaler!,
      maxLines: _config.maxLines,
      textWidthBasis: _config.textWidthBasis!,
      textHeightBehavior: _config.textHeightBehavior,
    );
  }

  late final TextPainter _charPainter;

  bool _needsClipping = false;
  ui.Shader? _overflowShader;

  List<_Line> _data;
  set data(List<_Line> value) {
    if (_data == value) return;
    _data = value;
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

  _NumericTextConfig _config;
  set config(_NumericTextConfig value) {
    if (_config == value) return;
    _config = value;
  }

  (Size, Size) _sizes = (Size.zero, Size.zero);
  set sizes((Size, Size) value) {
    if (_sizes == value) return;
    _sizes = value;
  }

  TextPainter _oldPainter;
  set oldPainter(TextPainter value) {
    _oldPainter = value;
  }

  TextPainter _newPainter;
  set newPainter(TextPainter value) {
    _newPainter = value;
  }

  TextSpan _span(String text) {
    return TextSpan(text: text, style: _config.style, locale: _config.locale);
  }

  @override
  void performLayout() {
    if (_data.isEmpty) {
      size = Size.zero;
    } else {
      final curve = Curves.easeInOut.transform(_t);
      size = constraints.constrain(_sizes.lerp(curve));
      final oldSize = constraints.constrain(_sizes.$1);
      final newSize = constraints.constrain(_sizes.$2);

      final didOverflowHeight =
          (oldSize.height < _oldPainter.size.height ||
              _oldPainter.didExceedMaxLines) ||
          (newSize.height < _newPainter.size.height ||
              _newPainter.didExceedMaxLines);
      final didOverflowWidth =
          oldSize.width < _oldPainter.size.width ||
          newSize.width < _newPainter.size.width;

      if (didOverflowWidth || didOverflowHeight) {
        switch (_config.overflow!) {
          case TextOverflow.visible:
            _needsClipping = false;
            _overflowShader = null;
          case TextOverflow.clip:
            _needsClipping = true;
            _overflowShader = null;
          case TextOverflow.ellipsis:
            _needsClipping = true;
            _overflowShader = null;
            // replace last pair with ellipsis
            var line = _data.elementAt(_data.length - 1);
            if (line.newChars.isNotEmpty) {
              line.oldChars[line.oldChars.length - 1] = _kEllipsis;
              line.newChars[line.newChars.length - 1] = _kEllipsis;
            }
          case TextOverflow.fade:
            _needsClipping = true;
            _charPainter.text = _span(_kEllipsis);
            _charPainter.layout();
            if (didOverflowWidth) {
              final (fadeStart, fadeEnd) = switch (_config.textDirection!) {
                TextDirection.rtl => (_charPainter.width, 0.0),
                TextDirection.ltr => (
                  size.width - _charPainter.width,
                  size.width,
                ),
              };
              _overflowShader = ui.Gradient.linear(
                Offset(fadeStart, 0.0),
                Offset(fadeEnd, 0.0),
                const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
              );
            } else {
              final fadeEnd = size.height;
              final fadeStart = fadeEnd - _charPainter.height / 2.0;
              _overflowShader = ui.Gradient.linear(
                Offset(0.0, fadeStart),
                Offset(0.0, fadeEnd),
                const [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
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

    final bounds = offset & size;
    if (_needsClipping) {
      if (_overflowShader != null) {
        context.canvas.saveLayer(bounds, Paint());
      } else {
        context.canvas.save();
      }
      context.canvas.clipRect(bounds);
    }

    for (final line in _data) {
      double oldCharWidths = .0;
      double newCharWidths = .0;

      final oldMetrics = line.oldLineMetrics;
      final newMetrics = line.newLineMetrics;

      final oldOffstageOffset = (oldMetrics?.height ?? .0) * .16;
      final newOffstageOffset = (newMetrics?.height ?? .0) * .14;

      int changeIdx = 0;
      for (var i = 0; i < line.newChars.length; i++) {
        final pair = (line.oldChars.elementAt(i), line.newChars.elementAt(i));
        if (pair.isEmpty) continue;

        if (pair.isEqual) {
          // draw unchanged data
          final metrics = newMetrics ?? oldMetrics;
          _charPainter.text = TextSpan(text: pair.$2, style: _config.style);
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
            final oldStyle = _config.style?.copyWith(
              color: _config.style?.color?.withValues(
                alpha: (1.0 - oldACurve) * .8,
              ),
            );
            if (pair.$1 == null) {
              // grow empty space
              _charPainter.text = TextSpan(text: pair.$2, style: oldStyle);
              _charPainter.layout();
              oldCharWidths += _charPainter.width * oldYCurve;
            } else {
              // draw char
              final yOffset =
                  oldMetrics.lineNumber * oldMetrics.height -
                  oldYCurve * oldOffstageOffset;
              _charPainter.text = TextSpan(text: pair.$1, style: oldStyle);
              _charPainter.layout();
              final oldOffset =
                  offset + Offset(oldMetrics.left + oldCharWidths, yOffset);
              _charPainter.paint(context.canvas, oldOffset);
              var oldPA = (-4.0 * pow(locT - .5, 2) + 1.0).clamp(.0, 1.0);
              final painter = _Painter(
                offset: oldOffset,
                color: _config.style?.color?.withValues(alpha: oldPA * .24),
                t: oldYCurve,
              );
              painter.paint(context.canvas, _charPainter.size);
              oldCharWidths += _charPainter.width;
            }
          }

          // draw new data
          if (newMetrics != null) {
            final newACurve = Curves.easeOutExpo.transform(locT).clamp(.0, 1.0);
            final newYCurve = Curves.easeOutBack.transform(locT);
            var newStyle = _config.style?.copyWith(
              color: _config.style?.color?.withValues(alpha: newACurve),
            );
            if (pair.$2 == null) {
              // shrink empty space
              _charPainter.text = TextSpan(text: pair.$1, style: newStyle);
              _charPainter.layout();
              newCharWidths -= _charPainter.width * (1.0 - newYCurve);
            } else {
              // draw char
              final yOffset =
                  newMetrics.lineNumber * newMetrics.height -
                  newOffstageOffset +
                  newYCurve * newOffstageOffset;
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

    if (_needsClipping) {
      if (_overflowShader != null) {
        context.canvas.translate(offset.dx, offset.dy);
        context.canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..blendMode = BlendMode.modulate
            ..shader = _overflowShader,
        );
      }
      context.canvas.restore();
    }
  }

  @override
  void dispose() {
    _charPainter.dispose();
    super.dispose();
  }
}
