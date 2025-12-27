import 'package:flutter/material.dart';
import '../services/comment_service.dart';

class CommentsWidgetForEpisode extends StatefulWidget {
  final String episodeId;
  const CommentsWidgetForEpisode({super.key, required this.episodeId});

  @override
  State<CommentsWidgetForEpisode> createState() =>
      _CommentsWidgetForEpisodeState();
}

class _CommentsWidgetForEpisodeState extends State<CommentsWidgetForEpisode> {
  final _svc = CommentService();
  final _ctrl = TextEditingController();
  List<dynamic> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await _svc.fetchComments(episodeId: widget.episodeId);
      setState(() => _comments = d);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _post() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _svc.postComment(episodeId: widget.episodeId, text: text);
      _ctrl.clear();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in _comments)
          ListTile(
            title: Text(c['user']?['name'] ?? 'User'),
            subtitle: Text(c['comment_text'] ?? c['text'] ?? ''),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                ),
              ),
            ),
            IconButton(onPressed: _post, icon: const Icon(Icons.send)),
          ],
        ),
      ],
    );
  }
}
