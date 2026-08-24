import 'package:flutter/material.dart';

import '../../data/repositories/layer_repository_impl.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_node.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import '../dialogs/create_node_dialog.dart';
import '../widgets/project_tree_node.dart';
import 'rebar_entry_screen.dart';

class ListoferyarProjectTreeScreen
    extends StatefulWidget {
  const ListoferyarProjectTreeScreen({
    super.key,
    required this.project,
  });

  final ListoferyarProject project;

  @override
  State<ListoferyarProjectTreeScreen>
      createState() =>
          _ListoferyarProjectTreeScreenState();
}

class _ListoferyarProjectTreeScreenState
    extends State<ListoferyarProjectTreeScreen> {
  final LayerRepository _repository =
      LayerRepository();

  List<ListoferyarProjectNode> _nodes =
      const [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  List<ListoferyarProjectNode> _childrenOf(
    int? parentId,
  ) {
    return _nodes
        .where(
          (node) => node.parentId == parentId,
        )
        .toList(growable: false);
  }

  Future<void> _loadTree() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final projectId = widget.project.id;

      if (projectId == null) {
        throw StateError(
          'شناسه پروژه نامعتبر است.',
        );
      }

      final nodes =
          await _repository.getAllByProject(
        projectId,
      );

      if (!mounted) return;

      setState(() {
        _nodes = nodes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'ساختار پروژه خوانده نشد: $error',
          ),
        ),
      );
    }
  }

  Future<void> _addNode({
    int? parentId,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CreateNodeDialog(
        title: parentId == null
            ? 'افزودن بخش اصلی'
            : 'افزودن زیرشاخه',
        helperText: parentId == null
            ? 'این بخش می‌تواند هر تعداد زیرشاخه داشته باشد.'
            : 'برای این بخش، زیرشاخه مورد نیاز را تعریف کنید.',
      ),
    );

    if (name == null ||
        name.trim().isEmpty) {
      return;
    }

    try {
      final projectId = widget.project.id;

      if (projectId == null) {
        throw StateError(
          'شناسه پروژه نامعتبر است.',
        );
      }

      await _repository.create(
        projectId: projectId,
        parentId: parentId,
        name: name.trim(),
      );

      await _loadTree();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'افزودن بخش انجام نشد: $error',
          ),
        ),
      );
    }
  }

  Future<void> _renameNode(
    ListoferyarProjectNode node,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CreateNodeDialog(
        title: 'ویرایش نام',
        initialName: node.name,
      ),
    );

    if (name == null ||
        name.trim().isEmpty) {
      return;
    }

    try {
      final id = node.id;

      if (id == null) {
        throw StateError(
          'شناسه بخش نامعتبر است.',
        );
      }

      await _repository.updateName(
        id: id,
        name: name.trim(),
      );

      await _loadTree();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'ویرایش انجام نشد: $error',
          ),
        ),
      );
    }
  }

  Future<void> _deleteNode(
    ListoferyarProjectNode node,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
        title: const Text('حذف بخش'),
        content: Text(
          '«${node.name}» و تمام زیرشاخه‌های آن حذف شوند؟',
          style:
              ListoferyarTypography.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(
                  dialogContext,
                ).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  ListoferyarColors.danger,
            ),
            onPressed: () =>
                Navigator.of(
                  dialogContext,
                ).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final id = node.id;

      if (id == null) {
        throw StateError(
          'شناسه بخش نامعتبر است.',
        );
      }

      await _repository.delete(id);

      await _loadTree();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'حذف انجام نشد: $error',
          ),
        ),
      );
    }
  }

  Future<void> _openRebarEntry() async {
    final projectId = widget.project.id;

    if (projectId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'شناسه پروژه نامعتبر است.',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ListoferyarRebarEntryScreen(
          project: widget.project,
        ),
      ),
    );
  }

  List<Widget> _buildChildren(
    ListoferyarProjectNode node,
    int depth,
  ) {
    return _childrenOf(node.id)
        .map(
          (child) =>
              ListoferyarProjectTreeNode(
            node: child,
            depth: depth + 1,
            childrenBuilder: _buildChildren,
            onAddChild: _addNodeForNode,
            onRename: _renameNode,
            onDelete: _deleteNode,
          ),
        )
        .toList(growable: false);
  }

  void _addNodeForNode(
    ListoferyarProjectNode node,
  ) {
    _addNode(parentId: node.id);
  }

  Widget _buildRootNode(
    ListoferyarProjectNode node,
  ) {
    return ListoferyarProjectTreeNode(
      node: node,
      depth: 0,
      childrenBuilder: _buildChildren,
      onAddChild: _addNodeForNode,
      onRename: _renameNode,
      onDelete: _deleteNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final roots = _childrenOf(null);

    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              ListoferyarColors.background,
          appBar: AppBar(
            title: const Text(
              'ساختار پروژه',
            ),
            leading: IconButton(
              tooltip: 'بازگشت',
              onPressed: () =>
                  Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'بازخوانی',
                onPressed:
                    _loading ? null : _loadTree,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
              ),
            ],
          ),
          body: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              30,
            ),
            children: [
              _buildProjectHeader(),
              const SizedBox(height: 14),
              _buildRebarEntryButton(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'بخش‌ها و زیرشاخه‌ها',
                      style:
                          ListoferyarTypography
                              .sectionTitle,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _addNode(),
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'بخش اصلی',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              if (_loading)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 60,
                  ),
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          ListoferyarColors
                              .accent,
                    ),
                  ),
                )
              else if (roots.isEmpty)
                _EmptyTree(
                  onAdd: _addNode,
                )
              else
                ...roots.map(_buildRootNode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            ListoferyarColors.primaryGradient,
        borderRadius:
            BorderRadius.circular(19),
        boxShadow: const [
          ListoferyarTheme.softShadow,
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'ساختار پروژه',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.project.name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRebarEntryButton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ListoferyarColors.surfaceBlue,
            ListoferyarColors.surfaceTeal,
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: ListoferyarColors
              .primaryLight
              .withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .format_list_numbered_rounded,
                color:
                    ListoferyarColors.primary,
                size: 25,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'ورود اطلاعات میلگرد مصرفی',
                  style:
                      ListoferyarTypography
                          .cardTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'اطلاعات میلگرد مصرفی را وارد کنید',
            style:
                ListoferyarTypography.bodyText,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed:
                  _loading ? null : _openRebarEntry,
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
              label: const Text(
                'ورود اطلاعات میلگرد مصرفی',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTree extends StatelessWidget {
  const _EmptyTree({
    required this.onAdd,
  });

  final Future<void> Function({
    int? parentId,
  }) onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        28,
        18,
        28,
      ),
      decoration:
          ListoferyarTheme.surfaceCard(
        radius: 18,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_tree_rounded,
            size: 50,
            color:
                ListoferyarColors.primaryLight,
          ),
          const SizedBox(height: 10),
          const Text(
            'ساختار پروژه هنوز ایجاد نشده است',
            textAlign: TextAlign.center,
            style:
                ListoferyarTypography
                    .cardTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'ابتدا بخش اصلی و سپس زیرشاخه‌های مورد نیاز را ایجاد کنید.',
            textAlign: TextAlign.center,
            style:
                ListoferyarTypography.bodyText,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'افزودن بخش اصلی',
            ),
          ),
        ],
      ),
    );
  }
}