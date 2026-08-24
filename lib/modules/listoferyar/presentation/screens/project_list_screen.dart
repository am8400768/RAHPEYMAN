
import 'package:flutter/material.dart';

import '../../data/repositories/project_repository_impl.dart';
import '../../domain/models/project.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import 'project_create_screen.dart';
import 'project_detail_screen.dart';

class ListoferyarProjectListScreen extends StatefulWidget {
  const ListoferyarProjectListScreen({super.key});

  @override
  State<ListoferyarProjectListScreen> createState() =>
      _ListoferyarProjectListScreenState();
}

class _ListoferyarProjectListScreenState
    extends State<ListoferyarProjectListScreen> {
  final ProjectRepository _repository = ProjectRepository();

  List<ListoferyarProject> _projects = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _loading = true);

    try {
      final projects = await _repository.getAll();

      if (!mounted) return;

      setState(() {
        _projects = projects;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بارگذاری پروژه‌ها ناموفق بود: $error')),
      );
    }
  }

  Future<void> _createProject() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ListoferyarProjectCreateScreen(),
      ),
    );
    await _loadProjects();
  }

  Future<void> _openProject(ListoferyarProject project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListoferyarProjectDetailScreen(
          project: project,
        ),
      ),
    );
    await _loadProjects();
  }

  Future<void> _editProject(ListoferyarProject project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListoferyarProjectCreateScreen(
          initialProject: project,
        ),
      ),
    );
    await _loadProjects();
  }

  Future<void> _deleteProject(ListoferyarProject project) async {
    final id = project.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف پروژه'),
        content: Text(
          'آیا پروژه «${project.name}» حذف شود؟\n'
          'این عملیات قابل بازگشت نیست.',
          style: ListoferyarTypography.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ListoferyarColors.danger,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.delete(id);
      await _loadProjects();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حذف پروژه انجام نشد: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ListoferyarColors.background,
          appBar: AppBar(
            title: const Text('پروژه‌های لیستوفر‌یار'),
            leading: IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            actions: [
              IconButton(
                tooltip: 'بارگذاری مجدد',
                onPressed: _loading ? null : _loadProjects,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _loading ? null : _createProject,
            icon: const Icon(Icons.add_rounded),
            label: const Text('پروژه جدید'),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ListoferyarColors.accent,
                  ),
                )
              : RefreshIndicator(
                  color: ListoferyarColors.accent,
                  onRefresh: _loadProjects,
                  child: _projects.isEmpty
                      ? _EmptyProjects(onCreate: _createProject)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
                          itemCount: _projects.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return _ProjectCard(
                              project: project,
                              onOpen: () => _openProject(project),
                              onEdit: () => _editProject(project),
                              onDelete: () => _deleteProject(project),
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
      children: [
        const Icon(
          Icons.folder_open_rounded,
          size: 64,
          color: ListoferyarColors.primaryLight,
        ),
        const SizedBox(height: 14),
        const Text(
          'هنوز پروژه‌ای ساخته نشده است',
          textAlign: TextAlign.center,
          style: ListoferyarTypography.screenTitle,
        ),
        const SizedBox(height: 8),
        const Text(
          'اولین پروژه را ایجاد کنید تا اطلاعات قرارداد و ساختار آن را مرحله‌به‌مرحله بسازیم.',
          textAlign: TextAlign.center,
          style: ListoferyarTypography.bodyText,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
          label: const Text('ایجاد اولین پروژه'),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ListoferyarProject project;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: ListoferyarTheme.surfaceCard(radius: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ListoferyarColors.surfaceBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: ListoferyarColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ListoferyarTypography.cardTitle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      project.contractNumber.isEmpty
                          ? 'شماره قرارداد ثبت نشده'
                          : 'قرارداد: ${project.contractNumber}',
                      style: ListoferyarTypography.helper,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'عملیات پروژه',
                onSelected: (value) {
                  if (value == 'open') onOpen();
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'open',
                    child: Text('باز کردن'),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('ویرایش اطلاعات'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
