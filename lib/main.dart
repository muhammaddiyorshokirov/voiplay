import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/services/api.dart';
import 'src/services/auth_service.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'src/screens/welcome_screen.dart';
import 'src/screens/main_screen.dart';
import 'src/screens/news_detail_screen.dart';
import 'src/screens/anime_detail_screen.dart';
import 'src/screens/watch_screen.dart';

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
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // listen for incoming deep links
    _initUniLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initUniLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) _handleUri(initialUri);
    } catch (e) {
      // ignore
    }
    _sub = uriLinkStream.listen((uri) {
      if (uri != null) _handleUri(uri);
    }, onError: (err) {
      // ignore
    });
  }

  void _handleUri(Uri uri) {
    // Examples: https://link.voiplay/news/{id}, uz.voiplay.tv://news/{id}
    final segments = uri.pathSegments;
    if (segments.isEmpty) return;
    try {
      if (segments.length >= 2) {
        final type = segments[0];
        final id = segments[1];
        if (type == 'news') {
          _navKey.currentState?.push(MaterialPageRoute(
              builder: (_) =>
                  NewsDetailScreen(newsId: id, heroTag: 'news-$id')));
        } else if (type == 'anime') {
          _navKey.currentState?.push(MaterialPageRoute(
              builder: (_) => AnimeDetailScreen(animeId: id)));
        } else if (type == 'episode') {
          _navKey.currentState?.push(
              MaterialPageRoute(builder: (_) => WatchScreen(episodeId: id)));
        }
      }
    } catch (e) {
      // ignore
    }
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
      navigatorKey: _navKey,
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
