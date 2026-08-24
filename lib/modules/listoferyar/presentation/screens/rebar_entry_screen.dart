import 'package:flutter/material.dart';

import '../../data/repositories/layer_repository_impl.dart';
import '../../data/repositories/rebar_repository_impl.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_node.dart';
import '../../domain/models/rebar_item.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import '../controllers/rebar_controller.dart';

class ListoferyarRebarEntryScreen extends StatefulWidget {
  const ListoferyarRebarEntryScreen({
    super.key,
    required this.project,
  });

  final ListoferyarProject project;

  @override
  State<ListoferyarRebarEntryScreen> createState() =>
      _ListoferyarRebarEntryScreenState();
}

class _ListoferyarRebarEntryScreenState
    extends State<ListoferyarRebarEntryScreen> {
  final LayerRepository _layerRepository = LayerRepository();
  final RebarRepository _rebarRepository = RebarRepository();
  final RebarController _controller = RebarController();

  List<ListoferyarProjectNode> _nodes =
      const <ListoferyarProjectNode>[];

  final List<_RebarEntryRow> _rows = <_RebarEntryRow>[];

  int? _selectedNodeId;

  bool _loadingNodes = true;
  bool _saving = false;
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }

    _controller.dispose();

    super.dispose();
  }

  Future<void> _loadNodes() async {
    try {
      final projectId = widget.project.id;

      if (projectId == null) {
        throw StateError('شناسه پروژه نامعتبر است.');
      }

      final nodes =
          await _layerRepository.getAllByProject(projectId);

      if (!mounted) return;

      setState(() {
        _nodes = nodes;
        _loadingNodes = false;

        if (_nodes.isNotEmpty) {
          _selectedNodeId ??= _nodes.first.id;
        }
      });

      if (_selectedNodeId != null) {
        await _controller.load(_selectedNodeId!);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingNodes = false;
      });

      _showError(
        'خواندن ساختار پروژه انجام نشد: $error',
      );
    }
  }

  String _nodePath(ListoferyarProjectNode node) {
    final List<String> names = <String>[node.name];

    int? parentId = node.parentId;

    while (parentId != null) {
      ListoferyarProjectNode? parent;

      for (final candidate in _nodes) {
        if (candidate.id == parentId) {
          parent = candidate;
          break;
        }
      }

      if (parent == null) {
        break;
      }

      names.insert(0, parent.name);
      parentId = parent.parentId;
    }

    return names.join(' ← ');
  }

  Future<void> _selectNode(int? nodeId) async {
    if (nodeId == null) return;

    setState(() {
      _selectedNodeId = nodeId;
    });

    await _controller.load(nodeId);
  }

  void _addRow() {
    final row = _RebarEntryRow(
      nodeId: _selectedNodeId,
    );

    setState(() {
      _rows.add(row);
    });
  }

  void _removeRow(_RebarEntryRow row) {
    setState(() {
      row.dispose();
      _rows.remove(row);
    });
  }

  double _parseNumber(String value) {
    var normalized = value.trim();

    const String persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const String arabicDigits = '٠١٢٣٤٥٦٧٨٩';

    for (int i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(
        persianDigits[i],
        '$i',
      );

      normalized = normalized.replaceAll(
        arabicDigits[i],
        '$i',
      );
    }

    normalized = normalized
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.');

    return double.tryParse(normalized) ?? 0;
  }

  int _parseInteger(String value) {
    return _parseNumber(value).round();
  }

  double _unitWeight(int diameter) {
    return diameter * diameter / 162.0;
  }

  double _roundByDiameter(
    double value,
    int diameter,
  ) {
    final int decimals = diameter <= 12 ? 3 : 2;
    final double factor =
        decimals == 3 ? 1000.0 : 100.0;

    return (value * factor).round() / factor;
  }

  String _formatNumber(
    double value, {
    int decimals = 2,
  }) {
    String result = value.toStringAsFixed(decimals);

    result = result.replaceFirst(
      RegExp(r'\.?0+$'),
      '',
    );

    final parts = result.split('.');

    final integerPart = parts.first;
    final decimalPart =
        parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 &&
          (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(integerPart[i]);
    }

    if (decimalPart.isNotEmpty) {
      buffer.write('.');
      buffer.write(decimalPart);
    }

    return buffer.toString();
  }

  double _rowTotalLength(_RebarEntryRow row) {
    final int quantity =
        _parseInteger(row.quantityController.text);

    final double length =
        _parseNumber(row.lengthController.text);

    if (quantity <= 0 || length <= 0) {
      return 0;
    }

    return quantity * length;
  }

  double _rowTotalWeight(_RebarEntryRow row) {
    final int? diameter = row.diameter;

    if (diameter == null) {
      return 0;
    }

    final double totalLength =
        _rowTotalLength(row);

    final double roundedUnitWeight =
        _roundByDiameter(
      _unitWeight(diameter),
      diameter,
    );

    return totalLength * roundedUnitWeight;
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveRows() async {
    if (_saving) return;

    if (_rows.isEmpty) {
      _showError(
        'حداقل یک ردیف میلگرد وارد کنید.',
      );
      return;
    }

    final int? projectId = widget.project.id;

    if (projectId == null) {
      _showError(
        'شناسه پروژه نامعتبر است.',
      );
      return;
    }

    final List<_PreparedRebarRow> validRows =
        <_PreparedRebarRow>[];

    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];

      if (row.nodeId == null) {
        _showError(
          'زیرشاخه پروژه برای ردیف ${i + 1} مشخص نشده است.',
        );
        return;
      }

      final String usage =
          row.usageController.text.trim();

      if (usage.isEmpty) {
        _showError(
          'محل مصرف ردیف ${i + 1} را وارد کنید.',
        );
        return;
      }

      if (row.diameter == null) {
        _showError(
          'قطر میلگرد ردیف ${i + 1} انتخاب نشده است.',
        );
        return;
      }

      final int quantity =
          _parseInteger(
        row.quantityController.text,
      );

      final double length =
          _parseNumber(
        row.lengthController.text,
      );

      final double spacing =
          _parseNumber(
        row.spacingController.text,
      );

      if (quantity <= 0) {
        _showError(
          'تعداد ردیف ${i + 1} باید بیشتر از صفر باشد.',
        );
        return;
      }

      if (length <= 0) {
        _showError(
          'طول واحد ردیف ${i + 1} باید بیشتر از صفر باشد.',
        );
        return;
      }

      if (spacing < 0) {
        _showError(
          'فاصله ردیف ${i + 1} نمی‌تواند منفی باشد.',
        );
        return;
      }

      validRows.add(
        _PreparedRebarRow(
          nodeId: row.nodeId!,
          diameter: row.diameter!,
          quantity: quantity,
          length: length,
          spacing: spacing,
          usage: usage,
        ),
      );
    }

    setState(() {
      _saving = true;
    });

    try {
      for (final prepared in validRows) {
        final ListoferyarRebarItem item =
            _controller.calculate(
          projectId: projectId,
          nodeId: prepared.nodeId,

          // RebarController مقدار double می‌خواهد.
          diameter: prepared.diameter.toDouble(),

          quantity: prepared.quantity,
          length: prepared.length,
          spacing: prepared.spacing,

          // محل مصرف در description ذخیره می‌شود
          // تا بعداً در خروجی PDF قابل استفاده باشد.
          description: prepared.usage,
        );

        await _controller.add(item);
      }

      if (!mounted) return;

      for (final row in _rows) {
        row.dispose();
      }

      setState(() {
        _rows.clear();
      });

      _showSuccess(
        '${validRows.length} ردیف میلگرد با موفقیت ثبت شد.',
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        'ثبت اطلاعات میلگرد انجام نشد: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              ListoferyarColors.danger,
          content: Text(message),
        ),
      );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              ListoferyarColors.accent,
          content: Text(message),
        ),
      );
  }

  Future<List<ListoferyarRebarItem>>
      _loadAllItems() async {
    final int? projectId = widget.project.id;

    if (projectId == null) {
      return const <ListoferyarRebarItem>[];
    }

    return _rebarRepository.getByProject(
      projectId,
    );
  }

  Map<int, double> _groupByDiameter(
    List<ListoferyarRebarItem> items,
  ) {
    final Map<int, double> result =
        <int, double>{};

    for (final item in items) {
      final int diameter =
          item.diameter.round();

      result[diameter] =
          (result[diameter] ?? 0) +
              item.totalWeight;
    }

    return result;
  }

  Map<int, double> _groupLengthByDiameter(
    List<ListoferyarRebarItem> items,
  ) {
    final Map<int, double> result =
        <int, double>{};

    for (final item in items) {
      final int diameter =
          item.diameter.round();

      result[diameter] =
          (result[diameter] ?? 0) +
              item.totalLength;
    }

    return result;
  }

  List<int> _sortedDiameters(
    Map<int, double> data,
  ) {
    final List<int> values =
        data.keys.toList();

    values.sort();

    return values;
  }

  List<int> _descendantIds(
    int rootId,
  ) {
    final List<int> result = <int>[];

    void visit(int parentId) {
      for (final node in _nodes) {
        if (node.parentId == parentId &&
            node.id != null) {
          result.add(node.id!);
          visit(node.id!);
        }
      }
    }

    visit(rootId);

    return result;
  }

  Widget _buildSummary() {
    return FutureBuilder<
        List<ListoferyarRebarItem>>(
      future: _loadAllItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const _SummaryMessage(
            icon: Icons.error_outline_rounded,
            text:
                'خواندن خلاصه اطلاعات میلگرد انجام نشد.',
          );
        }

        final List<ListoferyarRebarItem>
            allItems =
            snapshot.data ??
                const <ListoferyarRebarItem>[];

        if (allItems.isEmpty) {
          return const _SummaryMessage(
            icon: Icons.info_outline_rounded,
            text:
                'هنوز اطلاعاتی برای نمایش خلاصه ثبت نشده است.',
          );
        }

        final Map<int, double> groupedWeight =
            _groupByDiameter(allItems);

        final Map<int, double> groupedLength =
            _groupLengthByDiameter(allItems);

        final List<int> diameters =
            _sortedDiameters(groupedWeight);

        return _buildOverallSummaryTable(
          diameters,
          groupedLength,
          groupedWeight,
        );
      },
    );
  }

  Widget _buildOverallSummaryTable(
    List<int> diameters,
    Map<int, double> lengths,
    Map<int, double> weights,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ListoferyarColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ListoferyarColors.borderSoft,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: ListoferyarColors.surfaceBlue,
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'سایز',
                    textAlign: TextAlign.center,
                    style:
                        ListoferyarTypography.bodyStrong,
                  ),
                ),
                SizedBox(
                  width: 105,
                  child: Text(
                    'طول کل',
                    textAlign: TextAlign.center,
                    style:
                        ListoferyarTypography.bodyStrong,
                  ),
                ),
                SizedBox(
                  width: 105,
                  child: Text(
                    'وزن کل',
                    textAlign: TextAlign.center,
                    style:
                        ListoferyarTypography.bodyStrong,
                  ),
                ),
                SizedBox(
                  width: 125,
                  child: Text(
                    'شاخه ۱۲ متری',
                    textAlign: TextAlign.center,
                    style:
                        ListoferyarTypography.bodyStrong,
                  ),
                ),
                Expanded(
                  child: Text(
                    'وزن به تن',
                    textAlign: TextAlign.center,
                    style:
                        ListoferyarTypography.bodyStrong,
                  ),
                ),
              ],
            ),
          ),
          ...diameters.map(
            (diameter) {
              final double totalLength =
                  lengths[diameter] ?? 0;

              final double totalWeight =
                  weights[diameter] ?? 0;

              final double branches =
                  totalLength / 12.0;

              final double tons =
                  totalWeight / 1000.0;

              return Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          ListoferyarColors.borderSoft,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        'Ø $diameter',
                        textAlign:
                            TextAlign.center,
                        style:
                            ListoferyarTypography.bodyStrong,
                      ),
                    ),
                    SizedBox(
                      width: 105,
                      child: Text(
                        '${_formatNumber(totalLength, decimals: 2)} m',
                        textAlign:
                            TextAlign.center,
                        style:
                            ListoferyarTypography.bodyText,
                      ),
                    ),
                    SizedBox(
                      width: 105,
                      child: Text(
                        '${_formatNumber(totalWeight, decimals: 2)} kg',
                        textAlign:
                            TextAlign.center,
                        style:
                            ListoferyarTypography.bodyStrong,
                      ),
                    ),
                    SizedBox(
                      width: 125,
                      child: Text(
                        _formatNumber(
                          branches,
                          decimals: 2,
                        ),
                        textAlign:
                            TextAlign.center,
                        style:
                            ListoferyarTypography.bodyStrong,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_formatNumber(tons, decimals: 3)} ton',
                        textAlign:
                            TextAlign.center,
                        style:
                            ListoferyarTypography.bodyStrong,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ListoferyarTheme.surfaceCard(
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_tree_rounded,
                color: ListoferyarColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'زیرشاخه پروژه',
                style:
                    ListoferyarTypography.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'این گزینه فقط برای ارتباط اطلاعات میلگرد با ساختار پروژه است. محل مصرف هر ردیف را در جدول به صورت متنی وارد کنید.',
            style:
                ListoferyarTypography.bodyText,
          ),
          const SizedBox(height: 11),
          DropdownButtonFormField<int>(
            initialValue: _selectedNodeId,
            isExpanded: true,
            decoration:
                const InputDecoration(
              labelText: 'زیرشاخه پروژه',
              prefixIcon:
                  Icon(Icons.folder_open_rounded),
            ),
            items: _nodes
                .where(
                  (node) => node.id != null,
                )
                .map(
                  (node) =>
                      DropdownMenuItem<int>(
                    value: node.id!,
                    child: Text(
                      _nodePath(node),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged:
                _loadingNodes
                    ? null
                    : _selectNode,
          ),
        ],
      ),
    );
  }

  Widget _buildEntryHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient:
            ListoferyarColors.primaryGradient,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.construction_rounded,
                color: Colors.white,
                size: 25,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'ورود اطلاعات میلگرد مصرفی',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Text(
            'هر ردیف یک مورد مستقل از میلگرد مصرفی پروژه است.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: ListoferyarColors.surfaceBlue,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: ListoferyarColors.borderSoft,
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              'ردیف',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 220,
            child: Text(
              'محل مصرف',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 82,
            child: Text(
              'قطر',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 78,
            child: Text(
              'فاصله\n(cm)',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 82,
            child: Text(
              'تعداد',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              'طول واحد\n(m)',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 105,
            child: Text(
              'طول کل\n(m)',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(
            width: 105,
            child: Text(
              'وزن کل\n(kg)',
              textAlign: TextAlign.center,
              style:
                  ListoferyarTypography.bodyStrong,
            ),
          ),
          SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _buildRow(
    _RebarEntryRow row,
    int index,
  ) {
    return AnimatedBuilder(
      animation: row,
      builder: (context, _) {
        final double totalLength =
            _rowTotalLength(row);

        final double totalWeight =
            _rowTotalWeight(row);

        return Container(
          margin: const EdgeInsets.only(
            top: 7,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  ListoferyarColors.borderSoft,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                _buildRowNumber(
                  index + 1,
                ),
                const SizedBox(width: 6),

                SizedBox(
                  width: 220,
                  child: _textField(
                    controller:
                        row.usageController,
                    label: 'محل مصرف',
                    hint:
                        'مثلاً میلگرد طولی مش پایین فونداسیون',
                    onChanged: (_) =>
                        row.refresh(),
                  ),
                ),

                const SizedBox(width: 6),

                SizedBox(
                  width: 82,
                  child:
                      DropdownButtonFormField<int>(
                    initialValue:
                        row.diameter,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(
                      labelText: 'Ø',
                      contentPadding:
                          EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    items: _diameters
                        .map(
                          (diameter) =>
                              DropdownMenuItem<int>(
                            value: diameter,
                            child: Text(
                              '$diameter',
                              textAlign:
                                  TextAlign.center,
                            ),
                          ),
                        )
                        .toList(
                          growable: false,
                        ),
                    onChanged: (value) {
                      row.diameter = value;
                      row.refresh();
                    },
                  ),
                ),

                const SizedBox(width: 6),

                SizedBox(
                  width: 78,
                  child: _numberField(
                    controller:
                        row.spacingController,
                    label: 'cm',
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) =>
                        row.refresh(),
                  ),
                ),

                const SizedBox(width: 6),

                SizedBox(
                  width: 82,
                  child: _numberField(
                    controller:
                        row.quantityController,
                    label: 'تعداد',
                    keyboardType:
                        TextInputType.number,
                    onChanged: (_) =>
                        row.refresh(),
                  ),
                ),

                const SizedBox(width: 6),

                SizedBox(
                  width: 90,
                  child: _numberField(
                    controller:
                        row.lengthController,
                    label: 'm',
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) =>
                        row.refresh(),
                  ),
                ),

                const SizedBox(width: 6),

                _resultCell(
                  width: 105,
                  value:
                      '${_formatNumber(totalLength, decimals: 2)} m',
                ),

                const SizedBox(width: 6),

                _resultCell(
                  width: 105,
                  value:
                      '${_formatNumber(totalWeight, decimals: 2)} kg',
                  strong: true,
                ),

                const SizedBox(width: 4),

                SizedBox(
                  width: 45,
                  child: IconButton(
                    tooltip: 'حذف ردیف',
                    onPressed: _saving
                        ? null
                        : () =>
                            _removeRow(row),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color:
                          ListoferyarColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRowNumber(int number) {
    return Container(
      width: 45,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ListoferyarColors.surfaceBlue,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text(
        '$number',
        style:
            ListoferyarTypography.bodyStrong,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 10,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 10,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _resultCell({
    required double width,
    required String value,
    bool strong = false,
  }) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: ListoferyarColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow:
            TextOverflow.ellipsis,
        style: strong
            ? ListoferyarTypography.bodyStrong
            : ListoferyarTypography.bodyText,
      ),
    );
  }

  Widget _buildEntrySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ListoferyarTheme.surfaceCard(
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'اطلاعات میلگرد',
                  style:
                      ListoferyarTypography.sectionTitle,
                ),
              ),
              FilledButton.icon(
                onPressed:
                    _saving ? null : _addRow,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 19,
                ),
                label:
                    const Text('افزودن ردیف'),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'محل مصرف را به صورت آزاد وارد کنید. با اضافه کردن ردیف، شماره ردیف به صورت خودکار مشخص می‌شود.',
            style:
                ListoferyarTypography.helper,
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: SizedBox(
              width: 960,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _buildRowsHeader(),

                  if (_rows.isEmpty)
                    Container(
                      margin:
                          const EdgeInsets.only(
                        top: 10,
                      ),
                      padding:
                          const EdgeInsets.all(22),
                      decoration:
                          BoxDecoration(
                        color:
                            ListoferyarColors.surfaceSoft,
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons
                                .format_list_numbered_rounded,
                            size: 38,
                            color:
                                ListoferyarColors
                                    .primaryLight,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'هنوز ردیفی وارد نشده است.',
                            style:
                                ListoferyarTypography
                                    .bodyText,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'برای شروع روی «افزودن ردیف» بزنید.',
                            style:
                                ListoferyarTypography
                                    .helper,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._rows.asMap().entries.map(
                      (entry) => _buildRow(
                        entry.value,
                        entry.key,
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (_rows.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed:
                    _saving ? null : _saveRows,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save_rounded,
                      ),
                label: Text(
                  _saving
                      ? 'در حال ثبت...'
                      : 'ثبت اطلاعات میلگرد',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ListoferyarTheme.surfaceCard(
        radius: 18,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius:
                BorderRadius.circular(13),
            onTap: () {
              setState(() {
                _showSummary =
                    !_showSummary;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _showSummary,
                    onChanged: (value) {
                      setState(() {
                        _showSummary =
                            value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 2),
                  const Expanded(
                    child: Text(
                      'خلاصه میلگرد به تفکیک سایز',
                      style:
                          ListoferyarTypography.cardTitle,
                    ),
                  ),
                  Icon(
                    _showSummary
                        ? Icons
                            .expand_less_rounded
                        : Icons
                            .expand_more_rounded,
                    color:
                        ListoferyarColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_showSummary) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildNoNodes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration:
              ListoferyarTheme.surfaceCard(
            radius: 18,
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 55,
                color:
                    ListoferyarColors.primaryLight,
              ),
              SizedBox(height: 12),
              Text(
                'هنوز زیرشاخه‌ای تعریف نشده است.',
                textAlign:
                    TextAlign.center,
                style:
                    ListoferyarTypography.cardTitle,
              ),
              SizedBox(height: 7),
              Text(
                'ابتدا در ساختار پروژه بخش‌ها و زیرشاخه‌های مورد نیاز را تعریف کنید.',
                textAlign:
                    TextAlign.center,
                style:
                    ListoferyarTypography.bodyText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection:
            TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              ListoferyarColors.background,
          appBar: AppBar(
            title: const Text(
              'ورود اطلاعات میلگرد',
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
                    _loadingNodes
                        ? null
                        : _loadNodes,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
              ),
            ],
          ),
          body: _loadingNodes
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : _nodes.isEmpty
                  ? _buildNoNodes()
                  : ListView(
                      padding:
                          const EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        35,
                      ),
                      children: [
                        _buildEntryHeader(),
                        const SizedBox(
                          height: 12,
                        ),
                        _buildTopSelector(),
                        const SizedBox(
                          height: 14,
                        ),
                        _buildEntrySection(),
                        const SizedBox(
                          height: 18,
                        ),
                        _buildSummarySection(),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _RebarEntryRow extends ChangeNotifier {
  _RebarEntryRow({
    this.nodeId,
  });

  int? nodeId;
  int? diameter;

  final TextEditingController
      usageController =
      TextEditingController();

  final TextEditingController
      spacingController =
      TextEditingController();

  final TextEditingController
      quantityController =
      TextEditingController();

  final TextEditingController
      lengthController =
      TextEditingController();

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    usageController.dispose();
    spacingController.dispose();
    quantityController.dispose();
    lengthController.dispose();

    super.dispose();
  }
}

class _PreparedRebarRow {
  const _PreparedRebarRow({
    required this.nodeId,
    required this.diameter,
    required this.quantity,
    required this.length,
    required this.spacing,
    required this.usage,
  });

  final int nodeId;
  final int diameter;
  final int quantity;
  final double length;
  final double spacing;
  final String usage;
}

class _SummaryMessage extends StatelessWidget {
  const _SummaryMessage({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            ListoferyarColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                ListoferyarColors.primary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style:
                  ListoferyarTypography.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}

const List<int> _diameters = <int>[
  8,
  10,
  12,
  14,
  16,
  18,
  20,
  22,
  25,
  28,
  32,
  36,
  40,
];
