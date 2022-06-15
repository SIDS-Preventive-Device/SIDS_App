import 'dart:developer';

import 'package:code_grav_app/ble/device_connector.dart';
import 'package:code_grav_app/ble/device_interactor.dart';
import 'package:code_grav_app/ble/scanner.dart';
import 'package:code_grav_app/device.dart';
import 'package:code_grav_app/ui_ble/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _HomeWidget(
            scannerState: bleScannerState ??
                const BleScannerState(
                  discoveredDevices: [],
                  scanIsInProgress: false,
                ),
            startScan: bleScanner.startScan,
            stopScan: bleScanner.stopScan),
      );
}

class _HomeWidget extends StatefulWidget {
  const _HomeWidget(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan});

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<_HomeWidget> {
  bool get gravDeviceFound =>
      widget.scannerState.scanIsInProgress &&
      widget.scannerState.discoveredDevices
          .any((element) => element.name == "GravDevice");

  DiscoveredDevice get bleGravDeviceInstance =>
      widget.scannerState.discoveredDevices
          .firstWhere((element) => element.name == "GravDevice");

  @override
  void initState() {
    super.initState();
    widget.startScan([]);
  }

  @override
  Widget build(BuildContext context) => Consumer6<
              BleScanner,
              BleScannerState?,
              BleDeviceConnector,
              ConnectionStateUpdate,
              BleDeviceInteractor,
              BleStatus?>(
          builder: (_, bleScanner, bleScannerState, deviceConnector,
              connectionStateUpdate, serviceDiscoverer, status, __) {
        if (status == BleStatus.ready) {
          if (!gravDeviceFound) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              strokeWidth: 10,
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("Scanning...",
                            style: Theme.of(context).textTheme.headline6)),
                    Flexible(
                        child: ListView(
                            children: widget.scannerState.discoveredDevices
                                .map(
                                  (device) => ListTile(
                                    title: Text(device.name),
                                    subtitle: Text(
                                        "${device.id}\nRSSI: ${device.rssi}"),
                                  ),
                                )
                                .toList()))
                  ])),
            );
          }
          return DeviceDetailsScreen(device: bleGravDeviceInstance);
        } else {
          return BleStatusScreen(status: status ?? BleStatus.unknown);
        }
      });
}
