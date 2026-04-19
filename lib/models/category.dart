import 'package:flutter/material.dart';

import '../core/widgets/chapter_glyph.dart';

enum CategoryStatus { completed, current, locked }

class Category {
  final String id;
  final String name;
  final String slug;
  final IconData icon;
  final GlyphKind glyph;
  final int orderIndex;
  final CategoryStatus status;
  final double progress; // 0.0–1.0

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.glyph,
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
    glyph: GlyphKind.array,
    orderIndex: 0,
    status: CategoryStatus.completed,
    progress: 1.0,
  ),
  const Category(
    id: '2',
    name: 'Hashing',
    slug: 'hashing',
    icon: Icons.tag,
    glyph: GlyphKind.hash,
    orderIndex: 1,
    status: CategoryStatus.current,
    progress: 0.4,
  ),
  const Category(
    id: '3',
    name: 'Two Pointers',
    slug: 'two-pointers',
    icon: Icons.compare_arrows,
    glyph: GlyphKind.pointer,
    orderIndex: 2,
  ),
  const Category(
    id: '4',
    name: 'Sliding Window',
    slug: 'sliding-window',
    icon: Icons.view_carousel,
    glyph: GlyphKind.window,
    orderIndex: 3,
  ),
  const Category(
    id: '5',
    name: 'Stack & Queue',
    slug: 'stack-queue',
    icon: Icons.stacked_line_chart,
    glyph: GlyphKind.stack,
    orderIndex: 4,
  ),
  const Category(
    id: '6',
    name: 'Binary Search',
    slug: 'binary-search',
    icon: Icons.search,
    glyph: GlyphKind.search,
    orderIndex: 5,
  ),
  const Category(
    id: '7',
    name: 'Linked Lists',
    slug: 'linked-lists',
    icon: Icons.link,
    glyph: GlyphKind.pointer,
    orderIndex: 6,
  ),
  const Category(
    id: '8',
    name: 'Trees',
    slug: 'trees',
    icon: Icons.account_tree,
    glyph: GlyphKind.tree,
    orderIndex: 7,
  ),
  const Category(
    id: '9',
    name: 'Graphs',
    slug: 'graphs',
    icon: Icons.hub,
    glyph: GlyphKind.graph,
    orderIndex: 8,
  ),
  const Category(
    id: '10',
    name: 'Dynamic Programming',
    slug: 'dynamic-programming',
    icon: Icons.table_chart,
    glyph: GlyphKind.neural,
    orderIndex: 9,
  ),
  const Category(
    id: '11',
    name: 'Backtracking',
    slug: 'backtracking',
    icon: Icons.undo,
    glyph: GlyphKind.tree,
    orderIndex: 10,
  ),
  const Category(
    id: '12',
    name: 'Heap / Priority Queue',
    slug: 'heap',
    icon: Icons.filter_list,
    glyph: GlyphKind.tree,
    orderIndex: 11,
  ),
  const Category(
    id: '13',
    name: 'Tries',
    slug: 'tries',
    icon: Icons.lan,
    glyph: GlyphKind.tree,
    orderIndex: 12,
  ),
  const Category(
    id: '14',
    name: 'Bit Manipulation',
    slug: 'bit-manipulation',
    icon: Icons.memory,
    glyph: GlyphKind.neural,
    orderIndex: 13,
  ),
];
