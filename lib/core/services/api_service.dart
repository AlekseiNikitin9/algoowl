// Placeholder API service — all calls are stubs.
// Backend endpoints per architecture doc (FastAPI):
//
//   POST   /auth/login
//   POST   /auth/register
//   GET    /problems?category=&difficulty=&page=
//   GET    /problems/{slug}
//   POST   /submissions          — submit code for execution
//   GET    /submissions/{id}     — poll result
//   WS     /ws/submissions/{id}  — stream execution result
//   POST   /ai/review            — get AI hint for code snapshot
//   GET    /progress/me          — user stats, XP, streak
//   GET    /progress/me/queue    — today's spaced rep review queue
//   POST   /progress/me/review   — submit SM-2 review result
//   GET    /leaderboard          — weekly XP ranking
//
// Replace these stubs with real HTTP calls when the backend is ready.

class ApiService {
  static const String baseUrl = 'https://api.codekata.app'; // placeholder

  // ── Auth ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // TODO: POST /auth/login
    await _fakeDelay();
    return {'token': 'fake-jwt-token', 'userId': 'local-user'};
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // TODO: POST /auth/register
    await _fakeDelay();
    return {'token': 'fake-jwt-token', 'userId': 'local-user'};
  }

  Future<void> loginWithGoogle() async {
    // TODO: OAuth2 Google sign-in flow
    await _fakeDelay();
  }

  Future<void> loginWithApple() async {
    // TODO: OAuth2 Apple sign-in flow
    await _fakeDelay();
  }

  // ── Problems ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getProblems({
    String? category,
    String? difficulty,
    int page = 1,
  }) async {
    // TODO: GET /problems
    await _fakeDelay();
    return [];
  }

  Future<Map<String, dynamic>> getProblem(String slug) async {
    // TODO: GET /problems/{slug}
    await _fakeDelay();
    return {};
  }

  // ── Submissions ──────────────────────────────────────────

  Future<Map<String, dynamic>> submitCode({
    required String problemId,
    required String language,
    required String code,
  }) async {
    // TODO: POST /submissions
    // Returns submission ID, then poll or use WebSocket.
    await _fakeDelay();
    return {
      'submissionId': 'sub-001',
      'status': 'accepted',
      'testCasesPassed': 3,
      'testCasesTotal': 3,
      'runtimeMs': 12,
      'memoryMb': 14,
    };
  }

  Future<Map<String, dynamic>> getSubmissionResult(String submissionId) async {
    // TODO: GET /submissions/{id}
    await _fakeDelay();
    return {'status': 'accepted'};
  }

  // ── AI Review ────────────────────────────────────────────

  Future<Map<String, dynamic>> getAiReview({
    required String problemId,
    required String code,
    required String language,
  }) async {
    // TODO: POST /ai/review
    await _fakeDelay();
    return {
      'correct': ['Good use of hash map for O(n) lookup.'],
      'issues': ['Consider edge case: empty input array.'],
      'suggestion':
          'Add a check for len(nums) < 2 at the start.',
    };
  }

  // ── Progress ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getProgress() async {
    // TODO: GET /progress/me
    await _fakeDelay();
    return {'xp': 340, 'streak': 7, 'problemsSolved': 12};
  }

  Future<List<Map<String, dynamic>>> getReviewQueue() async {
    // TODO: GET /progress/me/queue
    await _fakeDelay();
    return [];
  }

  Future<void> submitReview({
    required String problemId,
    required String quality, // 'easy', 'hard', 'again'
  }) async {
    // TODO: POST /progress/me/review (SM-2 update)
    await _fakeDelay();
  }

  // ── Leaderboard ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // TODO: GET /leaderboard
    await _fakeDelay();
    return [];
  }

  // ── Helpers ──────────────────────────────────────────────

  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 300));
}
