import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frame/models/note.dart';
import 'package:frame/components/note_card.dart';
import 'package:frame/router/router.dart';
import 'package:frame/theme/theme.dart';

/// 笔记列表加载函数类型
typedef NoteListLoader = Future<NoteListResponse?> Function({int? cursor});

/// 通用笔记网格组件
class NoteGrid extends StatefulWidget {
  final NoteListLoader loader;
  final String emptyText;
  final VoidCallback? onRefresh;
  final bool showTopBadge; // 是否显示置顶标签

  const NoteGrid({
    super.key,
    required this.loader,
    this.emptyText = '暂无笔记',
    this.onRefresh,
    this.showTopBadge = true,
  });

  @override
  State<NoteGrid> createState() => NoteGridState();
}

class NoteGridState extends State<NoteGrid> with AutomaticKeepAliveClientMixin {
  List<NoteItemModel> _notes = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int? _nextCursor;

  @override
  bool get wantKeepAlive => true; // 保持状态，避免切换 Tab 时重新加载

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;

    if (!loadMore) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await widget.loader(
        cursor: loadMore ? _nextCursor : null,
      );
      if (mounted) {
        setState(() {
          if (response != null) {
            if (loadMore) {
              _notes.addAll(response.notes ?? []);
            } else {
              _notes = response.notes ?? [];
            }
            _nextCursor = response.nextCursor;
            _hasMore = response.hasMore;
          } else {
            // response 为 null 时，设置为空列表
            if (!loadMore) {
              _notes = [];
            }
            _hasMore = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('NoteGrid 加载失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 刷新列表
  Future<void> refresh() async {
    _nextCursor = null;
    _hasMore = true;
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用 super.build
    
    if (_isLoading && _notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(widget.emptyText, style: AppTextStyles.hint),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            _hasMore &&
            !_isLoading) {
          _loadNotes(loadMore: true);
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            return NoteCard(
              note: _notes[index],
              onTap: () => AppRouter.goNoteDetail(_notes[index].noteId),
              showTopBadge: widget.showTopBadge,
            );
          },
        ),
      ),
    );
  }
}
