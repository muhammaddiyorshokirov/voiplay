import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/services/api.dart';
import 'src/services/auth_service.dart';
import 'src/screens/welcome_screen.dart';
import 'src/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final auth = AuthService(api: api);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider.value(value: auth),
      ],
      child: const VoiPlayApp(),
    ),
  );
}

class VoiPlayApp extends StatefulWidget {
  const VoiPlayApp({super.key});
  @override
  State<VoiPlayApp> createState() => _VoiPlayAppState();
}

class _VoiPlayAppState extends State<VoiPlayApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      final auth = Provider.of<AuthService>(context, listen: false);
      auth.updateLastActive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiPlay Tv',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black87,
          selectedItemColor: Colors.red.shade400,
          unselectedItemColor: Colors.white54,
        ),
      ),
      home: const EntryRouter(),
    );
  }
}

class EntryRouter extends StatelessWidget {
  const EntryRouter({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (!auth.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.isLoggedIn) return const MainScreen();
    return const WelcomeScreen();
  }
}
