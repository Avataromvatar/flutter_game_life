import 'package:flutter/material.dart';
import 'package:life_game/lifegame.dart';

class CellWidget extends StatefulWidget {
  final int x, y;
  final LifeGame lifeGame;
  final Function()? onTap;
  const CellWidget(this.lifeGame, this.x, this.y, {super.key, this.onTap});
  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> {
  @override
  Widget build(BuildContext context) {
    int cell = widget.lifeGame.currentMap[widget.x][widget.y];
    Color color;
    if (cell & 2 == 2 && cell & 1 == 1)
      color = Colors.lightGreen;
    else if (cell & 2 != 2 && cell & 1 == 1)
      color = Colors.green;
    else if (cell & 2 == 2 && cell & 1 != 1)
      color = Colors.green[100]!;
    else
      color = Colors.grey;

    return GestureDetector(
      onTap: () {
        widget.lifeGame.currentMap[widget.x][widget.y] |= 1;
        widget.onTap?.call();
      },
      child: Container(color: color),
    );
  }
}
