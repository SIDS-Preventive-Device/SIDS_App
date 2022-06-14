import 'package:code_grav_app/ble/device_connector.dart';
import 'package:code_grav_app/ui_ble/details/interaction_tab.dart';
import 'package:code_grav_app/ui_ble/details/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => _DeviceDetail(
          device: device,
          disconnect: deviceConnector.disconnect,
        ),
      );
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    required this.device,
    required this.disconnect,
    Key? key,
  }) : super(key: key);

  final DiscoveredDevice device;
  final void Function(String deviceId) disconnect;
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          disconnect(device.id);
          return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(device.name),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.bluetooth_connected,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.find_in_page_sharp,
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                DeviceInteractionTab(
                  device: device,
                ),
                const DeviceLogTab(),
              ],
            ),
          ),
        ),
      );
}
