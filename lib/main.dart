import 'package:flutter/material.dart';
import 'game_state.dart';
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
  GameState gameState = GameState(gridHeight: height, gridWidth: width);

  @override
  void initState() {
    _newGame(1, 0);
    super.initState();
  }

  void _takeTurn(Direction d) {
    setState(() {
      if (!gameState.gameOver) {
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
    if (gameState.robots.isEmpty) {
      _newGame(gameState.level + 1, gameState.score);
    }
  }

  void _newGame(int newLevel, int newScore) {
    setState(() {
      gameState = gameState.fromExisting(
          score: newScore,
          human: Coord.getRandom(height, width),
          gameOver: false,
          level: newLevel,
          junk: []).placeRandomRobots(10);
    });
  }

  void _teleportHuman() {
    setState(() {
      if (!gameState.gameOver) {
        gameState = gameState.takeTeleportTurn();
        _runTurn();
      }
    });
  }

  void _moveHuman(Direction d) {
    gameState = gameState.takeMoveTurn(d);
  }

  void _moveRobots() {
    gameState = gameState.chaseHuman();
  }

  void _calculateCollisions() {
    gameState = gameState.calculateCollisions();
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
    if (gameState.gameOver && gameState.human.samePositionAs(r, c)) {
      return Center(
          child: Text(
        GameTheme.human,
        style: const TextStyle(color: Colors.red),
      ));
    }
    if (gameState.junk.contains(Coord(r, c))) {
      return Center(child: Text(GameTheme.junk));
    }
    if (gameState.robots.contains(Coord(r, c))) {
      return Center(child: Text(GameTheme.robot));
    }
    if (gameState.human.samePositionAs(r, c)) {
      return Center(child: Text(GameTheme.human));
    }
    return const Center(child: Text(''));
  }

  Widget _buildGameBody() {
    var level = gameState.level,
        gameOver = gameState.gameOver,
        score = gameState.score;
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
    gameState = gameState.spawnJunk();
  }

  void _safeTeleport() {}
}
