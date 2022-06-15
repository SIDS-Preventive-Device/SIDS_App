import 'package:code_grav_app/ble/device_connector.dart';
import 'package:code_grav_app/ble/device_interactor.dart';
import 'package:code_grav_app/ble/logger.dart';
import 'package:code_grav_app/ble/monitor.dart';
import 'package:code_grav_app/ble/scanner.dart';
import 'package:code_grav_app/calibration.dart';
import 'package:code_grav_app/home.dart';
import 'package:code_grav_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final bleLogger = BleLogger();
  final ble = FlutterReactiveBle();
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final connector = BleDeviceConnector(
    ble: ble,
    logMessage: bleLogger.addToLog,
  );
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: ble.discoverServices,
    readCharacteristic: ble.readCharacteristic,
    writeWithResponse: ble.writeCharacteristicWithResponse,
    writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: ble.subscribeToCharacteristic,
    logMessage: bleLogger.addToLog,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: scanner),
        Provider.value(value: monitor),
        Provider.value(value: connector),
        Provider.value(value: serviceDiscoverer),
        Provider.value(value: bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: const CodeGravApp(),
    ),
  );
}

class CodeGravApp extends StatelessWidget {
  const CodeGravApp({Key? key}) : super(key: key);

  static const String _title = 'CodeGrav App v0.1.1';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: ApplicationNavWidget(),
    );
  }
}

class ApplicationNavWidget extends StatefulWidget {
  const ApplicationNavWidget({Key? key}) : super(key: key);

  @override
  State<ApplicationNavWidget> createState() => ApplicationNavWidgetState();
}

class ApplicationNavWidgetState extends State<ApplicationNavWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(CodeGravApp._title),
        ),
        body: const Center(
          child: HomeWidget(),
        ));
  }
}
