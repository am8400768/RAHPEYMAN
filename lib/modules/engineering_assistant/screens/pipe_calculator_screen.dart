import 'package:flutter/material.dart';

import '../../estefsarieh/theme/estefsarieh_theme.dart';
import '../data/pipe_database_service.dart';
import '../models/pe_pipe_spec.dart';
import '../models/pe_pipe_type.dart';
import '../models/steel_pipe_size.dart';
import '../models/steel_pipe_weight.dart';

class PipeCalculatorScreen extends StatefulWidget {
  const PipeCalculatorScreen({super.key});

  @override
  State<PipeCalculatorScreen> createState() => _PipeCalculatorScreenState();
}

class _PipeCalculatorScreenState extends State<PipeCalculatorScreen> {
  final PipeDatabaseService _database = PipeDatabaseService.instance;

  int _selectedTab = 0;

  bool _loadingSteelSizes = true;
  bool _loadingSteelWeights = false;
  bool _loadingPeTypes = true;
  bool _loadingPeSpecs = false;

  String? _errorMessage;

  List<SteelPipeSize> _steelSizes = const [];
  List<SteelPipeWeight> _steelWeights = const [];

  List<PePipeType> _peTypes = const [];
  List<PePipeSpec> _peSpecs = const [];

  SteelPipeSize? _selectedSteelSize;
  SteelPipeWeight? _selectedSteelWeight;

  PePipeType? _selectedPeType;
  double? _selectedPeDiameter;
  String? _selectedPePn;
  PePipeSpec? _selectedPeSpec;

  // ------------------------------------------------------------
  // Cost estimation controllers
  // ------------------------------------------------------------

  final TextEditingController _steelLengthController = TextEditingController();

  final TextEditingController _steelPricePerKgController =
      TextEditingController();

  final TextEditingController _steelPricePerMeterController =
      TextEditingController();

  final TextEditingController _peLengthController = TextEditingController();

  final TextEditingController _pePricePerKgController = TextEditingController();

  final TextEditingController _pePricePerMeterController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _steelLengthController.dispose();
    _steelPricePerKgController.dispose();
    _steelPricePerMeterController.dispose();
    _peLengthController.dispose();
    _pePricePerKgController.dispose();
    _pePricePerMeterController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loadingSteelSizes = true;
      _loadingPeTypes = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _database.getSteelPipeSizes(),
        _database.getPePipeTypes(),
      ]);

      final steelSizes = results[0] as List<SteelPipeSize>;
      final peTypes = results[1] as List<PePipeType>;

      if (!mounted) {
        return;
      }

      setState(() {
        _steelSizes = steelSizes;
        _peTypes = peTypes;
        _loadingSteelSizes = false;
        _loadingPeTypes = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingSteelSizes = false;
        _loadingPeTypes = false;
        _errorMessage = 'خطا در بارگذاری اطلاعات لوله‌ها:\n$error';
      });
    }
  }

  Future<void> _selectSteelSize(SteelPipeSize? size) async {
    if (size == null) {
      setState(() {
        _selectedSteelSize = null;
        _selectedSteelWeight = null;
        _steelWeights = const [];
      });
      return;
    }

    setState(() {
      _selectedSteelSize = size;
      _selectedSteelWeight = null;
      _steelWeights = const [];
      _loadingSteelWeights = true;
    });

    try {
      final weights = await _database.getSteelPipeWeights(size.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _steelWeights = weights;
        _loadingSteelWeights = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingSteelWeights = false;
        _errorMessage = 'خطا در دریافت ضخامت‌های این سایز:\n$error';
      });
    }
  }

  Future<void> _selectPeType(PePipeType? type) async {
    setState(() {
      _selectedPeType = type;
      _selectedPeDiameter = null;
      _selectedPePn = null;
      _selectedPeSpec = null;
      _peSpecs = const [];
      _loadingPeSpecs = false;
    });

    if (type == null) {
      return;
    }

    setState(() {
      _loadingPeSpecs = true;
    });

    try {
      final specs = await _database.getPePipeSpecs(typeId: type.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _peSpecs = specs;
        _loadingPeSpecs = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingPeSpecs = false;
        _errorMessage = 'خطا در دریافت اطلاعات پلی‌اتیلن:\n$error';
      });
    }
  }

  void _selectPeDiameter(double? diameter) {
    setState(() {
      _selectedPeDiameter = diameter;
      _selectedPePn = null;
      _selectedPeSpec = null;
    });
  }

  void _selectPePn(String? pn) {
    if (pn == null || _selectedPeDiameter == null) {
      setState(() {
        _selectedPePn = pn;
        _selectedPeSpec = null;
      });
      return;
    }

    PePipeSpec? selected;

    for (final spec in _peSpecs) {
      if (spec.doMm == _selectedPeDiameter && spec.pn == pn) {
        selected = spec;
        break;
      }
    }

    setState(() {
      _selectedPePn = pn;
      _selectedPeSpec = selected;
    });
  }

  List<double> get _availablePeDiameters {
    final values = <double>{};

    for (final spec in _peSpecs) {
      values.add(spec.doMm);
    }

    final result = values.toList()..sort();

    return result;
  }

  List<String> get _availablePePns {
    if (_selectedPeDiameter == null) {
      return const [];
    }

    final values = <String>{};

    for (final spec in _peSpecs) {
      if (spec.doMm == _selectedPeDiameter) {
        values.add(spec.pn);
      }
    }

    final result = values.toList();

    result.sort((a, b) {
      final aValue = double.tryParse(a) ?? double.infinity;
      final bValue = double.tryParse(b) ?? double.infinity;

      return aValue.compareTo(bValue);
    });

    return result;
  }

  // ------------------------------------------------------------
  // Input / number helpers
  // ------------------------------------------------------------

  double? _parseNumber(String value) {
    var normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const englishDigits = '0123456789';

    for (var i = 0; i < englishDigits.length; i++) {
      normalized = normalized.replaceAll(
        persianDigits[i],
        englishDigits[i],
      );

      normalized = normalized.replaceAll(
        arabicDigits[i],
        englishDigits[i],
      );
    }

    normalized = normalized
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.')
        .replaceAll(' ', '');

    return double.tryParse(normalized);
  }

  String _formatMoney(double value) {
    if (!value.isFinite) {
      return '-';
    }

    final rounded = value.round();
    final text = rounded.toString();

    return _addThousandsSeparator(
      _toPersianDigits(text),
    );
  }

  String _formatMoneyWithUnit(double value) {
    return '${_formatMoney(value)} ریال';
  }

  String _addThousandsSeparator(String value) {
    final negative = value.startsWith('-');
    final digits = negative ? value.substring(1) : value;

    if (digits.length <= 3) {
      return value;
    }

    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    final result = buffer.toString();

    return negative ? '-$result' : result;
  }

  String _toPersianDigits(String value) {
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

  String _formatNumber(num value) {
    if (value is int) {
      return _toPersianDigits(value.toString());
    }

    final double doubleValue = value.toDouble();

    String text;

    if (doubleValue == doubleValue.roundToDouble()) {
      text = doubleValue.toInt().toString();
    } else {
      text = doubleValue
          .toStringAsFixed(3)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }

    return _toPersianDigits(text);
  }

  // ------------------------------------------------------------
  // Cost calculations
  // ------------------------------------------------------------

  Widget _buildSteelCostEstimator() {
    final selectedWeight = _selectedSteelWeight;

    if (selectedWeight == null) {
      return _buildInlineMessage(
        'ابتدا ضخامت لوله را انتخاب کنید تا امکان برآورد هزینه فعال شود.',
      );
    }

    return _buildCostEstimator(
      title: 'برآورد هزینه لوله فولادی',
      icon: Icons.calculate_rounded,
      lengthController: _steelLengthController,
      pricePerKgController: _steelPricePerKgController,
      pricePerMeterController: _steelPricePerMeterController,
      weightKgPerMeter: selectedWeight.weightKgPerM,
    );
  }

  Widget _buildPeCostEstimator() {
    final selectedSpec = _selectedPeSpec;

    if (selectedSpec == null) {
      return _buildInlineMessage(
        'ابتدا مشخصات کامل لوله پلی‌اتیلن را انتخاب کنید تا امکان برآورد هزینه فعال شود.',
      );
    }

    return _buildCostEstimator(
      title: 'برآورد هزینه لوله پلی‌اتیلن',
      icon: Icons.calculate_rounded,
      lengthController: _peLengthController,
      pricePerKgController: _pePricePerKgController,
      pricePerMeterController: _pePricePerMeterController,
      weightKgPerMeter: selectedSpec.weightKgPerM,
    );
  }

  Widget _buildCostEstimator({
    required String title,
    required IconData icon,
    required TextEditingController lengthController,
    required TextEditingController pricePerKgController,
    required TextEditingController pricePerMeterController,
    required double weightKgPerMeter,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.accent.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: EstefsariehDecor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: EstefsariehColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: EstefsariehColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'IRANSansWeb(FaNum)',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: EstefsariehColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'برای محاسبه ارزش ریالی، طول موردنیاز و یکی از قیمت‌های هر کیلوگرم یا هر متر را وارد کنید.',
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 11.5,
              height: 1.7,
              color: EstefsariehColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            controller: lengthController,
            label: 'طول موردنیاز',
            hint: 'مثلاً ۱۰۰',
            suffix: 'متر',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 11),
          _buildNumberField(
            controller: pricePerKgController,
            label: 'قیمت هر کیلوگرم',
            hint: 'مثلاً ۱۰۰۰۰۰',
            suffix: 'ریال/kg',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: EstefsariehColors.borderSoft,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'یا',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 11,
                    color: EstefsariehColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: EstefsariehColors.borderSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildNumberField(
            controller: pricePerMeterController,
            label: 'قیمت هر متر',
            hint: 'مثلاً ۱۰۰۰۰۰۰',
            suffix: 'ریال/m',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildCostResult(
            lengthController: lengthController,
            pricePerKgController: pricePerKgController,
            pricePerMeterController: pricePerMeterController,
            weightKgPerMeter: weightKgPerMeter,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'IRANSansWeb(FaNum)',
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        labelStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11.5,
        ),
        suffixStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 10.5,
          color: EstefsariehColors.textMuted,
        ),
        filled: true,
        fillColor: EstefsariehColors.panel2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: EstefsariehColors.borderSoft,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: EstefsariehColors.borderSoft,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: EstefsariehColors.accent,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildCostResult({
    required TextEditingController lengthController,
    required TextEditingController pricePerKgController,
    required TextEditingController pricePerMeterController,
    required double weightKgPerMeter,
  }) {
    final length = _parseNumber(lengthController.text);
    final inputPricePerKg = _parseNumber(pricePerKgController.text);
    final inputPricePerMeter = _parseNumber(pricePerMeterController.text);

    double? pricePerKg = inputPricePerKg;
    double? pricePerMeter = inputPricePerMeter;

    if (pricePerKg == null && pricePerMeter != null && weightKgPerMeter > 0) {
      pricePerKg = pricePerMeter / weightKgPerMeter;
    }

    if (pricePerMeter == null && pricePerKg != null && weightKgPerMeter > 0) {
      pricePerMeter = pricePerKg * weightKgPerMeter;
    }

    final totalWeight = length != null ? length * weightKgPerMeter : null;

    final totalCost =
        length != null && pricePerMeter != null ? length * pricePerMeter : null;

    final hasAnyValue =
        length != null || inputPricePerKg != null || inputPricePerMeter != null;

    if (!hasAnyValue) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: EstefsariehColors.panel2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'نتیجه محاسبه پس از ورود اطلاعات در این بخش نمایش داده می‌شود.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 11,
            height: 1.7,
            color: EstefsariehColors.textMuted,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: EstefsariehColors.accentSoft,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: EstefsariehColors.accent.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildCostRow(
            'وزن هر متر',
            '${_formatNumber(weightKgPerMeter)} کیلوگرم',
          ),
          if (totalWeight != null)
            _buildCostRow(
              'وزن کل',
              '${_formatNumber(totalWeight)} کیلوگرم',
            ),
          if (pricePerKg != null)
            _buildCostRow(
              'قیمت هر کیلوگرم',
              _formatMoneyWithUnit(pricePerKg),
            ),
          if (pricePerMeter != null)
            _buildCostRow(
              'قیمت هر متر',
              _formatMoneyWithUnit(pricePerMeter),
            ),
          if (totalCost != null) ...[
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                children: [
                  const Text(
                    'ارزش کل لوله',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11.5,
                      color: EstefsariehColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneyWithUnit(totalCost),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'IRANSansWeb(FaNum)',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: EstefsariehColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: EstefsariehColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

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
            'لوله‌یار',
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: _buildIntroCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
            child: _buildTypeSelector(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              10,
            ),
            child: _selectedTab == 0 ? _buildSteelPanel() : _buildPePanel(),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 4),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 18,
            ),
            child: _RahpeymanFooter(),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroCard() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مشخصات فنی لوله',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: EstefsariehColors.primary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'سایز و مشخصات لوله موردنظر را انتخاب کنید تا اطلاعات فنی آن از بانک اطلاعاتی نمایش داده شود. سپس می‌توانید ارزش ریالی لوله را نیز برآورد کنید.',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12.5,
              height: 1.7,
              color: EstefsariehColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: EstefsariehColors.panel2,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              index: 0,
              title: 'لوله فولادی',
              icon: Icons.straighten_rounded,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              index: 1,
              title: 'لوله پلی‌اتیلن',
              icon: Icons.water_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final selected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected ? EstefsariehDecor.cardShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? EstefsariehColors.accent
                  : EstefsariehColors.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'IRANSansWeb(FaNum)',
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? EstefsariehColors.primary
                    : EstefsariehColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteelPanel() {
    if (_loadingSteelSizes) {
      return _buildLoadingCard(
        'در حال بارگذاری سایزهای لوله فولادی...',
      );
    }

    if (_steelSizes.isEmpty) {
      return _buildEmptyCard(
        'اطلاعات سایزهای لوله فولادی در بانک اطلاعاتی پیدا نشد.',
      );
    }

    return Column(
      children: [
        _buildSectionCard(
          title: 'انتخاب سایز لوله',
          icon: Icons.straighten_rounded,
          child: _buildDropdown<SteelPipeSize>(
            value: _selectedSteelSize,
            items: _steelSizes,
            label: 'سایز اسمی',
            hint: 'سایز لوله را انتخاب کنید',
            itemLabel: (item) =>
                '${item.displayName} — ${_formatNumber(item.nominalMm)} mm',
            onChanged: _selectSteelSize,
          ),
        ),
        if (_selectedSteelSize != null) ...[
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'انتخاب ضخامت',
            icon: Icons.layers_rounded,
            child: _loadingSteelWeights
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _steelWeights.isEmpty
                    ? _buildInlineMessage(
                        'برای این سایز ضخامت ثبت‌شده‌ای پیدا نشد.',
                      )
                    : _buildDropdown<SteelPipeWeight>(
                        value: _selectedSteelWeight,
                        items: _steelWeights,
                        label: 'ضخامت',
                        hint: 'ضخامت لوله را انتخاب کنید',
                        itemLabel: (item) =>
                            '${_formatNumber(item.thicknessMm)} میلی‌متر',
                        onChanged: (value) {
                          setState(() {
                            _selectedSteelWeight = value;
                          });
                        },
                      ),
          ),
        ],
        if (_selectedSteelSize != null) ...[
          const SizedBox(height: 12),
          _buildSteelResult(),
        ],
        if (_selectedSteelWeight != null) ...[
          const SizedBox(height: 12),
          _buildSteelCostEstimator(),
        ],
      ],
    );
  }

  Widget _buildSteelResult() {
    final size = _selectedSteelSize;
    final weight = _selectedSteelWeight;

    if (size == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.accent.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: EstefsariehDecor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مشخصات لوله فولادی',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: EstefsariehColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          _buildResultRow(
            'سایز اسمی',
            size.displayName,
          ),
          _buildResultRow(
            'قطر اسمی',
            '${_formatNumber(size.nominalMm)} میلی‌متر',
          ),
          _buildResultRow(
            'قطر خارجی',
            '${_formatNumber(size.odMm)} میلی‌متر',
          ),
          if (weight != null) ...[
            _buildResultRow(
              'ضخامت',
              '${_formatNumber(weight.thicknessMm)} میلی‌متر',
            ),
            _buildResultRow(
              'وزن هر متر',
              '${_formatNumber(weight.weightKgPerM)} کیلوگرم',
              highlighted: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPePanel() {
    if (_loadingPeTypes) {
      return _buildLoadingCard(
        'در حال بارگذاری اطلاعات پلی‌اتیلن...',
      );
    }

    if (_peTypes.isEmpty) {
      return _buildEmptyCard(
        'اطلاعات انواع لوله پلی‌اتیلن در بانک اطلاعاتی پیدا نشد.',
      );
    }

    return Column(
      children: [
        _buildSectionCard(
          title: 'نوع لوله پلی‌اتیلن',
          icon: Icons.category_rounded,
          child: _buildDropdown<PePipeType>(
            value: _selectedPeType,
            items: _peTypes,
            label: 'نوع لوله',
            hint: 'PE 63، PE 80 یا PE 100',
            itemLabel: (item) => item.name,
            onChanged: _selectPeType,
          ),
        ),
        if (_selectedPeType != null) ...[
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'قطر خارجی',
            icon: Icons.radio_button_checked_rounded,
            child: _loadingPeSpecs
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buildDropdown<double>(
                    value: _selectedPeDiameter,
                    items: _availablePeDiameters,
                    label: 'قطر خارجی',
                    hint: 'قطر خارجی را انتخاب کنید',
                    itemLabel: (item) => '${_formatNumber(item)} میلی‌متر',
                    onChanged: _selectPeDiameter,
                  ),
          ),
        ],
        if (_selectedPeDiameter != null) ...[
          const SizedBox(height: 12),
          _buildSectionCard(
            title: 'فشار اسمی',
            icon: Icons.speed_rounded,
            child: _buildDropdown<String>(
              value: _selectedPePn,
              items: _availablePePns,
              label: 'PN',
              hint: 'رده PN را انتخاب کنید',
              itemLabel: (item) => 'PN $item',
              onChanged: _selectPePn,
            ),
          ),
        ],
        if (_selectedPeSpec != null) ...[
          const SizedBox(height: 12),
          _buildPeResult(_selectedPeSpec!),
          const SizedBox(height: 12),
          _buildPeCostEstimator(),
        ],
      ],
    );
  }

  Widget _buildPeResult(PePipeSpec spec) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.accent.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: EstefsariehDecor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مشخصات لوله پلی‌اتیلن',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: EstefsariehColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          _buildResultRow(
            'نوع',
            _selectedPeType?.name ?? '-',
          ),
          _buildResultRow(
            'فشار اسمی',
            'PN ${spec.pn}',
          ),
          _buildResultRow(
            'قطر خارجی',
            '${_formatNumber(spec.doMm)} میلی‌متر',
          ),
          _buildResultRow(
            'قطر داخلی',
            '${_formatNumber(spec.diMm)} میلی‌متر',
          ),
          _buildResultRow(
            'ضخامت',
            '${_formatNumber(spec.thicknessMm)} میلی‌متر',
          ),
          _buildResultRow(
            'وزن هر متر',
            '${_formatNumber(spec.weightKgPerM)} کیلوگرم',
            highlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: EstefsariehColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: EstefsariehColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'IRANSansWeb(FaNum)',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: EstefsariehColors.primary,
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

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String label,
    required String hint,
    required String Function(T item) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
        ),
        filled: true,
        fillColor: EstefsariehColors.panel2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: EstefsariehColors.borderSoft,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: EstefsariehColors.borderSoft,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: EstefsariehColors.accent,
            width: 1.4,
          ),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12.5,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultRow(
    String title,
    String value, {
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? EstefsariehColors.accentSoft
            : EstefsariehColors.panel2,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11.5,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'IRANSansWeb(FaNum)',
                fontSize: 12,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
                color: highlighted
                    ? EstefsariehColors.accent
                    : EstefsariehColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.borderSoft,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: EstefsariehColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EstefsariehColors.borderSoft,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          height: 1.7,
          color: EstefsariehColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildInlineMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EstefsariehColors.panel2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11.5,
          color: EstefsariehColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  height: 1.7,
                  color: EstefsariehColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'تلاش مجدد',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RahpeymanFooter extends StatelessWidget {
  const _RahpeymanFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
      ),
      child: Center(
        child: Text(
          'رهپیمان | همراه مهندسین از آموزش تا اجرا',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'IRANSansWeb(FaNum)',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: EstefsariehColors.textMuted,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
