import 'package:get_it/get_it.dart';
import '../core/manager/mqtt_manager.dart';

final getItInstance = GetIt.I;

Future<void> init() async {
  getItInstance.registerLazySingleton(() => MQTTManager());
}