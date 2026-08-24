// mobile/lib/features/courses/presentation/widgets/secure_video_player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/services/api_service.dart';

class SecureVideoPlayer extends StatefulWidget {
  final int videoId;
  
  const SecureVideoPlayer({Key? key, required this.videoId}) : super(key: key);
  
  @override
  State<SecureVideoPlayer> createState() => _SecureVideoPlayerState();
}

class _SecureVideoPlayerState extends State<SecureVideoPlayer> {
  VideoPlayerController? _controller;
  
  @override
  void initState() {
    super.initState();
    _fetchStreamUrl();
  }
  
  Future<void> _fetchStreamUrl() async {
    try {
      final response = await ApiService.get('courses/videos/${widget.videoId}/stream');
      if (response['stream_url'] != null) {
        _controller = VideoPlayerController.network(
          response['stream_url'],
          httpHeaders: {
            'Authorization': 'Bearer ${await _getToken()}',
          },
        )..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
    }
  }
  
  Future<String> _getToken() async {
    final storage = const FlutterSecureStorage();
    return await storage.read(key: 'rahpeyman_token') ?? '';
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _controller != null && _controller!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
        : const Center(child: CircularProgressIndicator());
  }
}