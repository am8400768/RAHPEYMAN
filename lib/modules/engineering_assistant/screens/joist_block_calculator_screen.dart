import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JoistBlockCalculatorScreen extends StatefulWidget {
  const JoistBlockCalculatorScreen({super.key});

  @override
  State<JoistBlockCalculatorScreen> createState() =>
      _JoistBlockCalculatorScreenState();
}

class _JoistBlockCalculatorScreenState
    extends State<JoistBlockCalculatorScreen> {
  // ============================================================
  // ثابت‌های محاسباتی
  // ============================================================

  static const double bagKg = 50.0;

  static const double cementWaste = 1.06;

  static const double aggregateTonPerM3Concrete = 2.2;

  // ضریب یونولیت:
  // 68 درصد مساحت کل سقف محاسبه می‌شود.
  static const double polystyreneAreaFactor = 0.68;

  // ============================================================
  // Controller ها
  // ============================================================

  final TextEditingController _widthController = TextEditingController();

  final TextEditingController _areaController = TextEditingController();

  final TextEditingController _joistPriceController = TextEditingController();

  final TextEditingController _fillerPriceController = TextEditingController();

  final TextEditingController _cementPriceController = TextEditingController();

  final TextEditingController _aggregatePriceController =
      TextEditingController();

  // ============================================================
  // وضعیت فرم
  // ============================================================

  double? _width;
  double? _area;

  double _axis = 0.50;

  String _filler = 'block';

  double _blockLength = 0.25;

  double _netPercentage = 0.725;

  double _ceilingThickness = 25;

  double _systemCoefficient = 0.50;

  int _concreteGradeIndex = 5;

  double _joistPrice = 0;
  double _fillerPrice = 0;
  double _cementPrice = 0;
  double _aggregatePrice = 0;

  // ============================================================
  // نتایج
  // ============================================================

  int? _joistCount;
  int? _fillerCount;

  double? _concreteVolume;
  double? _cementKg;

  // ============================================================
  // درجات بتن
  // ============================================================

  static const List<ConcreteGrade> concreteGrades = [
    ConcreteGrade(
      label: 'بتن مگر/نظافت — ۱۰۰ کیلوگرم',
      kgPerM3: 100,
    ),
    ConcreteGrade(
      label: 'بتن مگر/نظافت — ۱۵۰ کیلوگرم',
      kgPerM3: 150,
    ),
    ConcreteGrade(
      label: 'بتن رده ۱۲ مگاپاسکال',
      kgPerM3: 220,
    ),
    ConcreteGrade(
      label: 'بتن رده ۱۶ مگاپاسکال',
      kgPerM3: 260,
    ),
    ConcreteGrade(
      label: 'بتن رده ۲۰ مگاپاسکال',
      kgPerM3: 300,
    ),
    ConcreteGrade(
      label: 'بتن رده ۲۵ مگاپاسکال',
      kgPerM3: 350,
    ),
    ConcreteGrade(
      label: 'بتن رده ۳۰ مگاپاسکال',
      kgPerM3: 400,
    ),
    ConcreteGrade(
      label: 'بتن رده ۳۵ مگاپاسکال',
      kgPerM3: 450,
    ),
    ConcreteGrade(
      label: 'بتن رده ۴۰ مگاپاسکال',
      kgPerM3: 500,
    ),
  ];

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void dispose() {
    _widthController.dispose();
    _areaController.dispose();

    _joistPriceController.dispose();
    _fillerPriceController.dispose();
    _cementPriceController.dispose();
    _aggregatePriceController.dispose();

    super.dispose();
  }

  // ============================================================
  // Helpers
  // ============================================================

  double? _parseNumber(String value) {
    final normalized = value
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.')
        .trim();

    if (normalized.isEmpty) {
      return null;
    }

    final valueParsed = double.tryParse(normalized);

    if (valueParsed == null || valueParsed < 0) {
      return null;
    }

    return valueParsed;
  }

  String _formatNumber(
    num? value, {
    int decimals = 0,
  }) {
    if (value == null || !value.isFinite) {
      return '—';
    }

    final fixed = value.toStringAsFixed(decimals);

    final parts = fixed.split('.');

    final integerPart = parts[0];

    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(integerPart[i]);
    }

    if (decimals > 0) {
      buffer.write('.');
      buffer.write(parts[1]);
    }

    return buffer.toString();
  }

  String _formatPrice(num value) {
    return _formatNumber(value, decimals: 0);
  }

  // ============================================================
  // محاسبات
  // ============================================================

  void _recalculate() {
    final width = _width;
    final area = _area;

    int? joistCount;
    int? fillerCount;

    double? concreteVolume;
    double? cementKg;

    // ============================================================
    // تعداد تیرچه
    //
    // تعداد تیرچه = ceil(عرض / آکس) - 1
    //
    // توجه:
    // ceil متد خود عدد است و باید به شکل زیر نوشته شود:
    //
    // (width / _axis).ceil()
    // ============================================================

    if (width != null && width > 0) {
      final calculated = (width / _axis).ceil() - 1;

      joistCount = math.max(0, calculated);
    }

    // ============================================================
    // تعداد پرکننده
    // ============================================================

    if (area != null && area > 0) {
      if (_filler == 'polystyrene') {
        // ========================================================
        // یونولیت
        //
        // ضریب = 0.68
        //
        // یعنی 68 درصد مساحت کل سقف محاسبه می‌شود.
        // ========================================================

        fillerCount = (area * polystyreneAreaFactor).ceil();
      } else {
        // ========================================================
        // بلوک سقفی
        // ========================================================

        final rowsPerMeter = 1 / _axis;

        final blocksPerMeter = 1 / _blockLength;

        final blocksPerM2Net = rowsPerMeter * blocksPerMeter;

        final netArea = area * _netPercentage;

        fillerCount = (netArea * blocksPerM2Net).ceil();
      }
    }

    // ============================================================
    // بتن سقف
    // ============================================================

    if (area != null && area > 0) {
      concreteVolume = area * (_ceilingThickness / 100) * _systemCoefficient;

      final grade = concreteGrades[_concreteGradeIndex];

      cementKg = concreteVolume * grade.kgPerM3 * cementWaste;
    }

    setState(() {
      _joistCount = joistCount;
      _fillerCount = fillerCount;

      _concreteVolume = concreteVolume;
      _cementKg = cementKg;
    });
  }

  // ============================================================
  // ورودی‌ها
  // ============================================================

  void _onWidthChanged(String value) {
    _width = _parseNumber(value);
    _recalculate();
  }

  void _onAreaChanged(String value) {
    _area = _parseNumber(value);
    _recalculate();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _AppColors.background,
          foregroundColor: _AppColors.textPrimary,
          title: const Text(
            'سقف تیرچه‌بلوک',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              40,
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildRoofSpecificationPanel(),
                if (_joistCount != null) _buildJoistPanel(),
                if (_area != null) _buildFillerPanel(),
                if (_fillerCount != null) _buildFillerResultPanel(),
                if (_area != null) _buildConcretePanel(),
                if (_joistCount != null ||
                    _fillerCount != null ||
                    _concreteVolume != null)
                  _buildPricePanel(),
                if (_area != null) _buildTotalPanel(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
        bottom: 18,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _AppColors.panel2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _AppColors.border,
              ),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: _AppColors.accent,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سقف تیرچه‌بلوک',
                  style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'تیرچه، بلوک سقفی/یونولیت و بتن',
                  style: TextStyle(
                    color: _AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // مشخصات سقف
  // ============================================================

  Widget _buildRoofSpecificationPanel() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            number: '۱',
            title: 'مشخصات سقف',
          ),
          _NumberField(
            label: 'عرض سقف (فاصله دو تکیه‌گاه — متر)',
            controller: _widthController,
            suffix: 'm',
            onChanged: _onWidthChanged,
          ),
          const SizedBox(height: 13),
          _NumberField(
            label: 'مساحت کل سقف (مترمربع)',
            controller: _areaController,
            suffix: 'm²',
            onChanged: _onAreaChanged,
          ),
          const SizedBox(height: 13),
          _DropdownField<double>(
            label: 'فاصله آکس‌به‌آکس تیرچه‌ها',
            value: _axis,
            items: const [
              DropdownMenuItem(
                value: 0.50,
                child: Text('۵۰ سانتی‌متر'),
              ),
              DropdownMenuItem(
                value: 0.60,
                child: Text('۶۰ سانتی‌متر'),
              ),
              DropdownMenuItem(
                value: 0.70,
                child: Text('۷۰ سانتی‌متر'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _axis = value;
              });

              _recalculate();
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // تعداد تیرچه
  // ============================================================

  Widget _buildJoistPanel() {
    return _Panel(
      child: Column(
        children: [
          const _PanelTitle(
            number: '◆',
            title: 'تعداد تیرچه',
          ),
          _HeroStat(
            label: 'تعداد',
            value: _formatNumber(_joistCount),
            unit: 'عدد',
          ),
          const SizedBox(height: 11),
          _FormulaBox(
            text: 'تعداد تیرچه = ⌈عرض سقف ÷ فاصله آکس‌به‌آکس⌉ − ۱',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // انتخاب پرکننده
  // ============================================================

  Widget _buildFillerPanel() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            number: '۲',
            title: 'نوع پرکننده سقف',
          ),
          _MaterialToggle(
            selected: _filler,
            onChanged: (value) {
              setState(() {
                _filler = value;
              });

              _recalculate();
            },
          ),
          const SizedBox(height: 12),
          if (_filler == 'block') ...[
            _DropdownField<double>(
              label: 'طول بلوک سقفی',
              value: _blockLength,
              items: const [
                DropdownMenuItem(
                  value: 0.25,
                  child: Text('۲۵ سانتی‌متر'),
                ),
                DropdownMenuItem(
                  value: 0.30,
                  child: Text('۳۰ سانتی‌متر'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _blockLength = value;
                });

                _recalculate();
              },
            ),
            const SizedBox(height: 13),
            _DropdownField<double>(
              label: 'درصد مساحت خالص بلوک‌چینی (بدون تیر اصلی)',
              value: _netPercentage,
              items: const [
                DropdownMenuItem(
                  value: 0.70,
                  child: Text('۷۰٪'),
                ),
                DropdownMenuItem(
                  value: 0.725,
                  child: Text('۷۲.۵٪ (میانگین)'),
                ),
                DropdownMenuItem(
                  value: 0.75,
                  child: Text('۷۵٪'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _netPercentage = value;
                });

                _recalculate();
              },
            ),
          ] else ...[
            _InfoBox(
              title: 'محاسبه یونولیت',
              text: 'تعداد یونولیت بر اساس ۶۸٪ مساحت سقف محاسبه می‌شود.',
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // نتیجه پرکننده
  // ============================================================

  Widget _buildFillerResultPanel() {
    final isBlock = _filler == 'block';

    return _Panel(
      child: Column(
        children: [
          _PanelTitle(
            number: '◆',
            title: isBlock ? 'تعداد بلوک سقفی' : 'تعداد یونولیت سقفی',
          ),
          _HeroStat(
            label: 'تعداد',
            value: _formatNumber(_fillerCount),
            unit: 'عدد',
          ),
          const SizedBox(height: 11),
          _FormulaBox(
            text: isBlock
                ? 'تعداد = (مساحت خالص = مساحت × '
                    '${(_netPercentage * 100).toStringAsFixed(1)}٪) × '
                    '[(۱ ÷ فاصله آکس) × (۱ ÷ طول بلوک)]'
                : 'تعداد یونولیت = مساحت سقف × ۰.۶۸ '
                    '(برای بلوک یونولیتی ۲۰۰×۵۰)',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // بتن سقف
  // ============================================================

  Widget _buildConcretePanel() {
    final bags = _cementKg == null ? null : (_cementKg! / bagKg).ceil();

    final aggregate = _concreteVolume == null
        ? null
        : _concreteVolume! * aggregateTonPerM3Concrete;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            number: '۳',
            title: 'بتن سقف',
          ),
          _DropdownField<double>(
            label: 'ضخامت سقف',
            value: _ceilingThickness,
            items: const [
              DropdownMenuItem(
                value: 20,
                child: Text('۲۰ سانتی‌متر'),
              ),
              DropdownMenuItem(
                value: 25,
                child: Text('۲۵ سانتی‌متر'),
              ),
              DropdownMenuItem(
                value: 30,
                child: Text('۳۰ سانتی‌متر'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _ceilingThickness = value;
              });

              _recalculate();
            },
          ),
          const SizedBox(height: 13),
          _DropdownField<double>(
            label: 'نوع سیستم سقف',
            value: _systemCoefficient,
            items: const [
              DropdownMenuItem(
                value: 0.50,
                child: Text(
                  'پاشنه بتنی جان‌بسته / بلوک سفالی / پلی‌استایرن',
                ),
              ),
              DropdownMenuItem(
                value: 0.77,
                child: Text(
                  'پاشنه بتنی جان‌باز / تیرچه فولادی جان‌باز',
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _systemCoefficient = value;
              });

              _recalculate();
            },
          ),
          const SizedBox(height: 13),
          _DropdownField<int>(
            label: 'رده بتن',
            value: _concreteGradeIndex,
            items: List.generate(
              concreteGrades.length,
              (index) {
                final grade = concreteGrades[index];

                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    '${grade.label} — '
                    '${grade.kgPerM3} kg/m³',
                  ),
                );
              },
            ),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _concreteGradeIndex = value;
              });

              _recalculate();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SmallStat(
                  label: 'حجم بتن سقف',
                  value: _formatNumber(
                    _concreteVolume,
                    decimals: 2,
                  ),
                  unit: 'm³',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _SmallStat(
                  label: 'سیمان مصرفی',
                  value: _formatNumber(
                    _cementKg,
                    decimals: 1,
                  ),
                  unit: 'kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _ResultReadout(
            label: 'سیمان به کیسه ۵۰ کیلویی',
            value: bags == null ? '—' : _formatNumber(bags),
            unit: 'کیسه',
            subText: aggregate == null
                ? null
                : '≈ ${_formatNumber(aggregate, decimals: 2)} تن شن و ماسه',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // قیمت مصالح
  // ============================================================

  Widget _buildPricePanel() {
    final fillerLabel =
        _filler == 'block' ? 'قیمت هر عدد بلوک سقفی' : 'قیمت هر عدد یونولیت';

    return _Panel(
      child: Column(
        children: [
          const _PanelTitle(
            number: '۴',
            title: 'قیمت واحد مصالح (ریال)',
          ),
          _PriceRow(
            label: 'قیمت هر عدد تیرچه',
            controller: _joistPriceController,
            dotColor: _AppColors.accent,
            onChanged: (value) {
              _joistPrice = value;
              _recalculate();
            },
          ),
          _PriceRow(
            label: fillerLabel,
            controller: _fillerPriceController,
            dotColor: _AppColors.block,
            onChanged: (value) {
              _fillerPrice = value;
              _recalculate();
            },
          ),
          _PriceRow(
            label: 'قیمت هر کیسه سیمان',
            controller: _cementPriceController,
            dotColor: _AppColors.textMuted,
            onChanged: (value) {
              _cementPrice = value;
              _recalculate();
            },
          ),
          _PriceRow(
            label: 'قیمت هر تن شن و ماسه',
            controller: _aggregatePriceController,
            dotColor: _AppColors.mix2,
            onChanged: (value) {
              _aggregatePrice = value;
              _recalculate();
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // هزینه تمام شده
  // ============================================================

  Widget _buildTotalPanel() {
    final area = _area;

    if (area == null || area <= 0) {
      return const SizedBox.shrink();
    }

    final bags = _cementKg == null ? 0 : (_cementKg! / bagKg).ceil();

    final aggregateTon = (_concreteVolume ?? 0) * aggregateTonPerM3Concrete;

    final joistCost = (_joistCount ?? 0) * _joistPrice;

    final fillerCost = (_fillerCount ?? 0) * _fillerPrice;

    final cementCost = bags * _cementPrice;

    final aggregateCost = aggregateTon * _aggregatePrice;

    final total = joistCost + fillerCost + cementCost + aggregateCost;

    final unitPrice = area > 0 ? total / area : 0;

    return _Panel(
      child: Column(
        children: [
          const _PanelTitle(
            number: '◆',
            title: 'هزینه تمام‌شده',
          ),
          _TotalHero(
            label: 'قیمت هر مترمربع سقف',
            value: _formatPrice(unitPrice),
          ),
          const SizedBox(height: 10),
          _TotalHero(
            label: 'جمع کل',
            value: _formatPrice(total),
            large: true,
          ),
          const SizedBox(height: 14),
          _BreakdownRow(
            label: 'تیرچه (${_formatNumber(_joistCount)} عدد)',
            value: _formatPrice(joistCost),
          ),
          _BreakdownRow(
            label: '${_filler == 'block' ? 'بلوک سقفی' : 'یونولیت'} '
                '(${_formatNumber(_fillerCount)} عدد)',
            value: _formatPrice(fillerCost),
          ),
          _BreakdownRow(
            label: 'سیمان (${_formatNumber(bags)} کیسه)',
            value: _formatPrice(cementCost),
          ),
          _BreakdownRow(
            label: 'شن و ماسه '
                '(${_formatNumber(aggregateTon, decimals: 2)} تن)',
            value: _formatPrice(aggregateCost),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Footer
  // ============================================================

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 10,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            child: Divider(
              color: _AppColors.border,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'رهپیمان',
            style: TextStyle(
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'مهندسی ساده و قابل اعتماد',
            style: TextStyle(
              color: _AppColors.textDim,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// مدل بتن
// ============================================================================

class ConcreteGrade {
  final String label;
  final double kgPerM3;

  const ConcreteGrade({
    required this.label,
    required this.kgPerM3,
  });
}

// ============================================================================
// Colors
// ============================================================================

class _AppColors {
  static const Color background = Color(0xFF0B1118);

  static const Color panel = Color(0xFF101A24);

  static const Color panel2 = Color(0xFF152330);

  static const Color panel3 = Color(0xFF0D1720);

  static const Color border = Color(0x2A9AB6C7);

  static const Color borderSoft = Color(0x1C9AB6C7);

  static const Color textPrimary = Color(0xFFEAF2F7);

  static const Color textMuted = Color(0xFF8CA5B5);

  static const Color textDim = Color(0xFF60798A);

  static const Color accent = Color(0xFFB7F34A);

  static const Color accentDim = Color(0x1FB7F34A);

  static const Color block = Color(0xFF8E82D4);

  static const Color mix2 = Color(0xFF7FA6C9);

  static const Color concrete = Color(0xFF8299A8);

  static const Color cement = Color(0xFFC0A06A);
}

// ============================================================================
// Panel
// ============================================================================

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        17,
        16,
        18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _AppColors.panel2,
            _AppColors.panel,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _AppColors.borderSoft,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x50000000),
            blurRadius: 28,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================================
// Panel title
// ============================================================================

class _PanelTitle extends StatelessWidget {
  final String number;
  final String title;

  const _PanelTitle({
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        children: [
          Container(
            width: 19,
            height: 19,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _AppColors.accent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: _AppColors.background,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: _AppColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: _AppColors.borderSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Number field
// ============================================================================

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.label,
    required this.controller,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _AppColors.textMuted,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: _AppColors.background.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _AppColors.border,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9.]'),
              ),
            ],
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(
                color: _AppColors.textDim,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.045),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    suffix,
                    style: const TextStyle(
                      color: _AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Dropdown
// ============================================================================

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _AppColors.textMuted,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: _AppColors.background.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _AppColors.border,
            ),
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: _AppColors.panel2,
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Material toggle
// ============================================================================

class _MaterialToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MaterialToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _AppColors.panel3,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: _AppColors.borderSoft,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              title: 'بلوک سیمانی سقفی',
              active: selected == 'block',
              onTap: () {
                onChanged('block');
              },
            ),
          ),
          Expanded(
            child: _ToggleButton(
              title: 'یونولیت',
              active: selected == 'polystyrene',
              onTap: () {
                onChanged('polystyrene');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? _AppColors.accentDim : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? _AppColors.accent : _AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Hero stat
// ============================================================================

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: _AppColors.accentDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _AppColors.accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _AppColors.textDim,
              fontSize: 11,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                unit,
                style: const TextStyle(
                  color: _AppColors.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Small stat
// ============================================================================

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _SmallStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _AppColors.background.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _AppColors.borderSoft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _AppColors.textDim,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(
                  color: _AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Formula
// ============================================================================

class _FormulaBox extends StatelessWidget {
  final String text;

  const _FormulaBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _AppColors.border,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _AppColors.textDim,
          fontSize: 11.5,
          height: 1.7,
        ),
      ),
    );
  }
}

// ============================================================================
// Info box
// ============================================================================

class _InfoBox extends StatelessWidget {
  final String title;
  final String text;

  const _InfoBox({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _AppColors.accentDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _AppColors.accent.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              color: _AppColors.textMuted,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Result readout
// ============================================================================

class _ResultReadout extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? subText;

  const _ResultReadout({
    required this.label,
    required this.value,
    required this.unit,
    this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: _AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: _AppColors.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (subText != null) ...[
            const SizedBox(height: 8),
            Text(
              subText!,
              style: const TextStyle(
                color: _AppColors.textDim,
                fontSize: 11.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// Price row
// ============================================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color dotColor;
  final ValueChanged<double> onChanged;

  const _PriceRow({
    required this.label,
    required this.controller,
    required this.dotColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _AppColors.textMuted,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
              onChanged: (value) {
                final number = double.tryParse(
                      value.replaceAll(',', ''),
                    ) ??
                    0;

                onChanged(number);
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9,]'),
                ),
              ],
              style: const TextStyle(
                color: _AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: const TextStyle(
                  color: _AppColors.textDim,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 9,
                ),
                filled: true,
                fillColor: _AppColors.background.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Total hero
// ============================================================================

class _TotalHero extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _TotalHero({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: _AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: _AppColors.accent,
                    fontSize: large ? 29 : 27,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'ریال',
                  style: TextStyle(
                    color: _AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Breakdown row
// ============================================================================

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;

  const _BreakdownRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _AppColors.borderSoft,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _AppColors.textMuted,
                fontSize: 12.5,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
