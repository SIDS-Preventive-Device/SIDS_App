import 'dart:async';
import 'dart:developer';
import 'dart:convert';

import 'package:code_grav_app/3d_viewer/device.dart';
import 'package:code_grav_app/ble/device_connector.dart';
import 'package:code_grav_app/ble/device_interactor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class BatteryService {
  final uuid = "0000180f";
  final uuidBateryLevel = "00002a19";
  late DiscoveredService self;
  late QualifiedCharacteristic batteryLevel;

  BatteryService(
      {required String deviceId,
      required List<DiscoveredService> discoveredServices}) {
    self = discoveredServices
        .firstWhere((element) => element.serviceId.toString().startsWith(uuid));
    log("BatteryService found!");
    for (var element in self.characteristics) {
      if (element.characteristicId.toString().startsWith(uuidBateryLevel)) {
        batteryLevel = QualifiedCharacteristic(
            characteristicId: element.characteristicId,
            serviceId: self.serviceId,
            deviceId: deviceId);
        log("batteryLevel Characteristic found!");
      }
    }
  }
}

class PositionService {
  final uuid = "c47fb085";
  final uuidQuaternions = "e4544465";

  late DiscoveredService self;
  late QualifiedCharacteristic quaternions;

  PositionService(
      {required String deviceId,
      required List<DiscoveredService> discoveredServices}) {
    self = discoveredServices
        .firstWhere((element) => element.serviceId.toString().startsWith(uuid));
    log("PositionService found!");
    for (var element in self.characteristics) {
      if (element.characteristicId.toString().startsWith(uuidQuaternions)) {
        quaternions = QualifiedCharacteristic(
            characteristicId: element.characteristicId,
            serviceId: self.serviceId,
            deviceId: deviceId);
        log("quaternions Characteristic found!");
      }
    }
  }
}

class DeviceService {
  final uuid = "0000180a";
  final uuidFirmwareVersion = "00002a26";
  final uuidStatusCode = "00002bbb";

  late DiscoveredService self;
  late QualifiedCharacteristic firmwareVersion;
  late QualifiedCharacteristic statusCode;

  DeviceService(
      {required String deviceId,
      required List<DiscoveredService> discoveredServices}) {
    self = discoveredServices
        .firstWhere((element) => element.serviceId.toString().startsWith(uuid));
    log("DeviceService found!");
    for (var element in self.characteristics) {
      if (element.characteristicId.toString().startsWith(uuidFirmwareVersion)) {
        firmwareVersion = QualifiedCharacteristic(
            characteristicId: element.characteristicId,
            serviceId: self.serviceId,
            deviceId: deviceId);
        log("firmwareVersion Characteristic found!");
      } else if (element.characteristicId
          .toString()
          .startsWith(uuidStatusCode)) {
        statusCode = QualifiedCharacteristic(
            characteristicId: element.characteristicId,
            serviceId: self.serviceId,
            deviceId: deviceId);
        log("statusCode Characteristic found!");
      }
    }
  }
}

class DeviceDetailsScreen extends StatelessWidget {
  const DeviceDetailsScreen({required this.device, Key? key}) : super(key: key);

  final DiscoveredDevice device;

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, deviceConnector, connectionStateUpdate,
                  serviceDiscoverer, __) =>
              _DeviceDetailsScreen(
                  device: device,
                  bleDeviceConnector: deviceConnector,
                  connectionStateUpdate: connectionStateUpdate,
                  bleDeviceInteractor: serviceDiscoverer));
}

class _DeviceDetailsScreen extends StatefulWidget {
  const _DeviceDetailsScreen(
      {required this.device,
      required this.bleDeviceConnector,
      required this.connectionStateUpdate,
      required this.bleDeviceInteractor,
      Key? key})
      : super(key: key);

  final DiscoveredDevice device;
  final BleDeviceConnector bleDeviceConnector;
  final ConnectionStateUpdate connectionStateUpdate;
  final BleDeviceInteractor bleDeviceInteractor;

  @override
  State<_DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<_DeviceDetailsScreen> {
  late List<DiscoveredService> discoveredServices;
  late BatteryService batteryService;
  late PositionService positionService;
  late DeviceService deviceService;

  late String batteryLevelStr = "";
  late String quaternionsStr = "";
  late String firmwareVersionStr = "";
  late String statusCodeStr = "";
  late Timer timer =
      Timer.periodic(const Duration(seconds: 1), (Timer t) => setState(() {}));

  bool get deviceConnected =>
      widget.connectionStateUpdate.connectionState ==
      DeviceConnectionState.connected;

  Future<void> connect() async {
    log("@connect");
    widget.bleDeviceConnector.connect(widget.device.id);
    await Future.doWhile(() => Future.delayed(const Duration(milliseconds: 500))
        .then((_) => !deviceConnected));
    await discoverServices();
    timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) =>
            updateCharacteristicsValues().then((_) => setState(() {})));
  }

  Future<void> disconnect() async {
    widget.bleDeviceConnector.disconnect(widget.device.id);
    await Future.doWhile(() => deviceConnected);
    timer.cancel();
  }

  Future<void> updateCharacteristicsValues() async {
    log("@updateCharacteristicsValues:deviceConnected? $deviceConnected");
    if (!deviceConnected) {
      return;
    }

    const decoder = Utf8Decoder();
    List<int> batteryLevelBuff = await widget.bleDeviceInteractor
        .readCharacteristic(batteryService.batteryLevel);
    List<int> statusCodeBuff = await widget.bleDeviceInteractor
        .readCharacteristic(deviceService.statusCode);
    List<int> firmwareVersionBuff = await widget.bleDeviceInteractor
        .readCharacteristic(deviceService.firmwareVersion);
    List<int> quaternionsBuff = await widget.bleDeviceInteractor
        .readCharacteristic(positionService.quaternions);

    batteryLevelStr =
        batteryLevelBuff.isNotEmpty ? batteryLevelBuff[0].toString() : "UNK";
    statusCodeStr =
        statusCodeBuff.isNotEmpty ? statusCodeBuff[0].toString() : "UNK";

    firmwareVersionStr = decoder.convert(firmwareVersionBuff);
    quaternionsStr = decoder.convert(quaternionsBuff);

    dumpCharacteristicsValues();
  }

  void dumpCharacteristicsValues() {
    log("@dumpCharacteristicsValues");
    log("batteryLevel: $batteryLevelStr");
    log("firmwareVersion: $firmwareVersionStr");
    log("statusCode: $statusCodeStr");
    log("quaternions: $quaternionsStr");
  }

  Future<void> discoverServices() async {
    log("@discoverServices:deviceConnected? $deviceConnected");
    final result =
        await widget.bleDeviceInteractor.discoverServices(widget.device.id);
    discoveredServices = result;

    log("@discoverServices:found");
    log(discoveredServices
        .map((e) =>
            "ID: ${e.serviceId.toString()} Characteristics [${e.characteristicIds.map((x) => x.toString()).join(',')}]")
        .join('\n'));

    batteryService = BatteryService(
        deviceId: widget.device.id, discoveredServices: discoveredServices);
    positionService = PositionService(
        deviceId: widget.device.id, discoveredServices: discoveredServices);
    deviceService = DeviceService(
        deviceId: widget.device.id, discoveredServices: discoveredServices);
    log("@discoverServices:finished");

    await updateCharacteristicsValues();
  }

  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  void dispose() {
    timer.cancel();
    disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 500, width: 400, child: Device3DWidget()),
      Expanded(
          child: Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Row(children: <Widget>[
              Text('Device ${widget.device.name}'),
              const Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text('${widget.device.rssi}dB'),
            ]),
            subtitle: Text(widget.device.id)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(children: const <Widget>[
                  Text("Risk"),
                  Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Text("0%"),
                ]),
                Row(children: <Widget>[
                  const Text("Battery level"),
                  const Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Text(batteryLevelStr),
                ]),
                Row(children: <Widget>[
                  const Text("Quaternions"),
                  const Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Text(quaternionsStr),
                ]),
                Row(children: <Widget>[
                  const Text("Status code"),
                  const Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Text(statusCodeStr),
                ]),
                Row(children: <Widget>[
                  const Text("Firmware version"),
                  const Flexible(fit: FlexFit.tight, child: SizedBox()),
                  Text(firmwareVersionStr),
                ])
              ],
            )),
        const Flexible(fit: FlexFit.tight, child: SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text('Calibration'),
              onPressed: () {/* ... */},
            ),
            const SizedBox(width: 8),
            TextButton(
              child: const Text('Reconnect'),
              onPressed: () {
                disconnect().then((_) => connect());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ])))
    ]);
  }
}
