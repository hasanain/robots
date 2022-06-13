import 'package:flutter/material.dart';
import 'package:robots/game_state.dart';
import 'dart:math';
import 'coord.dart';
import 'direction.dart';
import './theme.dart';

void main() {
  runApp(const Robots());
}

class Robots extends StatelessWidget {
  const Robots({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robots Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RobotsGame(title: 'Robots'),
    );
  }
}

class RobotsGame extends StatefulWidget {
  const RobotsGame({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RobotsGame> createState() => _RobotsGameState();
}

int height = 22;
int width = 44;

class _RobotsGameState extends State<RobotsGame> {
  int score = 0;
  var human = Coord.origin();
  List<Coord> robots = [];
  List<Coord> junk = [];
  bool gameOver = false;
  var level = 1;
  GameState gameState = GameState(gridHeight: height, gridWidth: width);

  @override
  void initState() {
    _newGame(1, 0);
    super.initState();
  }

  void _takeTurn(Direction d) {
    setState(() {
      if (!gameOver) {
        _moveHuman(d);
        _runTurn();
      }
    });
  }

  void _runTurn() {
    _moveRobots();
    _calculateCollisions();
    _spawnJunk();
    _calculateLevelOver();
  }

  void _calculateLevelOver() {
    if (robots.isEmpty) {
      _newGame(level + 1, score);
    }
  }

  void _newGame(int newLevel, int newScore) {
    setState(() {
      var state = gameState.fromExisting(
          score: newScore,
          human: Coord.getRandom(height, width),
          gameOver: false,
          level: newLevel,
          junk: []).placeRandomRobots(10);
      score = state.score;
      human = state.human;
      robots = state.robots;
      gameOver = state.gameOver;
      level = state.level;
      junk = state.junk;
      gameState = state;
    });
  }

  void _teleportHuman() {
    setState(() {
      if (!gameOver) {
        human = Coord.getRandom(height, width);
        _runTurn();
      }
    });
  }

  void _moveHuman(Direction d) {
    GameState state = gameState.fromExisting(human: human, score: score);
    GameState newState = state.takeMoveTurn(d);
    human = newState.human;
    score = newState.score;
    gameState = newState;
  }

  Coord _moveRobot(Coord robot) {
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

  void _moveRobots() {
    robots = robots.map((r) => _moveRobot(r)).toList();
  }

  void _calculateCollisions() {
    GameState state = gameState.fromExisting(
        robots: robots, junk: junk, human: human, gameOver: gameOver);

    GameState newState = state.calculateCollisions();
    robots = newState.robots;
    junk = newState.junk;
    gameOver = newState.gameOver;
    gameState = newState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [_buildGameBody()]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _newGame(1, 0);
        },
        tooltip: 'New Game',
        child: const Icon(Icons.restart_alt),
      ),
    );
  }

  Widget _buildGridItem(int r, int c) {
    if (gameOver && human.samePositionAs(r, c)) {
      return Center(
          child: Text(
        GameTheme.human,
        style: const TextStyle(color: Colors.red),
      ));
    }
    if (junk.contains(Coord(r, c))) {
      return Center(child: Text(GameTheme.junk));
    }
    if (robots.contains(Coord(r, c))) {
      return Center(child: Text(GameTheme.robot));
    }
    if (human.samePositionAs(r, c)) {
      return Center(child: Text(GameTheme.human));
    }
    return const Center(child: Text(''));
  }

  Widget _buildGameBody() {
    return Column(children: <Widget>[
      Row(
        children: [
          Center(child: Text('Level: $level ')),
          Center(
              child:
                  Text(gameOver ? 'Game Over Score: $score' : 'Score: $score')),
          InkWell(
              onTap: () {
                _safeTeleport();
              },
              child: Center(child: Text(' Safe Teleport')))
        ],
      ),
      SizedBox(
          width: width * 20,
          height: height * 19,
          child: AspectRatio(
            aspectRatio: 2.0,
            child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: GridView.count(
                  crossAxisCount: width,
                  children: [
                    for (var r = 0; r < height; r++)
                      for (var c = 0; c < width; c++) _buildGridItem(r, c)
                  ],
                )),
          )),
      SizedBox(
          width: 200,
          height: 200,
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.upLeft);
                    },
                    child: Center(child: Text('↖'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.up);
                    },
                    child: Center(child: Text('⬆'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.upRight);
                    },
                    child: Center(child: Text('↗'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.left);
                    },
                    child: Center(child: Text('⬅'))),
                InkWell(
                    onTap: () {
                      _teleportHuman();
                    },
                    child: Center(child: Text('⬤'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.right);
                    },
                    child: Center(child: Text('➡'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.downLeft);
                    },
                    child: Center(child: Text('↙'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.down);
                    },
                    child: Center(child: Text('⬇'))),
                InkWell(
                    onTap: () {
                      _takeTurn(Direction.downRight);
                    },
                    child: Center(child: Text('↘'))),
              ],
            ),
          ))
    ]);
  }

  void _spawnJunk() {
    var rng = Random();
    if (rng.nextInt(10) > 6) {
      var set = false;
      while (!set) {
        var junkLocation = Coord.getRandom(height, width);
        if (human != junkLocation && !robots.contains(junkLocation)) {
          junk.add(junkLocation);
          set = true;
        }
      }
    }
  }

  void _safeTeleport() {}
}
