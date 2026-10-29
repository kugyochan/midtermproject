import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// 로컬 json-server에서 GET만 한다. POST · PUT · DELETE · 영구 저장은 없다(안내문 4장).
class Api {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE');
    if (fromEnv.isNotEmpty) return fromEnv;
    // 안드로이드 에뮬레이터는 PC의 localhost를 10.0.2.2로 본다.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static Future<dynamic> _get(String path) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$path')).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) {
        throw ApiException('서버가 응답하지 않았어요 (코드 ${res.statusCode}).');
      }
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on TimeoutException {
      throw ApiException('응답이 너무 늦어요. 네트워크를 확인해 주세요.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('추천 서버에 연결할 수 없어요.\njson-server가 켜져 있는지 확인해 주세요.');
    }
  }

  /// GET /picks?mood=short&_sort=rank&_expand=title
  static Future<List<Pick>> picks(String mood) async {
    final data = await _get('/picks?mood=$mood&_sort=rank&_order=asc&_expand=title') as List;
    return data.map((e) => Pick.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /titles/t3
  static Future<TitleItem> title(String id) async {
    final data = await _get('/titles/$id') as Map<String, dynamic>;
    return TitleItem.fromJson(data);
  }

  /// GET /moods
  static Future<List<Mood>> moods() async {
    final data = await _get('/moods') as List;
    return data.map((e) => Mood.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /history?_expand=title&_sort=watchedAt&_order=desc
  static Future<List<HistoryEntry>> history() async {
    final data = await _get('/history?_expand=title&_sort=watchedAt&_order=desc') as List;
    return data.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /watchlist?_expand=title — 시연 데이터는 비어 있다(빈 상태 화면).
  static Future<List<TitleItem>> watchlist() async {
    final data = await _get('/watchlist?_expand=title') as List;
    return data.map((e) => TitleItem.fromJson((e as Map<String, dynamic>)['title'] as Map<String, dynamic>)).toList();
  }

  /// GET /taste
  static Future<TasteReport> taste() async {
    final data = await _get('/taste') as Map<String, dynamic>;
    return TasteReport.fromJson(data);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
