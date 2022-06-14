import 'package:flutter/material.dart';

class CalibrationWidget extends StatefulWidget {
  const CalibrationWidget({Key? key}) : super(key: key);

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

class _CalibrationWidgetState extends State<CalibrationWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        Text('Deliver features faster'),
        Text('Craft beautiful UIs')
      ],
    );
  }
}
