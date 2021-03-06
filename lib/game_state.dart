import 'dart:math';

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

  GameState takeTeleportTurn() {
    return fromExisting(human: Coord.getRandom(gridHeight, gridWidth));
  }

  Coord _chaseWithOneRobot(Coord robot) {
    {
      var humanRow = human.r();
      var humanCol = human.c();
      var newCol = robot.c();
      var newRow = robot.r();

      if (humanCol > robot.c()) {
        newCol += 1;
      } else if (humanCol < robot.c()) {
        newCol -= 1;
      }

      if (humanRow > robot.r()) {
        newRow += 1;
      } else if (humanRow < robot.r()) {
        newRow -= 1;
      }

      return Coord(newRow, newCol);
    }
  }

  GameState chaseHuman() {
    List<Coord> newRobots = robots.map((r) => _chaseWithOneRobot(r)).toList();
    return fromExisting(robots: newRobots);
  }

  GameState spawnJunk() {
    var rng = Random();
    List<Coord> newJunk = junk.map((e) => e).toList();
    if (rng.nextInt(10) > 8) {
      var set = false;
      while (!set) {
        var junkLocation = Coord.getRandom(gridWidth, gridHeight);
        if (human != junkLocation && !robots.contains(junkLocation)) {
          newJunk.add(junkLocation);
          set = true;
        }
      }
    }
    return fromExisting(junk: newJunk);
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

  GameState placeHuman() {
    return fromExisting(human: _getSafeRandomCoord());
  }

  Coord _getSafeRandomCoord() {
    var candidate = Coord.getRandom(gridHeight, gridWidth);
    var safe = true;
    do {
      safe = true;
      var normalizedCandidate =
          Coord(max(candidate.r() - 2, 0), max(candidate.c() - 2, 0));
      for (var i = normalizedCandidate.r();
          i < normalizedCandidate.r() + 5;
          i++) {
        for (var j = normalizedCandidate.c();
            j < normalizedCandidate.c() + 5;
            j++) {
          for (var k = 0; k < robots.length; k++) {
            if (robots[k] == Coord(i, j)) {
              safe = false;
              candidate = Coord.getRandom(gridHeight, gridWidth);
              break;
            }
          }
          if (!safe) {
            break;
          }
        }
        if (!safe) {
          break;
        }
      }
      if (safe) {
        for (var i = 0; i < junk.length; i++) {
          if (junk[i] == candidate) {
            safe = false;
            candidate = Coord.getRandom(gridHeight, gridWidth);
            break;
          }
        }
      }
    } while (!safe);
    return candidate;
  }

  GameState safeTeleport() {
    return fromExisting(human: _getSafeRandomCoord());
  }
}
