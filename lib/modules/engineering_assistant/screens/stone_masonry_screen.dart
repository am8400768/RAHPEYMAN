import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// صفحه محاسبات «بنایی سنگی ملاتی»
///
/// این صفحه به صورت مستقل طراحی شده تا بدون دستکاری سایر ابزارهای
/// مهندس‌یار بتواند به عنوان یک ابزار جدید به Engineering Assistant
/// اضافه شود.
///
/// مرجع منطق اولیه:
/// - سنگ: 2 تن به ازای هر مترمکعب بنایی
/// - حجم ملات: 30 درصد حجم بنایی
/// - ماسه: 1.85 تن به ازای هر مترمکعب ملات
/// - ضریب پرت سیمان: 1.06
/// - کیسه سیمان: 50 کیلوگرم
class StoneMasonryScreen extends StatefulWidget {
  const StoneMasonryScreen({super.key});

  @override
  State<StoneMasonryScreen> createState() => _StoneMasonryScreenState();
}

class _StoneMasonryScreenState extends State<StoneMasonryScreen> {
  // ---------------------------------------------------------------------------
  // رنگ اختصاصی بنایی سنگی ملاتی
  // ---------------------------------------------------------------------------

  static const Color stoneColor = Color(0xFFA08A6E);

  // رنگ‌های مشترک Design System
  static const Color textDark = Color(0xFF1A237E);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color borderColor = Color(0xFFE1E6ED);
  static const Color textMuted = Color(0xFF65748B);
  static const Color sandColor = Color(0xFFB89B72);
  static const Color cementColor = Color(0xFF7D8793);
  static const Color successColor = Color(0xFF2E7D32);

  // ---------------------------------------------------------------------------
  // ثابت‌های محاسباتی مطابق دمو
  // ---------------------------------------------------------------------------

  static const double stoneTonPerM3 = 2.0;
  static const double mortarPercentOfStone = 0.30;
  static const double sandTonPerM3Mortar = 1.85;
  static const double cementWaste = 1.06;
  static const double cementBagKg = 50.0;

  // ---------------------------------------------------------------------------
  // اطلاعات ملات
  // مطابق داده‌های بخش بنایی سنگی ملاتی در دمو
  // ---------------------------------------------------------------------------

  static const List<MortarData> mortars = [
    MortarData(
      label: 'ملات ماسه سیمان ۱:۳',
      kgPerM3: 360,
    ),
    MortarData(
      label: 'ملات ماسه سیمان ۱:۴',
      kgPerM3: 285,
    ),
    MortarData(
      label: 'ملات ماسه سیمان ۱:۵',
      kgPerM3: 225,
    ),
    MortarData(
      label: 'ملات ماسه سیمان ۱:۶',
      kgPerM3: 200,
    ),
    MortarData(
      label: 'ماسه بادی و سیمان ۱:۴',
      kgPerM3: 285,
    ),
    MortarData(
      label: 'باتارد سیمان:آهک:ماسه ۱:۲:۹',
      kgPerM3: 130,
    ),
  ];

  // ---------------------------------------------------------------------------
  // ورودی‌ها
  // ---------------------------------------------------------------------------

  final TextEditingController volumeController = TextEditingController();
  final TextEditingController stonePriceController = TextEditingController();
  final TextEditingController cementPriceController = TextEditingController();
  final TextEditingController sandPriceController = TextEditingController();

  final FocusNode volumeFocus = FocusNode();
  final FocusNode stonePriceFocus = FocusNode();
  final FocusNode cementPriceFocus = FocusNode();
  final FocusNode sandPriceFocus = FocusNode();

  String selectedStoneType = 'سنگ قلوه';
  int selectedMortarIndex = 2;

  // ---------------------------------------------------------------------------
  // نتایج
  // ---------------------------------------------------------------------------

  double? stoneTon;
  double? mortarVolume;
  double? sandTon;
  double? cementKg;
  double? cementBags;

  double? stoneCost;
  double? cementCost;
  double? sandCost;
  double? totalCost;
  double? unitCost;

  @override
  void initState() {
    super.initState();

    volumeController.addListener(_recalculate);

    stonePriceController.addListener(_recalculate);
    cementPriceController.addListener(_recalculate);
    sandPriceController.addListener(_recalculate);
  }

  @override
  void dispose() {
    volumeController.dispose();
    stonePriceController.dispose();
    cementPriceController.dispose();
    sandPriceController.dispose();

    volumeFocus.dispose();
    stonePriceFocus.dispose();
    cementPriceFocus.dispose();
    sandPriceFocus.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // تبدیل متن عددی به double
  // ---------------------------------------------------------------------------

  double? _parseNumber(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    final normalized = value
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.')
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');

    return double.tryParse(normalized);
  }

  // ---------------------------------------------------------------------------
  // محاسبه
  // ---------------------------------------------------------------------------

  void _recalculate() {
    final volume = _parseNumber(volumeController.text);

    if (volume == null || volume <= 0) {
      setState(() {
        stoneTon = null;
        mortarVolume = null;
        sandTon = null;
        cementKg = null;
        cementBags = null;

        stoneCost = null;
        cementCost = null;
        sandCost = null;
        totalCost = null;
        unitCost = null;
      });

      return;
    }

    final calculatedStoneTon = volume * stoneTonPerM3;

    final calculatedMortarVolume = volume * mortarPercentOfStone;

    final calculatedSandTon = calculatedMortarVolume * sandTonPerM3Mortar;

    final mortar = mortars[selectedMortarIndex];

    final calculatedCementKg =
        calculatedMortarVolume * mortar.kgPerM3 * cementWaste;

    final calculatedCementBags = calculatedCementKg / cementBagKg;

    final stonePrice = _parseNumber(stonePriceController.text) ?? 0;
    final cementPrice = _parseNumber(cementPriceController.text) ?? 0;
    final sandPrice = _parseNumber(sandPriceController.text) ?? 0;

    final calculatedStoneCost = calculatedStoneTon * stonePrice;

    final calculatedCementCost = calculatedCementBags * cementPrice;

    final calculatedSandCost = calculatedSandTon * sandPrice;

    final calculatedTotalCost =
        calculatedStoneCost + calculatedCementCost + calculatedSandCost;

    final calculatedUnitCost = calculatedTotalCost / volume;

    setState(() {
      stoneTon = calculatedStoneTon;
      mortarVolume = calculatedMortarVolume;
      sandTon = calculatedSandTon;
      cementKg = calculatedCementKg;
      cementBags = calculatedCementBags;

      stoneCost = calculatedStoneCost;
      cementCost = calculatedCementCost;
      sandCost = calculatedSandCost;
      totalCost = calculatedTotalCost;
      unitCost = calculatedUnitCost;
    });
  }

  // ---------------------------------------------------------------------------
  // قالب‌بندی اعداد
  //
  // نکته مهم:
  // 1000       -> 1,000
  // 1250000    -> 1,250,000
  // 1250000.25 -> 1,250,000.25
  //
  // هیچ عددی بدون جداکننده هزارگان نمایش داده نمی‌شود.
  // ---------------------------------------------------------------------------

  String _formatNumber(
    double? value, {
    int decimals = 2,
    bool trimZeros = true,
  }) {
    if (value == null || value.isNaN || value.isInfinite) {
      return '—';
    }

    final safeDecimals = decimals.clamp(0, 6);

    String fixed = value.toStringAsFixed(safeDecimals);

    if (trimZeros && fixed.contains('.')) {
      fixed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    final parts = fixed.split('.');

    String integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final isNegative = integerPart.startsWith('-');

    if (isNegative) {
      integerPart = integerPart.substring(1);
    }

    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(integerPart[i]);
    }

    final formattedInteger = '${isNegative ? '-' : ''}${buffer.toString()}';

    if (decimalPart.isEmpty) {
      return formattedInteger;
    }

    return '$formattedInteger.$decimalPart';
  }

  // ---------------------------------------------------------------------------
  // تغییر خودکار فرمت ورودی‌های قیمت
  // ---------------------------------------------------------------------------

  void _formatPriceController(
    TextEditingController controller,
  ) {
    final raw = controller.text;

    if (raw.isEmpty) {
      return;
    }

    final cleaned = raw.replaceAll(',', '').replaceAll('٬', '');

    final parts = cleaned.split('.');

    final integerPart = parts.first.replaceAll(RegExp(r'[^0-9]'), '');

    if (integerPart.isEmpty) {
      return;
    }

    final formattedInteger = _formatIntegerString(integerPart);

    String result = formattedInteger;

    if (parts.length > 1) {
      final decimal = parts.sublist(1).join('').replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );

      result = '$formattedInteger.$decimal';
    }

    if (result == controller.text) {
      return;
    }

    controller.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(
        offset: result.length,
      ),
    );
  }

  String _formatIntegerString(String value) {
    if (value.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(value[i]);
    }

    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // ویجت متن نتیجه
  // ---------------------------------------------------------------------------

  Widget _resultValue(
    String value,
    String unit, {
    Color color = textDark,
    double fontSize = 20,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontFamily: 'IRANSansWeb(FaNum)',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            TextSpan(
              text: '  $unit',
              style: const TextStyle(
                fontFamily: 'IRANSansWeb',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHeaderIcon(),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'بنایی سنگی ملاتی',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'سنگ، ملات، سیمان و هزینه',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'بازگشت',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: stoneColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stoneColor.withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(
        Icons.terrain_outlined,
        color: stoneColor,
        size: 24,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // عنوان پنل
  // ---------------------------------------------------------------------------

  Widget _buildPanelLabel(
    String index,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 27,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: stoneColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            index,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: stoneColor,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'IRANSansWeb',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(
            color: borderColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // پنل
  // ---------------------------------------------------------------------------

  Widget _panel({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Label فیلد
  // ---------------------------------------------------------------------------

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'IRANSansWeb',
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dropdown
  // ---------------------------------------------------------------------------

  Widget _buildDropdown() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStoneType,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textMuted,
          ),
          style: const TextStyle(
            fontFamily: 'IRANSansWeb',
            fontSize: 13,
            color: textDark,
          ),
          items: const [
            DropdownMenuItem(
              value: 'سنگ قلوه',
              child: Text('سنگ قلوه'),
            ),
            DropdownMenuItem(
              value: 'سنگ لاشه',
              child: Text('سنگ لاشه'),
            ),
            DropdownMenuItem(
              value: 'سنگ قواره',
              child: Text('سنگ قواره'),
            ),
            DropdownMenuItem(
              value: 'سنگ لایه',
              child: Text('سنگ لایه (لایه‌لایه)'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedStoneType = value;
            });
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ورودی عددی
  // ---------------------------------------------------------------------------

  Widget _buildNumberField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String suffix,
    bool decimal = true,
    bool price = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus
                  ? stoneColor.withValues(alpha: 0.7)
                  : borderColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: decimal,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.,]'),
                    ),
                  ],
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: 'IRANSansWeb(FaNum)',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'IRANSansWeb(FaNum)',
                      color: Color(0xFF9AA5B4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (price) {
                      _formatPriceController(controller);
                    }
                    _recalculate();
                    setState(() {});
                  },
                ),
              ),
              Container(
                height: 27,
                width: 1,
                color: borderColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 10.5,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // نتیجه سنگ
  // ---------------------------------------------------------------------------

  Widget _buildStoneResult() {
    if (stoneTon == null) {
      return const SizedBox.shrink();
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelLabel(
            '◆',
            'مقدار سنگ مورد نیاز',
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: stoneColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: stoneColor.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مقدار',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 10,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                _resultValue(
                  _formatNumber(
                    stoneTon,
                    decimals: 2,
                  ),
                  'تن',
                  color: stoneColor,
                  fontSize: 21,
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _formulaBox(
            'سنگ (تن) = حجم بنایی (m³) × ۲ — بند ۱۰-۳-۱ نشریه',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ملات
  // ---------------------------------------------------------------------------

  Widget _buildMortarResult() {
    if (stoneTon == null) {
      return const SizedBox.shrink();
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelLabel(
            '۲',
            'نسبت حجمی ملات مصرفی',
          ),
          const SizedBox(height: 13),
          _fieldLabel('نوع ملات'),
          _buildMortarDropdown(),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: 'ماسه مصرفی',
                  value: _formatNumber(
                    sandTon,
                    decimals: 2,
                  ),
                  unit: 'تن',
                  accent: sandColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  title: 'سیمان مصرفی',
                  value: _formatNumber(
                    cementKg,
                    decimals: 1,
                  ),
                  unit: 'kg',
                  accent: cementColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _readoutBox(
            label: 'سیمان به کیسه ۵۰ کیلویی',
            value: _formatNumber(
              cementBags,
              decimals: 2,
            ),
            unit: 'کیسه',
          ),
        ],
      ),
    );
  }

  Widget _buildMortarDropdown() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedMortarIndex,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textMuted,
          ),
          style: const TextStyle(
            fontFamily: 'IRANSansWeb',
            fontSize: 12,
            color: textDark,
          ),
          items: List.generate(
            mortars.length,
            (index) {
              final mortar = mortars[index];

              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  '${mortar.label} — ${_formatNumber(mortar.kgPerM3, decimals: 0)} kg/m³',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedMortarIndex = value;
            });

            _recalculate();
          },
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String unit,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb',
              fontSize: 10,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 5),
          _resultValue(
            value,
            unit,
            color: accent,
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // قیمت
  // ---------------------------------------------------------------------------

  Widget _buildPricePanel() {
    if (stoneTon == null) {
      return const SizedBox.shrink();
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelLabel(
            '۳',
            'قیمت واحد مصالح (ریال)',
          ),
          const SizedBox(height: 14),
          _buildNumberField(
            controller: stonePriceController,
            focusNode: stonePriceFocus,
            label: 'قیمت هر تن سنگ',
            suffix: 'ریال',
            decimal: false,
            price: true,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            controller: cementPriceController,
            focusNode: cementPriceFocus,
            label: 'قیمت هر کیسه سیمان',
            suffix: 'ریال',
            decimal: false,
            price: true,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            controller: sandPriceController,
            focusNode: sandPriceFocus,
            label: 'قیمت هر تن ماسه',
            suffix: 'ریال',
            decimal: false,
            price: true,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // هزینه نهایی
  // ---------------------------------------------------------------------------

  Widget _buildTotalPanel() {
    if (stoneTon == null) {
      return const SizedBox.shrink();
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelLabel(
            '◆',
            'هزینه تمام‌شده',
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _totalHero(
                  label: 'قیمت هر مترمکعب بنایی سنگی',
                  value: _formatNumber(
                    unitCost,
                    decimals: 0,
                  ),
                  accent: stoneColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _totalHero(
                  label: 'جمع کل',
                  value: _formatNumber(
                    totalCost,
                    decimals: 0,
                  ),
                  accent: successColor,
                  strong: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBreakdown(),
        ],
      ),
    );
  }

  Widget _totalHero({
    required String label,
    required String value,
    required Color accent,
    bool strong = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: strong ? 0.10 : 0.07,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb',
              fontSize: 9.5,
              color: textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          _resultValue(
            value,
            'ریال',
            color: accent,
            fontSize: strong ? 17 : 15,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          _breakdownRow(
            'سنگ',
            _formatNumber(
              stoneTon,
              decimals: 2,
            ),
            'تن',
            stoneCost,
          ),
          const Divider(
            height: 1,
            color: borderColor,
          ),
          _breakdownRow(
            'سیمان',
            _formatNumber(
              cementBags,
              decimals: 2,
            ),
            'کیسه',
            cementCost,
          ),
          const Divider(
            height: 1,
            color: borderColor,
          ),
          _breakdownRow(
            'ماسه',
            _formatNumber(
              sandTon,
              decimals: 2,
            ),
            'تن',
            sandCost,
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(
    String title,
    String quantity,
    String quantityUnit,
    double? cost,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title ($quantity $quantityUnit)',
              style: const TextStyle(
                fontFamily: 'IRANSansWeb',
                fontSize: 11,
                color: textMuted,
              ),
            ),
          ),
          Text(
            '${_formatNumber(cost, decimals: 0)} ریال',
            style: const TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Readout
  // ---------------------------------------------------------------------------

  Widget _readoutBox({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb',
              fontSize: 10,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 5),
          _resultValue(
            value,
            unit,
            color: textDark,
            fontSize: 17,
          ),
        ],
      ),
    );
  }

  Widget _formulaBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'IRANSansWeb',
          fontSize: 10,
          height: 1.7,
          color: textMuted,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        24,
      ),
      child: Column(
        children: [
          const Divider(
            color: borderColor,
          ),
          const SizedBox(height: 9),
          Text(
            'رهپیمان — همراه مهندسین از آموزش تا اجرا',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb',
              fontSize: 10,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    0,
                  ),
                  children: [
                    _panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPanelLabel(
                            '۱',
                            'حجم بنایی سنگی',
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('نوع سنگ'),
                          _buildDropdown(),
                          const SizedBox(height: 13),
                          _buildNumberField(
                            controller: volumeController,
                            focusNode: volumeFocus,
                            label: 'حجم بنایی مورد نیاز (مترمکعب)',
                            suffix: 'm³',
                            decimal: true,
                          ),
                        ],
                      ),
                    ),
                    if (stoneTon != null) ...[
                      const SizedBox(height: 11),
                      _buildStoneResult(),
                      const SizedBox(height: 11),
                      _buildMortarResult(),
                      const SizedBox(height: 11),
                      _buildPricePanel(),
                      const SizedBox(height: 11),
                      _buildTotalPanel(),
                    ],
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// مدل ملات
// =============================================================================

class MortarData {
  final String label;
  final double kgPerM3;

  const MortarData({
    required this.label,
    required this.kgPerM3,
  });
}
