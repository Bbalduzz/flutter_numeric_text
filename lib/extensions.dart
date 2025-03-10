part of "./flutter_numeric_text.dart";

const _numberPattern = r"(\d{1,3}(?:[ ,.]\d+)*)";
final _numberRegex = RegExp(_numberPattern);

extension on String {
  Iterable<RegExpMatch> get allNumbers {
    return _numberRegex.allMatches(this);
  }
}

extension on (String?, String?) {
  bool get isEqual {
    return $1 == $2;
  }

  bool get isEmpty {
    return ($1?.isEmpty ?? true) && ($2?.isEmpty ?? true);
  }
}

extension on (Size, Size) {
  bool get isEmpty {
    return $1.isEmpty && $2.isEmpty;
  }

  Size lerp(double t) {
    return Size(t.lerp($1.width, $2.width), t.lerp($1.height, $2.height));
  }
}

extension on double {
  double lerp(double a, double b) {
    return (1.0 - this) * a + b * this;
  }

  double invLerp(double a, double b) {
    return (this - a) / max(1.0, b - a);
  }

  double remap(double imin, double imax, double omin, double omax) {
    final double inv = invLerp(imin, imax);
    return inv.lerp(omin, omax);
  }
}
