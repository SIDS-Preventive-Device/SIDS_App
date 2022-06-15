import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Device3DWidget extends StatefulWidget {
  const Device3DWidget({Key? key}) : super(key: key);

  @override
  Device3DWidgetState createState() => Device3DWidgetState();
}

class Device3DWidgetState extends State<Device3DWidget>
    with SingleTickerProviderStateMixin {
  late Scene _scene;
  Object? _bunny;
  late AnimationController _controller;
  final double _ambient = 0.1;
  final double _diffuse = 0.8;
  final double _specular = 0.5;

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    scene.camera.position.z = 10;
    scene.light.position.setFrom(Vector3(0, 10, 10));
    scene.light.setColor(Colors.white, _ambient, _diffuse, _specular);
    _bunny = Object(
        position: Vector3(0, -2, 0),
        scale: Vector3(10.0, 10.0, 10.0),
        lighting: true,
        fileName: 'assets/Bunny.obj');
    scene.world.add(_bunny!);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 30000), vsync: this)
      ..addListener(() {
        if (_bunny != null) {
          _bunny!.rotation.y = _controller.value * 360;
          _bunny!.updateTransform();
          _scene.update();
        }
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Cube(onSceneCreated: _onSceneCreated, interactive: false)
      ],
    );
  }
}
