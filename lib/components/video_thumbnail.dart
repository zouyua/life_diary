import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:frame/theme/theme.dart';

/// 视频缩略图组件 - 显示视频第一帧
class VideoThumbnail extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final BoxFit fit;

  const VideoThumbnail({
    super.key,
    required this.videoUrl,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      // 跳到第一帧并暂停
      await _controller!.seekTo(Duration.zero);
      await _controller!.pause();
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      // 模拟器可能不支持视频解码，静默处理
      debugPrint('视频缩略图加载失败（模拟器可能不支持）: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildPlaceholder();
    }

    if (!_initialized || _controller == null) {
      return _buildLoading();
    }

    // 使用 AspectRatio 和 ClipRect 避免绿线问题
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: widget.height ?? 150,
      color: AppColors.background,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height ?? 150,
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 48, color: Colors.white70),
            SizedBox(height: 4),
            Text('视频', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
