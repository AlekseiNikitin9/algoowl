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

class Problem {
  final String id;
  final String title;
  final String slug;
  final String categoryId;
  final Difficulty difficulty;
  final String description;
  final String constraints;
  final List<TestCase> testCases;
  final Map<String, String> starterCode; // language → code template

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
  });
}

/// Sample problems for the MVP.
final List<Problem> kSampleProblems = [
  Problem(
    id: '1',
    title: 'Two Sum',
    slug: 'two-sum',
    categoryId: '1',
    difficulty: Difficulty.easy,
    description:
        'Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.',
    constraints:
        '2 ≤ nums.length ≤ 10⁴\n-10⁹ ≤ nums[i] ≤ 10⁹\nExactly one solution exists.',
    testCases: [
      TestCase(input: '[2,7,11,15], target=9', expectedOutput: '[0,1]'),
      TestCase(input: '[3,2,4], target=6', expectedOutput: '[1,2]'),
      TestCase(
          input: '[3,3], target=6',
          expectedOutput: '[0,1]',
          isHidden: true),
    ],
    starterCode: {
      'python': 'def two_sum(nums, target):\n    # your code here\n    pass',
      'javascript':
          'function twoSum(nums, target) {\n    // your code here\n}',
    },
  ),
  Problem(
    id: '2',
    title: 'Contains Duplicate',
    slug: 'contains-duplicate',
    categoryId: '2',
    difficulty: Difficulty.easy,
    description:
        'Given an integer array nums, return true if any value appears at least twice in the array.',
    testCases: [
      TestCase(input: '[1,2,3,1]', expectedOutput: 'true'),
      TestCase(input: '[1,2,3,4]', expectedOutput: 'false'),
    ],
    starterCode: {
      'python':
          'def contains_duplicate(nums):\n    # your code here\n    pass',
    },
  ),
  Problem(
    id: '3',
    title: 'Valid Anagram',
    slug: 'valid-anagram',
    categoryId: '2',
    difficulty: Difficulty.easy,
    description:
        'Given two strings s and t, return true if t is an anagram of s.',
    testCases: [
      TestCase(input: 's="anagram", t="nagaram"', expectedOutput: 'true'),
      TestCase(input: 's="rat", t="car"', expectedOutput: 'false'),
    ],
    starterCode: {
      'python': 'def is_anagram(s, t):\n    # your code here\n    pass',
    },
  ),
];
