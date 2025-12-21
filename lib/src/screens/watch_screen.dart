import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';

import '../services/api.dart';
import '../services/auth_service.dart';
import '../services/app_cache_manager.dart';

class WatchScreen extends StatefulWidget {
  final String episodeId;
  final String? animeTitle;

  const WatchScreen({super.key, required this.episodeId, this.animeTitle});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  WebViewController? webViewController;
  Map<String, dynamic>? episode;
  bool isLoading = true;
  bool unsupportedSource = false;
  bool _playerLoading = false;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  int likes = 0;
  int dislikes = 0;
  int userVote = 0;
  List<dynamic> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _postingComment = false;

  List<dynamic> episodeList = [];
  int currentEpisodeIndex = -1;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _loadEpisode();
  }

  void _initWebView() {
    if (!kIsWeb) {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => isLoading = false);
            },
          ),
        );
    }
  }

  bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _loadEpisode() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final data = await api.getEpisode(widget.episodeId);
      if (mounted) {
        setState(() {
          episode = data;
          isLoading = false;
          unsupportedSource = false;
          if (episode != null) {
            likes = _safeInt(episode!['likes']);
            dislikes = _safeInt(episode!['dislikes']);
          }
        });

        // record watch history (episode id)
        final auth = Provider.of<AuthService>(context, listen: false);
        auth.addToHistory(widget.episodeId);

        final isEpPremium = _safeBool(episode?['is_premium']);
        if (!isEpPremium || auth.premium) {
          if (episode?['video_url'] != null) {
            await _loadEpisodeList();
            await _loadVideoUrl(episode!['video_url']);
          }
        } else {
          setState(() {
            _playerLoading = false;
            _videoController?.dispose();
            _videoController = null;
            _chewieController?.dispose();
            _chewieController = null;
          });
        }
      }

      await _loadComments();
      await _loadSavedVote();
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadVideoUrl(String videoUrl) async {
    if (videoUrl.isEmpty) return;

    final low = videoUrl.toLowerCase();
    if (low.contains('youtube.com') ||
        low.contains('youtu.be') ||
        low.contains('mover.uz')) {
      final embedUrl = low.contains('youtube') || low.contains('youtu.be')
          ? _getEmbedUrl(videoUrl)
          : videoUrl;
      final html = _buildIframeHtml(embedUrl);
      if (!kIsWeb) {
        webViewController?.loadHtmlString(html);
      }
    } else {
      setState(() {
        _playerLoading = true;
        unsupportedSource = false;
      });
      try {
        final file = await AppCacheManager.instance.getSingleFile(videoUrl);
        _videoController = VideoPlayerController.file(file);
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
        );
        setState(() {
          _playerLoading = false;
        });
      } catch (e) {
        try {
          _videoController =
              VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          await _videoController!.initialize();
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            allowFullScreen: true,
          );
          setState(() {
            _playerLoading = false;
          });
        } catch (e2) {
          setState(() {
            _playerLoading = false;
            unsupportedSource = true;
          });
        }
      }
    }
  }

  String _getEmbedUrl(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final videoId = _extractYoutubeId(url);
      if (videoId.isNotEmpty) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    }
    return url;
  }

  Future<void> _loadEpisodeList() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final animeId =
          episode?['anime_id']?.toString() ?? episode?['anime']?.toString();
      if (animeId == null) return;
      final eps = await api.getEpisodesByAnime(animeId);
      if (eps.isEmpty) return;
      setState(() {
        episodeList = eps;
        currentEpisodeIndex =
            eps.indexWhere((e) => e['id']?.toString() == widget.episodeId);
      });
    } catch (e) {
      // ignore errors
    }
  }

  String _buildIframeHtml(String embedUrl) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { margin: 0; padding: 0; background: black; }
        .player { position: relative; padding-top: 56.25%; }
        .player iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
      </style>
    </head>
    <body>
      <div class="player"><iframe src="$embedUrl" allowfullscreen="true" frameborder="0"></iframe></div>
    </body>
    </html>
    ''';
  }

  String _extractYoutubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final bool isUserPremium = _safeBool(auth.premium);
    final bool isEpisodePremium = _safeBool(episode?['is_premium']);
    final canWatch = episode == null || !isEpisodePremium || isUserPremium;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.red.shade400),
        ),
      );
    }

    if (episode == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const Text('Xato'),
        ),
        body: const Center(
          child: Text(
            'Episod topilmadi',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (!canWatch) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text(
            'E${episode!['episode_number'] ?? ''}',
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 20),
              const Text(
                'Faqat Premium obunachilar uchun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bu episodeni ko\'rish uchun Premium obunaga ehtiyoj',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                ),
                child: const Text(
                  'Orqaga',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black87],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black87,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  'E${episode!['episode_number'] ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        child: unsupportedSource
                            ? const Center(
                                child: Text(
                                  'Video manbasi qo\'llab-quvvatlanmaydi',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : (_playerLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : (!kIsWeb &&
                                        _chewieController != null &&
                                        _videoController != null &&
                                        _videoController!.value.isInitialized)
                                    ? Chewie(controller: _chewieController!)
                                    : (kIsWeb
                                        ? const Center(
                                            child: Text(
                                              'Video Web-da iframe orqali ishlaydi',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : (webViewController != null
                                            ? WebViewWidget(
                                                controller: webViewController!,
                                              )
                                            : const SizedBox()))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode!['title'] ?? 'Noma\'lum',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Davomiyligi: ${_formatDuration(_safeInt(episode!['duration']))}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _actionButton(
                                Icons.skip_previous,
                                'Oldingi',
                                Colors.white,
                                onTap: _goToPreviousEpisode,
                              ),
                              _actionButton(
                                Icons.thumb_up_outlined,
                                'Like $likes',
                                Colors.green,
                                onTap: _handleLike,
                              ),
                              _actionButton(
                                Icons.thumb_down_outlined,
                                'Dislike $dislikes',
                                Colors.red,
                                onTap: _handleDislike,
                              ),
                              _actionButton(
                                Icons.share,
                                'Ulashish',
                                Colors.blue,
                                onTap: _handleShare,
                              ),
                              _actionButton(
                                Icons.skip_next,
                                'Keyingi',
                                Colors.white,
                                onTap: _goToNextEpisode,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _commentsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _commentsSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Izohlar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          comments.isEmpty
              ? const Text('Hali izoh yo\'q',
                  style: TextStyle(color: Colors.white70))
              : Column(
                  children: comments.map((c) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        c['author'] ?? 'Foydalanuvchi',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        c['content'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Izoh yozing',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.02),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _postingComment ? null : _postComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                ),
                child: _postingComment
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Yubor'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLike() async {
    if (episode == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.userId == null) return;
    // Prevent double likes by client; allow switching from dislike -> like
    if (userVote == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Siz bu epizodga allaqachon like bergansiz'),
        ),
      );
      return;
    }
    setState(() {
      if (userVote == -1) {
        dislikes = (dislikes - 1).clamp(0, 1 << 31);
      }
      likes += 1;
      userVote = 1;
    });
    final ok = await Provider.of<ApiService>(
      context,
      listen: false,
    ).likeEpisode(episode!['id'], auth.userId!);
    if (!ok) {
      setState(() {
        likes = (likes - 1).clamp(0, 1 << 31);
        if (userVote == 1) userVote = 0;
      });
    } else {
      await _saveVoteLocally(1);
    }
  }

  void _handleDislike() async {
    if (episode == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.userId == null) return;
    // Prevent double dislikes by client; allow switching from like -> dislike
    if (userVote == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Siz bu epizodga allaqachon dislike bergansiz'),
        ),
      );
      return;
    }
    setState(() {
      if (userVote == 1) {
        likes = (likes - 1).clamp(0, 1 << 31);
      }
      dislikes += 1;
      userVote = -1;
    });
    final ok = await Provider.of<ApiService>(
      context,
      listen: false,
    ).dislikeEpisode(episode!['id'], auth.userId!);
    if (!ok) {
      setState(() {
        dislikes = (dislikes - 1).clamp(0, 1 << 31);
        if (userVote == -1) userVote = 0;
      });
    } else {
      await _saveVoteLocally(-1);
    }
  }

  Future<void> _loadComments() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final data = await api.getEpisodeComments(widget.episodeId);
      if (mounted) setState(() => comments = data);
    } catch (e) {
      // ignore errors for now
    }
  }

  Future<void> _postComment() async {
    if (episode == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izoh yuborish uchun tizimga kiring')),
      );
      return;
    }
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _postingComment = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);

      final ok = await api.postEpisodeComment(
        widget.episodeId,
        auth.userId!,
        text,
      );

      if (ok) {
        _commentController.clear();
        // Optimistically add comment locally
        final newComment = {
          'author': auth.username ?? 'Foydalanuvchi',
          'content': text,
        };
        setState(() {
          comments.insert(0, newComment);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izoh yuborilmadi')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izoh yuborishda xato: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _postingComment = false);
    }
  }

  Future<void> _loadSavedVote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'episode_vote_${widget.episodeId}';
      final v = prefs.getString(key);
      if (v != null) {
        userVote = int.tryParse(v) ?? 0;
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveVoteLocally(int v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'episode_vote_${widget.episodeId}';
      await prefs.setString(key, v.toString());
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Noma\'lum';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '$m daqiqa${s > 0 ? ' $s sek' : ''}';
    }
    return '$s sek';
  }

  void _goToPreviousEpisode() {
    if (currentEpisodeIndex > 0 && episodeList.isNotEmpty) {
      final prev = episodeList[currentEpisodeIndex - 1];
      if (prev != null && prev['id'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WatchScreen(
              episodeId: prev['id'].toString(),
              animeTitle: episode?['anime_title']?.toString(),
            ),
          ),
        );
      }
    }
  }

  void _goToNextEpisode() {
    if (currentEpisodeIndex >= 0 &&
        currentEpisodeIndex < episodeList.length - 1) {
      final next = episodeList[currentEpisodeIndex + 1];
      if (next != null && next['id'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WatchScreen(
              episodeId: next['id'].toString(),
              animeTitle: episode?['anime_title']?.toString(),
            ),
          ),
        );
      }
    }
  }

  void _handleShare() async {
    if (episode == null) return;
    final id = episode!['id']?.toString() ?? widget.episodeId;
    final deeplink = 'https://app.voiplay.uz/watch/$id';
    try {
      await Share.share(deeplink);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Share not available')));
    }
  }
}
