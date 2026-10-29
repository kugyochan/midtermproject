import 'package:flutter/material.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import '../widgets/state_views.dart';

/// B 작품 상세 — 결정에 필요한 정보만: 취향 일치 · 추천 이유 · 어디서 볼까 · 스포일러 없는 소개.
class TitleDetailScreen extends StatefulWidget {
  const TitleDetailScreen({super.key, required this.titleId, this.pick});
  final String titleId;
  final Pick? pick; // 오늘의 한 편에서 왔을 때만 추천 이유를 함께 보여 준다.

  @override
  State<TitleDetailScreen> createState() => _TitleDetailScreenState();
}

class _TitleDetailScreenState extends State<TitleDetailScreen> {
  late final Future<TitleItem> _future = Api.title(widget.titleId); // GET /titles/:id

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // B-1 상단 제목 바 — 뒤로 가기 + 홈으로 // P03 · 리뷰 #5 "홈으로 다시 가는 방법이 불편"
        title: const Text('작품 상세'),
        actions: [
          IconButton(
            tooltip: '오늘의 한 편으로',
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: FutureBuilder<TitleItem>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(message: '작품 정보를 불러오는 중이에요…');
          }
          if (snap.hasError) {
            return ErrorView(
              message: snap.error.toString(),
              onRetry: () => reloadWith(context, TitleDetailScreen(titleId: widget.titleId, pick: widget.pick)),
            );
          }
          return _DetailBody(item: snap.data!, pick: widget.pick);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item, this.pick});
  final TitleItem item;
  final Pick? pick;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // B-2 포스터 · B-3 기본 정보 · B-4 취향 일치
    final top = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: PosterBox(item: item, width: 180, radius: 18)),
        const SizedBox(height: 16),
        Text(item.title, style: text.headlineMedium),
        const SizedBox(height: 6),
        Text(item.meta, style: text.bodyMedium),
        if (pick != null) ...[
          const SizedBox(height: 12),
          MatchBadge(percent: pick!.matchPercent, large: true),
        ],
      ],
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pick != null) ...[
          // B-5 추천 이유 상세
          Text('추천 이유', style: text.titleMedium),
          const SizedBox(height: 8),
          ReasonChips(reasons: pick!.reasons),
          const SizedBox(height: 8),
          Text(pick!.aiComment, style: text.bodyLarge),
          const SizedBox(height: 24),
        ],
        // B-6 스포일러 없는 소개 — 키노라이츠의 잘된 점(스포 가리기, 리뷰 #1)을 이어받음 // P05
        Row(
          children: [
            Text('소개', style: text.titleMedium),
            const SizedBox(width: 8),
            const Chip(
              label: Text('스포일러 없음'),
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
              backgroundColor: NwColors.surfaceHigh,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(item.synopsis, style: text.bodyLarge),
        const SizedBox(height: 24),
        // B-7 어디서 볼까 — 구독 중인 서비스 먼저 // P06
        Text('어디서 볼까', style: text.titleMedium),
        const SizedBox(height: 4),
        for (final o in item.ott)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              o.subscribed ? Icons.play_circle_fill_rounded : Icons.shopping_bag_outlined,
              color: o.subscribed ? NwColors.accent : NwColors.textSecondary,
            ),
            title: Text(o.name),
            trailing: Text(o.price, style: text.bodyMedium),
          ),
        const SizedBox(height: 16),
        // B-8 평가하기 → F 한 줄 평가 시트
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: () => showQuickRateSheet(context, item),
          icon: const Icon(Icons.rate_review_rounded),
          label: const Text('봤어요 · 한 줄 평가'),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= Breakpoints.wide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: top),
                    const SizedBox(width: 40),
                    Expanded(child: info),
                  ],
                ),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [top, const SizedBox(height: 24), info],
        );
      },
    );
  }
}
