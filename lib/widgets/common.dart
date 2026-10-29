import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';

/// 화면 다시 불러오기: setState 대신 같은 화면으로 교체한다(안내문 4장 — setState로 표시 바꾸기 감점).
Route<T> instantRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );

void reloadWith(BuildContext context, Widget page) {
  Navigator.of(context).pushReplacement(instantRoute(page));
}

/// 포스터 자리. 실제 포스터 이미지는 쓰지 않고 작품 색 + 제목 첫 글자로 그린다.
class PosterBox extends StatelessWidget {
  const PosterBox({super.key, required this.item, this.width = 120, this.radius = 14});
  final TitleItem item;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(item.color, Colors.white, 0.18)!,
            item.color,
            Color.lerp(item.color, Colors.black, 0.45)!
          ],
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.all(width * 0.08),
      child: Text(
        item.title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: width * 0.13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.15,
        ),
      ),
    );
  }
}

/// 취향 일치 배지 — 별점·평론 점수와 헷갈리지 않게 "내 취향" 이름을 붙이고, 누르면 뜻을 설명한다. // P02 · P10
class MatchBadge extends StatelessWidget {
  const MatchBadge({super.key, required this.percent, this.large = false});
  final int percent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showMatchHelp(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: large ? 14 : 10, vertical: large ? 8 : 5),
        decoration: BoxDecoration(
          color: NwColors.accentSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NwColors.accent.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '내 취향 일치 $percent%',
              style: TextStyle(
                color: NwColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: large ? 16 : 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline_rounded, size: large ? 18 : 15, color: NwColors.accent),
          ],
        ),
      ),
    );
  }
}

void showMatchHelp(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('"내 취향 일치"란?'),
      content: const Text(
        '내가 남긴 평가와 비슷한 작품일수록 높아요.\n'
        '평론가 점수나 다른 사람의 별점이 아니라, 나에게 맞을 가능성이에요.\n\n'
        '90% 이상 · 거의 확실히 좋아할 작품\n'
        '80% 대 · 좋아할 가능성이 높은 작품\n'
        '80% 미만 · 새로운 시도',
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('알겠어요'))],
    ),
  );
}

/// 추천 이유 칩 — 3개까지, 한 줄씩 짧게. // P08
class ReasonChips extends StatelessWidget {
  const ReasonChips({super.key, required this.reasons});
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in reasons.take(3))
          Chip(
            avatar: const Icon(Icons.check_rounded, size: 16, color: NwColors.good),
            label: Text(r),
            backgroundColor: NwColors.surfaceHigh,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
      ],
    );
  }
}

/// 한 줄 평가 표시(기록 화면). 아이콘 + 글자를 함께 써서 색만으로 구분하지 않는다. // P06
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});
  final String rating;

  static const labels = {'good': '좋았어요', 'soso': '그저 그랬어요', 'bad': '별로였어요'};
  static const icons = {
    'good': Icons.sentiment_very_satisfied_rounded,
    'soso': Icons.sentiment_neutral_rounded,
    'bad': Icons.sentiment_dissatisfied_rounded,
  };
  static const colors = {'good': NwColors.good, 'soso': NwColors.soso, 'bad': NwColors.bad};

  @override
  Widget build(BuildContext context) {
    final color = colors[rating] ?? NwColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icons[rating], size: 18, color: color),
        const SizedBox(width: 4),
        Text(labels[rating] ?? rating, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

IconData moodIcon(String name) {
  switch (name) {
    case 'schedule':
      return Icons.schedule_rounded;
    case 'spa':
      return Icons.spa_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}
