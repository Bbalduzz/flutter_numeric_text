part of "./flutter_numeric_text.dart";

extension on (String?, String?) {
  bool get isEqual {
    return $1 == $2;
  }
}

extension on double {
  double lerp(double a, double b) {
    return (1.0 - this) * a + b * this;
  }
}
