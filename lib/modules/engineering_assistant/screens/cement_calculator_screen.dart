import 'package:flutter/material.dart';

import '../../estefsarieh/theme/estefsarieh_theme.dart';

class CementCalculatorScreen extends StatefulWidget {
  const CementCalculatorScreen({super.key});

  @override
  State<CementCalculatorScreen> createState() => _CementCalculatorScreenState();
}

class _CementCalculatorScreenState extends State<CementCalculatorScreen> {
  static const double _bagKg = 50;

  static const List<_CementMortar> _mortars = [
    _CementMortar(
      label: 'ملات ماسه سیمان ۱:۳',
      kgM3: 360,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('ماسه', 3),
      ],
    ),
    _CementMortar(
      label: 'ملات ماسه سیمان ۱:۴',
      kgM3: 285,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('ماسه', 4),
      ],
    ),
    _CementMortar(
      label: 'ملات ماسه سیمان ۱:۵',
      kgM3: 225,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('ماسه', 5),
      ],
    ),
    _CementMortar(
      label: 'ملات ماسه سیمان ۱:۶',
      kgM3: 200,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('ماسه', 6),
      ],
    ),
    _CementMortar(
      label: 'دوغاب سیمان سفید و پودر سنگ ۱:۴ (بندکشی سنگ و کاشی)',
      kgM3: 400,
      parts: [
        _MortarPart('سیمان سفید', 1),
        _MortarPart('پودر سنگ', 4),
      ],
    ),
    _CementMortar(
      label: 'ملات سیمان، پودر و خاک سنگ ۱:۱:۳',
      kgM3: 300,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('پودر', 1),
        _MortarPart('خاک سنگ', 3),
      ],
    ),
    _CementMortar(
      label: 'ملات باتارد ۱:۲:۹',
      kgM3: 130,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('آهک', 2),
        _MortarPart('ماسه', 9),
      ],
    ),
    _CementMortar(
      label: 'ملات ماسه بادی و سیمان ۱:۴',
      kgM3: 285,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('ماسه بادی', 4),
      ],
    ),
    _CementMortar(
      label: 'دوغاب سیمان معمولی',
      kgM3: 430,
      parts: [
        _MortarPart('سیمان خالص', 1),
      ],
    ),
    _CementMortar(
      label: 'ملات موزاییک (ماسه:سیمان:خاک‌سنگ) ۲.۵:۱:۲.۵',
      kgM3: 350,
      parts: [
        _MortarPart('ماسه', 2.5),
        _MortarPart('سیمان', 1),
        _MortarPart('خاک سنگ', 2.5),
      ],
    ),
    _CementMortar(
      label: 'دوغاب سیمان و خاک‌سنگ ۱:۶ (بندکشی موزاییک)',
      kgM3: 225,
      parts: [
        _MortarPart('سیمان', 1),
        _MortarPart('خاک سنگ', 6),
      ],
    ),
  ];

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  int _selectedMortarIndex = 0;

  _CementCalculationMode _mode = _CementCalculationMode.volumeToCement;

  double? _result;
  double? _totalKg;

  @override
  void initState() {
    super.initState();

    _amountController.addListener(_calculate);
    _priceController.addListener(_calculatePrice);

    _calculate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  _CementMortar get _selectedMortar => _mortars[_selectedMortarIndex];

  void _calculate() {
    final value = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    if (value == null || value <= 0) {
      setState(() {
        _result = null;
        _totalKg = null;
      });
      return;
    }

    final kgM3 = _selectedMortar.kgM3;

    if (_mode == _CementCalculationMode.volumeToCement) {
      final totalKg = value * kgM3;

      setState(() {
        _result = totalKg;
        _totalKg = totalKg;
      });
    } else {
      final volume = value / kgM3;

      setState(() {
        _result = volume;
        _totalKg = value;
      });
    }
  }

  void _calculatePrice() {
    if (_totalKg == null) {
      setState(() {});
      return;
    }

    setState(() {});
  }

  double? get _bagCount {
    if (_totalKg == null || _totalKg! <= 0) {
      return null;
    }

    return _totalKg! / _bagKg;
  }

  double? get _totalPrice {
    final bagCount = _bagCount;

    if (bagCount == null) {
      return null;
    }

    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );

    if (price == null || price <= 0) {
      return null;
    }

    return bagCount * price;
  }

  String _formatNumber(
    double? value, {
    int decimals = 0,
  }) {
    if (value == null || value.isNaN || value.isInfinite) {
      return '—';
    }

    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');

    final integerPart = parts.first;

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );

    if (decimals == 0) {
      return formattedInteger;
    }

    final decimalPart = parts.length > 1 ? parts[1] : '';

    return '$formattedInteger.$decimalPart';
  }

  String _persianNumber(String value) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';

    var result = value;

    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(
        english[i],
        persian[i],
      );
    }

    return result;
  }

  void _selectMortar(int index) {
    setState(() {
      _selectedMortarIndex = index;
      _result = null;
      _totalKg = null;
      _amountController.clear();
    });
  }

  void _changeMode(_CementCalculationMode mode) {
    if (_mode == mode) {
      return;
    }

    setState(() {
      _mode = mode;
      _result = null;
      _totalKg = null;
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: EstefsariehColors.bgBase,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: EstefsariehColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'سیمان‌یار',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            tooltip: 'بازگشت',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  28,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildMortarPanel(),
                      const SizedBox(height: 14),
                      _buildRatioPanel(),
                      const SizedBox(height: 14),
                      _buildCalculatorPanel(),
                      const SizedBox(height: 14),
                      _buildPricePanel(),
                      const SizedBox(height: 18),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.borderSoft,
        ),
        boxShadow: EstefsariehDecor.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: EstefsariehColors.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: EstefsariehColors.accent,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سیمان‌یار',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb(FaNum)',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: EstefsariehColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'محاسبه مصرف سیمان در انواع ملات',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 11.5,
                    height: 1.5,
                    color: EstefsariehColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMortarPanel() {
    return _Panel(
      index: '۱',
      title: 'انتخاب نوع ملات یا دوغاب',
      child: DropdownButtonFormField<int>(
        value: _selectedMortarIndex,
        isExpanded: true,
        decoration: _inputDecoration(
          label: 'نوع ملات',
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
        ),
        items: List.generate(
          _mortars.length,
          (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                _mortars[index].label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
        onChanged: (value) {
          if (value != null) {
            _selectMortar(value);
          }
        },
      ),
    );
  }

  Widget _buildRatioPanel() {
    final mortar = _selectedMortar;

    return _Panel(
      index: '۲',
      title: 'نسبت حجمی اجزا',
      child: Column(
        children: [
          if (mortar.parts.length > 1) ...[
            _buildRatioBar(mortar),
            const SizedBox(height: 12),
            _buildRatioLegend(mortar),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: EstefsariehColors.accentSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: EstefsariehColors.accent.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'مصرف سیمان هر مترمکعب ملات',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 11.5,
                    color: EstefsariehColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_persianNumber(_formatNumber(mortar.kgM3))} kg/m³',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: EstefsariehColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioBar(_CementMortar mortar) {
    final total = mortar.parts.fold<double>(
      0,
      (sum, part) => sum + part.value,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        height: 34,
        child: Row(
          children: mortar.parts.map(
            (part) {
              final ratio = part.value / total;

              return Expanded(
                flex: (ratio * 1000).round(),
                child: Container(
                  color: _partColor(
                    mortar.parts.indexOf(part),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _formatRatio(part.value),
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildRatioLegend(_CementMortar mortar) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(
        mortar.parts.length,
        (index) {
          final part = mortar.parts[index];

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _partColor(index),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${part.label} (${_formatRatio(part.value)})',
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 10.5,
                  color: EstefsariehColors.textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalculatorPanel() {
    final isVolumeToCement = _mode == _CementCalculationMode.volumeToCement;

    return _Panel(
      index: '۳',
      title: 'محاسبه‌گر مقدار سیمان',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: EstefsariehColors.panel2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: EstefsariehColors.borderSoft,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    title: 'حجم ملات دارم',
                    subtitle: 'سیمان می‌خواهم',
                    active: isVolumeToCement,
                    onTap: () => _changeMode(
                      _CementCalculationMode.volumeToCement,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ModeButton(
                    title: 'سیمان دارم',
                    subtitle: 'حجم می‌خواهم',
                    active: !isVolumeToCement,
                    onTap: () => _changeMode(
                      _CementCalculationMode.cementToVolume,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: _inputDecoration(
              hint:
                  isVolumeToCement ? 'حجم ملات مورد نیاز' : 'مقدار سیمان موجود',
              suffixText: isVolumeToCement ? 'متر مکعب' : 'کیلوگرم',
            ),
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildResultCard(
            label: 'نتیجه محاسبه',
            value: _result == null
                ? '—'
                : isVolumeToCement
                    ? _persianNumber(
                        _formatNumber(
                          _result,
                          decimals: 1,
                        ),
                      )
                    : _persianNumber(
                        _formatNumber(
                          _result,
                          decimals: 3,
                        ),
                      ),
            unit: isVolumeToCement ? 'کیلوگرم' : 'متر مکعب',
            accent: EstefsariehColors.accent,
            extra: _bagCount == null
                ? null
                : '≈ ${_persianNumber(_formatNumber(_bagCount, decimals: 2))} کیسه ۵۰ کیلویی',
            formula: isVolumeToCement
                ? 'سیمان (kg) = حجم ملات (m³) × مصرف سیمان (kg/m³)'
                : 'حجم ملات (m³) = سیمان (kg) ÷ مصرف سیمان (kg/m³)',
          ),
        ],
      ),
    );
  }

  Widget _buildPricePanel() {
    return _Panel(
      index: '۴',
      title: 'محاسبه قیمت سیمان',
      child: Column(
        children: [
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: _inputDecoration(
              label: 'قیمت هر کیسه سیمان ۵۰ کیلویی',
              suffixText: 'ریال / کیسه',
            ),
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildResultCard(
            label: 'قیمت کل سیمان',
            value: _totalPrice == null
                ? '—'
                : _persianNumber(
                    _formatNumber(
                      _totalPrice,
                    ),
                  ),
            unit: 'ریال',
            accent: EstefsariehColors.accent,
            extra: _bagCount == null
                ? null
                : 'تعداد کیسه: ${_persianNumber(_formatNumber(_bagCount, decimals: 2))}',
            formula: 'قیمت کل = تعداد کیسه × قیمت هر کیسه',
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String label,
    required String value,
    required String unit,
    required Color accent,
    String? extra,
    required String formula,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        17,
        16,
        15,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 11.5,
              color: EstefsariehColors.textMuted,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  textDirection: TextDirection.ltr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                unit,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 8),
            Text(
              extra,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11.5,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Text(
            formula,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 9.5,
              color: EstefsariehColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            'نسبت‌های جدول حجمی هستند؛ مثلاً ۱:۵ یعنی ۱ واحد سیمان در برابر ۵ واحد ماسه.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 10.5,
              height: 1.8,
              color: EstefsariehColors.textMuted,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'مقدار سیمان بر اساس کیلوگرم در مترمکعب ملات محاسبه می‌شود.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 10.5,
              height: 1.8,
              color: EstefsariehColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? label,
    String? hint,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      labelStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        color: EstefsariehColors.textMuted,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        color: EstefsariehColors.textMuted,
      ),
      suffixStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        color: EstefsariehColors.textMuted,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: EstefsariehColors.borderSoft,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: EstefsariehColors.borderSoft,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: EstefsariehColors.accent,
          width: 1.3,
        ),
      ),
    );
  }

  Color _partColor(int index) {
    const colors = [
      EstefsariehColors.accent,
      Color(0xFF7FA6C9),
      Color(0xFF89C6A9),
    ];

    return colors[index % colors.length];
  }

  String _formatRatio(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.index,
    required this.title,
    required this.child,
  });

  final String index;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        15,
        16,
        17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.borderSoft,
        ),
        boxShadow: EstefsariehDecor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: EstefsariehColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  index,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'IRANSansWeb(FaNum)',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: EstefsariehColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: EstefsariehColors.borderSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? EstefsariehColors.accentSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 9,
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? EstefsariehColors.accent
                      : EstefsariehColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 9,
                  color: active
                      ? EstefsariehColors.accent
                      : EstefsariehColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CementMortar {
  const _CementMortar({
    required this.label,
    required this.kgM3,
    required this.parts,
  });

  final String label;
  final double kgM3;
  final List<_MortarPart> parts;
}

class _MortarPart {
  const _MortarPart(
    this.label,
    this.value,
  );

  final String label;
  final double value;
}

enum _CementCalculationMode {
  volumeToCement,
  cementToVolume,
}
