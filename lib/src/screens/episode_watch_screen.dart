import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/episode_service.dart';
import '../network/api_client.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '_comments_widget_episode.dart';

class EpisodeWatchScreen extends StatefulWidget {
  final String episodeId;
  const EpisodeWatchScreen({super.key, required this.episodeId});

  @override
  State<EpisodeWatchScreen> createState() => _EpisodeWatchScreenState();
}

class _EpisodeWatchScreenState extends State<EpisodeWatchScreen> {
  final _service = EpisodeService();
  Map<String, dynamic>? _episode;
  VideoPlayerController? _videoPlayerController;
  bool _loading = true;
  // WebView fallback for iframe-hosted videos (mover.uz, YouTube)
  bool _useWebView = false;
  WebViewController? _webController;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _webController = null;
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getEpisode(widget.episodeId);
      setState(() => _episode = data);

      final url = data['stream_url'] ?? data['video_url'] ?? data['url'];

      // If the episode is hosted on an iframe provider (mover.uz or YouTube), use WebView
      if (url != null) {
        final host = Uri.tryParse(url)?.host ?? '';
        if (host.contains('mover.uz') ||
            host.contains('youtube.com') ||
            host.contains('youtu.be')) {
          setState(() {
            _useWebView = true;
          });
          _webController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(url));
          return;
        }
      }

      // Using video_player + chewie for playback
      // resume position
      final prefs = await SharedPreferences.getInstance();
      final pos = prefs.getInt('episode_pos_${widget.episodeId}') ?? 0;

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController?.initialize();
      if (pos > 0) {
        await _videoPlayerController?.seekTo(Duration(milliseconds: pos));
      }
      // autoplay
      await _videoPlayerController?.play();

      // Listen to position and save periodically (best-effort)
      _videoPlayerController?.addListener(() async {
        final p = _videoPlayerController?.value.position;
        if (p != null && p.inSeconds % 5 == 0) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
            'episode_pos_${widget.episodeId}',
            p.inMilliseconds,
          );
        }
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_episode == null) {
      return const Scaffold(body: Center(child: Text('Epizod topilmadi')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_episode?['title'] ?? 'Epizod')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _useWebView
                ? (_webController != null
                      ? WebViewWidget(controller: _webController!)
                      : const Center(child: CircularProgressIndicator()))
                : (_videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized
                      ? VideoPlayer(_videoPlayerController!)
                      : const Center(child: Text('Video yuklanmadi'))),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _likeEpisode,
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Yoqtirish'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openComments,
                  icon: const Icon(Icons.comment),
                  label: const Text('Izohlar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Text(_episode?['description'] ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12),
        child: CommentsWidgetForEpisode(episodeId: widget.episodeId),
      ),
    );
  }

  Future<void> _likeEpisode() async {
    try {
      await ApiClient().dio.post(
        '/likes',
        data: {'episode_id': widget.episodeId},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yoqildi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }
}
