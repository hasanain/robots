import 'dart:math';

class Coord {
  int _r = 0;
  int _c = 0;
  Coord(int? r, int? c) {
    _r = r ?? 0;
    _c = c ?? 0;
  }
  int c() {
    return _c;
  }

  int r() {
    return _r;
  }

  bool samePositionAs(int r, int c) {
    return _r == r && _c == c;
  }

  @override
  bool operator ==(covariant Coord other) => equals(other);

  bool equals(Coord other) {
    return samePositionAs(other.r(), other.c());
  }

  static Coord getRandom(int maxHeight, int maxWidth) {
    var rng = Random();

    return Coord(rng.nextInt(maxHeight), rng.nextInt(maxHeight));
  }

  static origin() {
    return Coord(0, 0);
  }

  @override
  String toString() {
    return '(row: $_r, column: $_c)';
  }

  @override
  int get hashCode => Object.hash(r, c);
}
