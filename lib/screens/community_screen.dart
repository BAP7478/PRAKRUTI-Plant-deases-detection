import 'package:flutter/material.dart';
import '../localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class CommunityPost {
  final String userId;
  final String userName;
  final String content;
  final String? imagePath;
  final DateTime timestamp;
  final List<String> likes;
  final List<CommunityComment> comments;

  CommunityPost({
    required this.userId,
    required this.userName,
    required this.content,
    this.imagePath,
    required this.timestamp,
    List<String>? likes,
    List<CommunityComment>? comments,
  })  : likes = likes ?? [],
        comments = comments ?? [];
}

class CommunityComment {
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;

  CommunityComment({
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<CommunityPost> _posts = [];
  bool _isLoading = false;
  final _currentUserId = 'user123'; // TODO: Get from auth
  String? _selectedImagePath;
  final _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _posts.addAll([
        CommunityPost(
          userId: 'user1',
          userName: 'Rajesh Patel',
          content:
              'My tomato plants are showing some unusual spots. Any suggestions?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          comments: [
            CommunityComment(
              userId: 'user2',
              userName: 'Amit Shah',
              content:
                  'It could be early blight. Try using copper-based fungicide.',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ],
        ),
        CommunityPost(
          userId: 'user3',
          userName: 'Priya Desai',
          content:
              'Great harvest this season! Thanks to everyone who helped with advice.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      _isLoading = false;
    });
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    final post = CommunityPost(
      userId: _currentUserId,
      userName: 'Current User', // TODO: Get actual user name
      content: _postController.text,
      imagePath: _selectedImagePath,
      timestamp: DateTime.now(),
    );

    setState(() {
      _posts.insert(0, post);
      _postController.clear();
      _selectedImagePath = null;
    });

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void _showCommentDialog(CommunityPost post) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('add_comment') ??
                    'ટિપ્પણી ઉમેરો',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                          ?.translate('write_comment') ??
                      'ટિપ્પણી લખો...',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                        AppLocalizations.of(context)?.translate('cancel') ??
                            'રદ કરો'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (commentController.text.trim().isNotEmpty) {
                        setState(() {
                          post.comments.add(
                            CommunityComment(
                              userId: _currentUserId,
                              userName: 'Current User', // TODO: Get actual name
                              content: commentController.text,
                              timestamp: DateTime.now(),
                            ),
                          );
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('post') ??
                          'પોસ્ટ',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)?.translate('community') ?? 'સમુદાય'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalizations.of(context)
                            ?.translate('search_coming_soon') ??
                        'Search coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) => _buildPostCard(_posts[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final isLiked = post.likes.contains(_currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                post.userName[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(post.userName),
            subtitle: Text(_formatTimestamp(post.timestamp)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Implement post options
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post.content),
          ),
          if (post.imagePath != null) ...[
            const SizedBox(height: 8),
            kIsWeb
                ? Image.network(
                    post.imagePath!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(post.imagePath!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
          ],
          ButtonBar(
            children: [
              TextButton.icon(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                label: Text(post.likes.length.toString()),
                onPressed: () {
                  setState(() {
                    if (isLiked) {
                      post.likes.remove(_currentUserId);
                    } else {
                      post.likes.add(_currentUserId);
                    }
                  });
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.comment),
                label: Text(post.comments.length.toString()),
                onPressed: () => _showCommentDialog(post),
              ),
              TextButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                onPressed: () {
                  // TODO: Implement sharing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing coming soon!')),
                  );
                },
              ),
            ],
          ),
          if (post.comments.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post.comments
                    .take(2)
                    .map((comment) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  comment.userName[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(comment.content),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            if (post.comments.length > 2)
              TextButton(
                onPressed: () => _showCommentDialog(post),
                child: Text(
                  '${AppLocalizations.of(context)?.translate('view_all') ?? 'બધા જુઓ'} ${post.comments.length} ${AppLocalizations.of(context)?.translate('comments') ?? 'ટિપ્પણીઓ'}',
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)?.translate('create_post') ??
                      'પોસ્ટ બનાવો',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                            ?.translate('whats_on_your_mind') ??
                        'તમારા મનમાં શું છે?',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                if (_selectedImagePath != null) ...[
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      kIsWeb
                          ? Image.network(
                              _selectedImagePath!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedImagePath!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedImagePath = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_camera),
                      onPressed: _pickImage,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _postController.clear();
                        _selectedImagePath = null;
                        Navigator.pop(context);
                      },
                      child: Text(
                          AppLocalizations.of(context)?.translate('cancel') ??
                              'રદ કરો'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('post') ??
                            'પોસ્ટ',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
