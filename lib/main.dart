import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_controller.dart';
import 'auth/discourse_auth_service.dart';
import 'screens/channel_list_screen.dart';
import 'screens/login_screen.dart';
import 'services/token_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(
        authService: DiscourseAuthService(),
        storageService: TokenStorageService(),
      )..initialize(),
      child: const DoChatApp(),
    ),
  );
}

class DoChatApp extends StatelessWidget {
  const DoChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoChat MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          if (auth.isLoading && auth.token == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (auth.isLoggedIn) {
            return const ChannelListScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
