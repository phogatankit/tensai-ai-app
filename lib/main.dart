import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tensai/features/chat/provider/msg_provider.dart';
import 'package:tensai/splash/splash.dart';

  //  main function ab async ban gaya hai
Future<void> main() async {
  //  Flutter engine ko pehle initialize karna padta hai
  WidgetsFlutterBinding.ensureInitialized();
  //  Yahan humari .env file memory mein load ho rahi hai
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(create: (context) => MessageProvider(), child: const MyApp(),),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}