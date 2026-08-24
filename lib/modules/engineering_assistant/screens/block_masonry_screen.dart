import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// صفحه محاسبات «بلوک‌چینی»
///
/// ابزار مستقیم زیرمجموعه «مهندس‌یار».
///
/// امکانات:
/// - انتخاب نوع بلوک
/// - انتخاب طول بلوک
/// - انتخاب ضریب اتلاف بلوک: ۰، ۵ یا ۱۰ درصد
/// - محاسبه تعداد بلوک
/// - محاسبه حجم بنایی
/// - محاسبه ملات بندکشی
/// - محاسبه ماسه
/// - محاسبه سیمان بدون اعمال پرت
/// - محاسبه تعداد کیسه سیمان
/// - محاسبه هزینه مصالح
/// - محاسبه قیمت هر مترمربع
/// - محاسبه جمع کل
/// - جداکننده خودکار هزارگان
class BlockMasonryScreen extends StatefulWidget {
  const BlockMasonryScreen({super.key});

  @override
  State<BlockMasonryScreen> createState() => _BlockMasonryScreenState();
}

class _BlockMasonryScreenState extends State<BlockMasonryScreen> {
  // ===========================================================================
  // رنگ اختصاصی بلوک‌چینی
  // ===========================================================================

  static const Color blockColor = Color(0xFF8C7FC9);

  static const Color blockDim = Color(0x268C7FC9);

  // ===========================================================================
  // رنگ‌های مشترک رهپیمان
  // ===========================================================================

  static const Color textDark = Color(0xFF1A237E);

  static const Color backgroundColor = Color(0xFFF5F7FA);

  static const Color borderColor = Color(0xFFE1E6ED);

  static const Color textMuted = Color(0xFF65748B);

  static const Color sandColor = Color(0xFF7FA6C9);

  static const Color cementColor = Color(0xFF7D8793);

  static const Color successColor = Color(0xFF2E7D32);

  // ===========================================================================
  // ثابت‌ها
  // ===========================================================================

  static const double bagKg = 50.0;

  /// حجم ملات بندکشی برابر ۱۰٪ حجم بنایی
  static const double blockMortarPercent = 0.10;

  /// مقدار ماسه به ازای هر مترمکعب ملات
  static const double sandTonPerM3Mortar = 1.85;

  // ===========================================================================
  // انواع بلوک
  // ===========================================================================

  static const List<BlockType> blockTypes = [
    BlockType(
      value: 'light10',
      title: 'بلوک سبک ۱۰',
      description: 'تیغه داخلی',
      thickness: 0.10,
    ),
    BlockType(
      value: 'light15',
      title: 'بلوک سبک ۱۵',
      description: 'دیوار داخلی',
      thickness: 0.15,
    ),
    BlockType(
      value: 'light20',
      title: 'بلوک سبک ۲۰',
      description: 'دیوار پیرامونی',
      thickness: 0.20,
    ),
    BlockType(
      value: 'heavy20',
      title: 'بلوک سنگین ۲۰',
      description: 'دیوار محوطه / باغ',
      thickness: 0.20,
    ),
  ];

  // ===========================================================================
  // ملات‌ها
  // ===========================================================================

  static const List<MortarData> mortars = [
    MortarData(
      label: 'ماسه سیمان ۱:۳ (سازه‌ای/پرمصرف)',
      kgPerM3: 360,
    ),
    MortarData(
      label: 'ماسه سیمان ۱:۴',
      kgPerM3: 285,
    ),
    MortarData(
      label: 'ماسه سیمان ۱:۵ (متداول)',
      kgPerM3: 225,
    ),
    MortarData(
      label: 'ماسه سیمان ۱:۶ (بنایی سبک)',
      kgPerM3: 200,
    ),
    MortarData(
      label: 'ماسه بادی و سیمان ۱:۴',
      kgPerM3: 285,
    ),
    MortarData(
      label: 'باتاره سیمان:آهک:ماسه ۱:۲:۹',
      kgPerM3: 130,
    ),
  ];

  // ===========================================================================
  // کنترلرها
  // ===========================================================================

  final TextEditingController areaController = TextEditingController();

  final TextEditingController blockPriceController = TextEditingController();

  final TextEditingController cementPriceController = TextEditingController();

  final TextEditingController sandPriceController = TextEditingController();

  final FocusNode areaFocus = FocusNode();

  final FocusNode blockPriceFocus = FocusNode();

  final FocusNode cementPriceFocus = FocusNode();

  final FocusNode sandPriceFocus = FocusNode();

  // ===========================================================================
  // وضعیت انتخاب‌ها
  // ===========================================================================

  String selectedBlockType = 'light20';

  double selectedBlockLength = 40;

  /// ضریب اتلاف بلوک:
  /// ۰٪ = 0.00
  /// ۵٪ = 0.05
  /// ۱۰٪ = 0.10
  double selectedWaste = 0.0;

  int selectedMortarIndex = 2;

  // ===========================================================================
  // نتایج
  // ===========================================================================

  int? blockCount;

  double? masonryVolume;

  double? mortarVolume;

  double? sandTon;

  double? cementKg;

  double? cementBags;

  double? blockCost;

  double? cementCost;

  double? sandCost;

  double? totalCost;

  double? unitCost;

  @override
  void initState() {
    super.initState();

    areaController.addListener(_recalculate);
    blockPriceController.addListener(_recalculate);
    cementPriceController.addListener(_recalculate);
    sandPriceController.addListener(_recalculate);
  }

  @override
  void dispose() {
    areaController.dispose();
    blockPriceController.dispose();
    cementPriceController.dispose();
    sandPriceController.dispose();

    areaFocus.dispose();
    blockPriceFocus.dispose();
    cementPriceFocus.dispose();
    sandPriceFocus.dispose();

    super.dispose();
  }

  // ===========================================================================
  // تبدیل متن به عدد
  // ===========================================================================

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

  // ===========================================================================
  // فرمت عدد با جداکننده هزارگان
  // ===========================================================================

  String _formatNumber(
    double? value, {
    int decimals = 2,
    bool trimZeros = true,
  }) {
    if (value == null || value.isNaN || value.isInfinite) {
      return '—';
    }

    String fixed = value.toStringAsFixed(decimals);

    if (trimZeros && fixed.contains('.')) {
      fixed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    final parts = fixed.split('.');

    String integerPart = parts[0];

    final String decimalPart = parts.length > 1 ? parts[1] : '';

    final bool negative = integerPart.startsWith('-');

    if (negative) {
      integerPart = integerPart.substring(1);
    }

    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(integerPart[i]);
    }

    final result = '${negative ? '-' : ''}${buffer.toString()}';

    if (decimalPart.isEmpty) {
      return result;
    }

    return '$result.$decimalPart';
  }

  // ===========================================================================
  // فرمت قیمت هنگام ورود
  // ===========================================================================

  void _formatPriceController(
    TextEditingController controller,
  ) {
    final raw = controller.text;

    if (raw.isEmpty) {
      return;
    }

    final cleaned = raw.replaceAll(',', '').replaceAll('٬', '');

    final parts = cleaned.split('.');

    final integerPart = parts.first.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

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

  String _formatIntegerString(
    String value,
  ) {
    if (value.isEmpty) {
      return '';
    }

    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(value[i]);
    }

    return buffer.toString();
  }

  // ===========================================================================
  // محاسبات
  // ===========================================================================

  void _recalculate() {
    final area = _parseNumber(areaController.text);

    if (area == null || area <= 0) {
      setState(() {
        blockCount = null;
        masonryVolume = null;
        mortarVolume = null;
        sandTon = null;
        cementKg = null;
        cementBags = null;

        blockCost = null;
        cementCost = null;
        sandCost = null;
        totalCost = null;
        unitCost = null;
      });

      return;
    }

    // -------------------------------------------------------------------------
    // مشخصات بلوک
    // -------------------------------------------------------------------------

    final double faceArea = (selectedBlockLength / 100.0) * 0.20;

    // تعداد بلوک در هر مترمربع
    //
    // ضریب اتلاف کاملاً انتخابی کاربر است:
    // ۰٪ = بدون پرت
    // ۵٪ = پنج درصد
    // ۱۰٪ = ده درصد
    final double blocksPerM2 = (1.0 / faceArea) * (1.0 + selectedWaste);

    final int calculatedBlockCount = (blocksPerM2 * area).ceil();

    // -------------------------------------------------------------------------
    // ضخامت بنایی
    // -------------------------------------------------------------------------

    final BlockType block = blockTypes.firstWhere(
      (item) => item.value == selectedBlockType,
    );

    final double calculatedMasonryVolume = area * block.thickness;

    // -------------------------------------------------------------------------
    // ملات بندکشی
    //
    // حجم ملات بندکشی = ۱۰٪ حجم بنایی
    // -------------------------------------------------------------------------

    final double calculatedMortarVolume =
        calculatedMasonryVolume * blockMortarPercent;

    // -------------------------------------------------------------------------
    // ماسه
    // -------------------------------------------------------------------------

    final double calculatedSandTon =
        calculatedMortarVolume * sandTonPerM3Mortar;

    // -------------------------------------------------------------------------
    // سیمان
    //
    // نکته:
    // هیچ ضریب پرت یا Waste برای سیمان اعمال نمی‌شود.
    // -------------------------------------------------------------------------

    final MortarData mortar = mortars[selectedMortarIndex];

    final double calculatedCementKg = calculatedMortarVolume * mortar.kgPerM3;

    final double calculatedCementBags = calculatedCementKg / bagKg;

    // -------------------------------------------------------------------------
    // قیمت‌ها
    // -------------------------------------------------------------------------

    final double blockPrice = _parseNumber(
          blockPriceController.text,
        ) ??
        0;

    final double cementPrice = _parseNumber(
          cementPriceController.text,
        ) ??
        0;

    final double sandPrice = _parseNumber(
          sandPriceController.text,
        ) ??
        0;

    final double calculatedBlockCost = calculatedBlockCount * blockPrice;

    final double calculatedCementCost = calculatedCementBags * cementPrice;

    final double calculatedSandCost = calculatedSandTon * sandPrice;

    final double calculatedTotalCost =
        calculatedBlockCost + calculatedCementCost + calculatedSandCost;

    final double calculatedUnitCost = calculatedTotalCost / area;

    setState(() {
      blockCount = calculatedBlockCount;

      masonryVolume = calculatedMasonryVolume;

      mortarVolume = calculatedMortarVolume;

      sandTon = calculatedSandTon;

      cementKg = calculatedCementKg;

      cementBags = calculatedCementBags;

      blockCost = calculatedBlockCost;

      cementCost = calculatedCementCost;

      sandCost = calculatedSandCost;

      totalCost = calculatedTotalCost;

      unitCost = calculatedUnitCost;
    });
  }

  // ===========================================================================
  // Header
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
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
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBlockIcon(),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بلوک‌چینی',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'تعداد بلوک، ملات و هزینه',
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

  Widget _buildBlockIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: blockDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: blockColor.withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(
        Icons.view_module_rounded,
        color: blockColor,
        size: 24,
      ),
    );
  }

  // ===========================================================================
  // عنوان پنل
  // ===========================================================================

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
            color: blockDim,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            index,
            style: const TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: blockColor,
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

  // ===========================================================================
  // پنل
  // ===========================================================================

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
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ===========================================================================
  // برچسب فیلد
  // ===========================================================================

  Widget _fieldLabel(
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
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

  // ===========================================================================
  // نوع بلوک
  // ===========================================================================

  Widget _buildBlockTypeDropdown() {
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
        child: DropdownButton<String>(
          value: selectedBlockType,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textMuted,
          ),
          style: const TextStyle(
            fontFamily: 'IRANSansWeb',
            fontSize: 12.5,
            color: textDark,
          ),
          items: blockTypes.map(
            (block) {
              return DropdownMenuItem<String>(
                value: block.value,
                child: Text(
                  '${block.title} (${block.description})',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedBlockType = value;
            });

            _recalculate();
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // طول بلوک
  // ===========================================================================

  Widget _buildLengthDropdown() {
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
        child: DropdownButton<double>(
          value: selectedBlockLength,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textMuted,
          ),
          style: const TextStyle(
            fontFamily: 'IRANSansWeb(FaNum)',
            fontSize: 13,
            color: textDark,
          ),
          items: const [
            DropdownMenuItem(
              value: 40,
              child: Text('۴۰ سانتی‌متر'),
            ),
            DropdownMenuItem(
              value: 50,
              child: Text('۵۰ سانتی‌متر'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedBlockLength = value;
            });

            _recalculate();
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // ضریب اتلاف بلوک
  // ===========================================================================

  Widget _buildWasteDropdown() {
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
        child: DropdownButton<double>(
          value: selectedWaste,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textMuted,
          ),
          style: const TextStyle(
            fontFamily: 'IRANSansWeb(FaNum)',
            fontSize: 13,
            color: textDark,
          ),
          items: const [
            DropdownMenuItem(
              value: 0.0,
              child: Text('۰٪'),
            ),
            DropdownMenuItem(
              value: 0.05,
              child: Text('۵٪'),
            ),
            DropdownMenuItem(
              value: 0.10,
              child: Text('۱۰٪'),
            ),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              selectedWaste = value;
            });

            _recalculate();
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // ملات
  // ===========================================================================

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
            fontSize: 11.5,
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
            if (value == null) {
              return;
            }

            setState(() {
              selectedMortarIndex = value;
            });

            _recalculate();
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // فیلد عددی
  // ===========================================================================

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
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: focusNode.hasFocus
                  ? blockColor.withValues(
                      alpha: 0.7,
                    )
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
                      RegExp(
                        r'[0-9.,]',
                      ),
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
                      color: Color(
                        0xFF9AA5B4,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (price) {
                      _formatPriceController(
                        controller,
                      );
                    }

                    _recalculate();
                  },
                ),
              ),
              Container(
                height: 27,
                width: 1,
                color: borderColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
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

  // ===========================================================================
  // نتیجه تعداد بلوک
  // ===========================================================================

  Widget _buildBlockResult() {
    if (blockCount == null) {
      return const SizedBox.shrink();
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelLabel(
            '◆',
            'تعداد بلوک مورد نیاز',
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: blockDim,
              borderRadius: BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: blockColor.withValues(
                  alpha: 0.18,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعداد',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 10,
                    color: textMuted,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                _resultValue(
                  _formatNumber(
                    blockCount!.toDouble(),
                    decimals: 0,
                  ),
                  'عدد',
                  color: blockColor,
                  fontSize: 23,
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          _formulaBox(
            'تعداد = مساحت × [۱ ÷ (طول بلوک × ۰٫۲۰)] × (۱ + ضریب اتلاف انتخابی)',
          ),
          const SizedBox(height: 6),
          _formulaBox(
            'ضریب اتلاف انتخاب‌شده: ${_formatWaste()}',
          ),
        ],
      ),
    );
  }

  String _formatWaste() {
    if (selectedWaste == 0.0) {
      return '۰٪';
    }

    if (selectedWaste == 0.05) {
      return '۵٪';
    }

    return '۱۰٪';
  }

  // ===========================================================================
  // ملات
  // ===========================================================================

  Widget _buildMortarResult() {
    if (blockCount == null) {
      return const SizedBox.shrink();
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelLabel(
            '۲',
            'نسبت حجمی ملات بندکشی',
          ),
          const SizedBox(height: 13),
          _fieldLabel(
            'نوع ملات',
          ),
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
              const SizedBox(
                width: 10,
              ),
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
          SizedBox(height: 9),
          _formulaBox(
            'حجم ملات بندکشی = ۱۰٪ حجم بنایی؛ بدون اعمال پرت سیمان.',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // کارت آماری
  // ===========================================================================

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

  // ===========================================================================
  // قیمت
  // ===========================================================================

  Widget _buildPricePanel() {
    if (blockCount == null) {
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
            controller: blockPriceController,
            focusNode: blockPriceFocus,
            label: 'قیمت هر عدد بلوک',
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

  // ===========================================================================
  // هزینه تمام شده
  // ===========================================================================

  Widget _buildTotalPanel() {
    if (blockCount == null) {
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
                  label: 'قیمت هر مترمربع دیوار',
                  value: _formatNumber(
                    unitCost,
                    decimals: 0,
                  ),
                  accent: blockColor,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
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
          color: accent.withValues(
            alpha: 0.15,
          ),
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

  // ===========================================================================
  // تفکیک هزینه
  // ===========================================================================

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
            'بلوک',
            _formatNumber(
              blockCount?.toDouble(),
              decimals: 0,
            ),
            'عدد',
            blockCost,
          ),
          Divider(
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
          Divider(
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

  // ===========================================================================
  // Readout
  // ===========================================================================

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

  // ===========================================================================
  // فرمول
  // ===========================================================================

  Widget _formulaBox(
    String text,
  ) {
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

  // ===========================================================================
  // مقدار نتیجه
  // ===========================================================================

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

  // ===========================================================================
  // Footer
  // ===========================================================================

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        24,
      ),
      child: Column(
        children: [
          Divider(
            color: borderColor,
          ),
          SizedBox(height: 9),
          Text(
            'رهپیمان — همراه مهندسین از آموزش تا اجرا',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IRANSansWeb',
              fontSize: 10,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
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
                    // =========================================================
                    // مشخصات دیوار
                    // =========================================================

                    _panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPanelLabel(
                            '۱',
                            'مشخصات دیوار بلوکی',
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          _fieldLabel(
                            'نوع بلوک',
                          ),
                          _buildBlockTypeDropdown(),
                          const SizedBox(
                            height: 12,
                          ),
                          _fieldLabel(
                            'طول بلوک',
                          ),
                          _buildLengthDropdown(),
                          const SizedBox(
                            height: 12,
                          ),
                          _fieldLabel(
                            'ضریب اتلاف بلوک',
                          ),
                          _buildWasteDropdown(),
                          const SizedBox(
                            height: 12,
                          ),
                          _buildNumberField(
                            controller: areaController,
                            focusNode: areaFocus,
                            label: 'مساحت دیوار (مترمربع)',
                            suffix: 'm²',
                            decimal: true,
                          ),
                        ],
                      ),
                    ),

                    // =========================================================
                    // نتایج
                    // =========================================================

                    if (blockCount != null) ...[
                      const SizedBox(
                        height: 11,
                      ),
                      _buildBlockResult(),
                      const SizedBox(
                        height: 11,
                      ),
                      _buildMortarResult(),
                      const SizedBox(
                        height: 11,
                      ),
                      _buildPricePanel(),
                      const SizedBox(
                        height: 11,
                      ),
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
// مدل نوع بلوک
// =============================================================================

class BlockType {
  final String value;
  final String title;
  final String description;
  final double thickness;

  const BlockType({
    required this.value,
    required this.title,
    required this.description,
    required this.thickness,
  });
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
