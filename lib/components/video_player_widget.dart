import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:frame/theme/theme.dart';

/// 视频播放器组件
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      _controller.addListener(_videoListener);
      if (mounted) {
        setState(() => _initialized = true);
        if (widget.autoPlay) {
          _controller.play();
        }
      }
    } catch (e) {
      debugPrint('视频加载失败: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildError();
    }

    if (!_initialized) {
      return _buildLoading();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 视频
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            // 播放/暂停按钮
            if (_showControls || !_isPlaying)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            // 进度条
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildProgressBar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
        ),
      ),
      child: Row(
        children: [
          // 当前时间
          Text(
            _formatDuration(_controller.value.position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          // 进度条
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: Colors.white.withValues(alpha: 0.5),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 总时长
          Text(
            _formatDuration(_controller.value.duration),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildLoading() {
    return Container(
      height: 300,
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      height: 300,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 48, color: Colors.white54),
            const SizedBox(height: 12),
            const Text('视频加载失败', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 4),
            Text(
              '模拟器可能不支持此视频格式\n请在真机上测试',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
