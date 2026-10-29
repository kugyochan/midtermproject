import 'dart:ui';

/// json-server 응답을 화면에서 쓰기 좋게 바꾼 모델. 계산 로직은 없다.

class Ott {
  final String name;
  final String kind; // 구독 · 대여
  final String price;

  Ott.fromJson(Map<String, dynamic> j)
      : name = j['name'] as String,
        kind = j['kind'] as String,
        price = j['price'] as String;

  bool get subscribed => price == '구독 중';
}

class TitleItem {
  final String id;
  final String title;
  final String type; // 영화 · 드라마
  final int year;
  final String runtime;
  final List<String> genres;
  final Color color;
  final String synopsis;
  final List<Ott> ott;

  TitleItem.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        title = j['title'] as String,
        type = j['type'] as String,
        year = j['year'] as int,
        runtime = j['runtime'] as String,
        genres = List<String>.from(j['genres'] as List),
        color = Color(int.parse(j['color'] as String, radix: 16)),
        synopsis = j['synopsis'] as String,
        ott = (j['ott'] as List).map((e) => Ott.fromJson(e as Map<String, dynamic>)).toList();

  String get meta => '$type · $year · $runtime · ${genres.join('/')}';
}

/// "오늘의 한 편" 후보. 추천 결과는 db.json에 미리 정해 둔 임의 결과다.
class Pick {
  final String id;
  final String mood;
  final int rank;
  final int matchPercent;
  final List<String> reasons;
  final String aiComment;
  final TitleItem title;

  Pick.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        mood = j['mood'] as String,
        rank = j['rank'] as int,
        matchPercent = j['matchPercent'] as int,
        reasons = List<String>.from(j['reasons'] as List),
        aiComment = j['aiComment'] as String,
        title = TitleItem.fromJson(j['title'] as Map<String, dynamic>);
}

class Mood {
  final String id;
  final String label;
  final String desc;
  final String icon;

  Mood.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        label = j['label'] as String,
        desc = j['desc'] as String,
        icon = j['icon'] as String;
}

class HistoryEntry {
  final String id;
  final String rating; // good · soso · bad
  final String watchedAt;
  final TitleItem title;

  HistoryEntry.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        rating = j['rating'] as String,
        watchedAt = j['watchedAt'] as String,
        title = TitleItem.fromJson(j['title'] as Map<String, dynamic>);
}

class GenreShare {
  final String name;
  final int percent;

  GenreShare.fromJson(Map<String, dynamic> j)
      : name = j['name'] as String,
        percent = j['percent'] as int;
}

class TasteReport {
  final int basedOn;
  final String summary;
  final List<GenreShare> genres;
  final List<String> keywords;
  final List<String> howItWorks;

  TasteReport.fromJson(Map<String, dynamic> j)
      : basedOn = j['basedOn'] as int,
        summary = j['summary'] as String,
        genres = (j['genres'] as List).map((e) => GenreShare.fromJson(e as Map<String, dynamic>)).toList(),
        keywords = List<String>.from(j['keywords'] as List),
        howItWorks = List<String>.from(j['howItWorks'] as List);
}
