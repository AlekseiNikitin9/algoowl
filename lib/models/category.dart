import 'package:flutter/material.dart';

enum CategoryStatus { completed, current, locked }

class Category {
  final String id;
  final String name;
  final String slug;
  final IconData icon;
  final int orderIndex;
  final CategoryStatus status;
  final double progress; // 0.0–1.0

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.orderIndex,
    this.status = CategoryStatus.locked,
    this.progress = 0.0,
  });
}

/// MVP categories per architecture doc.
final List<Category> kCategories = [
  const Category(
    id: '1',
    name: 'Arrays & Strings',
    slug: 'arrays-strings',
    icon: Icons.grid_on,
    orderIndex: 0,
    status: CategoryStatus.completed,
    progress: 1.0,
  ),
  const Category(
    id: '2',
    name: 'Hashing',
    slug: 'hashing',
    icon: Icons.tag,
    orderIndex: 1,
    status: CategoryStatus.current,
    progress: 0.4,
  ),
  const Category(
    id: '3',
    name: 'Two Pointers',
    slug: 'two-pointers',
    icon: Icons.compare_arrows,
    orderIndex: 2,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '4',
    name: 'Sliding Window',
    slug: 'sliding-window',
    icon: Icons.view_carousel,
    orderIndex: 3,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '5',
    name: 'Stack & Queue',
    slug: 'stack-queue',
    icon: Icons.stacked_line_chart,
    orderIndex: 4,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '6',
    name: 'Binary Search',
    slug: 'binary-search',
    icon: Icons.search,
    orderIndex: 5,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '7',
    name: 'Linked Lists',
    slug: 'linked-lists',
    icon: Icons.link,
    orderIndex: 6,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '8',
    name: 'Trees',
    slug: 'trees',
    icon: Icons.account_tree,
    orderIndex: 7,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '9',
    name: 'Graphs',
    slug: 'graphs',
    icon: Icons.hub,
    orderIndex: 8,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '10',
    name: 'Dynamic Programming',
    slug: 'dynamic-programming',
    icon: Icons.table_chart,
    orderIndex: 9,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '11',
    name: 'Backtracking',
    slug: 'backtracking',
    icon: Icons.undo,
    orderIndex: 10,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '12',
    name: 'Heap / Priority Queue',
    slug: 'heap',
    icon: Icons.filter_list,
    orderIndex: 11,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '13',
    name: 'Tries',
    slug: 'tries',
    icon: Icons.lan,
    orderIndex: 12,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
  const Category(
    id: '14',
    name: 'Bit Manipulation',
    slug: 'bit-manipulation',
    icon: Icons.memory,
    orderIndex: 13,
    status: CategoryStatus.locked,
    progress: 0.0,
  ),
];
