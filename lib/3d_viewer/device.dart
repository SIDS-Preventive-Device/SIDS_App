import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Device3DWidget extends StatelessWidget {
  const Device3DWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Cube(
      onSceneCreated: (Scene scene) {
        scene.world.add(Object(fileName: 'assets/Board.obj'));
        scene.camera.zoom = 100;
      },
    );
  }
}
