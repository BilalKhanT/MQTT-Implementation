import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../app_state/mqtt_app_state.dart';

class MQTTManager extends ChangeNotifier {

  final MQTTAppState _currentState = MQTTAppState();
  MqttServerClient? _client;
  late String _identifier;
  String? _host;
  String _topic = "";

  String _generateRandom() {
    var random = Random();
    const length = 8;
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void initializeMQTTClient({
    required String host,
  }) {

    _identifier = 'Client_${_generateRandom()}';
    _host = host;
    _client = MqttServerClient(_host!, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;
    _client!.onUnsubscribed = onUnsubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
        'willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;
  }

  String? get host => _host;
  MQTTAppState get currentState => _currentState;

  void connect() async {
    assert(_client != null);
    try {
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      updateState();
      await _client!.connect();
    } on Exception {
      disconnect();
    }
  }

  void disconnect() {
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    _currentState
        .setAppConnectionState(MQTTAppConnectionState.connectedSubscribed);
    updateState();
  }

  void onUnsubscribed(String? topic) {
    _currentState.clearText();
    _currentState
        .setAppConnectionState(MQTTAppConnectionState.connectedUnSubscribed);
    updateState();
  }

  void onDisconnected() {
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
    }
    _currentState.clearText();
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    updateState();
  }

  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    updateState();
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState.setReceivedText(pt);
      updateState();
    });
  }

  void subScribeTo(String topic) {
    _topic = topic;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  void unSubscribe(String topic) {
    _client!.unsubscribe(topic);
  }

  void unSubscribeFromCurrentTopic() {
    _client!.unsubscribe(_topic);
  }

  void updateState() {
    notifyListeners();
  }
}