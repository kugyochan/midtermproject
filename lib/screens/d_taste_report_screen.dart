import 'package:flutter/material.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/state_views.dart';
import 'root_tabs.dart';

/// D 취향 리포트 — 추천이 "왜" 그렇게 나오는지 보여 주는 화면. // P01 · P10
class TasteReportScreen extends StatefulWidget {
  const TasteReportScreen({super.key});

  @override
  State<TasteReportScreen> createState() => _TasteReportScreenState();
}

class _TasteReportScreenState extends State<TasteReportScreen> {
  // STATE: S4 취향 분석 결과가 바뀌면(새 평가) → D-1 AI 취향 요약 · D-2 장르 막대 · D-3 키워드
  late final Future<TasteReport> _future = Api.taste();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TasteReport>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(message: '취향 리포트를 만드는 중이에요…');
        }
        if (snap.hasError) {
          return ErrorView(
            message: snap.error.toString(),
            onRetry: () => reloadWith(context, const RootTabs(initialIndex: 2)),
          );
        }
        final r = snap.data!;
        if (r.genres.isEmpty) {
          return EmptyView(
            icon: Icons.insights_rounded,
            title: '아직 취향을 알 수 없어요',
            message: '3편 이상 평가하면 리포트가 만들어져요.',
            actionLabel: '오늘의 한 편 보러 가기',
            onAction: () => reloadWith(context, const RootTabs(initialIndex: 0)),
          );
        }
        return _ReportBody(report: r);
      },
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});
  final TasteReport report;

  Widget _section(BuildContext context, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: NwColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // D-1 AI 취향 요약
    final summary = _section(
      context,
      '기록 ${report.basedOn}편으로 본 내 취향',
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: NwColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(report.summary, style: text.bodyLarge)),
        ],
      ),
    );

    // D-2 장르 막대 — 숫자와 막대를 함께 // P06
    final genres = _section(
      context,
      '많이 좋아한 장르',
      Column(
        children: [
          for (final g in report.genres)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: 96, child: Text(g.name, style: text.bodyLarge)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: g.percent / 100,
                        minHeight: 10,
                        color: NwColors.accent,
                        backgroundColor: NwColors.surfaceHigh,
                      ),
                    ),
                  ),
                  SizedBox(width: 48, child: Text('${g.percent}%', textAlign: TextAlign.right)),
                ],
              ),
            ),
        ],
      ),
    );

    // D-3 취향 키워드
    final keywords = _section(
      context,
      '취향 키워드',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final k in report.keywords)
            Chip(label: Text('#$k'), side: BorderSide.none, backgroundColor: NwColors.surfaceHigh),
        ],
      ),
    );

    // D-4 이렇게 골랐어요 — 추천 근거 설명 // P10
    final how = _section(
      context,
      '이렇게 골라요',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, line) in report.howItWorks.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${i + 1}. $line', style: text.bodyLarge),
            ),
        ],
      ),
    );

    // D-5 오늘의 한 편 바로가기
    final cta = FilledButton.icon(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      onPressed: () => DefaultTabController.of(context).animateTo(0),
      icon: const Icon(Icons.movie_filter_rounded),
      label: const Text('이 취향으로 오늘의 한 편 보기'),
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= Breakpoints.wide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    summary,
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: genres),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [keywords, const SizedBox(height: 16), how],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(width: 400, child: cta),
                  ],
                ),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summary,
            const SizedBox(height: 12),
            genres,
            const SizedBox(height: 12),
            keywords,
            const SizedBox(height: 12),
            how,
            const SizedBox(height: 20),
            cta,
          ],
        );
      },
    );
  }
}
