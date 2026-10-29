import 'package:flutter/material.dart';

import '../theme.dart';
import 'a_today_pick_screen.dart';
import 'c_history_screen.dart';
import 'd_taste_report_screen.dart';

/// 앱 뼈대 — TabBar 3개(오늘의 한 편 · 내 기록 · 취향 리포트).
/// 폰: 아래 탭 / 넓은 화면: 위 탭. 탭 전환은 TabController가 맡는다(setState 없음).
class RootTabs extends StatelessWidget {
  const RootTabs({super.key, this.initialIndex = 0, this.mood = 'default'});
  final int initialIndex;
  final String mood;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= Breakpoints.wide;
          // STATE: S6 선택된 탭 → T-1 주 메뉴 탭 (TabController가 관리, 직접 구현 없음)
          // T-1 주 메뉴 탭 — 가장 많이 쓰는 3곳을 항상 같은 자리에 // P04 · 리뷰 #14 "하단 메인바에서 없어지니 불편"
          const tabBar = TabBar(
            indicatorColor: NwColors.accent,
            labelColor: NwColors.accent,
            unselectedLabelColor: NwColors.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.movie_filter_rounded), text: '오늘의 한 편'),
              Tab(icon: Icon(Icons.bookmarks_rounded), text: '내 기록'),
              Tab(icon: Icon(Icons.insights_rounded), text: '취향 리포트'),
            ],
          );
          return Scaffold(
            appBar: AppBar(
              title: const Row(
                children: [
                  Icon(Icons.play_arrow_rounded, color: NwColors.accent),
                  SizedBox(width: 4),
                  Text('Nextwatch', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              bottom: wide ? tabBar : null,
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TodayPickScreen(mood: mood, asTab: true),
                const HistoryScreen(),
                const TasteReportScreen(),
              ],
            ),
            bottomNavigationBar: wide ? null : const Material(color: NwColors.surface, child: SafeArea(child: tabBar)),
          );
        },
      ),
    );
  }
}
