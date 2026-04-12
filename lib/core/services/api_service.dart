import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// All backend communication goes through this class.
///
/// Base URL:
///   iOS Simulator    → http://localhost:8000
///   Android Emulator → http://10.0.2.2:8000
///   Physical device  → http://<your-lan-ip>:8000
class ApiService {
  static const String baseUrl = 'http://192.168.0.136:8000';

  static const _tokenKey = 'jwt_token';
  static const _credEmailKey = 'device_email';
  static const _credPassKey = 'device_password';

  String? _token;
  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Initialization ───────────────────────────────────────────

  /// Restore stored JWT and validate it. Returns true if a valid session was
  /// found so the app can skip onboarding.
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    if (_token != null) {
      try {
        await _get('/auth/me');
        return true;
      } catch (_) {
        _token = null;
        await prefs.remove(_tokenKey);
      }
    }

    // Try re-auth with stored device credentials
    final email = prefs.getString(_credEmailKey);
    final password = prefs.getString(_credPassKey);
    if (email != null && password != null) {
      try {
        await _performLogin(email: email, password: password);
        return true;
      } catch (_) {}
    }
    return false;
  }

  /// Create or restore an anonymous device account. Called automatically
  /// before any authenticated request.
  Future<void> ensureAuth() async {
    if (_token != null) return;

    final prefs = await SharedPreferences.getInstance();
    var email = prefs.getString(_credEmailKey);
    var password = prefs.getString(_credPassKey);

    if (email == null) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      email = 'device-$ts@codekata.app';
      password = 'pwd-$ts-secret';
      await prefs.setString(_credEmailKey, email);
      await prefs.setString(_credPassKey, password);
    }

    // Register first (no-op if account already exists), then login
    try {
      await _performRegister(email: email, password: password!, name: 'Learner');
      return;
    } catch (_) {}
    await _performLogin(email: email, password: password!);
  }

  // ── Auth ─────────────────────────────────────────────────────

  Future<void> _performLogin({
    required String email,
    required String password,
  }) async {
    final res = await _post(
      '/auth/login',
      {'email': email, 'password': password},
      requiresAuth: false,
    );
    await _saveToken(res['access_token'] as String);
  }

  Future<void> _performRegister({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await _post(
      '/auth/register',
      {'email': email, 'password': password, 'name': name},
      requiresAuth: false,
    );
    await _saveToken(res['access_token'] as String);
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await _performLogin(email: email, password: password);
    return {'token': _token, 'userId': 'backend-user'};
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _performRegister(email: email, password: password, name: name);
    return {'token': _token, 'userId': 'backend-user'};
  }

  Future<void> loginWithGoogle() async {}
  Future<void> loginWithApple() async {}

  Future<Map<String, dynamic>> getMe() async {
    final res = await _get('/auth/me');
    return res as Map<String, dynamic>;
  }

  // ── Problems ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getProblems({
    String? category,
    String? difficulty,
    int page = 1,
  }) async {
    final params = <String, String>{'page': '$page'};
    if (category != null) params['category'] = category;
    if (difficulty != null) params['difficulty'] = difficulty;
    final res = await _get('/problems', queryParams: params);
    return List<Map<String, dynamic>>.from(res as List);
  }

  Future<Map<String, dynamic>> getProblem(String slug) async {
    final res = await _get('/problems/$slug');
    return res as Map<String, dynamic>;
  }

  // ── Submissions ──────────────────────────────────────────────

  /// Submit code and poll until execution completes.
  /// [problemSlug] is used to resolve the backend UUID.
  Future<Map<String, dynamic>> submitCode({
    required String problemSlug,
    required String language,
    required String code,
  }) async {
    await ensureAuth();

    // Resolve the backend problem UUID from slug
    final problem = await getProblem(problemSlug);
    final problemId = problem['id'] as String;

    // Create the submission (returns immediately as "pending")
    final submission = await _post('/submissions', {
      'problem_id': problemId,
      'language': language,
      'code': code,
    });
    final submissionId = submission['submission_id'] as String;

    // Poll until terminal status
    return _pollSubmission(submissionId);
  }

  Future<Map<String, dynamic>> _pollSubmission(String id) async {
    const maxAttempts = 30;
    const interval = Duration(milliseconds: 600);

    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(interval);
      final result = await getSubmissionResult(id);
      final status = result['status'] as String? ?? '';
      if (status != 'pending' && status != 'running') {
        return result;
      }
    }
    return {
      'status': 'time_limit',
      'test_cases_passed': 0,
      'test_cases_total': 0,
      'test_results': [],
    };
  }

  Future<Map<String, dynamic>> getSubmissionResult(String submissionId) async {
    await ensureAuth();
    final res = await _get('/submissions/$submissionId');
    return res as Map<String, dynamic>;
  }

  // ── AI Review ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAiReview({
    required String problemId,
    required String code,
    required String language,
  }) async {
    // TODO: POST /ai/review when backend endpoint is live
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'correct': ['Good use of hash map for O(n) lookup.'],
      'issues': ['Consider edge case: empty input array.'],
      'suggestion': 'Add a check for len(nums) < 2 at the start.',
    };
  }

  /// Send a message to the Socratic AI tutor.
  /// [messages] is the full conversation history so far (not including [newMessage]).
  /// [isFinalRound] signals the AI to wrap up warmly.
  /// Returns {'reply': String, 'refused': bool}.
  Future<Map<String, dynamic>> chatWithTutor({
    required String problemTitle,
    required String problemDescription,
    required List<Map<String, String>> messages,
    required String newMessage,
    bool isFinalRound = false,
  }) async {
    await ensureAuth();
    try {
      final res = await _post('/ai/chat', {
        'problem_title': problemTitle,
        'problem_description': problemDescription,
        'messages': messages,
        'new_message': newMessage,
        'is_final_round': isFinalRound,
      });
      return res as Map<String, dynamic>;
    } on ApiException catch (e) {
      return {
        'reply': 'Hmm, I ran into an issue (${e.message}). '
            'Keep thinking - what data structure might help here?',
        'refused': false,
      };
    } catch (_) {
      return {
        'reply': 'Network hiccup! Your thinking is still valid - keep going.',
        'refused': false,
      };
    }
  }

  /// Run code against a custom test input and return stdout + output.
  Future<Map<String, dynamic>> runCustomTest({
    required String language,
    required String code,
    required String testInput,
    String expectedOutput = '',
  }) async {
    await ensureAuth();
    try {
      final res = await _post('/submissions/run', {
        'language': language,
        'code': code,
        'test_input': testInput,
        'expected_output': expectedOutput,
      });
      return res as Map<String, dynamic>;
    } on ApiException catch (e) {
      return {
        'status': 'runtime_error',
        'actual': null,
        'stdout': null,
        'error': e.message,
      };
    }
  }

  // ── Progress ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProgress() async {
    await ensureAuth();
    final res = await _get('/progress/me');
    return res as Map<String, dynamic>;
  }

  /// Save onboarding preferences and mark onboarding complete.
  /// [focus] accepts frontend values: 'interview' | 'learn' | 'both'
  Future<Map<String, dynamic>> completeOnboarding({
    required int dailyGoalMinutes,
    required String experienceLevel,
    required String focus,
  }) async {
    await ensureAuth();
    final res = await _put('/progress/me/onboarding', {
      'daily_goal_minutes': dailyGoalMinutes.clamp(5, 120),
      'experience_level': experienceLevel,
      'focus': _mapFocus(focus),
    });
    return res as Map<String, dynamic>;
  }

  /// Map frontend focus labels to backend enum values.
  String _mapFocus(String f) {
    switch (f) {
      case 'interview':
        return 'algorithms';
      case 'learn':
        return 'data_structures';
      default:
        return 'both';
    }
  }

  Future<List<Map<String, dynamic>>> getReviewQueue() async {
    // TODO: implement when endpoint available
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<void> submitReview({
    required String problemId,
    required String quality,
  }) async {
    // TODO: implement when endpoint available
  }

  // ── Leaderboard ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // TODO: implement when /leaderboard endpoint is added to backend
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  // ── HTTP Helpers ─────────────────────────────────────────────

  Future<dynamic> _get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http.get(uri, headers: _headers);
    return _handle(response);
  }

  Future<dynamic> _post(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = requiresAuth
        ? _headers
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};
    final response = await http.post(uri, headers: headers, body: jsonEncode(body));
    return _handle(response);
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(uri, headers: _headers, body: jsonEncode(body));
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: _parseError(response.body),
    );
  }

  String _parseError(String body) {
    try {
      final data = jsonDecode(body);
      return data['detail']?.toString() ?? 'Unknown error';
    } catch (_) {
      return body.isNotEmpty ? body : 'Request failed';
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
