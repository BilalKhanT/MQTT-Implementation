import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_impl/presentation/screens/msg_screen.dart';
import 'package:provider/provider.dart';
import 'core/manager/mqtt_manager.dart';
import 'dependency_inject/get_it.dart' as get_it;
import 'dependency_inject/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await get_it.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MQTTManager>(
      create: (context) =>getItInstance<MQTTManager>(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: MessageScreen(),
      ),
    );
  }
}

