import 'coord.dart';
import 'direction.dart';

class GameState {
  int _score = 0;
  var _human = Coord.origin();
  List<Coord> _robots = [];
  List<Coord> _junk = [];
  bool _gameOver = false;
  var _level = 1;
  int _gridWidth = 0;
  int _gridHeight = 0;
  GameState(
      {int? score,
      Coord? human,
      List<Coord>? robots,
      List<Coord>? junk,
      bool? gameOver,
      int? level,
      int? gridWidth,
      int? gridHeight}) {
    _score = score ?? 0;
    _gameOver = gameOver ?? false;
    _human = human ?? Coord.origin();
    _junk = junk ?? [];
    _robots = robots ?? [];
    _level = level ?? 1;
    _gridHeight = gridHeight ?? 0;
    _gridWidth = gridWidth ?? 0;
  }

  int get score => _score;
  int get level => _level;
  Coord get human => _human;
  List<Coord> get robots => _robots;
  List<Coord> get junk => _junk;
  bool get gameOver => _gameOver;
  int get gridWidth => _gridWidth;
  int get gridHeight => _gridHeight;

  GameState fromExisting(
      {int? score,
      Coord? human,
      List<Coord>? robots,
      List<Coord>? junk,
      bool? gameOver,
      int? level,
      int? gridWidth,
      int? gridHeight}) {
    var existingState = this;
    return GameState(
      score: score ?? existingState.score,
      human: human ?? existingState.human,
      robots: robots ?? existingState.robots,
      junk: junk ?? existingState.junk,
      level: level ?? existingState.level,
      gameOver: gameOver ?? existingState.gameOver,
      gridHeight: gridHeight ?? existingState.gridHeight,
      gridWidth: gridWidth ?? existingState.gridWidth,
    );
  }

  GameState calculateCollisions() {
    List<Coord> newRobots = [];
    List<Coord> newJunk = [];
    var newGameOver = gameOver;
    for (var i = 0; i < robots.length; i++) {
      // human
      if (robots[i] == human) {
        newGameOver = true;
      }
      // another robot
      bool found = false;
      for (var j = 0; j < robots.length; j++) {
        if (i != j && robots[i] == robots[j]) {
          found = true;
          break;
        }
      }
      if (!found && !junk.contains(robots[i])) {
        newRobots.add(robots[i]);
      }
    }
    for (var i = 0; i < junk.length; i++) {
      if (human == junk[i]) {
        newGameOver = true;
      }
      if (!robots.contains(junk[i])) {
        newJunk.add(junk[i]);
      }
    }
    return fromExisting(
        gameOver: newGameOver, robots: newRobots, junk: newJunk);
  }

  GameState moveHuman(Direction d) {
    switch (d) {
      case Direction.up:
        var newRow = human.r() - 1 >= 0 ? human.r() - 1 : human.r();
        return fromExisting(human: Coord(newRow, human.c()));
      case Direction.down:
        var newRow = human.r() + 1 < gridHeight ? human.r() + 1 : human.r();
        return fromExisting(human: Coord(newRow, human.c()));
      case Direction.left:
        var newCol = human.c() - 1 >= 0 ? human.c() - 1 : human.c();
        return fromExisting(human: Coord(human.r(), newCol));
      case Direction.right:
        var newCol = human.c() + 1 < gridWidth ? human.c() + 1 : human.c();
        return fromExisting(human: Coord(human.r(), newCol));
      case Direction.upLeft:
        return moveHuman(Direction.left).moveHuman(Direction.up);
      case Direction.upRight:
        return moveHuman(Direction.right).moveHuman(Direction.up);
      case Direction.downLeft:
        return moveHuman(Direction.left).moveHuman(Direction.down);
      case Direction.downRight:
        return moveHuman(Direction.down).moveHuman(Direction.right);
    }
  }

  GameState takeMoveTurn(Direction d) {
    return fromExisting(score: score + 1).moveHuman(d);
  }

  GameState placeRandomRobots(int amount) {
    int placedRobots = 0;
    List<Coord> robots = [];
    while (placedRobots < amount) {
      var r = Coord.getRandom(gridHeight, gridWidth);
      while (human == r || robots.contains(r)) {
        r = Coord.getRandom(gridHeight, gridWidth);
      }
      robots.add(r);
      placedRobots += 1;
    }
    return fromExisting(robots: robots);
  }
}
