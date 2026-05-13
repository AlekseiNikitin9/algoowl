"""Expanded problem set for seeding the Codekata database (~174 problems, 14 categories)."""

# ── Shared helper code appended to starter_code for LL/Tree problems ──

_LL = (
    "\n\nclass ListNode:\n"
    "    def __init__(self, val=0, next=None):\n"
    "        self.val, self.next = val, next\n"
    "\n"
    "def _to_ll(arr):\n"
    "    if not arr: return None\n"
    "    h = ListNode(arr[0]); c = h\n"
    "    for v in arr[1:]: c.next = ListNode(v); c = c.next\n"
    "    return h\n"
    "\n"
    "def _to_list(h):\n"
    "    r = []\n"
    "    while h: r.append(h.val); h = h.next\n"
    "    return r\n"
)

_TREE = (
    "\n\nclass TreeNode:\n"
    "    def __init__(self, val=0, left=None, right=None):\n"
    "        self.val, self.left, self.right = val, left, right\n"
    "\n"
    "def _a2t(arr):\n"
    "    if not arr or arr[0] is None: return None\n"
    "    root = TreeNode(arr[0]); q, i = [root], 1\n"
    "    while i < len(arr):\n"
    "        node = q.pop(0)\n"
    "        if i < len(arr) and arr[i] is not None:\n"
    "            node.left = TreeNode(arr[i]); q.append(node.left)\n"
    "        i += 1\n"
    "        if i < len(arr) and arr[i] is not None:\n"
    "            node.right = TreeNode(arr[i]); q.append(node.right)\n"
    "        i += 1\n"
    "    return root\n"
    "\n"
    "def _t2a(root):\n"
    "    if not root: return []\n"
    "    res, q = [], [root]\n"
    "    while q:\n"
    "        node = q.pop(0)\n"
    "        if node: res.append(node.val); q.append(node.left); q.append(node.right)\n"
    "        else: res.append(None)\n"
    "    while res and res[-1] is None: res.pop()\n"
    "    return res\n"
)


PROBLEMS = [

    # ─── ARRAYS & STRINGS (15) ───────────────────────────────────────────────────

    {
        "title": "Two Sum",
        "slug": "two-sum",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given an integer array `nums` and an integer `target`, return the indices of the two numbers that add up to `target`. Exactly one solution exists.",
        "constraints": "2 ≤ nums.length ≤ 10⁴\n-10⁹ ≤ nums[i] ≤ 10⁹",
        "starter_code": {
            "python": "def two_sum(nums, target):\n    # your code here\n    pass",
            "javascript": "function twoSum(nums, target) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[2,7,11,15], 9", "expected_output": "[0,1]", "is_hidden": False},
            {"input": "[3,2,4], 6", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[3,3], 6", "expected_output": "[0,1]", "is_hidden": True},
        ],
    },
    {
        "title": "Best Time to Buy and Sell Stock",
        "slug": "best-time-buy-sell-stock",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given an array `prices` where `prices[i]` is the stock price on day `i`, return the maximum profit from one buy and one sell. Return 0 if no profit is possible.",
        "constraints": "1 ≤ prices.length ≤ 10⁵\n0 ≤ prices[i] ≤ 10⁴",
        "starter_code": {
            "python": "def max_profit(prices):\n    # your code here\n    pass",
            "javascript": "function maxProfit(prices) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[7,1,5,3,6,4]", "expected_output": "5", "is_hidden": False},
            {"input": "[7,6,4,3,1]", "expected_output": "0", "is_hidden": False},
            {"input": "[2,4,1]", "expected_output": "2", "is_hidden": True},
        ],
    },
    {
        "title": "Maximum Subarray",
        "slug": "maximum-subarray",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, find the contiguous subarray with the largest sum and return its sum.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴",
        "starter_code": {
            "python": "def max_sub_array(nums):\n    # your code here\n    pass",
            "javascript": "function maxSubArray(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[-2,1,-3,4,-1,2,1,-5,4]", "expected_output": "6", "is_hidden": False},
            {"input": "[1]", "expected_output": "1", "is_hidden": False},
            {"input": "[5,4,-1,7,8]", "expected_output": "23", "is_hidden": True},
        ],
    },
    {
        "title": "Product of Array Except Self",
        "slug": "product-of-array-except-self",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an array `nums`, return an array `answer` such that `answer[i]` equals the product of all elements except `nums[i]`. Solve in O(n) without division.",
        "constraints": "2 ≤ nums.length ≤ 10⁵\n-30 ≤ nums[i] ≤ 30",
        "starter_code": {
            "python": "def product_except_self(nums):\n    # your code here\n    pass",
            "javascript": "function productExceptSelf(nums) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,2,3,4]", "expected_output": "[24,12,8,6]", "is_hidden": False},
            {"input": "[-1,1,0,-3,3]", "expected_output": "[0,0,9,0,0]", "is_hidden": False},
            {"input": "[2,3]", "expected_output": "[3,2]", "is_hidden": True},
        ],
    },
    {
        "title": "Valid Palindrome",
        "slug": "valid-palindrome",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given a string `s`, return `true` if it is a palindrome after keeping only alphanumeric characters and ignoring case.",
        "constraints": "1 ≤ s.length ≤ 2 × 10⁵\ns consists of printable ASCII characters.",
        "starter_code": {
            "python": "def is_palindrome(s):\n    # your code here\n    pass",
            "javascript": "function isPalindrome(s) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": '"A man, a plan, a canal: Panama"', "expected_output": "true", "is_hidden": False},
            {"input": '"race a car"', "expected_output": "false", "is_hidden": False},
            {"input": '" "', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Move Zeroes",
        "slug": "move-zeroes",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given an integer array `nums`, move all zeroes to the end while maintaining the relative order of non-zero elements. Return the modified array.",
        "constraints": "1 ≤ nums.length ≤ 10⁴\n-2³¹ ≤ nums[i] ≤ 2³¹ - 1",
        "starter_code": {
            "python": "def move_zeroes(nums):\n    # modify nums in place, then return it\n    pass",
            "javascript": "function moveZeroes(nums) {\n    // modify in place and return\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[0,1,0,3,12]", "expected_output": "[1,3,12,0,0]", "is_hidden": False},
            {"input": "[0]", "expected_output": "[0]", "is_hidden": False},
            {"input": "[0,0,1]", "expected_output": "[1,0,0]", "is_hidden": True},
        ],
    },
    {
        "title": "Merge Sorted Array",
        "slug": "merge-sorted-array",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Merge two sorted arrays `nums1` (size m+n, last n elements are 0) and `nums2` (size n) into `nums1` in-place sorted. Return `nums1`.",
        "constraints": "0 ≤ m, n ≤ 200\n-10⁹ ≤ nums1[i], nums2[j] ≤ 10⁹",
        "starter_code": {
            "python": "def merge(nums1, m, nums2, n):\n    # merge nums2 into nums1 in-place\n    # return nums1\n    pass",
            "javascript": "function merge(nums1, m, nums2, n) {\n    // merge in place and return nums1\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "[1,2,3,0,0,0], 3, [2,5,6], 3", "expected_output": "[1,2,2,3,5,6]", "is_hidden": False},
            {"input": "[1], 1, [], 0", "expected_output": "[1]", "is_hidden": False},
            {"input": "[0], 0, [1], 1", "expected_output": "[1]", "is_hidden": True},
        ],
    },
    {
        "title": "Pascal's Triangle",
        "slug": "pascals-triangle",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given an integer `numRows`, return the first `numRows` of Pascal's triangle.",
        "constraints": "1 ≤ numRows ≤ 30",
        "starter_code": {
            "python": "def generate(numRows):\n    # your code here\n    pass",
            "javascript": "function generate(numRows) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "5", "expected_output": "[[1],[1,1],[1,2,1],[1,3,3,1],[1,4,6,4,1]]", "is_hidden": False},
            {"input": "1", "expected_output": "[[1]]", "is_hidden": False},
            {"input": "3", "expected_output": "[[1],[1,1],[1,2,1]]", "is_hidden": True},
        ],
    },
    {
        "title": "Jump Game",
        "slug": "jump-game-greedy",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an array `nums` where `nums[i]` is the maximum jump length from index `i`, return `true` if you can reach the last index starting from index 0.",
        "constraints": "1 ≤ nums.length ≤ 10⁴\n0 ≤ nums[i] ≤ 10⁵",
        "starter_code": {
            "python": "def can_jump(nums):\n    # your code here\n    pass",
            "javascript": "function canJump(nums) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[2,3,1,1,4]", "expected_output": "true", "is_hidden": False},
            {"input": "[3,2,1,0,4]", "expected_output": "false", "is_hidden": False},
            {"input": "[0]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Roman to Integer",
        "slug": "roman-to-integer",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given a Roman numeral string `s`, convert it to an integer. Roman symbols: I=1, V=5, X=10, L=50, C=100, D=500, M=1000. Subtraction applies when a smaller value precedes a larger one.",
        "constraints": "1 ≤ s.length ≤ 15\ns is a valid Roman numeral in range [1, 3999].",
        "starter_code": {
            "python": "def roman_to_int(s):\n    # your code here\n    pass",
            "javascript": "function romanToInt(s) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": '"III"', "expected_output": "3", "is_hidden": False},
            {"input": '"LVIII"', "expected_output": "58", "is_hidden": False},
            {"input": '"MCMXCIV"', "expected_output": "1994", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Common Prefix",
        "slug": "longest-common-prefix",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Write a function to find the longest common prefix string amongst an array of strings. Return an empty string if there is no common prefix.",
        "constraints": "1 ≤ strs.length ≤ 200\n0 ≤ strs[i].length ≤ 200\nAll characters are lowercase English letters.",
        "starter_code": {
            "python": "def longest_common_prefix(strs):\n    # your code here\n    pass",
            "javascript": "function longestCommonPrefix(strs) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": '["flower","flow","flight"]', "expected_output": "fl", "is_hidden": False},
            {"input": '["dog","racecar","car"]', "expected_output": "", "is_hidden": False},
            {"input": '["ab","a"]', "expected_output": "a", "is_hidden": True},
        ],
    },
    {
        "title": "Rotate Array",
        "slug": "rotate-array",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, rotate it to the right by `k` steps. Return the rotated array.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-2³¹ ≤ nums[i] ≤ 2³¹-1\n0 ≤ k ≤ 10⁵",
        "starter_code": {
            "python": "def rotate(nums, k):\n    # rotate nums in place and return it\n    pass",
            "javascript": "function rotate(nums, k) {\n    // rotate in place and return nums\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[1,2,3,4,5,6,7], 3", "expected_output": "[5,6,7,1,2,3,4]", "is_hidden": False},
            {"input": "[-1,-100,3,99], 2", "expected_output": "[3,99,-1,-100]", "is_hidden": False},
            {"input": "[1,2], 1", "expected_output": "[2,1]", "is_hidden": True},
        ],
    },
    {
        "title": "Length of Last Word",
        "slug": "length-of-last-word",
        "category_slug": "arrays-strings",
        "difficulty": "easy",
        "description": "Given a string `s` consisting of words and spaces, return the length of the last word.",
        "constraints": "1 ≤ s.length ≤ 10⁴\ns consists of English letters and spaces.\nAt least one word exists.",
        "starter_code": {
            "python": "def length_of_last_word(s):\n    # your code here\n    pass",
            "javascript": "function lengthOfLastWord(s) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": '"Hello World"', "expected_output": "5", "is_hidden": False},
            {"input": '"   fly me   to   the moon  "', "expected_output": "4", "is_hidden": False},
            {"input": '"luffy is still joyboy"', "expected_output": "6", "is_hidden": True},
        ],
    },
    {
        "title": "Spiral Matrix",
        "slug": "spiral-matrix",
        "category_slug": "arrays-strings",
        "difficulty": "medium",
        "description": "Given an `m x n` matrix, return all elements in spiral order.",
        "constraints": "m == matrix.length\n1 ≤ m, n ≤ 10\n-100 ≤ matrix[i][j] ≤ 100",
        "starter_code": {
            "python": "def spiral_order(matrix):\n    # your code here\n    pass",
            "javascript": "function spiralOrder(matrix) {\n    // your code here\n}",
        },
        "order_index": 13,
        "test_cases": [
            {"input": "[[1,2,3],[4,5,6],[7,8,9]]", "expected_output": "[1,2,3,6,9,8,7,4,5]", "is_hidden": False},
            {"input": "[[1,2,3,4],[5,6,7,8],[9,10,11,12]]", "expected_output": "[1,2,3,4,8,12,11,10,9,5,6,7]", "is_hidden": False},
            {"input": "[[1]]", "expected_output": "[1]", "is_hidden": True},
        ],
    },
    {
        "title": "Trapping Rain Water",
        "slug": "trapping-rain-water",
        "category_slug": "arrays-strings",
        "difficulty": "hard",
        "description": "Given an array `height` representing an elevation map, compute how much water can be trapped after raining.",
        "constraints": "1 ≤ height.length ≤ 2 × 10⁴\n0 ≤ height[i] ≤ 10⁵",
        "starter_code": {
            "python": "def trap(height):\n    # your code here\n    pass",
            "javascript": "function trap(height) {\n    // your code here\n}",
        },
        "order_index": 14,
        "test_cases": [
            {"input": "[0,1,0,2,1,0,1,3,2,1,2,1]", "expected_output": "6", "is_hidden": False},
            {"input": "[4,2,0,3,2,5]", "expected_output": "9", "is_hidden": False},
            {"input": "[3,0,2,0,4]", "expected_output": "7", "is_hidden": True},
        ],
    },

    # ─── HASHING (13) ────────────────────────────────────────────────────────────

    {
        "title": "Contains Duplicate",
        "slug": "contains-duplicate",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given an integer array `nums`, return `true` if any value appears at least twice.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁹ ≤ nums[i] ≤ 10⁹",
        "starter_code": {
            "python": "def contains_duplicate(nums):\n    # your code here\n    pass",
            "javascript": "function containsDuplicate(nums) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[1,2,3,1]", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2,3,4]", "expected_output": "false", "is_hidden": False},
            {"input": "[1,1,1,3,3,4,3,2,4,2]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Valid Anagram",
        "slug": "valid-anagram",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given two strings `s` and `t`, return `true` if `t` is an anagram of `s`.",
        "constraints": "1 ≤ s.length, t.length ≤ 5 × 10⁴\ns and t consist of lowercase English letters.",
        "starter_code": {
            "python": "def is_anagram(s, t):\n    # your code here\n    pass",
            "javascript": "function isAnagram(s, t) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": '"anagram", "nagaram"', "expected_output": "true", "is_hidden": False},
            {"input": '"rat", "car"', "expected_output": "false", "is_hidden": False},
            {"input": '"a", "a"', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Group Anagrams",
        "slug": "group-anagrams",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given an array of strings `strs`, group the anagrams together. You can return the answer in any order.",
        "constraints": "1 ≤ strs.length ≤ 10⁴\n0 ≤ strs[i].length ≤ 100\nstrs[i] consists of lowercase English letters.",
        "starter_code": {
            "python": "def group_anagrams(strs):\n    # your code here\n    pass",
            "javascript": "function groupAnagrams(strs) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": '["eat","tea","tan","ate","nat","bat"]', "expected_output": '[["bat"],["nat","tan"],["ate","eat","tea"]]', "is_hidden": False},
            {"input": '[""]', "expected_output": '[[""]]', "is_hidden": False},
            {"input": '["a"]', "expected_output": '[["a"]]', "is_hidden": True},
        ],
    },
    {
        "title": "Top K Frequent Elements",
        "slug": "top-k-frequent",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given an integer array `nums` and an integer `k`, return the `k` most frequent elements in any order.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴\n1 ≤ k ≤ number of unique elements",
        "starter_code": {
            "python": "def top_k_frequent(nums, k):\n    # your code here\n    pass",
            "javascript": "function topKFrequent(nums, k) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,1,1,2,2,3], 2", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[1], 1", "expected_output": "[1]", "is_hidden": False},
            {"input": "[4,1,-1,2,-1,2,3], 2", "expected_output": "[-1,2]", "is_hidden": True},
        ],
    },
    {
        "title": "Happy Number",
        "slug": "happy-number",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "A number is happy if repeatedly replacing it with the sum of squares of its digits eventually reaches 1. Return `true` if `n` is a happy number.",
        "constraints": "1 ≤ n ≤ 2³¹ - 1",
        "starter_code": {
            "python": "def is_happy(n):\n    # your code here\n    pass",
            "javascript": "function isHappy(n) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "19", "expected_output": "true", "is_hidden": False},
            {"input": "2", "expected_output": "false", "is_hidden": False},
            {"input": "1", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Isomorphic Strings",
        "slug": "isomorphic-strings",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given two strings `s` and `t`, return `true` if they are isomorphic — characters in `s` can be replaced to get `t` with a consistent one-to-one mapping.",
        "constraints": "1 ≤ s.length ≤ 5 × 10⁴\nt.length == s.length\nCharacters are valid ASCII.",
        "starter_code": {
            "python": "def is_isomorphic(s, t):\n    # your code here\n    pass",
            "javascript": "function isIsomorphic(s, t) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": '"egg", "add"', "expected_output": "true", "is_hidden": False},
            {"input": '"foo", "bar"', "expected_output": "false", "is_hidden": False},
            {"input": '"paper", "title"', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Word Pattern",
        "slug": "word-pattern",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given a pattern and a string `s`, return `true` if `s` follows the same pattern — there is a bijection between each letter in `pattern` and each word in `s`.",
        "constraints": "1 ≤ pattern.length ≤ 300\n1 ≤ s.length ≤ 3000\npattern and s contain only lowercase letters.",
        "starter_code": {
            "python": "def word_pattern(pattern, s):\n    # your code here\n    pass",
            "javascript": "function wordPattern(pattern, s) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": '"abba", "dog cat cat dog"', "expected_output": "true", "is_hidden": False},
            {"input": '"abba", "dog cat cat fish"', "expected_output": "false", "is_hidden": False},
            {"input": '"aaaa", "dog cat cat dog"', "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Ransom Note",
        "slug": "ransom-note",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given two strings `ransomNote` and `magazine`, return `true` if `ransomNote` can be constructed using letters from `magazine` (each letter used only once).",
        "constraints": "1 ≤ ransomNote.length, magazine.length ≤ 10⁵\nStrings consist of lowercase English letters.",
        "starter_code": {
            "python": "def can_construct(ransomNote, magazine):\n    # your code here\n    pass",
            "javascript": "function canConstruct(ransomNote, magazine) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": '"a", "b"', "expected_output": "false", "is_hidden": False},
            {"input": '"aa", "ab"', "expected_output": "false", "is_hidden": False},
            {"input": '"aa", "aab"', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Consecutive Sequence",
        "slug": "longest-consecutive-sequence",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given an unsorted array `nums`, return the length of the longest consecutive elements sequence. Must run in O(n).",
        "constraints": "0 ≤ nums.length ≤ 10⁵\n-10⁹ ≤ nums[i] ≤ 10⁹",
        "starter_code": {
            "python": "def longest_consecutive(nums):\n    # your code here\n    pass",
            "javascript": "function longestConsecutive(nums) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[100,4,200,1,3,2]", "expected_output": "4", "is_hidden": False},
            {"input": "[0,3,7,2,5,8,4,6,0,1]", "expected_output": "9", "is_hidden": False},
            {"input": "[]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Subarray Sum Equals K",
        "slug": "subarray-sum-equals-k",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given an integer array `nums` and an integer `k`, return the total number of subarrays whose sum equals `k`.",
        "constraints": "1 ≤ nums.length ≤ 2 × 10⁴\n-1000 ≤ nums[i] ≤ 1000\n-10⁷ ≤ k ≤ 10⁷",
        "starter_code": {
            "python": "def subarray_sum(nums, k):\n    # your code here\n    pass",
            "javascript": "function subarraySum(nums, k) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[1,1,1], 2", "expected_output": "2", "is_hidden": False},
            {"input": "[1,2,3], 3", "expected_output": "2", "is_hidden": False},
            {"input": "[1], 0", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Find All Anagrams in a String",
        "slug": "find-all-anagrams",
        "category_slug": "hashing",
        "difficulty": "medium",
        "description": "Given strings `s` and `p`, return a list of start indices of `p`'s anagrams in `s`.",
        "constraints": "1 ≤ s.length, p.length ≤ 3 × 10⁴\ns and p consist of lowercase English letters.",
        "starter_code": {
            "python": "def find_anagrams(s, p):\n    # your code here\n    pass",
            "javascript": "function findAnagrams(s, p) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": '"cbaebabacd", "abc"', "expected_output": "[0,6]", "is_hidden": False},
            {"input": '"abab", "ab"', "expected_output": "[0,1,2]", "is_hidden": False},
            {"input": '"aa", "bb"', "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Intersection of Two Arrays",
        "slug": "intersection-two-arrays",
        "category_slug": "hashing",
        "difficulty": "easy",
        "description": "Given two integer arrays `nums1` and `nums2`, return their intersection — each element in the result must be unique.",
        "constraints": "1 ≤ nums1.length, nums2.length ≤ 1000\n0 ≤ nums1[i], nums2[i] ≤ 1000",
        "starter_code": {
            "python": "def intersection(nums1, nums2):\n    # return sorted list of unique common elements\n    pass",
            "javascript": "function intersection(nums1, nums2) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[1,2,2,1], [2,2]", "expected_output": "[2]", "is_hidden": False},
            {"input": "[4,9,5], [9,4,9,8,4]", "expected_output": "[4,9]", "is_hidden": False},
            {"input": "[1,2,3], [4,5,6]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "First Missing Positive",
        "slug": "first-missing-positive",
        "category_slug": "hashing",
        "difficulty": "hard",
        "description": "Given an unsorted integer array `nums`, return the smallest missing positive integer. Must run in O(n) time using O(1) extra space.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-2³¹ ≤ nums[i] ≤ 2³¹ - 1",
        "starter_code": {
            "python": "def first_missing_positive(nums):\n    # your code here\n    pass",
            "javascript": "function firstMissingPositive(nums) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": "[1,2,0]", "expected_output": "3", "is_hidden": False},
            {"input": "[3,4,-1,1]", "expected_output": "2", "is_hidden": False},
            {"input": "[7,8,9,11,12]", "expected_output": "1", "is_hidden": True},
        ],
    },

    # ─── TWO POINTERS (13) ────────────────────────────────────────────────────────

    {
        "title": "Valid Palindrome II",
        "slug": "valid-palindrome-ii",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Given a string `s`, return `true` if it can become a palindrome by deleting at most one character.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns consists of lowercase English letters.",
        "starter_code": {
            "python": "def valid_palindrome(s):\n    # your code here\n    pass",
            "javascript": "function validPalindrome(s) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": '"aba"', "expected_output": "true", "is_hidden": False},
            {"input": '"abca"', "expected_output": "true", "is_hidden": False},
            {"input": '"abc"', "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Two Sum II - Sorted Array",
        "slug": "two-sum-ii",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given a 1-indexed sorted array `numbers`, find two numbers that add up to `target` and return their 1-based indices.",
        "constraints": "2 ≤ numbers.length ≤ 3 × 10⁴\n-1000 ≤ numbers[i] ≤ 1000\nExactly one solution exists.",
        "starter_code": {
            "python": "def two_sum_sorted(numbers, target):\n    # your code here\n    pass",
            "javascript": "function twoSum(numbers, target) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[2,7,11,15], 9", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[2,3,4], 6", "expected_output": "[1,3]", "is_hidden": False},
            {"input": "[-1,0], -1", "expected_output": "[1,2]", "is_hidden": True},
        ],
    },
    {
        "title": "3Sum",
        "slug": "three-sum",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, return all unique triplets `[nums[i], nums[j], nums[k]]` such that they sum to zero.",
        "constraints": "3 ≤ nums.length ≤ 3000\n-10⁵ ≤ nums[i] ≤ 10⁵",
        "starter_code": {
            "python": "def three_sum(nums):\n    # your code here\n    pass",
            "javascript": "function threeSum(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[-1,0,1,2,-1,-4]", "expected_output": "[[-1,-1,2],[-1,0,1]]", "is_hidden": False},
            {"input": "[0,1,1]", "expected_output": "[]", "is_hidden": False},
            {"input": "[0,0,0]", "expected_output": "[[0,0,0]]", "is_hidden": True},
        ],
    },
    {
        "title": "Container With Most Water",
        "slug": "container-most-water",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given an array `height` of n integers, find two lines that together with the x-axis form a container that holds the most water.",
        "constraints": "2 ≤ height.length ≤ 10⁵\n0 ≤ height[i] ≤ 10⁴",
        "starter_code": {
            "python": "def max_area(height):\n    # your code here\n    pass",
            "javascript": "function maxArea(height) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,8,6,2,5,4,8,3,7]", "expected_output": "49", "is_hidden": False},
            {"input": "[1,1]", "expected_output": "1", "is_hidden": False},
            {"input": "[4,3,2,1,4]", "expected_output": "16", "is_hidden": True},
        ],
    },
    {
        "title": "Remove Duplicates from Sorted Array",
        "slug": "remove-duplicates-sorted",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Given a sorted array `nums`, remove duplicates in-place so each element appears only once. Return the number of unique elements `k`.",
        "constraints": "1 ≤ nums.length ≤ 3 × 10⁴\n-100 ≤ nums[i] ≤ 100\nnums is sorted in non-decreasing order.",
        "starter_code": {
            "python": "def remove_duplicates(nums):\n    # modify nums in place and return k\n    pass",
            "javascript": "function removeDuplicates(nums) {\n    // modify in place and return k\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[1,1,2]", "expected_output": "2", "is_hidden": False},
            {"input": "[0,0,1,1,1,2,2,3,3,4]", "expected_output": "5", "is_hidden": False},
            {"input": "[1]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Reverse String",
        "slug": "reverse-string",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Write a function that reverses a character array `s` in-place and returns it.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns[i] is a printable ASCII character.",
        "starter_code": {
            "python": "def reverse_string(s):\n    # reverse s in place and return it\n    pass",
            "javascript": "function reverseString(s) {\n    // reverse in place and return s\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": '["h","e","l","l","o"]', "expected_output": '["o","l","l","e","h"]', "is_hidden": False},
            {"input": '["H","a","n","n","a","h"]', "expected_output": '["h","a","n","n","a","H"]', "is_hidden": False},
            {"input": '["a"]', "expected_output": '["a"]', "is_hidden": True},
        ],
    },
    {
        "title": "Sort Colors",
        "slug": "sort-colors",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given an array `nums` with values 0 (red), 1 (white), and 2 (blue), sort them in-place in the order red, white, blue. Return the sorted array.",
        "constraints": "1 ≤ nums.length ≤ 300\nnums[i] is 0, 1, or 2.",
        "starter_code": {
            "python": "def sort_colors(nums):\n    # sort nums in place and return it\n    pass",
            "javascript": "function sortColors(nums) {\n    // sort in place and return nums\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "[2,0,2,1,1,0]", "expected_output": "[0,0,1,1,2,2]", "is_hidden": False},
            {"input": "[2,0,1]", "expected_output": "[0,1,2]", "is_hidden": False},
            {"input": "[1,2,0]", "expected_output": "[0,1,2]", "is_hidden": True},
        ],
    },
    {
        "title": "Squares of a Sorted Array",
        "slug": "squares-sorted-array",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Given an integer array `nums` sorted in non-decreasing order, return an array of the squares of each number sorted in non-decreasing order.",
        "constraints": "1 ≤ nums.length ≤ 10⁴\n-10⁴ ≤ nums[i] ≤ 10⁴\nnums is sorted in non-decreasing order.",
        "starter_code": {
            "python": "def sorted_squares(nums):\n    # your code here\n    pass",
            "javascript": "function sortedSquares(nums) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[-4,-1,0,3,10]", "expected_output": "[0,1,9,16,100]", "is_hidden": False},
            {"input": "[-7,-3,2,3,11]", "expected_output": "[4,9,9,49,121]", "is_hidden": False},
            {"input": "[1,2,3]", "expected_output": "[1,4,9]", "is_hidden": True},
        ],
    },
    {
        "title": "Boats to Save People",
        "slug": "boats-to-save-people",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Each boat carries at most 2 people with combined weight ≤ `limit`. Given `people` weights, return the minimum number of boats.",
        "constraints": "1 ≤ people.length ≤ 5 × 10⁴\n1 ≤ people[i] ≤ limit ≤ 3 × 10⁴",
        "starter_code": {
            "python": "def num_rescue_boats(people, limit):\n    # your code here\n    pass",
            "javascript": "function numRescueBoats(people, limit) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[1,2], 3", "expected_output": "1", "is_hidden": False},
            {"input": "[3,2,2,1], 3", "expected_output": "3", "is_hidden": False},
            {"input": "[3,5,3,4], 5", "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "Remove Element",
        "slug": "remove-element",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Given an array `nums` and a value `val`, remove all occurrences of `val` in-place and return the count of remaining elements.",
        "constraints": "0 ≤ nums.length ≤ 100\n0 ≤ nums[i] ≤ 50\n0 ≤ val ≤ 100",
        "starter_code": {
            "python": "def remove_element(nums, val):\n    # your code here\n    pass",
            "javascript": "function removeElement(nums, val) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[3,2,2,3], 3", "expected_output": "2", "is_hidden": False},
            {"input": "[0,1,2,2,3,0,4,2], 2", "expected_output": "5", "is_hidden": False},
            {"input": "[], 0", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Is Subsequence",
        "slug": "is-subsequence",
        "category_slug": "two-pointers",
        "difficulty": "easy",
        "description": "Given strings `s` and `t`, return `true` if `s` is a subsequence of `t`.",
        "constraints": "0 ≤ s.length ≤ 100\n0 ≤ t.length ≤ 10⁴\nBoth strings consist of lowercase English letters.",
        "starter_code": {
            "python": "def is_subsequence(s, t):\n    # your code here\n    pass",
            "javascript": "function isSubsequence(s, t) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": '"abc", "ahbgdc"', "expected_output": "true", "is_hidden": False},
            {"input": '"axc", "ahbgdc"', "expected_output": "false", "is_hidden": False},
            {"input": '"", "ahbgdc"', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Partition Labels",
        "slug": "partition-labels",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Partition string `s` into as many parts as possible so each letter appears in at most one part. Return the sizes of these parts.",
        "constraints": "1 ≤ s.length ≤ 500\ns consists of lowercase English letters.",
        "starter_code": {
            "python": "def partition_labels(s):\n    # your code here\n    pass",
            "javascript": "function partitionLabels(s) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": '"ababcbacadefegdehijhklij"', "expected_output": "[9,7,8]", "is_hidden": False},
            {"input": '"eccbbbbdec"', "expected_output": "[10]", "is_hidden": False},
            {"input": '"a"', "expected_output": "[1]", "is_hidden": True},
        ],
    },
    {
        "title": "4Sum",
        "slug": "four-sum",
        "category_slug": "two-pointers",
        "difficulty": "medium",
        "description": "Given an integer array `nums` and a target, return all unique quadruplets `[a,b,c,d]` such that `a+b+c+d == target`.",
        "constraints": "1 ≤ nums.length ≤ 200\n-10⁹ ≤ nums[i] ≤ 10⁹\n-10⁹ ≤ target ≤ 10⁹",
        "starter_code": {
            "python": "def four_sum(nums, target):\n    # your code here\n    pass",
            "javascript": "function fourSum(nums, target) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": "[1,0,-1,0,-2,2], 0", "expected_output": "[[-2,-1,1,2],[-2,0,0,2],[-1,0,0,1]]", "is_hidden": False},
            {"input": "[2,2,2,2,2], 8", "expected_output": "[[2,2,2,2]]", "is_hidden": False},
            {"input": "[0,0,0,0], 0", "expected_output": "[[0,0,0,0]]", "is_hidden": True},
        ],
    },

    # ─── SLIDING WINDOW (13) ─────────────────────────────────────────────────────

    {
        "title": "Minimum Size Subarray Sum",
        "slug": "min-size-subarray-sum",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given an array of positive integers `nums` and a positive integer `target`, return the minimal length of a contiguous subarray whose sum ≥ `target`. Return 0 if no such subarray exists.",
        "constraints": "1 ≤ target ≤ 10⁹\n1 ≤ nums.length ≤ 10⁵\n1 ≤ nums[i] ≤ 10⁴",
        "starter_code": {
            "python": "def min_sub_array_len(target, nums):\n    # your code here\n    pass",
            "javascript": "function minSubArrayLen(target, nums) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "7, [2,3,1,2,4,3]", "expected_output": "2", "is_hidden": False},
            {"input": "4, [1,4,4]", "expected_output": "1", "is_hidden": False},
            {"input": "11, [1,1,1,1,1,1,1,1]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Substring Without Repeating Characters",
        "slug": "longest-substring-no-repeat",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given a string `s`, find the length of the longest substring without repeating characters.",
        "constraints": "0 ≤ s.length ≤ 5 × 10⁴\ns consists of English letters, digits, symbols and spaces.",
        "starter_code": {
            "python": "def length_of_longest_substring(s):\n    # your code here\n    pass",
            "javascript": "function lengthOfLongestSubstring(s) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": '"abcabcbb"', "expected_output": "3", "is_hidden": False},
            {"input": '"bbbbb"', "expected_output": "1", "is_hidden": False},
            {"input": '"pwwkew"', "expected_output": "3", "is_hidden": True},
        ],
    },
    {
        "title": "Minimum Window Substring",
        "slug": "min-window-substring",
        "category_slug": "sliding-window",
        "difficulty": "hard",
        "description": "Given strings `s` and `t`, return the minimum window substring of `s` that contains every character of `t`. Return empty string if none exists.",
        "constraints": "1 ≤ s.length, t.length ≤ 10⁵\ns and t consist of uppercase and lowercase English letters.",
        "starter_code": {
            "python": "def min_window(s, t):\n    # your code here\n    pass",
            "javascript": "function minWindow(s, t) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": '"ADOBECODEBANC", "ABC"', "expected_output": "BANC", "is_hidden": False},
            {"input": '"a", "a"', "expected_output": "a", "is_hidden": False},
            {"input": '"a", "aa"', "expected_output": "", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Repeating Character Replacement",
        "slug": "longest-repeating-replacement",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given a string `s` and integer `k`, you can replace at most `k` characters. Return the length of the longest substring with all same letters after replacements.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns consists of uppercase English letters.\n0 ≤ k ≤ s.length",
        "starter_code": {
            "python": "def character_replacement(s, k):\n    # your code here\n    pass",
            "javascript": "function characterReplacement(s, k) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": '"ABAB", 2', "expected_output": "4", "is_hidden": False},
            {"input": '"AABABBA", 1', "expected_output": "4", "is_hidden": False},
            {"input": '"AAAA", 2', "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "Max Consecutive Ones III",
        "slug": "max-consecutive-ones-iii",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given a binary array `nums` and an integer `k`, return the maximum number of consecutive 1s if you can flip at most `k` 0s.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\nnums[i] is 0 or 1.\n0 ≤ k ≤ nums.length",
        "starter_code": {
            "python": "def longest_ones(nums, k):\n    # your code here\n    pass",
            "javascript": "function longestOnes(nums, k) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[1,1,1,0,0,0,1,1,1,1,0], 2", "expected_output": "6", "is_hidden": False},
            {"input": "[0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], 3", "expected_output": "10", "is_hidden": False},
            {"input": "[1,1,1], 0", "expected_output": "3", "is_hidden": True},
        ],
    },
    {
        "title": "Permutation in String",
        "slug": "permutation-in-string",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given strings `s1` and `s2`, return `true` if `s2` contains a permutation of `s1` as a substring.",
        "constraints": "1 ≤ s1.length, s2.length ≤ 10⁴\ns1 and s2 consist of lowercase English letters.",
        "starter_code": {
            "python": "def check_inclusion(s1, s2):\n    # your code here\n    pass",
            "javascript": "function checkInclusion(s1, s2) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": '"ab", "eidbaooo"', "expected_output": "true", "is_hidden": False},
            {"input": '"ab", "eidboaoo"', "expected_output": "false", "is_hidden": False},
            {"input": '"adc", "dcda"', "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Fruit Into Baskets",
        "slug": "fruit-into-baskets",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "You have two baskets, each holding only one type of fruit. Given `fruits` array, pick the maximum number of fruits in any subarray using at most 2 distinct types.",
        "constraints": "1 ≤ fruits.length ≤ 10⁵\n0 ≤ fruits[i] < fruits.length",
        "starter_code": {
            "python": "def total_fruit(fruits):\n    # your code here\n    pass",
            "javascript": "function totalFruit(fruits) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "[1,2,1]", "expected_output": "3", "is_hidden": False},
            {"input": "[0,1,2,2]", "expected_output": "3", "is_hidden": False},
            {"input": "[1,2,3,2,2]", "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "Maximum Average Subarray I",
        "slug": "max-average-subarray",
        "category_slug": "sliding-window",
        "difficulty": "easy",
        "description": "Given an integer array `nums` and an integer `k`, find a contiguous subarray of length `k` with the maximum average value and return it.",
        "constraints": "1 ≤ k ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴",
        "starter_code": {
            "python": "def find_max_average(nums, k):\n    # your code here\n    pass",
            "javascript": "function findMaxAverage(nums, k) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[1,12,-5,-6,50,3], 4", "expected_output": "12.75", "is_hidden": False},
            {"input": "[5], 1", "expected_output": "5.0", "is_hidden": False},
            {"input": "[0,4,0,3,2], 1", "expected_output": "4.0", "is_hidden": True},
        ],
    },
    {
        "title": "Sliding Window Maximum",
        "slug": "sliding-window-maximum",
        "category_slug": "sliding-window",
        "difficulty": "hard",
        "description": "Given an integer array `nums` and a sliding window of size `k`, return the max value in each window position.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴\n1 ≤ k ≤ nums.length",
        "starter_code": {
            "python": "def max_sliding_window(nums, k):\n    # your code here\n    pass",
            "javascript": "function maxSlidingWindow(nums, k) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[1,3,-1,-3,5,3,6,7], 3", "expected_output": "[3,3,5,5,6,7]", "is_hidden": False},
            {"input": "[1], 1", "expected_output": "[1]", "is_hidden": False},
            {"input": "[1,-1], 1", "expected_output": "[1,-1]", "is_hidden": True},
        ],
    },
    {
        "title": "Contains Duplicate II",
        "slug": "contains-duplicate-ii",
        "category_slug": "sliding-window",
        "difficulty": "easy",
        "description": "Given an integer array `nums` and integer `k`, return `true` if there are two distinct indices `i` and `j` such that `nums[i] == nums[j]` and `abs(i-j) <= k`.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\n-10⁹ ≤ nums[i] ≤ 10⁹\n0 ≤ k ≤ 10⁵",
        "starter_code": {
            "python": "def contains_nearby_duplicate(nums, k):\n    # your code here\n    pass",
            "javascript": "function containsNearbyDuplicate(nums, k) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[1,2,3,1], 3", "expected_output": "true", "is_hidden": False},
            {"input": "[1,0,1,1], 1", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2,3,1,2,3], 2", "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Subarray Product Less Than K",
        "slug": "subarray-product-less-k",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given an array of integers `nums` and an integer `k`, return the number of contiguous subarrays where the product of all elements is strictly less than `k`.",
        "constraints": "1 ≤ nums.length ≤ 3 × 10⁴\n1 ≤ nums[i] ≤ 1000\n0 ≤ k ≤ 10⁶",
        "starter_code": {
            "python": "def num_subarray_product_less_than_k(nums, k):\n    # your code here\n    pass",
            "javascript": "function numSubarrayProductLessThanK(nums, k) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "[10,5,2,6], 100", "expected_output": "8", "is_hidden": False},
            {"input": "[1,2,3], 0", "expected_output": "0", "is_hidden": False},
            {"input": "[1,1,1], 2", "expected_output": "6", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Substring with At Most Two Distinct Characters",
        "slug": "longest-two-distinct",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given a string `s`, return the length of the longest substring with at most two distinct characters.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns consists of English letters.",
        "starter_code": {
            "python": "def length_of_longest_substring_two_distinct(s):\n    # your code here\n    pass",
            "javascript": "function lengthOfLongestSubstringTwoDistinct(s) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": '"eceba"', "expected_output": "3", "is_hidden": False},
            {"input": '"ccaabbb"', "expected_output": "5", "is_hidden": False},
            {"input": '"a"', "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Maximum Number of Vowels in a Substring",
        "slug": "max-vowels-substring",
        "category_slug": "sliding-window",
        "difficulty": "medium",
        "description": "Given a string `s` and integer `k`, return the maximum number of vowels (a, e, i, o, u) in any substring of length `k`.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns consists of lowercase English letters.\n1 ≤ k ≤ s.length",
        "starter_code": {
            "python": "def max_vowels(s, k):\n    # your code here\n    pass",
            "javascript": "function maxVowels(s, k) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": '"abciiidef", 3', "expected_output": "3", "is_hidden": False},
            {"input": '"aeiou", 2', "expected_output": "2", "is_hidden": False},
            {"input": '"leetcode", 3', "expected_output": "2", "is_hidden": True},
        ],
    },

    # ─── STACK & QUEUE (13) ──────────────────────────────────────────────────────

    {
        "title": "Valid Parentheses",
        "slug": "valid-parentheses",
        "category_slug": "stack-queue",
        "difficulty": "easy",
        "description": "Given a string `s` containing `(`, `)`, `{`, `}`, `[`, `]`, return `true` if the input string is valid (brackets closed in correct order).",
        "constraints": "1 ≤ s.length ≤ 10⁴\ns consists of parentheses characters only.",
        "starter_code": {
            "python": "def is_valid(s):\n    # your code here\n    pass",
            "javascript": "function isValid(s) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": '"()"', "expected_output": "true", "is_hidden": False},
            {"input": '"()[]{}"', "expected_output": "true", "is_hidden": False},
            {"input": '"(]"', "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Evaluate Reverse Polish Notation",
        "slug": "evaluate-rpn",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Evaluate an expression in Reverse Polish Notation given as a list of tokens. Operators are `+`, `-`, `*`, `/` (integer division truncating toward zero).",
        "constraints": "1 ≤ tokens.length ≤ 10⁴\ntokens[i] is an integer or one of `+ - * /`.",
        "starter_code": {
            "python": "def eval_rpn(tokens):\n    # your code here\n    pass",
            "javascript": "function evalRPN(tokens) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": '["2","1","+","3","*"]', "expected_output": "9", "is_hidden": False},
            {"input": '["4","13","5","/","+"]', "expected_output": "6", "is_hidden": False},
            {"input": '["10","6","9","3","+","-11","*","/","*","17","+","5","+"]', "expected_output": "22", "is_hidden": True},
        ],
    },
    {
        "title": "Daily Temperatures",
        "slug": "daily-temperatures",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Given an array `temperatures`, return an array `answer` where `answer[i]` is the number of days until a warmer temperature. If no future warmer day exists, answer[i] = 0.",
        "constraints": "1 ≤ temperatures.length ≤ 10⁵\n30 ≤ temperatures[i] ≤ 100",
        "starter_code": {
            "python": "def daily_temperatures(temperatures):\n    # your code here\n    pass",
            "javascript": "function dailyTemperatures(temperatures) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[73,74,75,71,69,72,76,73]", "expected_output": "[1,1,4,2,1,1,0,0]", "is_hidden": False},
            {"input": "[30,40,50,60]", "expected_output": "[1,1,1,0]", "is_hidden": False},
            {"input": "[30,60,90]", "expected_output": "[1,1,0]", "is_hidden": True},
        ],
    },
    {
        "title": "Largest Rectangle in Histogram",
        "slug": "largest-rectangle-histogram",
        "category_slug": "stack-queue",
        "difficulty": "hard",
        "description": "Given an array `heights` representing the histogram's bar heights (each bar width = 1), return the area of the largest rectangle in the histogram.",
        "constraints": "1 ≤ heights.length ≤ 10⁵\n0 ≤ heights[i] ≤ 10⁴",
        "starter_code": {
            "python": "def largest_rectangle_area(heights):\n    # your code here\n    pass",
            "javascript": "function largestRectangleArea(heights) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[2,1,5,6,2,3]", "expected_output": "10", "is_hidden": False},
            {"input": "[2,4]", "expected_output": "4", "is_hidden": False},
            {"input": "[1,1]", "expected_output": "2", "is_hidden": True},
        ],
    },
    {
        "title": "Next Greater Element I",
        "slug": "next-greater-element-i",
        "category_slug": "stack-queue",
        "difficulty": "easy",
        "description": "For each element in `nums1` (a subset of `nums2`), find the next greater element in `nums2`. Return -1 if no greater element exists to the right.",
        "constraints": "1 ≤ nums1.length ≤ nums2.length ≤ 1000\n0 ≤ nums1[i], nums2[i] ≤ 10⁴\nAll integers in nums2 are unique.",
        "starter_code": {
            "python": "def next_greater_element(nums1, nums2):\n    # your code here\n    pass",
            "javascript": "function nextGreaterElement(nums1, nums2) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[4,1,2], [1,3,4,2]", "expected_output": "[-1,3,-1]", "is_hidden": False},
            {"input": "[2,4], [1,2,3,4]", "expected_output": "[3,-1]", "is_hidden": False},
            {"input": "[1], [1,3,5]", "expected_output": "[3]", "is_hidden": True},
        ],
    },
    {
        "title": "Asteroid Collision",
        "slug": "asteroid-collision",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Given `asteroids` where positive = right, negative = left (same speed). When opposite-direction asteroids meet, the smaller explodes (equal = both). Return the surviving asteroids.",
        "constraints": "2 ≤ asteroids.length ≤ 10⁴\n-1000 ≤ asteroids[i] ≤ 1000\nasteroids[i] ≠ 0",
        "starter_code": {
            "python": "def asteroid_collision(asteroids):\n    # your code here\n    pass",
            "javascript": "function asteroidCollision(asteroids) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[5,10,-5]", "expected_output": "[5,10]", "is_hidden": False},
            {"input": "[8,-8]", "expected_output": "[]", "is_hidden": False},
            {"input": "[10,2,-5]", "expected_output": "[10]", "is_hidden": True},
        ],
    },
    {
        "title": "Decode String",
        "slug": "decode-string",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Given an encoded string like `k[encoded_string]`, return the decoded string. The encoding rule is: repeat `encoded_string` exactly `k` times.",
        "constraints": "1 ≤ s.length ≤ 30\ns consists of digits, lowercase letters, and square brackets.\nk is a positive integer ≤ 300.",
        "starter_code": {
            "python": "def decode_string(s):\n    # your code here\n    pass",
            "javascript": "function decodeString(s) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": '"3[a]2[bc]"', "expected_output": "aaabcbc", "is_hidden": False},
            {"input": '"3[a2[c]]"', "expected_output": "accaccacc", "is_hidden": False},
            {"input": '"2[abc]3[cd]ef"', "expected_output": "abcabccdcdcdef", "is_hidden": True},
        ],
    },
    {
        "title": "Remove All Adjacent Duplicates in String",
        "slug": "remove-adjacent-duplicates",
        "category_slug": "stack-queue",
        "difficulty": "easy",
        "description": "Given a string `s`, repeatedly remove adjacent duplicate pairs until no more remain. Return the final string.",
        "constraints": "1 ≤ s.length ≤ 10⁵\ns consists of lowercase English letters.",
        "starter_code": {
            "python": "def remove_duplicates(s):\n    # your code here\n    pass",
            "javascript": "function removeDuplicates(s) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": '"abbaca"', "expected_output": "ca", "is_hidden": False},
            {"input": '"azxxzy"', "expected_output": "ay", "is_hidden": False},
            {"input": '"aabbcc"', "expected_output": "", "is_hidden": True},
        ],
    },
    {
        "title": "Basic Calculator II",
        "slug": "basic-calculator-ii",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Implement a basic calculator to evaluate a string expression with `+`, `-`, `*`, `/` and non-negative integers. Integer division truncates toward zero.",
        "constraints": "1 ≤ s.length ≤ 3 × 10⁵\ns consists of digits, `+`, `-`, `*`, `/`, and spaces.",
        "starter_code": {
            "python": "def calculate(s):\n    # your code here\n    pass",
            "javascript": "function calculate(s) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": '"3+2*2"', "expected_output": "7", "is_hidden": False},
            {"input": '" 3/2 "', "expected_output": "1", "is_hidden": False},
            {"input": '" 3+5 / 2 "', "expected_output": "5", "is_hidden": True},
        ],
    },
    {
        "title": "Car Fleet",
        "slug": "car-fleet",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Given `target` distance, car `position`s and `speed`s, a faster car that catches a slower one becomes a fleet. Return the number of fleets that arrive at the target.",
        "constraints": "1 ≤ target ≤ 10⁶\n1 ≤ position.length = speed.length ≤ 10⁵\nAll positions are distinct.",
        "starter_code": {
            "python": "def car_fleet(target, position, speed):\n    # your code here\n    pass",
            "javascript": "function carFleet(target, position, speed) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "12, [10,8,0,5,3], [2,4,1,1,3]", "expected_output": "3", "is_hidden": False},
            {"input": "10, [3], [3]", "expected_output": "1", "is_hidden": False},
            {"input": "100, [0,2,4], [4,2,1]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Simplify Path",
        "slug": "simplify-path",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Given an absolute Unix file path `path`, simplify it. Remove redundant slashes, `.` (current dir), and handle `..` (parent dir).",
        "constraints": "1 ≤ path.length ≤ 3000\npath is a valid absolute Unix path.",
        "starter_code": {
            "python": "def simplify_path(path):\n    # your code here\n    pass",
            "javascript": "function simplifyPath(path) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": '"/home/"', "expected_output": "/home", "is_hidden": False},
            {"input": '"/../"', "expected_output": "/", "is_hidden": False},
            {"input": '"/home//foo/"', "expected_output": "/home/foo", "is_hidden": True},
        ],
    },
    {
        "title": "Score of Parentheses",
        "slug": "score-of-parentheses",
        "category_slug": "stack-queue",
        "difficulty": "medium",
        "description": "Given a balanced parentheses string `s`, return its score. `()` scores 1, `AB` scores A+B, `(A)` scores 2×A.",
        "constraints": "2 ≤ s.length ≤ 50\ns consists of `(` and `)` only and is balanced.",
        "starter_code": {
            "python": "def score_of_parentheses(s):\n    # your code here\n    pass",
            "javascript": "function scoreOfParentheses(s) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": '"()"', "expected_output": "1", "is_hidden": False},
            {"input": '"(())"', "expected_output": "2", "is_hidden": False},
            {"input": '"()()"', "expected_output": "2", "is_hidden": True},
        ],
    },
    {
        "title": "Make The String Great",
        "slug": "make-string-great",
        "category_slug": "stack-queue",
        "difficulty": "easy",
        "description": "Given string `s`, remove pairs of adjacent characters that are the same letter in different cases (e.g., `aA` or `Aa`) until no such pair exists. Return the final string.",
        "constraints": "1 ≤ s.length ≤ 100\ns consists of lowercase and uppercase English letters.",
        "starter_code": {
            "python": "def make_good(s):\n    # your code here\n    pass",
            "javascript": "function makeGood(s) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": '"leEeetcode"', "expected_output": "leetcode", "is_hidden": False},
            {"input": '"abBAcC"', "expected_output": "", "is_hidden": False},
            {"input": '"s"', "expected_output": "s", "is_hidden": True},
        ],
    },

    # ─── BINARY SEARCH (14) ───────────────────────────────────────────────────────

    {
        "title": "Binary Search",
        "slug": "binary-search",
        "category_slug": "binary-search",
        "difficulty": "easy",
        "description": "Given a sorted integer array `nums` and a `target`, return the index of `target` if it exists, or -1 otherwise.",
        "constraints": "1 ≤ nums.length ≤ 10⁴\n-10⁴ ≤ nums[i], target ≤ 10⁴\nnums is sorted in ascending order with distinct values.",
        "starter_code": {
            "python": "def search(nums, target):\n    # your code here\n    pass",
            "javascript": "function search(nums, target) {\n    // your code here\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[-1,0,3,5,9,12], 9", "expected_output": "4", "is_hidden": False},
            {"input": "[-1,0,3,5,9,12], 2", "expected_output": "-1", "is_hidden": False},
            {"input": "[5], 5", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Find Minimum in Rotated Sorted Array",
        "slug": "find-min-rotated",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Given a sorted array rotated between 1 and n times, return the minimum element. Must run in O(log n).",
        "constraints": "1 ≤ nums.length ≤ 5000\n-5000 ≤ nums[i] ≤ 5000\nAll values are unique.",
        "starter_code": {
            "python": "def find_min(nums):\n    # your code here\n    pass",
            "javascript": "function findMin(nums) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[3,4,5,1,2]", "expected_output": "1", "is_hidden": False},
            {"input": "[4,5,6,7,0,1,2]", "expected_output": "0", "is_hidden": False},
            {"input": "[11,13,15,17]", "expected_output": "11", "is_hidden": True},
        ],
    },
    {
        "title": "Search in Rotated Sorted Array",
        "slug": "search-rotated-array",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Given a rotated sorted array of distinct integers and a `target`, return the index of `target` or -1 if not present. Must run in O(log n).",
        "constraints": "1 ≤ nums.length ≤ 5000\n-10⁴ ≤ nums[i] ≤ 10⁴\nAll values are unique.",
        "starter_code": {
            "python": "def search_rotated(nums, target):\n    # your code here\n    pass",
            "javascript": "function search(nums, target) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[4,5,6,7,0,1,2], 0", "expected_output": "4", "is_hidden": False},
            {"input": "[4,5,6,7,0,1,2], 3", "expected_output": "-1", "is_hidden": False},
            {"input": "[1], 0", "expected_output": "-1", "is_hidden": True},
        ],
    },
    {
        "title": "Koko Eating Bananas",
        "slug": "koko-eating-bananas",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Koko can eat `k` bananas per hour. Given `piles` and `h` hours, find the minimum eating speed `k` such that she finishes all piles within `h` hours.",
        "constraints": "1 ≤ piles.length ≤ 10⁴\npiles.length ≤ h ≤ 10⁹\n1 ≤ piles[i] ≤ 10⁹",
        "starter_code": {
            "python": "def min_eating_speed(piles, h):\n    # your code here\n    pass",
            "javascript": "function minEatingSpeed(piles, h) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[3,6,7,11], 8", "expected_output": "4", "is_hidden": False},
            {"input": "[30,11,23,4,20], 5", "expected_output": "30", "is_hidden": False},
            {"input": "[30,11,23,4,20], 6", "expected_output": "23", "is_hidden": True},
        ],
    },
    {
        "title": "Capacity To Ship Packages Within D Days",
        "slug": "capacity-ship-packages",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Given package `weights` and `days`, return the minimum ship capacity to ship all packages in order within `days` days.",
        "constraints": "1 ≤ days ≤ weights.length ≤ 5 × 10⁴\n1 ≤ weights[i] ≤ 500",
        "starter_code": {
            "python": "def ship_within_days(weights, days):\n    # your code here\n    pass",
            "javascript": "function shipWithinDays(weights, days) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[1,2,3,4,5,6,7,8,9,10], 5", "expected_output": "15", "is_hidden": False},
            {"input": "[3,2,2,4,1,4], 3", "expected_output": "6", "is_hidden": False},
            {"input": "[1,2,3,1,1], 4", "expected_output": "3", "is_hidden": True},
        ],
    },
    {
        "title": "Search a 2D Matrix",
        "slug": "search-2d-matrix",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Given an `m x n` matrix where each row is sorted and the first element of each row is greater than the last of the previous row, return `true` if `target` is in the matrix.",
        "constraints": "1 ≤ m, n ≤ 100\n-10⁴ ≤ matrix[i][j], target ≤ 10⁴",
        "starter_code": {
            "python": "def search_matrix(matrix, target):\n    # your code here\n    pass",
            "javascript": "function searchMatrix(matrix, target) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[[1,3,5,7],[10,11,16,20],[23,30,34,60]], 3", "expected_output": "true", "is_hidden": False},
            {"input": "[[1,3,5,7],[10,11,16,20],[23,30,34,60]], 13", "expected_output": "false", "is_hidden": False},
            {"input": "[[1]], 1", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "First Bad Version",
        "slug": "first-bad-version",
        "category_slug": "binary-search",
        "difficulty": "easy",
        "description": "Given `n` versions and a `bad` version number (the first bad one), find the first bad version. The `is_bad_version(v, bad)` helper is provided in the starter code.",
        "constraints": "1 ≤ bad ≤ n ≤ 2³¹ - 1",
        "starter_code": {
            "python": (
                "def first_bad_version(n, bad):\n"
                "    # Use is_bad_version(version, bad) to check if a version is bad\n"
                "    # your code here\n"
                "    pass\n"
                "\n"
                "def is_bad_version(version, bad):\n"
                "    return version >= bad\n"
            ),
            "javascript": "function solution(bad) {\n    return function(n) {\n        // binary search here\n    };\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "5, 4", "expected_output": "4", "is_hidden": False},
            {"input": "1, 1", "expected_output": "1", "is_hidden": False},
            {"input": "10, 7", "expected_output": "7", "is_hidden": True},
        ],
    },
    {
        "title": "Find Peak Element",
        "slug": "find-peak-element",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, find a peak element (strictly greater than neighbors) and return its index. Must run in O(log n).",
        "constraints": "1 ≤ nums.length ≤ 1000\n-2³¹ ≤ nums[i] ≤ 2³¹ - 1\nNums[-1] and nums[n] are -∞.",
        "starter_code": {
            "python": "def find_peak_element(nums):\n    # your code here\n    pass",
            "javascript": "function findPeakElement(nums) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[1,2,3,1]", "expected_output": "2", "is_hidden": False},
            {"input": "[1,2,1,3,5,6,4]", "expected_output": "5", "is_hidden": False},
            {"input": "[1]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Sqrt(x)",
        "slug": "sqrt-x",
        "category_slug": "binary-search",
        "difficulty": "easy",
        "description": "Given a non-negative integer `x`, return the integer square root (floor). Do not use `pow` or `**`.",
        "constraints": "0 ≤ x ≤ 2³¹ - 1",
        "starter_code": {
            "python": "def my_sqrt(x):\n    # your code here\n    pass",
            "javascript": "function mySqrt(x) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "4", "expected_output": "2", "is_hidden": False},
            {"input": "8", "expected_output": "2", "is_hidden": False},
            {"input": "0", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Find First and Last Position",
        "slug": "find-first-last-position",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Given a sorted array `nums` and a `target`, return the starting and ending position of `target`. Return `[-1,-1]` if not found. Must run in O(log n).",
        "constraints": "0 ≤ nums.length ≤ 10⁵\n-10⁹ ≤ nums[i] ≤ 10⁹\nnums is sorted in ascending order.",
        "starter_code": {
            "python": "def search_range(nums, target):\n    # your code here\n    pass",
            "javascript": "function searchRange(nums, target) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[5,7,7,8,8,10], 8", "expected_output": "[3,4]", "is_hidden": False},
            {"input": "[5,7,7,8,8,10], 6", "expected_output": "[-1,-1]", "is_hidden": False},
            {"input": "[], 0", "expected_output": "[-1,-1]", "is_hidden": True},
        ],
    },
    {
        "title": "Valid Perfect Square",
        "slug": "valid-perfect-square",
        "category_slug": "binary-search",
        "difficulty": "easy",
        "description": "Given a positive integer `num`, return `true` if it is a perfect square. Do not use `sqrt`.",
        "constraints": "1 ≤ num ≤ 2³¹ - 1",
        "starter_code": {
            "python": "def is_perfect_square(num):\n    # your code here\n    pass",
            "javascript": "function isPerfectSquare(num) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "16", "expected_output": "true", "is_hidden": False},
            {"input": "14", "expected_output": "false", "is_hidden": False},
            {"input": "1", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Search Insert Position",
        "slug": "search-insert-position",
        "category_slug": "binary-search",
        "difficulty": "easy",
        "description": "Given a sorted distinct integer array `nums` and a `target`, return the index if found, or the index where it would be inserted in order.",
        "constraints": "1 ≤ nums.length ≤ 10⁴\n-10⁴ ≤ nums[i] ≤ 10⁴\nAll values are distinct.",
        "starter_code": {
            "python": "def search_insert(nums, target):\n    # your code here\n    pass",
            "javascript": "function searchInsert(nums, target) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[1,3,5,6], 5", "expected_output": "2", "is_hidden": False},
            {"input": "[1,3,5,6], 2", "expected_output": "1", "is_hidden": False},
            {"input": "[1,3,5,6], 7", "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "Median of Two Sorted Arrays",
        "slug": "median-two-sorted-arrays",
        "category_slug": "binary-search",
        "difficulty": "hard",
        "description": "Given two sorted arrays `nums1` and `nums2`, return the median of the combined sorted arrays. Must run in O(log(m+n)).",
        "constraints": "0 ≤ nums1.length, nums2.length ≤ 1000\n-10⁶ ≤ nums1[i], nums2[i] ≤ 10⁶",
        "starter_code": {
            "python": "def find_median_sorted_arrays(nums1, nums2):\n    # your code here\n    pass",
            "javascript": "function findMedianSortedArrays(nums1, nums2) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": "[1,3], [2]", "expected_output": "2.0", "is_hidden": False},
            {"input": "[1,2], [3,4]", "expected_output": "2.5", "is_hidden": False},
            {"input": "[], [1]", "expected_output": "1.0", "is_hidden": True},
        ],
    },
    {
        "title": "Time Based Key-Value Store",
        "slug": "time-based-key-value",
        "category_slug": "binary-search",
        "difficulty": "medium",
        "description": "Implement `time_set(key, value, timestamp)` and `time_get(key, timestamp)` where `get` returns the value with the largest timestamp ≤ given timestamp, or empty string.",
        "constraints": "1 ≤ key.length, value.length ≤ 100\n1 ≤ timestamp ≤ 10⁷\nAll timestamps in set are strictly increasing.",
        "starter_code": {
            "python": (
                "def time_map_ops(operations):\n"
                "    # operations: list of [op, key, val_or_ts, ts_or_None]\n"
                "    # op='set': set(key, val, ts); op='get': get(key, ts) -> return value\n"
                "    store = {}\n"
                "    results = []\n"
                "    for op in operations:\n"
                "        if op[0] == 'set':\n"
                "            key, val, ts = op[1], op[2], op[3]\n"
                "            store.setdefault(key, []).append((ts, val))\n"
                "        else:\n"
                "            key, ts = op[1], op[2]\n"
                "            # your binary search here\n"
                "            results.append('')\n"
                "    return results\n"
            ),
            "javascript": "function timeMapOps(operations) {\n    // your code here\n}",
        },
        "order_index": 13,
        "test_cases": [
            {"input": '[["set","foo","bar",1],["get","foo",1],["get","foo",3],["set","foo","bar2",4],["get","foo",4],["get","foo",5]]', "expected_output": '["bar","bar","bar2","bar2"]', "is_hidden": False},
            {"input": '[["set","love","high",10],["set","love","low",20],["get","love",5],["get","love",10],["get","love",15]]', "expected_output": '["","high","high"]', "is_hidden": False},
            {"input": '[["set","a","b",1],["get","a",2]]', "expected_output": '["b"]', "is_hidden": True},
        ],
    },

    # ─── LINKED LISTS (12) ────────────────────────────────────────────────────────

    {
        "title": "Reverse Linked List",
        "slug": "reverse-linked-list",
        "category_slug": "linked-lists",
        "difficulty": "easy",
        "description": "Given a linked list as an array, reverse it and return the reversed list. Helper functions `_to_ll` and `_to_list` are provided.",
        "constraints": "0 ≤ n ≤ 5000\n-5000 ≤ Node.val ≤ 5000",
        "starter_code": {
            "python": (
                "def reverse_list(head_arr):\n"
                "    head = _to_ll(head_arr)\n"
                "    prev, curr = None, head\n"
                "    while curr:\n"
                "        nxt = curr.next\n"
                "        curr.next = prev\n"
                "        prev, curr = curr, nxt\n"
                "    return _to_list(prev)\n"
                + _LL
            ),
            "javascript": "function reverseList(head) {\n    let prev = null, curr = head;\n    while (curr) { let nxt = curr.next; curr.next = prev; prev = curr; curr = nxt; }\n    return prev;\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[1,2,3,4,5]", "expected_output": "[5,4,3,2,1]", "is_hidden": False},
            {"input": "[1,2]", "expected_output": "[2,1]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Merge Two Sorted Lists",
        "slug": "merge-two-sorted-lists",
        "category_slug": "linked-lists",
        "difficulty": "easy",
        "description": "Merge two sorted linked lists (given as arrays) into one sorted list and return it as an array.",
        "constraints": "0 ≤ n, m ≤ 50\n-100 ≤ Node.val ≤ 100\nBoth lists are sorted in non-decreasing order.",
        "starter_code": {
            "python": (
                "def merge_two_lists(list1, list2):\n"
                "    l1, l2 = _to_ll(list1), _to_ll(list2)\n"
                "    # merge l1 and l2, return _to_list(merged)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function mergeTwoLists(list1, list2) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[1,2,4], [1,3,4]", "expected_output": "[1,1,2,3,4,4]", "is_hidden": False},
            {"input": "[], []", "expected_output": "[]", "is_hidden": False},
            {"input": "[], [0]", "expected_output": "[0]", "is_hidden": True},
        ],
    },
    {
        "title": "Find the Duplicate Number",
        "slug": "find-duplicate-linked-list",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Given an array of n+1 integers where each integer is in [1, n], return the duplicate number. Must use O(1) extra space (Floyd's cycle detection).",
        "constraints": "1 ≤ n ≤ 10⁵\nnums.length == n + 1\n1 ≤ nums[i] ≤ n\nOnly one repeated number.",
        "starter_code": {
            "python": "def find_duplicate(nums):\n    # Floyd's cycle detection — treat array as linked list\n    pass",
            "javascript": "function findDuplicate(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[1,3,4,2,2]", "expected_output": "2", "is_hidden": False},
            {"input": "[3,1,3,4,2]", "expected_output": "3", "is_hidden": False},
            {"input": "[1,1]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Remove Nth Node From End of List",
        "slug": "remove-nth-node-end",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Given a linked list (as array) and integer `n`, remove the nth node from the end and return the list.",
        "constraints": "1 ≤ sz ≤ 30\n0 ≤ Node.val ≤ 100\n1 ≤ n ≤ sz",
        "starter_code": {
            "python": (
                "def remove_nth_from_end(head_arr, n):\n"
                "    head = _to_ll(head_arr)\n"
                "    # remove nth from end, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function removeNthFromEnd(head, n) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,2,3,4,5], 2", "expected_output": "[1,2,3,5]", "is_hidden": False},
            {"input": "[1], 1", "expected_output": "[]", "is_hidden": False},
            {"input": "[1,2], 1", "expected_output": "[1]", "is_hidden": True},
        ],
    },
    {
        "title": "Palindrome Linked List",
        "slug": "palindrome-linked-list",
        "category_slug": "linked-lists",
        "difficulty": "easy",
        "description": "Given a linked list (as array), return `true` if it is a palindrome.",
        "constraints": "1 ≤ n ≤ 10⁵\n0 ≤ Node.val ≤ 9",
        "starter_code": {
            "python": (
                "def is_palindrome(head_arr):\n"
                "    head = _to_ll(head_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function isPalindrome(head) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[1,2,2,1]", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2]", "expected_output": "false", "is_hidden": False},
            {"input": "[1]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Middle of the Linked List",
        "slug": "middle-linked-list",
        "category_slug": "linked-lists",
        "difficulty": "easy",
        "description": "Given a linked list (as array), return the values from the middle node to the end. If two middles, return the second middle.",
        "constraints": "1 ≤ n ≤ 100\n1 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def middle_node(head_arr):\n"
                "    head = _to_ll(head_arr)\n"
                "    # find middle and return _to_list(middle)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function middleNode(head) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[1,2,3,4,5]", "expected_output": "[3,4,5]", "is_hidden": False},
            {"input": "[1,2,3,4,5,6]", "expected_output": "[4,5,6]", "is_hidden": False},
            {"input": "[1]", "expected_output": "[1]", "is_hidden": True},
        ],
    },
    {
        "title": "Add Two Numbers",
        "slug": "add-two-numbers",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Two non-empty linked lists represent non-negative integers in reverse digit order. Add the two numbers and return the sum as a linked list (array).",
        "constraints": "1 ≤ sz ≤ 100\n0 ≤ Node.val ≤ 9\nNo leading zeros (except the number 0 itself).",
        "starter_code": {
            "python": (
                "def add_two_numbers(l1, l2):\n"
                "    a, b = _to_ll(l1), _to_ll(l2)\n"
                "    # add digits with carry, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function addTwoNumbers(l1, l2) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "[2,4,3], [5,6,4]", "expected_output": "[7,0,8]", "is_hidden": False},
            {"input": "[0], [0]", "expected_output": "[0]", "is_hidden": False},
            {"input": "[9,9,9,9,9,9,9], [9,9,9,9]", "expected_output": "[8,9,9,9,0,0,0,1]", "is_hidden": True},
        ],
    },
    {
        "title": "Remove Linked List Elements",
        "slug": "remove-linked-list-elements",
        "category_slug": "linked-lists",
        "difficulty": "easy",
        "description": "Given a linked list (as array) and value `val`, remove all nodes with `Node.val == val` and return the list.",
        "constraints": "0 ≤ n ≤ 10⁴\n1 ≤ Node.val ≤ 50\n0 ≤ val ≤ 50",
        "starter_code": {
            "python": (
                "def remove_elements(head_arr, val):\n"
                "    head = _to_ll(head_arr)\n"
                "    # remove nodes with val, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function removeElements(head, val) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[1,2,6,3,4,5,6], 6", "expected_output": "[1,2,3,4,5]", "is_hidden": False},
            {"input": "[], 1", "expected_output": "[]", "is_hidden": False},
            {"input": "[7,7,7,7], 7", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Odd Even Linked List",
        "slug": "odd-even-linked-list",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Given a linked list (as array), group all odd-indexed nodes together followed by even-indexed nodes. Return the reordered list.",
        "constraints": "0 ≤ n ≤ 10⁴\n-10⁶ ≤ Node.val ≤ 10⁶",
        "starter_code": {
            "python": (
                "def odd_even_list(head_arr):\n"
                "    head = _to_ll(head_arr)\n"
                "    # group odd-index then even-index nodes, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function oddEvenList(head) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[1,2,3,4,5]", "expected_output": "[1,3,5,2,4]", "is_hidden": False},
            {"input": "[2,1,3,5,6,4,7]", "expected_output": "[2,3,6,7,1,5,4]", "is_hidden": False},
            {"input": "[1]", "expected_output": "[1]", "is_hidden": True},
        ],
    },
    {
        "title": "Reverse Linked List II",
        "slug": "reverse-linked-list-ii",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Given a linked list (as array) and positions `left` and `right`, reverse the nodes from position `left` to `right` (1-indexed).",
        "constraints": "1 ≤ n ≤ 500\n-500 ≤ Node.val ≤ 500\n1 ≤ left ≤ right ≤ n",
        "starter_code": {
            "python": (
                "def reverse_between(head_arr, left, right):\n"
                "    head = _to_ll(head_arr)\n"
                "    # reverse from left to right, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function reverseBetween(head, left, right) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[1,2,3,4,5], 2, 4", "expected_output": "[1,4,3,2,5]", "is_hidden": False},
            {"input": "[5], 1, 1", "expected_output": "[5]", "is_hidden": False},
            {"input": "[1,2,3], 1, 3", "expected_output": "[3,2,1]", "is_hidden": True},
        ],
    },
    {
        "title": "Sort List",
        "slug": "sort-list",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Given a linked list (as array), sort it in O(n log n) time and O(1) memory, then return the sorted array.",
        "constraints": "0 ≤ n ≤ 5 × 10⁴\n-10⁵ ≤ Node.val ≤ 10⁵",
        "starter_code": {
            "python": (
                "def sort_list(head_arr):\n"
                "    head = _to_ll(head_arr)\n"
                "    # sort using merge sort, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function sortList(head) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "[4,2,1,3]", "expected_output": "[1,2,3,4]", "is_hidden": False},
            {"input": "[-1,5,3,4,0]", "expected_output": "[-1,0,3,4,5]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Swap Nodes in Pairs",
        "slug": "swap-nodes-pairs",
        "category_slug": "linked-lists",
        "difficulty": "medium",
        "description": "Given a linked list (as array), swap every two adjacent nodes and return the result. Must not modify the values — only node links.",
        "constraints": "0 ≤ n ≤ 100\n0 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def swap_pairs(head_arr):\n"
                "    head = _to_ll(head_arr)\n"
                "    # swap adjacent pairs, return _to_list(result)\n"
                "    pass\n"
                + _LL
            ),
            "javascript": "function swapPairs(head) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[1,2,3,4]", "expected_output": "[2,1,4,3]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": False},
            {"input": "[1]", "expected_output": "[1]", "is_hidden": True},
        ],
    },

    # ─── TREES (13) ───────────────────────────────────────────────────────────────

    {
        "title": "Maximum Depth of Binary Tree",
        "slug": "max-depth-binary-tree",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given a binary tree as a level-order array (None for missing nodes), return its maximum depth.",
        "constraints": "0 ≤ n ≤ 10⁴\n-100 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def max_depth(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function maxDepth(root) {\n    if (!root) return 0;\n    return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));\n}",
        },
        "order_index": 0,
        "test_cases": [
            {"input": "[3,9,20,None,None,15,7]", "expected_output": "3", "is_hidden": False},
            {"input": "[1,None,2]", "expected_output": "2", "is_hidden": False},
            {"input": "[]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Invert Binary Tree",
        "slug": "invert-binary-tree",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given a binary tree as a level-order array, invert it (mirror) and return the level-order array of the result.",
        "constraints": "0 ≤ n ≤ 100\n-100 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def invert_tree(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # invert the tree, then return _t2a(result)\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function invertTree(root) {\n    if (!root) return null;\n    [root.left, root.right] = [invertTree(root.right), invertTree(root.left)];\n    return root;\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[4,2,7,1,3,6,9]", "expected_output": "[4,7,2,9,6,3,1]", "is_hidden": False},
            {"input": "[2,1,3]", "expected_output": "[2,3,1]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Same Tree",
        "slug": "same-tree",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given two binary trees as level-order arrays, return `true` if they are structurally identical with the same node values.",
        "constraints": "0 ≤ n ≤ 100\n-10⁴ ≤ Node.val ≤ 10⁴",
        "starter_code": {
            "python": (
                "def is_same_tree(p_arr, q_arr):\n"
                "    p, q = _a2t(p_arr), _a2t(q_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function isSameTree(p, q) {\n    if (!p && !q) return true;\n    if (!p || !q || p.val !== q.val) return false;\n    return isSameTree(p.left, q.left) && isSameTree(p.right, q.right);\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[1,2,3], [1,2,3]", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2], [1,None,2]", "expected_output": "false", "is_hidden": False},
            {"input": "[], []", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Symmetric Tree",
        "slug": "symmetric-tree",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given a binary tree as a level-order array, check whether it is a mirror of itself (symmetric around its center).",
        "constraints": "1 ≤ n ≤ 1000\n-100 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def is_symmetric(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function isSymmetric(root) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,2,2,3,4,4,3]", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2,2,None,3,None,3]", "expected_output": "false", "is_hidden": False},
            {"input": "[1]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Binary Tree Level Order Traversal",
        "slug": "level-order-traversal",
        "category_slug": "trees",
        "difficulty": "medium",
        "description": "Given a binary tree as a level-order array, return its level order traversal as a list of lists.",
        "constraints": "0 ≤ n ≤ 2000\n-1000 ≤ Node.val ≤ 1000",
        "starter_code": {
            "python": (
                "def level_order(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # BFS traversal, return list of lists\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function levelOrder(root) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[3,9,20,None,None,15,7]", "expected_output": "[[3],[9,20],[15,7]]", "is_hidden": False},
            {"input": "[1]", "expected_output": "[[1]]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Validate Binary Search Tree",
        "slug": "validate-bst",
        "category_slug": "trees",
        "difficulty": "medium",
        "description": "Given a binary tree as a level-order array, determine if it is a valid binary search tree.",
        "constraints": "1 ≤ n ≤ 10⁴\n-2³¹ ≤ Node.val ≤ 2³¹ - 1",
        "starter_code": {
            "python": (
                "def is_valid_bst(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function isValidBST(root) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[2,1,3]", "expected_output": "true", "is_hidden": False},
            {"input": "[5,1,4,None,None,3,6]", "expected_output": "false", "is_hidden": False},
            {"input": "[2,2,2]", "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Lowest Common Ancestor of BST",
        "slug": "lca-bst",
        "category_slug": "trees",
        "difficulty": "medium",
        "description": "Given a BST (level-order array) and two values `p` and `q`, return the value of their lowest common ancestor.",
        "constraints": "2 ≤ n ≤ 10⁵\n-10⁹ ≤ Node.val ≤ 10⁹\np ≠ q, both exist in the tree.",
        "starter_code": {
            "python": (
                "def lowest_common_ancestor(root_arr, p, q):\n"
                "    root = _a2t(root_arr)\n"
                "    # return the VALUE of the LCA node\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function lowestCommonAncestor(root, p, q) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "[6,2,8,0,4,7,9,None,None,3,5], 2, 8", "expected_output": "6", "is_hidden": False},
            {"input": "[6,2,8,0,4,7,9,None,None,3,5], 2, 4", "expected_output": "2", "is_hidden": False},
            {"input": "[2,1], 2, 1", "expected_output": "2", "is_hidden": True},
        ],
    },
    {
        "title": "Diameter of Binary Tree",
        "slug": "diameter-binary-tree",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given a binary tree as a level-order array, return the length of the diameter (longest path between any two nodes — measured in edges).",
        "constraints": "1 ≤ n ≤ 10⁴\n-100 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def diameter_of_binary_tree(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function diameterOfBinaryTree(root) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[1,2,3,4,5]", "expected_output": "3", "is_hidden": False},
            {"input": "[1,2]", "expected_output": "1", "is_hidden": False},
            {"input": "[1]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Path Sum",
        "slug": "path-sum",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given a binary tree (level-order array) and `targetSum`, return `true` if there is a root-to-leaf path whose node values sum to `targetSum`.",
        "constraints": "0 ≤ n ≤ 5000\n-1000 ≤ Node.val ≤ 1000\n-1000 ≤ targetSum ≤ 1000",
        "starter_code": {
            "python": (
                "def has_path_sum(root_arr, targetSum):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function hasPathSum(root, targetSum) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[5,4,8,11,None,13,4,7,2,None,None,None,1], 22", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2,3], 5", "expected_output": "false", "is_hidden": False},
            {"input": "[], 0", "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Count Good Nodes in Binary Tree",
        "slug": "count-good-nodes",
        "category_slug": "trees",
        "difficulty": "medium",
        "description": "Given a binary tree (level-order array), a node X is good if no node on the path from root to X has a value greater than X. Return the count of good nodes.",
        "constraints": "1 ≤ n ≤ 10⁵\n-10⁴ ≤ Node.val ≤ 10⁴",
        "starter_code": {
            "python": (
                "def good_nodes(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function goodNodes(root) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[3,1,4,3,None,1,5]", "expected_output": "4", "is_hidden": False},
            {"input": "[3,3,None,4,2]", "expected_output": "3", "is_hidden": False},
            {"input": "[1]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Binary Tree Maximum Path Sum",
        "slug": "binary-tree-max-path-sum",
        "category_slug": "trees",
        "difficulty": "hard",
        "description": "Given a binary tree (level-order array), return the maximum path sum. A path is any sequence of nodes from some starting node to any node in the tree (no need to pass through root).",
        "constraints": "1 ≤ n ≤ 3 × 10⁴\n-1000 ≤ Node.val ≤ 1000",
        "starter_code": {
            "python": (
                "def max_path_sum(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function maxPathSum(root) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "[1,2,3]", "expected_output": "6", "is_hidden": False},
            {"input": "[-3]", "expected_output": "-3", "is_hidden": False},
            {"input": "[-10,9,20,None,None,15,7]", "expected_output": "42", "is_hidden": True},
        ],
    },
    {
        "title": "Binary Tree Right Side View",
        "slug": "binary-tree-right-side-view",
        "category_slug": "trees",
        "difficulty": "medium",
        "description": "Given a binary tree (level-order array), return the values of nodes visible from the right side (the rightmost node at each depth level).",
        "constraints": "0 ≤ n ≤ 100\n-100 ≤ Node.val ≤ 100",
        "starter_code": {
            "python": (
                "def right_side_view(root_arr):\n"
                "    root = _a2t(root_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function rightSideView(root) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[1,2,3,None,5,None,4]", "expected_output": "[1,3,4]", "is_hidden": False},
            {"input": "[1,None,3]", "expected_output": "[1,3]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Subtree of Another Tree",
        "slug": "subtree-another-tree",
        "category_slug": "trees",
        "difficulty": "easy",
        "description": "Given two binary trees (as level-order arrays) `root` and `subRoot`, return `true` if there is a subtree of `root` with the same structure and values as `subRoot`.",
        "constraints": "1 ≤ root.n ≤ 2000\n1 ≤ subRoot.n ≤ 1000\n-10⁴ ≤ Node.val ≤ 10⁴",
        "starter_code": {
            "python": (
                "def is_subtree(root_arr, subRoot_arr):\n"
                "    root, sub = _a2t(root_arr), _a2t(subRoot_arr)\n"
                "    # your code here\n"
                "    pass\n"
                + _TREE
            ),
            "javascript": "function isSubtree(root, subRoot) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": "[3,4,5,1,2], [4,1,2]", "expected_output": "true", "is_hidden": False},
            {"input": "[3,4,5,1,2,None,None,None,None,0], [4,1,2]", "expected_output": "false", "is_hidden": False},
            {"input": "[1], [1]", "expected_output": "true", "is_hidden": True},
        ],
    },

    # ── GRAPHS ────────────────────────────────────────────────────────────────
    {
        "title": "Number of Islands",
        "slug": "number-of-islands",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Given a 2D grid of `'1'`s (land) and `'0'`s (water), count the number of islands. An island is surrounded by water and formed by connecting adjacent land cells horizontally or vertically.",
        "constraints": "1 ≤ rows, cols ≤ 300",
        "starter_code": {
            "python": "def num_islands(grid):\n    # grid is a list of list of '1'/'0'\n    # your code here\n    pass\n",
            "javascript": "function numIslands(grid) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": '[["1","1","1","1","0"],["1","1","0","1","0"],["1","1","0","0","0"],["0","0","0","0","0"]]', "expected_output": "1", "is_hidden": False},
            {"input": '[["1","1","0","0","0"],["1","1","0","0","0"],["0","0","1","0","0"],["0","0","0","1","1"]]', "expected_output": "3", "is_hidden": False},
            {"input": '[["0","0","0"],["0","0","0"]]', "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Max Area of Island",
        "slug": "max-area-island",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Given a binary matrix grid, return the maximum area of an island (connected group of 1s). Return 0 if there is no island.",
        "constraints": "1 ≤ rows, cols ≤ 50\ngrid[i][j] is 0 or 1",
        "starter_code": {
            "python": "def max_area_of_island(grid):\n    # your code here\n    pass\n",
            "javascript": "function maxAreaOfIsland(grid) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[[0,0,1,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,0,0,0,1,1,1,0,0,0],[0,1,1,0,1,0,0,0,0,0,0,0,0],[0,1,0,0,1,1,0,0,1,0,1,0,0],[0,1,0,0,1,1,0,0,1,1,1,0,0],[0,0,0,0,0,0,0,0,0,0,1,0,0],[0,0,0,0,0,0,0,1,1,1,0,0,0],[0,0,0,0,0,0,0,1,1,0,0,0,0]]", "expected_output": "6", "is_hidden": False},
            {"input": "[[0,0,0,0,0,0,0,0]]", "expected_output": "0", "is_hidden": False},
            {"input": "[[1,1],[1,1]]", "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "Pacific Atlantic Water Flow",
        "slug": "pacific-atlantic-water-flow",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Given an `m x n` integer matrix `heights`, return a sorted list of `[r, c]` coordinates where rain water can flow to both the Pacific and Atlantic oceans.",
        "constraints": "1 ≤ m, n ≤ 200\n0 ≤ heights[r][c] ≤ 10⁵",
        "starter_code": {
            "python": "def pacific_atlantic(heights):\n    # return sorted list of [r,c] pairs\n    pass\n",
            "javascript": "function pacificAtlantic(heights) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]", "expected_output": "[[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]]", "is_hidden": False},
            {"input": "[[1]]", "expected_output": "[[0,0]]", "is_hidden": False},
            {"input": "[[1,2],[2,1]]", "expected_output": "[[0,1],[1,0]]", "is_hidden": True},
        ],
    },
    {
        "title": "Course Schedule",
        "slug": "course-schedule",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "There are `numCourses` courses (0 to numCourses-1). Given `prerequisites` as a list of `[a, b]` pairs (must take b before a), return `true` if it is possible to finish all courses.",
        "constraints": "1 ≤ numCourses ≤ 2000\n0 ≤ prerequisites.length ≤ 5000",
        "starter_code": {
            "python": "def can_finish(numCourses, prerequisites):\n    # your code here\n    pass\n",
            "javascript": "function canFinish(numCourses, prerequisites) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "2, [[1,0]]", "expected_output": "true", "is_hidden": False},
            {"input": "2, [[1,0],[0,1]]", "expected_output": "false", "is_hidden": False},
            {"input": "4, [[1,0],[2,0],[3,1],[3,2]]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Course Schedule II",
        "slug": "course-schedule-ii",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Return a valid ordering of courses to finish all `numCourses` given a list of `prerequisites`. If impossible, return an empty list.",
        "constraints": "1 ≤ numCourses ≤ 2000\n0 ≤ prerequisites.length ≤ 5000",
        "starter_code": {
            "python": "def find_order(numCourses, prerequisites):\n    # return a valid topological order or []\n    pass\n",
            "javascript": "function findOrder(numCourses, prerequisites) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "2, [[1,0]]", "expected_output": "[0,1]", "is_hidden": False},
            {"input": "4, [[1,0],[2,0],[3,1],[3,2]]", "expected_output": "[0,1,2,3]", "is_hidden": False},
            {"input": "2, [[1,0],[0,1]]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Graph Valid Tree",
        "slug": "graph-valid-tree",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Given `n` nodes and a list of undirected `edges`, return `true` if the edges form a valid tree (connected and acyclic).",
        "constraints": "1 ≤ n ≤ 2000\n0 ≤ edges.length ≤ 5000",
        "starter_code": {
            "python": "def valid_tree(n, edges):\n    # your code here\n    pass\n",
            "javascript": "function validTree(n, edges) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "5, [[0,1],[0,2],[0,3],[1,4]]", "expected_output": "true", "is_hidden": False},
            {"input": "5, [[0,1],[1,2],[2,3],[1,3],[1,4]]", "expected_output": "false", "is_hidden": False},
            {"input": "1, []", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Number of Connected Components",
        "slug": "number-connected-components",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Given `n` nodes and a list of undirected `edges`, return the number of connected components in the graph.",
        "constraints": "1 ≤ n ≤ 2000\n0 ≤ edges.length ≤ 5000",
        "starter_code": {
            "python": "def count_components(n, edges):\n    # your code here\n    pass\n",
            "javascript": "function countComponents(n, edges) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "5, [[0,1],[1,2],[3,4]]", "expected_output": "2", "is_hidden": False},
            {"input": "5, [[0,1],[1,2],[2,3],[3,4]]", "expected_output": "1", "is_hidden": False},
            {"input": "3, []", "expected_output": "3", "is_hidden": True},
        ],
    },
    {
        "title": "Rotting Oranges",
        "slug": "rotting-oranges",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "In a grid, 0=empty, 1=fresh orange, 2=rotten orange. Every minute, any fresh orange adjacent to a rotten one becomes rotten. Return the minimum minutes until no fresh orange remains, or -1 if impossible.",
        "constraints": "1 ≤ rows, cols ≤ 10\ngrid[i][j] ∈ {0, 1, 2}",
        "starter_code": {
            "python": "def oranges_rotting(grid):\n    # your code here\n    pass\n",
            "javascript": "function orangesRotting(grid) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "[[2,1,1],[1,1,0],[0,1,1]]", "expected_output": "4", "is_hidden": False},
            {"input": "[[2,1,1],[0,1,1],[1,0,1]]", "expected_output": "-1", "is_hidden": False},
            {"input": "[[0,2]]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Word Ladder",
        "slug": "word-ladder",
        "category_slug": "graphs",
        "difficulty": "hard",
        "description": "Given `beginWord`, `endWord`, and a `wordList`, return the length of the shortest transformation sequence from `beginWord` to `endWord` (changing one letter at a time, each word must be in wordList). Return 0 if no sequence exists.",
        "constraints": "1 ≤ beginWord.length ≤ 10\nbeginWord ≠ endWord\n1 ≤ wordList.length ≤ 5000",
        "starter_code": {
            "python": "def ladder_length(beginWord, endWord, wordList):\n    # your code here\n    pass\n",
            "javascript": "function ladderLength(beginWord, endWord, wordList) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": '"hit", "cog", ["hot","dot","dog","lot","log","cog"]', "expected_output": "5", "is_hidden": False},
            {"input": '"hit", "cog", ["hot","dot","dog","lot","log"]', "expected_output": "0", "is_hidden": False},
            {"input": '"a", "c", ["a","b","c"]', "expected_output": "2", "is_hidden": True},
        ],
    },
    {
        "title": "Redundant Connection",
        "slug": "redundant-connection",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "In a tree with n nodes labeled 1 to n, one extra edge was added creating a cycle. Given the list of edges, return the redundant edge that can be removed to restore the tree.",
        "constraints": "3 ≤ n ≤ 1000",
        "starter_code": {
            "python": "def find_redundant_connection(edges):\n    # return [u, v] — the last edge that forms a cycle\n    pass\n",
            "javascript": "function findRedundantConnection(edges) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "[[1,2],[1,3],[2,3]]", "expected_output": "[2,3]", "is_hidden": False},
            {"input": "[[1,2],[2,3],[3,4],[1,4],[1,5]]", "expected_output": "[1,4]", "is_hidden": False},
            {"input": "[[1,2],[2,3],[1,3]]", "expected_output": "[1,3]", "is_hidden": True},
        ],
    },
    {
        "title": "Walls and Gates",
        "slug": "walls-and-gates",
        "category_slug": "graphs",
        "difficulty": "medium",
        "description": "Fill each empty room (INF = 2147483647) in the grid with its distance to the nearest gate (0). -1 represents a wall. Return the modified grid.",
        "constraints": "1 ≤ rows, cols ≤ 250",
        "starter_code": {
            "python": "def walls_and_gates(rooms):\n    INF = 2147483647\n    # modify rooms in-place and return it\n    return rooms\n",
            "javascript": "function wallsAndGates(rooms) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[[2147483647,-1,0,2147483647],[2147483647,2147483647,2147483647,-1],[2147483647,-1,2147483647,-1],[0,-1,2147483647,2147483647]]", "expected_output": "[[3,-1,0,1],[2,2,1,-1],[1,-1,2,-1],[0,-1,3,4]]", "is_hidden": False},
            {"input": "[[-1]]", "expected_output": "[[-1]]", "is_hidden": False},
            {"input": "[[0,-1],[2147483647,2147483647]]", "expected_output": "[[0,-1],[1,2]]", "is_hidden": True},
        ],
    },
    {
        "title": "Swim in Rising Water",
        "slug": "swim-rising-water",
        "category_slug": "graphs",
        "difficulty": "hard",
        "description": "Given an `n x n` grid where grid[i][j] is the elevation, return the minimum time `t` such that there is a path from (0,0) to (n-1,n-1) where all cells on the path have elevation ≤ t.",
        "constraints": "1 ≤ n ≤ 50\n0 ≤ grid[i][j] < n²\nAll values are unique",
        "starter_code": {
            "python": "def swim_in_water(grid):\n    # your code here\n    pass\n",
            "javascript": "function swimInWater(grid) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": "[[0,2],[1,3]]", "expected_output": "3", "is_hidden": False},
            {"input": "[[0,1,2,3,4],[24,23,22,21,5],[12,13,14,15,16],[11,17,18,19,20],[10,9,8,7,6]]", "expected_output": "16", "is_hidden": False},
            {"input": "[[0]]", "expected_output": "0", "is_hidden": True},
        ],
    },

    # ── DYNAMIC PROGRAMMING ───────────────────────────────────────────────────
    {
        "title": "Climbing Stairs",
        "slug": "climbing-stairs",
        "category_slug": "dynamic-programming",
        "difficulty": "easy",
        "description": "You are climbing a staircase with `n` steps. Each time you can climb 1 or 2 steps. Return the number of distinct ways to reach the top.",
        "constraints": "1 ≤ n ≤ 45",
        "starter_code": {
            "python": "def climb_stairs(n):\n    # your code here\n    pass\n",
            "javascript": "function climbStairs(n) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "2", "expected_output": "2", "is_hidden": False},
            {"input": "3", "expected_output": "3", "is_hidden": False},
            {"input": "10", "expected_output": "89", "is_hidden": True},
        ],
    },
    {
        "title": "House Robber",
        "slug": "house-robber",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given an array of non-negative integers representing money in houses, return the maximum amount you can rob without robbing two adjacent houses.",
        "constraints": "1 ≤ nums.length ≤ 100\n0 ≤ nums[i] ≤ 400",
        "starter_code": {
            "python": "def rob(nums):\n    # your code here\n    pass\n",
            "javascript": "function rob(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[1,2,3,1]", "expected_output": "4", "is_hidden": False},
            {"input": "[2,7,9,3,1]", "expected_output": "12", "is_hidden": False},
            {"input": "[2,1,1,2]", "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "House Robber II",
        "slug": "house-robber-ii",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "All houses are arranged in a circle (first and last are adjacent). Return the maximum amount you can rob without robbing two adjacent houses.",
        "constraints": "1 ≤ nums.length ≤ 100\n0 ≤ nums[i] ≤ 1000",
        "starter_code": {
            "python": "def rob2(nums):\n    # your code here\n    pass\n",
            "javascript": "function rob(nums) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[2,3,2]", "expected_output": "3", "is_hidden": False},
            {"input": "[1,2,3,1]", "expected_output": "4", "is_hidden": False},
            {"input": "[1,2,3]", "expected_output": "3", "is_hidden": True},
        ],
    },
    {
        "title": "Coin Change",
        "slug": "coin-change",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given coin denominations and a total `amount`, return the fewest number of coins needed to make up that amount. Return -1 if not possible.",
        "constraints": "1 ≤ coins.length ≤ 12\n1 ≤ coins[i] ≤ 2³¹-1\n0 ≤ amount ≤ 10⁴",
        "starter_code": {
            "python": "def coin_change(coins, amount):\n    # your code here\n    pass\n",
            "javascript": "function coinChange(coins, amount) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[1,2,5], 11", "expected_output": "3", "is_hidden": False},
            {"input": "[2], 3", "expected_output": "-1", "is_hidden": False},
            {"input": "[1], 0", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Increasing Subsequence",
        "slug": "longest-increasing-subsequence",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, return the length of the longest strictly increasing subsequence.",
        "constraints": "1 ≤ nums.length ≤ 2500\n-10⁴ ≤ nums[i] ≤ 10⁴",
        "starter_code": {
            "python": "def length_of_lis(nums):\n    # your code here\n    pass\n",
            "javascript": "function lengthOfLIS(nums) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[10,9,2,5,3,7,101,18]", "expected_output": "4", "is_hidden": False},
            {"input": "[0,1,0,3,2,3]", "expected_output": "4", "is_hidden": False},
            {"input": "[7,7,7,7,7,7,7]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Word Break",
        "slug": "word-break",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given a string `s` and a dictionary `wordDict`, return `true` if `s` can be segmented into a space-separated sequence of dictionary words.",
        "constraints": "1 ≤ s.length ≤ 300\n1 ≤ wordDict.length ≤ 1000",
        "starter_code": {
            "python": "def word_break(s, wordDict):\n    # your code here\n    pass\n",
            "javascript": "function wordBreak(s, wordDict) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": '"leetcode", ["leet","code"]', "expected_output": "true", "is_hidden": False},
            {"input": '"applepenapple", ["apple","pen"]', "expected_output": "true", "is_hidden": False},
            {"input": '"catsandog", ["cats","dog","sand","and","cat"]', "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Combination Sum IV",
        "slug": "combination-sum-iv",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given distinct integers `nums` and a `target`, return the number of possible ordered combinations that add up to target.",
        "constraints": "1 ≤ nums.length ≤ 200\n1 ≤ nums[i] ≤ 1000\n1 ≤ target ≤ 1000",
        "starter_code": {
            "python": "def combination_sum4(nums, target):\n    # your code here\n    pass\n",
            "javascript": "function combinationSum4(nums, target) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[1,2,3], 4", "expected_output": "7", "is_hidden": False},
            {"input": "[9], 3", "expected_output": "0", "is_hidden": False},
            {"input": "[1,2,3], 1", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Unique Paths",
        "slug": "unique-paths",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "A robot starts at the top-left of an `m x n` grid and moves only right or down. Return the number of unique paths to the bottom-right corner.",
        "constraints": "1 ≤ m, n ≤ 100",
        "starter_code": {
            "python": "def unique_paths(m, n):\n    # your code here\n    pass\n",
            "javascript": "function uniquePaths(m, n) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "3, 7", "expected_output": "28", "is_hidden": False},
            {"input": "3, 2", "expected_output": "3", "is_hidden": False},
            {"input": "1, 1", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Jump Game",
        "slug": "jump-game",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given an array where each element represents your maximum jump length from that position, return `true` if you can reach the last index starting from index 0.",
        "constraints": "1 ≤ nums.length ≤ 3×10⁴\n0 ≤ nums[i] ≤ 10⁵",
        "starter_code": {
            "python": "def can_jump(nums):\n    # your code here\n    pass\n",
            "javascript": "function canJump(nums) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[2,3,1,1,4]", "expected_output": "true", "is_hidden": False},
            {"input": "[3,2,1,0,4]", "expected_output": "false", "is_hidden": False},
            {"input": "[0]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "Decode Ways",
        "slug": "decode-ways",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "A string of digits can be decoded where 'A'→1, 'B'→2, ..., 'Z'→26. Given string `s`, return the number of ways to decode it.",
        "constraints": "1 ≤ s.length ≤ 100\ns contains only digits",
        "starter_code": {
            "python": "def num_decodings(s):\n    # your code here\n    pass\n",
            "javascript": "function numDecodings(s) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": '"12"', "expected_output": "2", "is_hidden": False},
            {"input": '"226"', "expected_output": "3", "is_hidden": False},
            {"input": '"06"', "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Longest Common Subsequence",
        "slug": "longest-common-subsequence",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given two strings `text1` and `text2`, return the length of their longest common subsequence.",
        "constraints": "1 ≤ text1.length, text2.length ≤ 1000",
        "starter_code": {
            "python": "def longest_common_subsequence(text1, text2):\n    # your code here\n    pass\n",
            "javascript": "function longestCommonSubsequence(text1, text2) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": '"abcde", "ace"', "expected_output": "3", "is_hidden": False},
            {"input": '"abc", "abc"', "expected_output": "3", "is_hidden": False},
            {"input": '"abc", "def"', "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Edit Distance",
        "slug": "edit-distance",
        "category_slug": "dynamic-programming",
        "difficulty": "hard",
        "description": "Given two strings `word1` and `word2`, return the minimum number of operations (insert, delete, replace) to convert `word1` to `word2`.",
        "constraints": "0 ≤ word1.length, word2.length ≤ 500",
        "starter_code": {
            "python": "def min_distance(word1, word2):\n    # your code here\n    pass\n",
            "javascript": "function minDistance(word1, word2) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": '"horse", "ros"', "expected_output": "3", "is_hidden": False},
            {"input": '"intention", "execution"', "expected_output": "5", "is_hidden": False},
            {"input": '"", "a"', "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Partition Equal Subset Sum",
        "slug": "partition-equal-subset-sum",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, return `true` if you can partition it into two subsets with equal sums.",
        "constraints": "1 ≤ nums.length ≤ 200\n1 ≤ nums[i] ≤ 100",
        "starter_code": {
            "python": "def can_partition(nums):\n    # your code here\n    pass\n",
            "javascript": "function canPartition(nums) {\n    // your code here\n}",
        },
        "order_index": 13,
        "test_cases": [
            {"input": "[1,5,11,5]", "expected_output": "true", "is_hidden": False},
            {"input": "[1,2,3,5]", "expected_output": "false", "is_hidden": False},
            {"input": "[2,2,1,1]", "expected_output": "true", "is_hidden": True},
        ],
    },
    {
        "title": "0/1 Knapsack",
        "slug": "zero-one-knapsack",
        "category_slug": "dynamic-programming",
        "difficulty": "medium",
        "description": "Given `weights` and `values` of items and a knapsack capacity `W`, find the maximum value you can carry. Each item can be used at most once.",
        "constraints": "1 ≤ n ≤ 1000\n1 ≤ W ≤ 1000",
        "starter_code": {
            "python": "def knapsack(weights, values, W):\n    # your code here\n    pass\n",
            "javascript": "function knapsack(weights, values, W) {\n    // your code here\n}",
        },
        "order_index": 14,
        "test_cases": [
            {"input": "[1,3,4,5], [1,4,5,7], 7", "expected_output": "9", "is_hidden": False},
            {"input": "[2,3,4,5], [3,4,5,6], 5", "expected_output": "7", "is_hidden": False},
            {"input": "[1], [10], 1", "expected_output": "10", "is_hidden": True},
        ],
    },

    # ── BACKTRACKING ──────────────────────────────────────────────────────────
    {
        "title": "Subsets",
        "slug": "subsets",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given a unique integer array `nums`, return all possible subsets (the power set). Return subsets sorted (each subset sorted, result sorted lexicographically).",
        "constraints": "1 ≤ nums.length ≤ 10\n-10 ≤ nums[i] ≤ 10",
        "starter_code": {
            "python": "def subsets(nums):\n    # return sorted list of sorted subsets\n    pass\n",
            "javascript": "function subsets(nums) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[1,2,3]", "expected_output": "[[],[1],[1,2],[1,2,3],[1,3],[2],[2,3],[3]]", "is_hidden": False},
            {"input": "[0]", "expected_output": "[[],[0]]", "is_hidden": False},
            {"input": "[1,2]", "expected_output": "[[],[1],[1,2],[2]]", "is_hidden": True},
        ],
    },
    {
        "title": "Subsets II",
        "slug": "subsets-ii",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given an integer array `nums` that may contain duplicates, return all possible unique subsets. Return subsets sorted.",
        "constraints": "1 ≤ nums.length ≤ 10\n-10 ≤ nums[i] ≤ 10",
        "starter_code": {
            "python": "def subsets_with_dup(nums):\n    # return sorted list of unique sorted subsets\n    pass\n",
            "javascript": "function subsetsWithDup(nums) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[1,2,2]", "expected_output": "[[],[1],[1,2],[1,2,2],[2],[2,2]]", "is_hidden": False},
            {"input": "[0]", "expected_output": "[[],[0]]", "is_hidden": False},
            {"input": "[1,1,2]", "expected_output": "[[],[1],[1,1],[1,1,2],[1,2],[2]]", "is_hidden": True},
        ],
    },
    {
        "title": "Permutations",
        "slug": "permutations",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given an array `nums` of distinct integers, return all possible permutations in sorted order.",
        "constraints": "1 ≤ nums.length ≤ 6\n-10 ≤ nums[i] ≤ 10",
        "starter_code": {
            "python": "def permutations(nums):\n    # return sorted list of all permutations\n    pass\n",
            "javascript": "function permute(nums) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,2,3]", "expected_output": "[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]", "is_hidden": False},
            {"input": "[0,1]", "expected_output": "[[0,1],[1,0]]", "is_hidden": False},
            {"input": "[1]", "expected_output": "[[1]]", "is_hidden": True},
        ],
    },
    {
        "title": "Combination Sum",
        "slug": "combination-sum",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given distinct integers `candidates` and a `target`, return all unique combinations where candidates sum to target. Numbers may be reused. Return combinations sorted.",
        "constraints": "1 ≤ candidates.length ≤ 30\n2 ≤ candidates[i] ≤ 40\n1 ≤ target ≤ 40",
        "starter_code": {
            "python": "def combination_sum(candidates, target):\n    # return sorted list of sorted combinations\n    pass\n",
            "javascript": "function combinationSum(candidates, target) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "[2,3,6,7], 7", "expected_output": "[[2,2,3],[7]]", "is_hidden": False},
            {"input": "[2,3,5], 8", "expected_output": "[[2,2,2,2],[2,3,3],[3,5]]", "is_hidden": False},
            {"input": "[2], 1", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Combination Sum II",
        "slug": "combination-sum-ii",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given `candidates` (may have duplicates) and a `target`, return all unique combinations summing to target. Each number may only be used once. Return combinations sorted.",
        "constraints": "1 ≤ candidates.length ≤ 100\n1 ≤ candidates[i] ≤ 50\n1 ≤ target ≤ 30",
        "starter_code": {
            "python": "def combination_sum2(candidates, target):\n    # return sorted list of sorted unique combinations\n    pass\n",
            "javascript": "function combinationSum2(candidates, target) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[10,1,2,7,6,1,5], 8", "expected_output": "[[1,1,6],[1,2,5],[1,7],[2,6]]", "is_hidden": False},
            {"input": "[2,5,2,1,2], 5", "expected_output": "[[1,2,2],[5]]", "is_hidden": False},
            {"input": "[1,1], 2", "expected_output": "[[1,1]]", "is_hidden": True},
        ],
    },
    {
        "title": "N-Queens",
        "slug": "n-queens",
        "category_slug": "backtracking",
        "difficulty": "hard",
        "description": "Place `n` queens on an `n x n` chessboard so no two queens attack each other. Return all distinct solutions as board configurations. Return solutions sorted.",
        "constraints": "1 ≤ n ≤ 9",
        "starter_code": {
            "python": "def solve_n_queens(n):\n    # return sorted list of board configurations (list of strings)\n    pass\n",
            "javascript": "function solveNQueens(n) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "4", "expected_output": '[[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]', "is_hidden": False},
            {"input": "1", "expected_output": '[["Q"]]', "is_hidden": False},
            {"input": "3", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "Word Search",
        "slug": "word-search",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given an `m x n` board of characters and a string `word`, return `true` if the word exists in the grid using adjacent cells (each cell used at most once).",
        "constraints": "1 ≤ m, n ≤ 6\n1 ≤ word.length ≤ 15",
        "starter_code": {
            "python": "def exist(board, word):\n    # your code here\n    pass\n",
            "javascript": "function exist(board, word) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": '[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "ABCCED"', "expected_output": "true", "is_hidden": False},
            {"input": '[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "SEE"', "expected_output": "true", "is_hidden": False},
            {"input": '[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], "ABCB"', "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Palindrome Partitioning",
        "slug": "palindrome-partitioning",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given string `s`, partition it so every substring is a palindrome. Return all possible palindrome partitionings sorted.",
        "constraints": "1 ≤ s.length ≤ 16",
        "starter_code": {
            "python": "def partition(s):\n    # return sorted list of partitions\n    pass\n",
            "javascript": "function partition(s) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": '"aab"', "expected_output": '[["a","a","b"],["aa","b"]]', "is_hidden": False},
            {"input": '"a"', "expected_output": '[["a"]]', "is_hidden": False},
            {"input": '"aba"', "expected_output": '[["a","b","a"],["aba"]]', "is_hidden": True},
        ],
    },
    {
        "title": "Letter Combinations of Phone Number",
        "slug": "letter-combinations-phone",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given a string of digits 2-9, return all possible letter combinations (keypad: 2=abc, 3=def, 4=ghi, 5=jkl, 6=mno, 7=pqrs, 8=tuv, 9=wxyz). Return sorted.",
        "constraints": "0 ≤ digits.length ≤ 4",
        "starter_code": {
            "python": "def letter_combinations(digits):\n    # return sorted list or []\n    pass\n",
            "javascript": "function letterCombinations(digits) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": '"23"', "expected_output": '["ad","ae","af","bd","be","bf","cd","ce","cf"]', "is_hidden": False},
            {"input": '""', "expected_output": "[]", "is_hidden": False},
            {"input": '"2"', "expected_output": '["a","b","c"]', "is_hidden": True},
        ],
    },
    {
        "title": "Generate Parentheses",
        "slug": "generate-parentheses",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given `n` pairs of parentheses, generate all combinations of well-formed parentheses. Return result sorted.",
        "constraints": "1 ≤ n ≤ 8",
        "starter_code": {
            "python": "def generate_parentheses(n):\n    # return sorted list of valid parenthesis strings\n    pass\n",
            "javascript": "function generateParenthesis(n) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "3", "expected_output": '["((()))","(()())","(())()","()(())","()()()"]', "is_hidden": False},
            {"input": "1", "expected_output": '["()"]', "is_hidden": False},
            {"input": "2", "expected_output": '["(())","()()"]', "is_hidden": True},
        ],
    },
    {
        "title": "Restore IP Addresses",
        "slug": "restore-ip-addresses",
        "category_slug": "backtracking",
        "difficulty": "medium",
        "description": "Given a string of digits `s`, return all valid IP address representations by inserting dots. Return sorted.",
        "constraints": "1 ≤ s.length ≤ 20",
        "starter_code": {
            "python": "def restore_ip_addresses(s):\n    # return sorted list of valid IP strings\n    pass\n",
            "javascript": "function restoreIpAddresses(s) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": '"25525511135"', "expected_output": '["255.255.11.135","255.255.111.35"]', "is_hidden": False},
            {"input": '"0000"', "expected_output": '["0.0.0.0"]', "is_hidden": False},
            {"input": '"1111"', "expected_output": '["1.1.1.1"]', "is_hidden": True},
        ],
    },

    # ── HEAP / PRIORITY QUEUE ─────────────────────────────────────────────────
    {
        "title": "Kth Largest Element in Array",
        "slug": "kth-largest-element",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Given an integer array `nums` and an integer `k`, return the `k`th largest element in the array.",
        "constraints": "1 ≤ k ≤ nums.length ≤ 10⁵\n-10⁴ ≤ nums[i] ≤ 10⁴",
        "starter_code": {
            "python": "def find_kth_largest(nums, k):\n    # your code here\n    pass\n",
            "javascript": "function findKthLargest(nums, k) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[3,2,1,5,6,4], 2", "expected_output": "5", "is_hidden": False},
            {"input": "[3,2,3,1,2,4,5,5,6], 4", "expected_output": "4", "is_hidden": False},
            {"input": "[1], 1", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "K Closest Points to Origin",
        "slug": "k-closest-points-origin",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Given a list of `points` and an integer `k`, return the `k` closest points to the origin. Return them sorted by [x, y].",
        "constraints": "1 ≤ k ≤ points.length ≤ 10⁴\n-10⁴ ≤ xi, yi ≤ 10⁴",
        "starter_code": {
            "python": "def k_closest(points, k):\n    # return k closest points sorted by [x,y]\n    pass\n",
            "javascript": "function kClosest(points, k) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "[[1,3],[-2,2]], 1", "expected_output": "[[-2,2]]", "is_hidden": False},
            {"input": "[[3,3],[5,-1],[-2,4]], 2", "expected_output": "[[-2,4],[3,3]]", "is_hidden": False},
            {"input": "[[0,1],[1,0]], 2", "expected_output": "[[0,1],[1,0]]", "is_hidden": True},
        ],
    },
    {
        "title": "Top K Frequent Elements",
        "slug": "top-k-frequent-elements-heap",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Given an integer array `nums` and an integer `k`, return the `k` most frequent elements sorted in ascending order.",
        "constraints": "1 ≤ nums.length ≤ 10⁵\nk is in range [1, number of unique elements]",
        "starter_code": {
            "python": "def top_k_frequent_heap(nums, k):\n    # return sorted list of k most frequent elements\n    pass\n",
            "javascript": "function topKFrequent(nums, k) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "[1,1,1,2,2,3], 2", "expected_output": "[1,2]", "is_hidden": False},
            {"input": "[1], 1", "expected_output": "[1]", "is_hidden": False},
            {"input": "[4,4,4,3,3,2,1], 2", "expected_output": "[3,4]", "is_hidden": True},
        ],
    },
    {
        "title": "Find Median from Data Stream",
        "slug": "find-median-data-stream",
        "category_slug": "heap",
        "difficulty": "hard",
        "description": "Simulate a median tracker. Operations: `['add', x]` adds x, `['median']` returns current median. Return list of float results for each 'median' call.",
        "constraints": "-10⁵ ≤ val ≤ 10⁵\nAt least one 'median' call",
        "starter_code": {
            "python": "def median_finder(operations):\n    # operations: ['add', x] or ['median']\n    # return list of floats for each 'median' call\n    pass\n",
            "javascript": "function medianFinder(operations) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": '[["add",1],["add",2],["median"],["add",3],["median"]]', "expected_output": "[1.5,2.0]", "is_hidden": False},
            {"input": '[["add",6],["median"],["add",10],["add",2],["median"]]', "expected_output": "[6.0,6.0]", "is_hidden": False},
            {"input": '[["add",1],["median"]]', "expected_output": "[1.0]", "is_hidden": True},
        ],
    },
    {
        "title": "Task Scheduler",
        "slug": "task-scheduler",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Given a list of CPU tasks and a cooldown `n`, return the minimum number of intervals to finish all tasks. Idle intervals count.",
        "constraints": "1 ≤ tasks.length ≤ 10⁴\n0 ≤ n ≤ 100",
        "starter_code": {
            "python": "def least_interval(tasks, n):\n    # your code here\n    pass\n",
            "javascript": "function leastInterval(tasks, n) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": '["A","A","A","B","B","B"], 2', "expected_output": "8", "is_hidden": False},
            {"input": '["A","A","A","B","B","B"], 0', "expected_output": "6", "is_hidden": False},
            {"input": '["A","A","A","A","A","A","B","C","D","E","F","G"], 2', "expected_output": "16", "is_hidden": True},
        ],
    },
    {
        "title": "Last Stone Weight",
        "slug": "last-stone-weight",
        "category_slug": "heap",
        "difficulty": "easy",
        "description": "Smash the two heaviest stones each turn. Equal weights destroy both; otherwise the difference remains. Return the last stone's weight, or 0 if none remain.",
        "constraints": "1 ≤ stones.length ≤ 30\n1 ≤ stones[i] ≤ 1000",
        "starter_code": {
            "python": "def last_stone_weight(stones):\n    # your code here\n    pass\n",
            "javascript": "function lastStoneWeight(stones) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "[2,7,4,1,8,1]", "expected_output": "1", "is_hidden": False},
            {"input": "[1]", "expected_output": "1", "is_hidden": False},
            {"input": "[3,3]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Kth Smallest in Sorted Matrix",
        "slug": "kth-smallest-sorted-matrix",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Given an `n x n` matrix where each row and column is sorted ascending, return the `k`th smallest element.",
        "constraints": "1 ≤ n ≤ 300\n1 ≤ k ≤ n²",
        "starter_code": {
            "python": "def kth_smallest(matrix, k):\n    # your code here\n    pass\n",
            "javascript": "function kthSmallest(matrix, k) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "[[1,5,9],[10,11,13],[12,13,15]], 8", "expected_output": "13", "is_hidden": False},
            {"input": "[[-5]], 1", "expected_output": "-5", "is_hidden": False},
            {"input": "[[1,2],[3,3]], 3", "expected_output": "3", "is_hidden": True},
        ],
    },
    {
        "title": "Reorganize String",
        "slug": "reorganize-string",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Rearrange characters of string `s` so no two adjacent characters are the same. Return any valid rearrangement, or `\"\"` if not possible.",
        "constraints": "1 ≤ s.length ≤ 500\ns consists of lowercase English letters",
        "starter_code": {
            "python": "def reorganize_string(s):\n    # return rearranged string or \"\"\n    pass\n",
            "javascript": "function reorganizeString(s) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": '"aab"', "expected_output": '"aba"', "is_hidden": False},
            {"input": '"aaab"', "expected_output": '""', "is_hidden": False},
            {"input": '"aa"', "expected_output": '""', "is_hidden": True},
        ],
    },
    {
        "title": "Merge K Sorted Lists",
        "slug": "merge-k-sorted-lists",
        "category_slug": "heap",
        "difficulty": "hard",
        "description": "Given an array of `k` sorted integer arrays, merge all into one sorted list and return it.",
        "constraints": "0 ≤ k ≤ 10⁴\n0 ≤ lists[i].length ≤ 500",
        "starter_code": {
            "python": "def merge_k_lists(lists_arr):\n    # lists_arr is a list of sorted arrays\n    # return one merged sorted list\n    pass\n",
            "javascript": "function mergeKLists(lists) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[[1,4,5],[1,3,4],[2,6]]", "expected_output": "[1,1,2,3,4,4,5,6]", "is_hidden": False},
            {"input": "[]", "expected_output": "[]", "is_hidden": False},
            {"input": "[[]]", "expected_output": "[]", "is_hidden": True},
        ],
    },
    {
        "title": "IPO",
        "slug": "ipo",
        "category_slug": "heap",
        "difficulty": "hard",
        "description": "Given `k` projects (profits and required capitals) and initial capital `w`, pick at most `k` projects to maximize total capital. Can only start a project if current capital ≥ required capital.",
        "constraints": "1 ≤ k ≤ 10⁵\n0 ≤ w ≤ 10⁹\n0 ≤ profit[i], capital[i] ≤ 10⁴",
        "starter_code": {
            "python": "def find_maximized_capital(k, w, profits, capital):\n    # your code here\n    pass\n",
            "javascript": "function findMaximizedCapital(k, w, profits, capital) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "2, 0, [1,2,3], [0,1,1]", "expected_output": "4", "is_hidden": False},
            {"input": "3, 0, [1,2,3], [0,1,2]", "expected_output": "6", "is_hidden": False},
            {"input": "1, 0, [1,2,3], [1,2,3]", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Twitter Feed",
        "slug": "twitter-feed",
        "category_slug": "heap",
        "difficulty": "medium",
        "description": "Simulate a simplified Twitter. Operations: `['post', userId, tweetId]`, `['follow', followerId, followeeId]`, `['unfollow', followerId, followeeId]`, `['news', userId]` returns 10 most recent tweets. Return list of results for 'news' calls.",
        "constraints": "1 ≤ userId, tweetId ≤ 500",
        "starter_code": {
            "python": "def twitter(operations):\n    # return list of results for 'news' operations\n    pass\n",
            "javascript": "function twitter(operations) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": '[["post",1,5],["post",1,3],["post",2,1],["follow",1,2],["news",1],["unfollow",1,2],["news",1]]', "expected_output": "[[3,1,5],[3,5]]", "is_hidden": False},
            {"input": '[["post",1,1],["news",1]]', "expected_output": "[[1]]", "is_hidden": False},
            {"input": '[["post",1,1],["post",1,2],["news",1]]', "expected_output": "[[2,1]]", "is_hidden": True},
        ],
    },

    # ── TRIES ─────────────────────────────────────────────────────────────────
    {
        "title": "Implement Trie",
        "slug": "implement-trie",
        "category_slug": "tries",
        "difficulty": "medium",
        "description": "Implement a trie with `insert`, `search`, and `startsWith`. Simulate with operations `['insert', w]`, `['search', w]`, `['startsWith', p]`. Return list of bool results for search/startsWith.",
        "constraints": "1 ≤ word.length ≤ 2000\nAll chars are lowercase letters",
        "starter_code": {
            "python": "def trie_operations(operations):\n    # operations: ['insert',w], ['search',w], or ['startsWith',p]\n    # return list of True/False for search and startsWith\n    pass\n",
            "javascript": "function trieOperations(operations) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": '[["insert","apple"],["search","apple"],["search","app"],["startsWith","app"],["insert","app"],["search","app"]]', "expected_output": "[true,false,true,true]", "is_hidden": False},
            {"input": '[["insert","a"],["search","a"],["search","b"]]', "expected_output": "[true,false]", "is_hidden": False},
            {"input": '[["insert","hello"],["startsWith","hel"],["startsWith","world"]]', "expected_output": "[true,false]", "is_hidden": True},
        ],
    },
    {
        "title": "Design Add and Search Words",
        "slug": "add-search-words",
        "category_slug": "tries",
        "difficulty": "medium",
        "description": "Implement a word dictionary supporting `addWord` and `search` where `'.'` matches any letter. Operations `['add', w]` and `['search', p]`. Return list of bool results for search calls.",
        "constraints": "1 ≤ word.length ≤ 25\nPatterns use lowercase letters and '.'",
        "starter_code": {
            "python": "def word_dictionary(operations):\n    # operations: ['add', w] or ['search', p]\n    # return list of bool for each 'search'\n    pass\n",
            "javascript": "function wordDictionary(operations) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": '[["add","bad"],["add","dad"],["add","mad"],["search","pad"],["search","bad"],["search",".ad"],["search","b.."]]', "expected_output": "[false,true,true,true]", "is_hidden": False},
            {"input": '[["add","a"],["search","."]]', "expected_output": "[true]", "is_hidden": False},
            {"input": '[["add","abc"],["search","a.c"],["search","ab."]]', "expected_output": "[true,true]", "is_hidden": True},
        ],
    },
    {
        "title": "Word Search II",
        "slug": "word-search-ii",
        "category_slug": "tries",
        "difficulty": "hard",
        "description": "Given an `m x n` board of characters and a list of words, return all words found in the board (adjacent cells, each cell once per word). Return sorted.",
        "constraints": "1 ≤ m, n ≤ 12\n1 ≤ words.length ≤ 3×10⁴",
        "starter_code": {
            "python": "def find_words(board, words):\n    # return sorted list of found words\n    pass\n",
            "javascript": "function findWords(board, words) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": '[["o","a","a","n"],["e","t","a","e"],["i","h","k","r"],["i","f","l","v"]], ["oath","pea","eat","rain"]', "expected_output": '["eat","oath"]', "is_hidden": False},
            {"input": '[["a","b"],["c","d"]], ["abcd"]', "expected_output": "[]", "is_hidden": False},
            {"input": '[["a","b"],["c","d"]], ["ab","ba","abdc"]', "expected_output": '["ab","ba"]', "is_hidden": True},
        ],
    },
    {
        "title": "Replace Words",
        "slug": "replace-words",
        "category_slug": "tries",
        "difficulty": "medium",
        "description": "Given a `dictionary` of root words and a `sentence`, replace each word in the sentence with its shortest root from the dictionary. Return the modified sentence.",
        "constraints": "1 ≤ dictionary.length ≤ 1000\n1 ≤ sentence.length ≤ 10⁶",
        "starter_code": {
            "python": "def replace_words(dictionary, sentence):\n    # your code here\n    pass\n",
            "javascript": "function replaceWords(dictionary, sentence) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": '["cat","bat","rat"], "the cattle was rattled by the battery"', "expected_output": '"the cat was rat by the bat"', "is_hidden": False},
            {"input": '["a","b","c"], "aadsfasf absbs bbab cadsfafs"', "expected_output": '"a a b c"', "is_hidden": False},
            {"input": '["abc","ab"], "abcde"', "expected_output": '"ab"', "is_hidden": True},
        ],
    },
    {
        "title": "Longest Word in Dictionary",
        "slug": "longest-word-dictionary",
        "category_slug": "tries",
        "difficulty": "easy",
        "description": "Given an array of strings `words`, return the longest word buildable one character at a time by other words in the list. If multiple exist, return the lexicographically smallest.",
        "constraints": "1 ≤ words.length ≤ 1000\n1 ≤ words[i].length ≤ 30",
        "starter_code": {
            "python": "def longest_word(words):\n    # your code here\n    pass\n",
            "javascript": "function longestWord(words) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": '["w","wo","wor","worl","world"]', "expected_output": '"world"', "is_hidden": False},
            {"input": '["a","banana","app","appl","ap","apply","apple"]', "expected_output": '"apple"', "is_hidden": False},
            {"input": '["a","b"]', "expected_output": '"a"', "is_hidden": True},
        ],
    },
    {
        "title": "Map Sum Pairs",
        "slug": "map-sum-pairs",
        "category_slug": "tries",
        "difficulty": "medium",
        "description": "Design a map supporting `insert(key, val)` and `sum(prefix)` returning the sum of values for all keys starting with prefix. Simulate with `['insert', key, val]` and `['sum', prefix]`. Return int results for 'sum'.",
        "constraints": "1 ≤ key.length ≤ 50\n0 ≤ val ≤ 1000",
        "starter_code": {
            "python": "def map_sum(operations):\n    # operations: ['insert', key, val] or ['sum', prefix]\n    # return list of int results for 'sum' calls\n    pass\n",
            "javascript": "function mapSum(operations) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": '[["insert","apple",3],["sum","ap"],["insert","app",2],["sum","ap"]]', "expected_output": "[3,5]", "is_hidden": False},
            {"input": '[["insert","aa",3],["sum","a"],["insert","aa",2],["sum","a"]]', "expected_output": "[3,2]", "is_hidden": False},
            {"input": '[["insert","abc",5],["sum","ab"],["sum","xyz"]]', "expected_output": "[5,0]", "is_hidden": True},
        ],
    },
    {
        "title": "Palindrome Pairs",
        "slug": "palindrome-pairs",
        "category_slug": "tries",
        "difficulty": "hard",
        "description": "Given a list of unique words, return all index pairs `[i, j]` where `words[i] + words[j]` forms a palindrome. Return pairs sorted by `[i, j]`.",
        "constraints": "1 ≤ words.length ≤ 5000\n0 ≤ words[i].length ≤ 300",
        "starter_code": {
            "python": "def palindrome_pairs(words):\n    # return sorted list of [i, j] pairs\n    pass\n",
            "javascript": "function palindromePairs(words) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": '["abcd","dcba","lls","s","sssll"]', "expected_output": "[[0,1],[1,0],[2,4],[3,2]]", "is_hidden": False},
            {"input": '["bat","tab","cat"]', "expected_output": "[[0,1],[1,0]]", "is_hidden": False},
            {"input": '["a",""]', "expected_output": "[[0,1],[1,0]]", "is_hidden": True},
        ],
    },
    {
        "title": "Search Suggestions System",
        "slug": "search-suggestions-system",
        "category_slug": "tries",
        "difficulty": "medium",
        "description": "Given a list of `products` and a `searchWord`, return a list of up to 3 lexicographically smallest product suggestions after each character typed that share the prefix.",
        "constraints": "1 ≤ products.length ≤ 1000\n1 ≤ searchWord.length ≤ 1000",
        "starter_code": {
            "python": "def suggested_products(products, searchWord):\n    # return list of up to 3 suggestions per character typed\n    pass\n",
            "javascript": "function suggestedProducts(products, searchWord) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": '["mobile","mouse","moneypot","monitor","mousepad"], "mouse"', "expected_output": '[["mobile","moneypot","monitor"],["mobile","moneypot","monitor"],["mouse","mousepad"],["mouse","mousepad"],["mouse","mousepad"]]', "is_hidden": False},
            {"input": '["havana"], "havana"', "expected_output": '[["havana"],["havana"],["havana"],["havana"],["havana"],["havana"]]', "is_hidden": False},
            {"input": '["bags","baggage","banner","box","cloths"], "bags"', "expected_output": '[["baggage","bags","banner"],["baggage","bags","banner"],["baggage","bags"],["bags"]]', "is_hidden": True},
        ],
    },

    # ── BIT MANIPULATION ──────────────────────────────────────────────────────
    {
        "title": "Single Number",
        "slug": "single-number",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "Given a non-empty array where every element appears twice except for one, find that single element using O(1) extra space.",
        "constraints": "1 ≤ nums.length ≤ 3×10⁴\n-3×10⁴ ≤ nums[i] ≤ 3×10⁴",
        "starter_code": {
            "python": "def single_number(nums):\n    # your code here\n    pass\n",
            "javascript": "function singleNumber(nums) {\n    // your code here\n}",
        },
        "order_index": 1,
        "test_cases": [
            {"input": "[2,2,1]", "expected_output": "1", "is_hidden": False},
            {"input": "[4,1,2,1,2]", "expected_output": "4", "is_hidden": False},
            {"input": "[1]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Number of 1 Bits",
        "slug": "number-of-1-bits",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "Given an unsigned integer `n`, return the number of `1` bits it has (Hamming weight).",
        "constraints": "0 ≤ n ≤ 2³²-1",
        "starter_code": {
            "python": "def hamming_weight(n):\n    # your code here\n    pass\n",
            "javascript": "function hammingWeight(n) {\n    // your code here\n}",
        },
        "order_index": 2,
        "test_cases": [
            {"input": "11", "expected_output": "3", "is_hidden": False},
            {"input": "128", "expected_output": "1", "is_hidden": False},
            {"input": "2147483645", "expected_output": "30", "is_hidden": True},
        ],
    },
    {
        "title": "Counting Bits",
        "slug": "counting-bits",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "Given integer `n`, return an array of length `n+1` where `ans[i]` is the number of 1 bits in `i`.",
        "constraints": "0 ≤ n ≤ 10⁵",
        "starter_code": {
            "python": "def count_bits(n):\n    # return list of length n+1\n    pass\n",
            "javascript": "function countBits(n) {\n    // your code here\n}",
        },
        "order_index": 3,
        "test_cases": [
            {"input": "2", "expected_output": "[0,1,1]", "is_hidden": False},
            {"input": "5", "expected_output": "[0,1,1,2,1,2]", "is_hidden": False},
            {"input": "0", "expected_output": "[0]", "is_hidden": True},
        ],
    },
    {
        "title": "Reverse Bits",
        "slug": "reverse-bits",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "Reverse the bits of a 32-bit unsigned integer and return the result.",
        "constraints": "0 ≤ n ≤ 2³²-1",
        "starter_code": {
            "python": "def reverse_bits(n):\n    # your code here\n    pass\n",
            "javascript": "function reverseBits(n) {\n    // your code here\n}",
        },
        "order_index": 4,
        "test_cases": [
            {"input": "43261596", "expected_output": "964176192", "is_hidden": False},
            {"input": "4294967293", "expected_output": "3221225471", "is_hidden": False},
            {"input": "0", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Missing Number",
        "slug": "missing-number",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "Given an array `nums` of `n` distinct numbers in range `[0, n]`, return the missing number.",
        "constraints": "1 ≤ n ≤ 10⁴\nAll numbers are unique",
        "starter_code": {
            "python": "def missing_number(nums):\n    # your code here\n    pass\n",
            "javascript": "function missingNumber(nums) {\n    // your code here\n}",
        },
        "order_index": 5,
        "test_cases": [
            {"input": "[3,0,1]", "expected_output": "2", "is_hidden": False},
            {"input": "[0,1]", "expected_output": "2", "is_hidden": False},
            {"input": "[9,6,4,2,3,5,7,0,1]", "expected_output": "8", "is_hidden": True},
        ],
    },
    {
        "title": "Sum of Two Integers",
        "slug": "sum-two-integers",
        "category_slug": "bit-manipulation",
        "difficulty": "medium",
        "description": "Calculate the sum of two integers `a` and `b` without using `+` or `-` operators.",
        "constraints": "-1000 ≤ a, b ≤ 1000",
        "starter_code": {
            "python": "def get_sum(a, b):\n    # do not use + or - operators\n    pass\n",
            "javascript": "function getSum(a, b) {\n    // your code here\n}",
        },
        "order_index": 6,
        "test_cases": [
            {"input": "1, 2", "expected_output": "3", "is_hidden": False},
            {"input": "2, 3", "expected_output": "5", "is_hidden": False},
            {"input": "-1, 1", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Power of Two",
        "slug": "power-of-two",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "Given an integer `n`, return `true` if it is a power of two.",
        "constraints": "-2³¹ ≤ n ≤ 2³¹-1",
        "starter_code": {
            "python": "def is_power_of_two(n):\n    # your code here\n    pass\n",
            "javascript": "function isPowerOfTwo(n) {\n    // your code here\n}",
        },
        "order_index": 7,
        "test_cases": [
            {"input": "1", "expected_output": "true", "is_hidden": False},
            {"input": "16", "expected_output": "true", "is_hidden": False},
            {"input": "3", "expected_output": "false", "is_hidden": True},
        ],
    },
    {
        "title": "Bitwise AND of Numbers Range",
        "slug": "bitwise-and-range",
        "category_slug": "bit-manipulation",
        "difficulty": "medium",
        "description": "Given integers `left` and `right`, return the bitwise AND of all numbers in range `[left, right]`.",
        "constraints": "0 ≤ left ≤ right ≤ 2³¹-1",
        "starter_code": {
            "python": "def range_bitwise_and(left, right):\n    # your code here\n    pass\n",
            "javascript": "function rangeBitwiseAnd(left, right) {\n    // your code here\n}",
        },
        "order_index": 8,
        "test_cases": [
            {"input": "5, 7", "expected_output": "4", "is_hidden": False},
            {"input": "0, 0", "expected_output": "0", "is_hidden": False},
            {"input": "1, 2147483647", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Find the Duplicate Number",
        "slug": "find-duplicate-number",
        "category_slug": "bit-manipulation",
        "difficulty": "medium",
        "description": "Given an array of `n+1` integers where each is between 1 and n, find the one duplicate number using O(1) extra space.",
        "constraints": "1 ≤ n ≤ 10⁵\nOnly one duplicate",
        "starter_code": {
            "python": "def find_duplicate(nums):\n    # your code here\n    pass\n",
            "javascript": "function findDuplicate(nums) {\n    // your code here\n}",
        },
        "order_index": 9,
        "test_cases": [
            {"input": "[1,3,4,2,2]", "expected_output": "2", "is_hidden": False},
            {"input": "[3,1,3,4,2]", "expected_output": "3", "is_hidden": False},
            {"input": "[1,1]", "expected_output": "1", "is_hidden": True},
        ],
    },
    {
        "title": "Hamming Distance",
        "slug": "hamming-distance",
        "category_slug": "bit-manipulation",
        "difficulty": "easy",
        "description": "The Hamming distance between two integers is the number of bit positions where they differ. Given `x` and `y`, return the Hamming distance.",
        "constraints": "0 ≤ x, y ≤ 2³¹-1",
        "starter_code": {
            "python": "def hamming_distance(x, y):\n    # your code here\n    pass\n",
            "javascript": "function hammingDistance(x, y) {\n    // your code here\n}",
        },
        "order_index": 10,
        "test_cases": [
            {"input": "1, 4", "expected_output": "2", "is_hidden": False},
            {"input": "3, 1", "expected_output": "1", "is_hidden": False},
            {"input": "0, 0", "expected_output": "0", "is_hidden": True},
        ],
    },
    {
        "title": "Total Hamming Distance",
        "slug": "total-hamming-distance",
        "category_slug": "bit-manipulation",
        "difficulty": "medium",
        "description": "Given an integer array `nums`, return the sum of Hamming distances between all pairs of numbers.",
        "constraints": "1 ≤ nums.length ≤ 10⁴\n0 ≤ nums[i] ≤ 10⁹",
        "starter_code": {
            "python": "def total_hamming_distance(nums):\n    # your code here\n    pass\n",
            "javascript": "function totalHammingDistance(nums) {\n    // your code here\n}",
        },
        "order_index": 11,
        "test_cases": [
            {"input": "[4,14,2]", "expected_output": "6", "is_hidden": False},
            {"input": "[4,14,4]", "expected_output": "4", "is_hidden": False},
            {"input": "[1,2,4]", "expected_output": "4", "is_hidden": True},
        ],
    },
    {
        "title": "Single Number II",
        "slug": "single-number-ii",
        "category_slug": "bit-manipulation",
        "difficulty": "medium",
        "description": "Given an array where every element appears exactly three times except for one that appears once, return the single element. Use O(1) extra space.",
        "constraints": "1 ≤ nums.length ≤ 3×10⁴\n-2³¹ ≤ nums[i] ≤ 2³¹-1",
        "starter_code": {
            "python": "def single_number2(nums):\n    # your code here\n    pass\n",
            "javascript": "function singleNumber(nums) {\n    // your code here\n}",
        },
        "order_index": 12,
        "test_cases": [
            {"input": "[2,2,3,2]", "expected_output": "3", "is_hidden": False},
            {"input": "[0,1,0,1,0,1,99]", "expected_output": "99", "is_hidden": False},
            {"input": "[1,1,1,2]", "expected_output": "2", "is_hidden": True},
        ],
    },
]
