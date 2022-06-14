import 'package:code_grav_app/ui_ble/device_list.dart';
import 'package:code_grav_app/ui_ble/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) =>
      Consumer<BleStatus?>(builder: (_, status, __) {
        if (status == BleStatus.ready) {
          return const SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                strokeWidth: 10,
              ));
        } else {
          return BleStatusScreen(status: status ?? BleStatus.unknown);
        }
      });
}
