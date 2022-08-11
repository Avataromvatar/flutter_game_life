import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:life_game/cell_widget.dart';
import 'package:life_game/lifegame.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LifeGame lifeGame = LifeGame(width: 10, height: 10);
  bool needStart = false;
  Widget _generateNewWidget() {
    return Container(
      width: Random().nextInt(40) + 40,
      height: Random().nextInt(40) + 20,
      color: Color(Random().nextInt(0xFFFFFF) | 0xFF000000),
    );
  }

  @override
  void initState() {
    // lifeGame.generateLife();
    super.initState();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<List<int>>>(
              stream: needStart ? lifeGame.startGame(timeINmsec: 2000) : null,
              builder: (context, snapshot) {
                // if (snapshot.hasData)
                return Container(
                    child: GridView.count(
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: lifeGame.height,
                  children: [
                    for (var i = 0; i < lifeGame.width; i++)
                      for (var i1 = 0; i1 < lifeGame.height; i1++)
                        CellWidget(
                          lifeGame,
                          i1,
                          i,
                          onTap: update,
                        ),
                  ],
                ));
                // else
                //   return Container();
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.all(4),
                  color: Colors.green,
                  onPressed: () async {
                    if (needStart) {
                      await lifeGame.stop();
                      lifeGame.clear();
                      needStart = false;
                    } else {
                      lifeGame.generateLife();
                      needStart = true;
                    }
                    setState(() {});
                  },
                  child: needStart ? Text('стоп') : Text('сгенерировать'),
                ),
                CupertinoButton(
                  padding: EdgeInsets.all(4),
                  color: Colors.blue,
                  onPressed: () async {
                    if (needStart) {
                      await lifeGame.stop();
                      lifeGame.clear();
                      needStart = false;
                    } else {
                      needStart = true;
                    }
                    setState(() {});
                  },
                  child: needStart ? Text('стоп') : Text('старт'),
                ),
              ],
            ),
          )
        ],
      ),
      // floatingActionButton:  // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
