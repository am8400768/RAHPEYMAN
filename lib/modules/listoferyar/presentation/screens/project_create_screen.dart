
import 'package:flutter/material.dart';

import '../../data/repositories/project_repository_impl.dart';
import '../../domain/models/project.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import 'project_detail_screen.dart';

class ListoferyarProjectCreateScreen extends StatefulWidget {
  const ListoferyarProjectCreateScreen({
    super.key,
    this.initialProject,
  });

  final ListoferyarProject? initialProject;

  bool get isEditing => initialProject?.id != null;

  @override
  State<ListoferyarProjectCreateScreen> createState() =>
      _ListoferyarProjectCreateScreenState();
}

class _ListoferyarProjectCreateScreenState
    extends State<ListoferyarProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProjectRepository _repository = ProjectRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _employerController;
  late final TextEditingController _consultantController;
  late final TextEditingController _contractorController;
  late final TextEditingController _supervisorController;
  late final TextEditingController _contractDateController;
  late final TextEditingController _contractNumberController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final project = widget.initialProject;

    _nameController = TextEditingController(text: project?.name ?? '');
    _employerController =
        TextEditingController(text: project?.employer ?? '');
    _consultantController =
        TextEditingController(text: project?.consultant ?? '');
    _contractorController =
        TextEditingController(text: project?.contractor ?? '');
    _supervisorController =
        TextEditingController(text: project?.residentSupervisor ?? '');
    _contractDateController =
        TextEditingController(text: project?.contractDate ?? '');
    _contractNumberController =
        TextEditingController(text: project?.contractNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employerController.dispose();
    _consultantController.dispose();
    _contractorController.dispose();
    _supervisorController.dispose();
    _contractDateController.dispose();
    _contractNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final old = widget.initialProject;

      final project = ListoferyarProject(
        id: old?.id,
        name: _nameController.text.trim(),
        employer: _employerController.text.trim(),
        consultant: _consultantController.text.trim(),
        contractor: _contractorController.text.trim(),
        residentSupervisor: _supervisorController.text.trim(),
        contractDate: _contractDateController.text.trim(),
        contractNumber: _contractNumberController.text.trim(),
        createdAt: old?.createdAt,
        updatedAt: DateTime.now(),
      );

      ListoferyarProject? saved;

      if (old == null) {
        final id = await _repository.create(project);
        saved = await _repository.getById(id);
      } else {
        await _repository.update(project);
        saved = project;
      }

      if (!mounted || saved == null) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ListoferyarProjectDetailScreen(
            project: saved!,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ذخیره پروژه انجام نشد: $error',
            style: const TextStyle(
              fontFamily: ListoferyarTypography.body,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.isEditing;

    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ListoferyarColors.background,
          appBar: AppBar(
            title: Text(editing ? 'ویرایش پروژه' : 'پروژه جدید'),
            leading: IconButton(
              tooltip: 'بازگشت',
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: ListoferyarColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [ListoferyarTheme.softShadow],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اطلاعات پایه پروژه',
                          style: TextStyle(
                            fontFamily: ListoferyarTypography.heading,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'نام پروژه اجباری است؛ سایر اطلاعات را می‌توانید بعداً ویرایش کنید.',
                          style: TextStyle(
                            fontFamily: ListoferyarTypography.body,
                            fontSize: 12,
                            height: 1.7,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _nameController,
                    label: 'نام پروژه *',
                    hint: 'مثلاً پروژه ساختمان اداری مرکزی',
                    icon: Icons.folder_rounded,
                    required: true,
                  ),
                  _field(
                    controller: _employerController,
                    label: 'کارفرما',
                    hint: 'نام کارفرما',
                    icon: Icons.business_rounded,
                  ),
                  _field(
                    controller: _consultantController,
                    label: 'مشاور',
                    hint: 'نام مشاور',
                    icon: Icons.engineering_rounded,
                  ),
                  _field(
                    controller: _contractorController,
                    label: 'پیمانکار',
                    hint: 'نام پیمانکار',
                    icon: Icons.construction_rounded,
                  ),
                  _field(
                    controller: _supervisorController,
                    label: 'ناظر مقیم',
                    hint: 'نام ناظر مقیم',
                    icon: Icons.person_pin_circle_rounded,
                  ),
                  _field(
                    controller: _contractNumberController,
                    label: 'شماره قرارداد',
                    hint: 'شماره قرارداد',
                    icon: Icons.numbers_rounded,
                  ),
                  _field(
                    controller: _contractDateController,
                    label: 'تاریخ قرارداد',
                    hint: 'مثلاً ۱۴۰۵/۰۵/۲۵',
                    icon: Icons.event_rounded,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _saving
                          ? 'در حال ذخیره...'
                          : editing
                              ? 'ذخیره و ادامه'
                              : 'ذخیره و ادامه',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        style: ListoferyarTypography.bodyText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: ListoferyarColors.primary,
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'نام پروژه الزامی است.';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
