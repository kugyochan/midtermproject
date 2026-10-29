import 'package:flutter/material.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../theme.dart';
import 'common.dart';
import 'state_views.dart';

/// E 상황 고르기 시트 — showModalBottomSheet. 고른 상황 id를 돌려준다.
/// // P07 유연성 — 매번 필터를 조합하지 않고, 자주 쓰는 상황 4개를 한 번에 고른다.
Future<String?> showMoodSheet(BuildContext context, String currentMood) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: NwColors.surface,
    builder: (context) => _MoodSheet(currentMood: currentMood),
  );
}

class _MoodSheet extends StatefulWidget {
  const _MoodSheet({required this.currentMood});
  final String currentMood;

  @override
  State<_MoodSheet> createState() => _MoodSheetState();
}

class _MoodSheetState extends State<_MoodSheet> {
  late final Future<List<Mood>> _future = Api.moods(); // GET /moods

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('지금 어떤 상황이에요?', style: Theme.of(context).textTheme.titleLarge), // E-1
            ),
            Expanded(
              child: FutureBuilder<List<Mood>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const LoadingView(message: '상황 목록을 불러오는 중이에요…');
                  }
                  if (snap.hasError) {
                    return ErrorView(
                      message: snap.error.toString(),
                      onRetry: () => Navigator.pop(context),
                    );
                  }
                  final moods = snap.data!;
                  return ListView(
                    children: [
                      for (final m in moods)
                        // E-2 상황 항목 · 현재 고른 상황에 체크 표시 // P01
                        // STATE: S2 고른 상황(mood) → E-2 체크 표시 · A-1 상황 칩
                        ListTile(
                          leading: Icon(moodIcon(m.icon), color: NwColors.accent),
                          title: Text(m.label),
                          subtitle: Text(m.desc),
                          trailing: m.id == widget.currentMood
                              ? const Icon(Icons.check_circle_rounded, color: NwColors.accent)
                              : null,
                          onTap: () => Navigator.pop(context, m.id),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// F 한 줄 평가 시트 — 별 5개 대신 3단계 버튼 하나만 누르면 끝. // P07 · 셀프 논증 쟁점 4
/// 결과는 저장하지 않고 스낵바로만 알린다(영구 저장 감점).
Future<void> showQuickRateSheet(BuildContext context, TitleItem item) async {
  final label = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: NwColors.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("'${item.title}' 어땠어요?", style: Theme.of(context).textTheme.titleLarge), // F-1
            const SizedBox(height: 4),
            Text('하나만 누르면 다음 추천에 반영돼요.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            for (final r in ['good', 'soso', 'bad'])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                // F-2 평가 버튼 — 아이콘 + 글자, 손가락 크기 56px // P06
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: RatingBadge.colors[r],
                    side: BorderSide(color: RatingBadge.colors[r]!.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => Navigator.pop(context, RatingBadge.labels[r]),
                  icon: Icon(RatingBadge.icons[r]),
                  label: Text(RatingBadge.labels[r]!),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  if (label == null || !context.mounted) return;
  // STATE: S5 한 줄 평가가 추가되면 → C-2 기록 카드 목록 · D-1 취향 요약 (지금은 스낵바만, 저장 없음)
  // P01 피드백 — 무엇이 일어났는지 바로 알린다. "되돌리기"로 사용자 통제권 // P03
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("'${item.title}'을(를) '$label'로 기록했어요 (시연 화면 · 저장되지 않아요)"),
      action: SnackBarAction(label: '되돌리기', onPressed: () {}),
    ),
  );
}

/// G 어디서 볼까 다이얼로그 — "볼래요"를 누르면 구독 중인 서비스부터 보여 준다. // P06
void showWhereToWatch(BuildContext context, TitleItem item) {
  final sorted = [...item.ott]..sort((a, b) => (b.subscribed ? 1 : 0) - (a.subscribed ? 1 : 0));
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text("'${item.title}' 어디서 볼까요?"), // G-1
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in sorted)
            // G-2 서비스 행 — 구독 중이면 강조 // P06
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                o.subscribed ? Icons.play_circle_fill_rounded : Icons.shopping_bag_outlined,
                color: o.subscribed ? NwColors.accent : NwColors.textSecondary,
              ),
              title: Text(o.name),
              subtitle: Text(o.price),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('닫기')),
        // G-3 다 보고 평가하기 → F 한 줄 평가 시트
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            showQuickRateSheet(context, item);
          },
          child: const Text('다 봤어요 · 평가하기'),
        ),
      ],
    ),
  );
}
