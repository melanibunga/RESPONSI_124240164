import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/bookmark_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cek sesi login yang tersimpan di Shared Preferences
  final user = await AuthService.currentUser();
  if (user != null) {
    await BookmarkStore.instance.load(user);
  }
  runApp(MyApp(startLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool startLoggedIn;
  const MyApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Explorer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Halaman utama hanya bisa diakses setelah login
      home: startLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
