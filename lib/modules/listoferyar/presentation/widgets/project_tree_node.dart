import 'package:flutter/material.dart';

import '../../domain/models/project_node.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';

class ListoferyarProjectTreeNode
    extends StatelessWidget {
  const ListoferyarProjectTreeNode({
    super.key,
    required this.node,
    required this.childrenBuilder,
    required this.depth,
    required this.onAddChild,
    required this.onRename,
    required this.onDelete,
  });

  final ListoferyarProjectNode node;

  final List<Widget> Function(
    ListoferyarProjectNode node,
    int depth,
  ) childrenBuilder;

  final int depth;

  final void Function(
    ListoferyarProjectNode node,
  ) onAddChild;

  final void Function(
    ListoferyarProjectNode node,
  ) onRename;

  final void Function(
    ListoferyarProjectNode node,
  ) onDelete;

  @override
  Widget build(BuildContext context) {
    final children =
        childrenBuilder(node, depth);

    final isRoot = depth == 0;

    return Padding(
      padding: EdgeInsets.only(
        right: depth * 12.0,
        bottom: 10,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: isRoot
                    ? ListoferyarColors
                        .primaryLight
                        .withValues(alpha: 0.28)
                    : ListoferyarColors
                        .borderSoft,
              ),
              boxShadow: isRoot
                  ? const [
                      ListoferyarTheme
                          .subtleShadow,
                    ]
                  : const [],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                11,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration:
                            BoxDecoration(
                          color: isRoot
                              ? ListoferyarColors
                                  .surfaceBlue
                              : ListoferyarColors
                                  .surfaceTeal,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          isRoot
                              ? Icons
                                  .account_tree_rounded
                              : Icons
                                  .segment_rounded,
                          color: isRoot
                              ? ListoferyarColors
                                  .primary
                              : ListoferyarColors
                                  .accent,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              node.name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  ListoferyarTypography
                                      .cardTitle,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              children.isEmpty
                                  ? 'بدون زیرشاخه'
                                  : '${children.length} زیرشاخه مستقیم',
                              style:
                                  ListoferyarTypography
                                      .helper,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'عملیات',
                        onSelected: (value) {
                          switch (value) {
                            case 'rename':
                              onRename(node);
                              break;

                            case 'delete':
                              onDelete(node);
                              break;
                          }
                        },
                        itemBuilder: (_) =>
                            const [
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .edit_rounded,
                                  size: 20,
                                ),
                                SizedBox(width: 9),
                                Text(
                                  'ویرایش نام',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .delete_outline_rounded,
                                  size: 20,
                                ),
                                SizedBox(width: 9),
                                Text(
                                  'حذف',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          onAddChild(node),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 19,
                      ),
                      label: const Text(
                        'افزودن زیرشاخه',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (children.isNotEmpty)
            Container(
              margin:
                  const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.only(
                right: 10,
                top: 7,
              ),
              decoration:
                  const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color:
                        ListoferyarColors.accent,
                    width: 1.4,
                  ),
                ),
              ),
              child: Column(
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}