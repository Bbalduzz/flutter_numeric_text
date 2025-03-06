part of "./flutter_numeric_text.dart";

final class _Painter extends CustomPainter {
  final Offset offset;
  final Color? color;
  final double t;

  _Painter({required this.offset, required this.color, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final color = this.color;
    if (color == null) return;

    final width = size.width * .6;
    final height = size.height * .4;
    final left = (size.width - width) * .5;
    final top = (size.height - height) * .4;
    final rect = (offset + Offset(left, top) & Size(width, height));

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * .11
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [color, const Color(0x00FFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            height * (t + .05) * .3,
          );

    canvas.drawArc(rect, .0, -pi, false, paint);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.color != color ||
        oldDelegate.t != t;
  }
}
