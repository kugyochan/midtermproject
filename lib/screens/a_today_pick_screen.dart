import 'package:flutter/material.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import '../widgets/state_views.dart';
import 'b_title_detail_screen.dart';
import 'root_tabs.dart';

/// A 오늘의 한 편 — v2의 대표 화면.
/// 목록 대신 "한 편 + 추천 이유"를 먼저 보여 주고, 다른 후보는 최대 2편만 더(쟁점 1).
class TodayPickScreen extends StatefulWidget {
  const TodayPickScreen({super.key, this.mood = 'default', this.index = 0, this.asTab = false});
  final String mood;
  final int index; // 몇 번째 후보인지 (0 · 1 · 2)
  final bool asTab;

  @override
  State<TodayPickScreen> createState() => _TodayPickScreenState();
}

class _TodayPickScreenState extends State<TodayPickScreen> {
  // STATE: S1 상황(mood)이 바뀌면 → A-1 상황 칩 · A-3 추천 카드 (지금은 화면을 새로 열어 GET)
  late final Future<List<Pick>> _future = Api.picks(widget.mood);

  void _reload({String? mood, int? index}) {
    final m = mood ?? widget.mood;
    if (widget.asTab) {
      reloadWith(context, RootTabs(initialIndex: 0, mood: m));
    } else {
      reloadWith(context, TodayPickScreen(mood: m, index: index ?? widget.index));
    }
  }

  Future<void> _chooseMood() async {
    final picked = await showMoodSheet(context, widget.mood);
    if (picked == null || picked == widget.mood || !mounted) return;
    // 상황이 바뀌면 1번 후보부터 다시 — 탭 화면으로 돌아간다.
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    nav.pushReplacement(instantRoute(RootTabs(initialIndex: 0, mood: picked)));
  }

  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder<List<Pick>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(message: '내 기록 47편으로 오늘의 한 편을 고르는 중이에요…'); // P01
        }
        if (snap.hasError) {
          return ErrorView(message: snap.error.toString(), onRetry: _reload); // P09
        }
        final picks = snap.data!;
        if (picks.isEmpty) {
          return EmptyView(
            icon: Icons.movie_filter_outlined,
            title: '이 상황에 맞는 추천이 아직 없어요',
            message: '기본 추천으로 다시 골라 볼까요?',
            actionLabel: '기본 추천 보기',
            onAction: () => _reload(mood: 'default', index: 0),
          );
        }
        final i = widget.index.clamp(0, picks.length - 1);
        return _PickLayout(
          pick: picks[i],
          position: i + 1,
          total: picks.length,
          moodLabel: _moodLabel(widget.mood),
          onChooseMood: _chooseMood,
          onNext: i + 1 < picks.length
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TodayPickScreen(mood: widget.mood, index: i + 1)),
                  )
              : null,
        );
      },
    );

    if (widget.asTab) return body;
    // A' 다른 후보 — push로 쌓이므로 뒤로 가기 하면 앞 후보로 돌아간다. // P03
    return Scaffold(appBar: AppBar(title: Text('다른 후보 ${widget.index + 1}')), body: body);
  }

  static String _moodLabel(String id) =>
      const {'default': '기본', 'short': '2시간 이내', 'light': '가볍게', 'deep': '몰입해서'}[id] ?? id;
}

class _PickLayout extends StatelessWidget {
  const _PickLayout({
    required this.pick,
    required this.position,
    required this.total,
    required this.moodLabel,
    required this.onChooseMood,
    required this.onNext,
  });
  final Pick pick;
  final int position;
  final int total;
  final String moodLabel;
  final VoidCallback onChooseMood;
  final VoidCallback? onNext;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TitleDetailScreen(titleId: pick.title.id, pick: pick)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // A-1 상황 칩 + A-2 후보 위치
    final header = Row(
      children: [
        ActionChip(
          avatar: const Icon(Icons.tune_rounded, size: 18, color: NwColors.accent),
          label: Text('지금 상황 · $moodLabel'),
          onPressed: onChooseMood,
          backgroundColor: NwColors.surfaceHigh,
          side: BorderSide.none,
        ),
        const Spacer(),
        Text('후보 $position / $total', style: text.bodyMedium), // P01
      ],
    );

    // A-3 추천 카드 — 넓은 화면에서는 포스터를 키운다
    Widget buildCard(double posterWidth) => InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetail(context),
          child: Ink(
            decoration: BoxDecoration(color: NwColors.surface, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PosterBox(item: pick.title, width: posterWidth),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('오늘 밤, 이 한 편', style: text.bodyMedium),
                      const SizedBox(height: 4),
                      Text(pick.title.title, style: text.headlineMedium),
                      const SizedBox(height: 6),
                      Text(pick.title.meta, style: text.bodyMedium),
                      const SizedBox(height: 12),
                      MatchBadge(percent: pick.matchPercent), // A-3a 취향 일치 // P02 · P10
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    // A-4 추천 이유 — 칩 3개 + AI 한 줄 // P01 · P08
    final reasons = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('왜 이 작품이냐면', style: text.titleMedium),
        const SizedBox(height: 10),
        ReasonChips(reasons: pick.reasons),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 18, color: NwColors.accent),
            const SizedBox(width: 8),
            Expanded(child: Text(pick.aiComment, style: text.bodyLarge)),
          ],
        ),
      ],
    );

    // A-5 결정 버튼 · A-6 다른 후보 · A-7 자세히
    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () => showWhereToWatch(context, pick.title),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('이걸로 볼래요'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: onNext, // P03 · 마지막 후보면 비활성
                child: Text(onNext == null ? '오늘 후보는 $total편까지' : '다른 후보 보기'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => _openDetail(context),
                child: const Text('자세히 보기'),
              ),
            ),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= Breakpoints.wide) {
          // 넓은 화면: 왼쪽 카드 · 오른쪽 이유와 결정 버튼
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    header,
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: buildCard(200)),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 4,
                          child: Column(children: [reasons, const SizedBox(height: 28), actions]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            header,
            const SizedBox(height: 12),
            buildCard(112),
            const SizedBox(height: 20),
            reasons,
            const SizedBox(height: 24),
            actions,
          ],
        );
      },
    );
  }
}
