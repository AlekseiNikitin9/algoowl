enum Difficulty { easy, medium, hard }

class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  const TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });
}

// ── Lesson content ────────────────────────────────────────────

class LessonQuiz {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const LessonQuiz({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });
}

class LessonContent {
  final LessonQuiz? approachQuiz;
  final LessonQuiz? complexityQuiz;
  final List<String> approachKeywords;
  final String goodApproachFeedback;
  final String genericApproachFeedback;

  const LessonContent({
    this.approachQuiz,
    this.complexityQuiz,
    this.approachKeywords = const [],
    this.goodApproachFeedback = '',
    this.genericApproachFeedback = '',
  });
}

// ── Problem ───────────────────────────────────────────────────

class Problem {
  final String id;
  final String title;
  final String slug;
  final String categoryId;
  final Difficulty difficulty;
  final String description;
  final String constraints;
  final List<TestCase> testCases;
  final Map<String, String> starterCode;
  final LessonContent lessonContent;
  final List<String> hints;

  const Problem({
    required this.id,
    required this.title,
    required this.slug,
    required this.categoryId,
    required this.difficulty,
    required this.description,
    this.constraints = '',
    this.testCases = const [],
    this.starterCode = const {},
    this.lessonContent = const LessonContent(),
    this.hints = const [],
  });
}

// ── Sample problems ───────────────────────────────────────────

final List<Problem> kSampleProblems = [
  Problem(
    id: '1',
    title: 'Two Sum',
    slug: 'two-sum',
    categoryId: '1',
    difficulty: Difficulty.easy,
    description:
        'Given an array of integers nums and an integer target, return indices '
        'of the two numbers such that they add up to target.\n\n'
        'You may assume that each input would have exactly one solution, and '
        'you may not use the same element twice.',
    constraints:
        '2 ≤ nums.length ≤ 10⁴\n-10⁹ ≤ nums[i] ≤ 10⁹\nExactly one solution exists.',
    testCases: [
      TestCase(input: '[2,7,11,15], target=9', expectedOutput: '[0,1]'),
      TestCase(input: '[3,2,4], target=6', expectedOutput: '[1,2]'),
      TestCase(
          input: '[3,3], target=6', expectedOutput: '[0,1]', isHidden: true),
    ],
    starterCode: {
      'python': 'def two_sum(nums, target):\n    # your code here\n    pass',
      'javascript':
          'function twoSum(nums, target) {\n    // your code here\n}',
    },
    hints: [
      'Think about what you need to find for each number as you walk the array.',
      'For each nums[i], you need to know if (target - nums[i]) exists somewhere.',
      'A hash map lets you check if a number exists in O(1). Store each number as you go, then check if the complement is already in the map.',
    ],
    lessonContent: LessonContent(
      approachQuiz: LessonQuiz(
        question:
            'Which data structure gives you O(1) lookup to check if a number has been seen?',
        options: [
          'Array - scan each time',
          'Hash Map - instant lookup',
          'Stack - last in, first out',
          'Linked List - sequential access',
        ],
        correctIndex: 1,
        explanation:
            'A hash map (Python dict) stores key–value pairs with O(1) average lookup. '
            'This is the key to solving Two Sum in a single pass.',
      ),
      complexityQuiz: LessonQuiz(
        question: 'What\'s the optimal time complexity for Two Sum?',
        options: [
          'O(n²) - check every pair',
          'O(n log n) - sort then search',
          'O(n) - single pass with hash map',
          'O(1) - math trick',
        ],
        correctIndex: 2,
        explanation:
            'One pass with a hash map: for each element, check if target − num is already stored. '
            'O(n) time, O(n) space.',
      ),
      approachKeywords: [
        'hash',
        'map',
        'dict',
        'dictionary',
        'complement',
        'seen',
        'lookup',
        'store',
        'target minus',
        'target -',
        'one pass',
        'single pass',
      ],
      goodApproachFeedback:
          'Excellent! You\'ve spotted the core trick - storing seen values so you can '
          'check for the complement instantly. Make sure you also think about what '
          'to do if target − nums[i] equals nums[i] itself.',
      genericApproachFeedback:
          'Good start! Here\'s a nudge: as you walk through the array, '
          'can you remember what you\'ve already seen in a way that makes it instant '
          'to know whether the complement exists - without scanning the whole array again?',
    ),
  ),
  Problem(
    id: '2',
    title: 'Contains Duplicate',
    slug: 'contains-duplicate',
    categoryId: '2',
    difficulty: Difficulty.easy,
    description:
        'Given an integer array nums, return true if any value appears '
        'at least twice in the array, and return false if every element is distinct.',
    constraints:
        '1 ≤ nums.length ≤ 10⁵\n-10⁹ ≤ nums[i] ≤ 10⁹',
    testCases: [
      TestCase(input: '[1,2,3,1]', expectedOutput: 'true'),
      TestCase(input: '[1,2,3,4]', expectedOutput: 'false'),
      TestCase(
          input: '[1,1,1,3,3,4,3,2,4,2]',
          expectedOutput: 'true',
          isHidden: true),
    ],
    starterCode: {
      'python':
          'def contains_duplicate(nums):\n    # your code here\n    pass',
      'javascript':
          'function containsDuplicate(nums) {\n    // your code here\n}',
    },
    hints: [
      'You need to detect if any value repeats. What data structure is built for uniqueness?',
      'A set only stores unique values. Adding a duplicate to a set fails or is a no-op - use that.',
      'Walk through nums. Before adding nums[i] to your set, check if it\'s already there.',
    ],
    lessonContent: LessonContent(
      approachQuiz: LessonQuiz(
        question:
            'Which data structure is designed to hold only unique values?',
        options: [
          'List - ordered, allows duplicates',
          'Set - unique values, O(1) membership test',
          'Stack - LIFO order',
          'Queue - FIFO order',
        ],
        correctIndex: 1,
        explanation:
            'A set stores only unique values. If you try to add a number that\'s already '
            'in the set, you know it\'s a duplicate - O(1) check, O(n) overall.',
      ),
      complexityQuiz: LessonQuiz(
        question: 'What\'s the optimal time complexity for Contains Duplicate?',
        options: [
          'O(n²) - compare all pairs',
          'O(n log n) - sort and check adjacent',
          'O(n) - hash set single pass',
          'O(1) - always constant',
        ],
        correctIndex: 2,
        explanation:
            'One pass with a hash set: add each element, and if it\'s already there, return true. '
            'O(n) time, O(n) space.',
      ),
      approachKeywords: [
        'set',
        'seen',
        'hash',
        'unique',
        'visited',
        'already',
        'duplicate',
        'membership',
        'add',
      ],
      goodApproachFeedback:
          'Nice! Using a set to track seen values and checking membership before adding is '
          'exactly right. It\'s clean, O(n), and handles all edge cases automatically.',
      genericApproachFeedback:
          'You\'re thinking about it! Consider: is there a collection type that '
          'inherently enforces uniqueness? If something can\'t be added because it\'s '
          'already there - that\'s your duplicate signal.',
    ),
  ),
  Problem(
    id: '3',
    title: 'Valid Anagram',
    slug: 'valid-anagram',
    categoryId: '2',
    difficulty: Difficulty.easy,
    description:
        'Given two strings s and t, return true if t is an anagram of s, '
        'and false otherwise.\n\n'
        'An anagram is a word formed by rearranging the letters of another word '
        'using all the original letters exactly once.',
    constraints:
        '1 ≤ s.length, t.length ≤ 5 × 10⁴\ns and t consist of lowercase English letters.',
    testCases: [
      TestCase(input: 's="anagram", t="nagaram"', expectedOutput: 'true'),
      TestCase(input: 's="rat", t="car"', expectedOutput: 'false'),
      TestCase(
          input: 's="listen", t="silent"',
          expectedOutput: 'true',
          isHidden: true),
    ],
    starterCode: {
      'python': 'def is_anagram(s, t):\n    # your code here\n    pass',
      'javascript':
          'function isAnagram(s, t) {\n    // your code here\n}',
    },
    hints: [
      'Two strings are anagrams if they have the same characters in the same quantities.',
      'Try counting how many times each character appears in each string.',
      'You can use a Counter (Python) or a frequency dictionary, then compare the two frequency maps.',
    ],
    lessonContent: LessonContent(
      approachQuiz: LessonQuiz(
        question: 'Anagrams have the same characters in the same quantities. How do you verify that?',
        options: [
          'Sort both strings and compare - O(n log n)',
          'Count character frequencies and compare - O(n)',
          'Check if every character of s is in t - O(n²)',
          'Both A and B work correctly',
        ],
        correctIndex: 3,
        explanation:
            'Both sorting and frequency counting work! Sorting is simpler to write; '
            'frequency counting is faster at O(n). For interviews, either is usually acceptable.',
      ),
      complexityQuiz: LessonQuiz(
        question:
            'What\'s the best time complexity for Valid Anagram?',
        options: [
          'O(n²) - nested loops',
          'O(n log n) - sort-based solution',
          'O(n) - frequency count',
          'O(1) - length check only',
        ],
        correctIndex: 2,
        explanation:
            'Counting character frequencies with a hash map is O(n). '
            'The sort-based approach is O(n log n) but also commonly accepted.',
      ),
      approachKeywords: [
        'count',
        'frequency',
        'sort',
        'counter',
        'character',
        'char',
        'map',
        'dict',
        'compare',
        'frequency map',
      ],
      goodApproachFeedback:
          'Great approach! Whether you sort both strings or count character frequencies, '
          'you\'ve got the core idea. Remember to also handle the case where s and t '
          'have different lengths - that\'s an instant false.',
      genericApproachFeedback:
          'Good thinking! Ask yourself: what property do anagrams share exactly? '
          'Each character appears the same number of times. How would you capture '
          'and compare those counts efficiently?',
    ),
  ),
];
