import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uni_links/uni_links.dart';

import 'src/screens/welcome_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/services/auth_service.dart';
import 'src/config.dart';
import 'src/network/api_client.dart';
import 'src/screens/episode_watch_screen.dart';
import 'src/screens/anime_detail_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize services, e.g. auth auto-login will be checked in app
  final auth = AuthService();
  final autoLoggedIn = await auth.tryAutoLogin();

  // Initialize OneSignal if App ID is set
  if (AppConfig.oneSignalAppId.isNotEmpty) {
    // Initialize OneSignal (v5+ API)
    OneSignal.initialize(AppConfig.oneSignalAppId);
    // Notification click handler
    OneSignal.Notifications.addClickListener((event) {
      // Try to navigate based on notification additional data
      final additional = event.notification.additionalData;
      if (additional != null) {
        final episodeId = additional['episode_id'] ?? additional['episodeId'];
        final animeId = additional['anime_id'] ?? additional['animeId'];
        if (episodeId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) =>
                  EpisodeWatchScreen(episodeId: episodeId.toString()),
            ),
          );
        } else if (animeId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => AnimeDetailScreen(animeId: animeId.toString()),
            ),
          );
        }
      }
    });

    // Register device with backend (best-effort)
    try {
      // In OneSignal v5+, use pushSubscription to get the device id
      final osUserId = OneSignal.User.pushSubscription.id;
      if (osUserId != null && osUserId.isNotEmpty) {
        try {
          await ApiClient().dio.post(
            '/devices',
            data: {'onesignal_id': osUserId, 'platform': 'mobile'},
          );
        } catch (_) {
          // ignore backend registration errors
        }
      }
    } catch (_) {
      // ignore OneSignal errors
    }
  }

  runApp(ProviderScope(child: MyApp(autoLoggedIn: autoLoggedIn)));

  // Start listening for incoming deep links (while the app is running)
  _handleIncomingLinks();
}

void _handleIncomingLinks() {
  // initial link already handled elsewhere on navigation when needed
  uriLinkStream.listen(
    (Uri? uri) {
      if (uri == null) return;
      // e.g. myapp://episode/123 or https://api.voiplay.uz/episode/123
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        if (segments.length >= 2 && segments[0] == 'episode') {
          final id = segments[1];
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => EpisodeWatchScreen(episodeId: id),
            ),
          );
        } else if (segments.length >= 2 && segments[0] == 'anime') {
          final id = segments[1];
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => AnimeDetailScreen(animeId: id)),
          );
        }
      }
    },
    onError: (_) {
      // ignore link errors
    },
  );
}

class MyApp extends StatelessWidget {
  final bool autoLoggedIn;
  const MyApp({super.key, required this.autoLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'VoiPlay Tv',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeDecider(autoLoggedIn: autoLoggedIn),
    );
  }
}

class WelcomeDecider extends StatelessWidget {
  final bool autoLoggedIn;
  const WelcomeDecider({super.key, required this.autoLoggedIn});

  @override
  Widget build(BuildContext context) {
    if (autoLoggedIn) {
      // if user is already logged in, go to Home
      return const HomeScreen();
    }

    return const WelcomeScreen();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
