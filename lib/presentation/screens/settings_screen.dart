import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state/mqtt_app_state.dart';
import '../../core/manager/mqtt_manager.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _hostTextController = TextEditingController();
  late MQTTManager _manager;

  @override
  void dispose() {
    _hostTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _manager = Provider.of<MQTTManager>(context);
    return Scaffold(
        appBar: _buildAppBar(context) as PreferredSizeWidget?,
        body: _buildColumn(_manager));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Settings', style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.grey.shade900,
    );
  }

  Widget _buildColumn(MQTTManager manager) {
    return _buildEditableColumn(manager.currentState);
  }

  Widget _buildEditableColumn(MQTTAppState currentAppState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          buildTextField(_hostTextController, 'Enter broker address',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildConnectButtonFrom(currentAppState.getAppConnectionState)
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if ((controller == _hostTextController &&
        state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    } else if (controller == _hostTextController && _manager.host != null) {
      _hostTextController.text = _manager.host!;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildConnectButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null,
            child: const Text('Connect'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: state != MQTTAppConnectionState.disconnected
                ? _disconnect
                : null,
            child: const Text('Disconnect'),
          ),
        ),
      ],
    );
  }

  void _configureAndConnect() {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    _manager.initializeMQTTClient(
        host: _hostTextController.text, identifier: osPrefix);
    _manager.connect();
  }

  void _disconnect() {
    _manager.disconnect();
  }
}