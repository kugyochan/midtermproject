import 'package:flutter/material.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/state_views.dart';
import 'b_title_detail_screen.dart';
import 'root_tabs.dart';

/// C 내 기록 — 안쪽 TabBar(봤어요 · 보고 싶어요).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // C-1 기록 탭
          TabBar(
            indicatorColor: NwColors.accent,
            labelColor: NwColors.textPrimary,
            unselectedLabelColor: NwColors.textSecondary,
            tabs: [Tab(text: '봤어요'), Tab(text: '보고 싶어요')],
          ),
          Expanded(
            child: TabBarView(children: [_WatchedList(), _Watchlist()]),
          ),
        ],
      ),
    );
  }
}

class _WatchedList extends StatefulWidget {
  const _WatchedList();

  @override
  State<_WatchedList> createState() => _WatchedListState();
}

class _WatchedListState extends State<_WatchedList> {
  // STATE: S3 기록 목록이 바뀌면(평가 추가) → C-2 기록 카드 목록 · C-3 기록 요약
  late final Future<List<HistoryEntry>> _future = Api.history();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryEntry>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(message: '내 기록을 불러오는 중이에요…');
        }
        if (snap.hasError) {
          return ErrorView(
            message: snap.error.toString(),
            onRetry: () => reloadWith(context, const RootTabs(initialIndex: 1)),
          );
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return EmptyView(
            icon: Icons.history_rounded,
            title: '아직 기록이 없어요',
            message: '본 작품에 한 줄 평가를 남기면 추천이 정확해져요.',
            actionLabel: '오늘의 한 편 보러 가기',
            onAction: () => reloadWith(context, const RootTabs(initialIndex: 0)),
          );
        }
        return LayoutBuilder(
          builder: (context, c) {
            final columns = c.maxWidth >= 1200 ? 3 : (c.maxWidth >= Breakpoints.wide ? 2 : 1);
            final good = items.where((e) => e.rating == 'good').length;
            return CustomScrollView(
              slivers: [
                // C-3 기록 요약 (표시만, 계산 로직 아님: 받은 목록의 개수)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '최근 ${items.length}편 · 좋았어요 $good편',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                // C-2 기록 카드 목록 — 넓은 화면은 2~3열 그리드
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 112,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) => _HistoryCard(entry: items[i]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TitleDetailScreen(titleId: entry.title.id)),
      ),
      child: Ink(
        decoration: BoxDecoration(color: NwColors.surface, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PosterBox(item: entry.title, width: 60, radius: 8),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title.title, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${entry.watchedAt} · ${entry.title.type}', style: text.bodyMedium),
                  const SizedBox(height: 6),
                  RatingBadge(rating: entry.rating), // C-2a 한 줄 평가 // P06
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Watchlist extends StatefulWidget {
  const _Watchlist();

  @override
  State<_Watchlist> createState() => _WatchlistState();
}

class _WatchlistState extends State<_Watchlist> {
  late final Future<List<TitleItem>> _future = Api.watchlist();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TitleItem>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(message: '보고 싶은 작품을 불러오는 중이에요…');
        }
        if (snap.hasError) {
          return ErrorView(
            message: snap.error.toString(),
            onRetry: () => reloadWith(context, const RootTabs(initialIndex: 1)),
          );
        }
        final items = snap.data!;
        if (items.isEmpty) {
          // C-4 빈 상태 안내 // P10
          return EmptyView(
            icon: Icons.bookmark_add_outlined,
            title: '아직 보고 싶은 작품이 없어요',
            message: '고르기 어렵다면, 오늘의 한 편부터 시작해 보세요.',
            actionLabel: '오늘의 한 편 보러 가기',
            onAction: () => reloadWith(context, const RootTabs(initialIndex: 0)),
          );
        }
        return ListView(
          children: [
            for (final t in items) ListTile(title: Text(t.title), subtitle: Text(t.meta)),
          ],
        );
      },
    );
  }
}
