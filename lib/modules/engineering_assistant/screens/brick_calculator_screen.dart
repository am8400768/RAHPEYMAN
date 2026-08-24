import 'package:flutter/material.dart';

import '../../estefsarieh/theme/estefsarieh_theme.dart';
import '../data/brick_repository.dart';

class BrickCalculatorScreen extends StatefulWidget {
  const BrickCalculatorScreen({super.key});

  @override
  State<BrickCalculatorScreen> createState() => _BrickCalculatorScreenState();
}

enum _BrickWorkType {
  facade,
  masonry,
}

class _BrickCalculatorScreenState extends State<BrickCalculatorScreen> {
  static const double _cementBagKg = 50;
  static const double _masonryMortarFactor = 0.30;
  static const double _facadeMortarThicknessM = 0.03;
  static const double _sandTonPerM3 = 1.85;

  static const List<_Mortar> _mortars = [
    _Mortar(
      label: 'ملات ماسه سیمان ۱:۳',
      cementKgM3: 360,
      cementPart: 1,
      sandPart: 3,
    ),
    _Mortar(
      label: 'ملات ماسه سیمان ۱:۴',
      cementKgM3: 285,
      cementPart: 1,
      sandPart: 4,
    ),
    _Mortar(
      label: 'ملات ماسه سیمان ۱:۵',
      cementKgM3: 225,
      cementPart: 1,
      sandPart: 5,
    ),
    _Mortar(
      label: 'ملات ماسه سیمان ۱:۶',
      cementKgM3: 200,
      cementPart: 1,
      sandPart: 6,
    ),
  ];

  final _areaController = TextEditingController();
  final _brickPriceController = TextEditingController();
  final _cementPriceController = TextEditingController();
  final _sandPriceController = TextEditingController();

  final _db = BrickDatabase.instance;

  _BrickWorkType _workType = _BrickWorkType.masonry;
  _Mortar _selectedMortar = _mortars[2];

  List<BrickFacade> _facadeBricks = const [];
  List<int> _wallThicknesses = const [];

  BrickFacade? _selectedFacade;
  int? _selectedThicknessCm;
  String _masonryBrick = 'لفتون';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _areaController,
      _brickPriceController,
      _cementPriceController,
      _sandPriceController,
    ]) {
      c.addListener(_recalculate);
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final facades = await _db.getFacadeBricks();
      final thicknesses = await _db.getWallThicknesses();

      if (!mounted) return;

      setState(() {
        _facadeBricks = facades;
        _wallThicknesses = thicknesses;
        _selectedFacade = facades.isNotEmpty ? facades.first : null;
        _selectedThicknessCm =
            thicknesses.isNotEmpty ? thicknesses.first : null;
        _loading = false;
      });

      if (_workType == _BrickWorkType.masonry) {
        await _loadWallRow();
      } else {
        _recalculate();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'خطا در خواندن اطلاعات آجر: $e',
            style: const TextStyle(fontFamily: 'Vazirmatn'),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _brickPriceController.dispose();
    _cementPriceController.dispose();
    _sandPriceController.dispose();
    super.dispose();
  }

  double _number(TextEditingController controller) {
    return double.tryParse(
          controller.text.trim().replaceAll(',', '.'),
        ) ??
        0;
  }

  double get _area => _number(_areaController);

  double get _bricksPerM2 {
    if (_workType == _BrickWorkType.facade) {
      return _selectedFacade?.defaultBricksPerSqMeter ?? 0;
    }

    if (_selectedThicknessCm == null) return 0;

    final row = _wallRow;

    if (row == null) return 0;

    switch (_masonryBrick) {
      case 'سفال':
        return row.sofaliCount.toDouble();
      case 'فشاری':
        return row.feshariCount.toDouble();
      default:
        return row.leftonCount.toDouble();
    }
  }

  BrickWallCount? _wallRow;
  double _bricksTotal = 0;
  double _mortarVolume = 0;
  double _cementKg = 0;
  double _cementBags = 0;
  double _sandTon = 0;
  double _totalCost = 0;

  Future<void> _loadWallRow() async {
    if (_selectedThicknessCm == null) {
      if (mounted) setState(() => _wallRow = null);
      return;
    }

    final row = await _db.getWallBrickCount(_selectedThicknessCm!);
    if (!mounted) return;

    setState(() {
      _wallRow = row;
      _recalculate();
    });
  }

  void _recalculate() {
    final bricksPerM2 = _bricksPerM2;
    _bricksTotal = _area > 0 ? bricksPerM2 * _area : 0;

    if (_area <= 0 || bricksPerM2 <= 0) {
      _mortarVolume = 0;
      _cementKg = 0;
      _cementBags = 0;
      _sandTon = 0;
      _totalCost = 0;
      if (mounted) setState(() {});
      return;
    }

    if (_workType == _BrickWorkType.masonry) {
      final wallThicknessM = (_selectedThicknessCm ?? 0) / 100;
      final masonryVolume = _area * wallThicknessM;
      _mortarVolume = masonryVolume * _masonryMortarFactor;
    } else {
      _mortarVolume = _area * _facadeMortarThicknessM;
    }

    _cementKg = _mortarVolume * _selectedMortar.cementKgM3 * 1.06;
    _cementBags = _cementKg / _cementBagKg;
    _sandTon = _mortarVolume * _sandTonPerM3;

    final brickPrice = _number(_brickPriceController);
    final cementPrice = _number(_cementPriceController);
    final sandPrice = _number(_sandPriceController);

    _totalCost = (_bricksTotal * brickPrice) +
        (_cementBags * cementPrice) +
        (_sandTon * sandPrice);

    if (mounted) setState(() {});
  }

  void _changeWorkType(_BrickWorkType value) {
    if (_workType == value) return;

    setState(() {
      _workType = value;
    });

    if (value == _BrickWorkType.masonry) {
      _loadWallRow();
    } else {
      _recalculate();
    }
  }

  String _formatNumber(double value, {int decimals = 0}) {
    if (!value.isFinite) return '—';

    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts.first;

    final formatted = integer.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m.group(1)},',
    );

    if (decimals == 0) return formatted;

    return '$formatted.${parts.length > 1 ? parts[1] : ''}';
  }

  String _fa(String value) {
    const en = '0123456789';
    const fa = '۰۱۲۳۴۵۶۷۸۹';

    var result = value;
    for (var i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], fa[i]);
    }
    return result;
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
            'آجر‌یار',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            tooltip: 'بازگشت',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(),
                          const SizedBox(height: 14),
                          _buildWorkTypePanel(),
                          const SizedBox(height: 14),
                          _buildBrickPanel(),
                          const SizedBox(height: 14),
                          _buildAreaPanel(),
                          const SizedBox(height: 14),
                          _buildMortarPanel(),
                          const SizedBox(height: 14),
                          _buildResultPanel(),
                          const SizedBox(height: 14),
                          _buildPricePanel(),
                          const SizedBox(height: 18),
                          _buildFooter(),
                        ]),
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
        border: Border.all(color: EstefsariehColors.borderSoft),
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
              Icons.grid_view_rounded,
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
                  'آجر‌یار',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb(FaNum)',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: EstefsariehColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'محاسبه تعداد آجر، ملات، سیمان، ماسه و هزینه دیوار',
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

  Widget _buildWorkTypePanel() {
    return _Panel(
      index: '۱',
      title: 'انتخاب نوع کار',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: EstefsariehColors.panel2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: EstefsariehColors.borderSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ModeButton(
                title: 'آجر نما',
                subtitle: 'محاسبه بر اساس سطح نما',
                active: _workType == _BrickWorkType.facade,
                onTap: () => _changeWorkType(_BrickWorkType.facade),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _ModeButton(
                title: 'آجرچینی',
                subtitle: 'محاسبه بر اساس ضخامت دیوار',
                active: _workType == _BrickWorkType.masonry,
                onTap: () => _changeWorkType(_BrickWorkType.masonry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrickPanel() {
    if (_workType == _BrickWorkType.facade) {
      return _Panel(
        index: '۲',
        title: 'انتخاب آجر نما',
        child: Column(
          children: [
            DropdownButtonFormField<BrickFacade>(
              value: _selectedFacade,
              isExpanded: true,
              decoration: _inputDecoration(label: 'نوع آجر نما'),
              items: _facadeBricks
                  .map(
                    (brick) => DropdownMenuItem<BrickFacade>(
                      value: brick,
                      child: Text(
                        '${brick.brickType} — ${brick.dimensions}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedFacade = value);
                _recalculate();
              },
            ),
            const SizedBox(height: 12),
            Text(
              'داده SQL: ${_selectedFacade?.bricksPerSqMeterText ?? '—'} در هر مترمربع',
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 10.5,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return _Panel(
      index: '۲',
      title: 'انتخاب آجرچینی',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _masonryBrick,
            decoration: _inputDecoration(label: 'نوع آجر'),
            items: const [
              DropdownMenuItem(
                value: 'لفتون',
                child: Text('آجر لفتون (۱۰ سوراخ)'),
              ),
              DropdownMenuItem(
                value: 'سفال',
                child: Text('آجر سفال'),
              ),
              DropdownMenuItem(
                value: 'فشاری',
                child: Text('آجر فشاری'),
              ),
            ],
            onChanged: (value) async {
              if (value == null) return;
              setState(() => _masonryBrick = value);
              await _loadWallRow();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _selectedThicknessCm,
            decoration: _inputDecoration(label: 'ضخامت دیوار'),
            items: _wallThicknesses
                .map(
                  (cm) => DropdownMenuItem<int>(
                    value: cm,
                    child: Text(
                      '${_fa(cm.toString())} سانتی‌متر',
                      style: const TextStyle(fontFamily: 'Vazirmatn'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              setState(() => _selectedThicknessCm = value);
              await _loadWallRow();
            },
          ),
          const SizedBox(height: 12),
          _buildInfoBox(
            'تعداد آجر در مترمربع',
            _bricksPerM2 <= 0 ? '—' : _fa(_formatNumber(_bricksPerM2)),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaPanel() {
    return _Panel(
      index: '۳',
      title: 'مساحت دیوار',
      child: TextField(
        controller: _areaController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: _inputDecoration(
          label: 'مساحت کل دیوار',
          suffixText: 'مترمربع',
        ),
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMortarPanel() {
    return _Panel(
      index: '۴',
      title: 'نسبت حجمی ملات',
      child: Column(
        children: [
          DropdownButtonFormField<_Mortar>(
            value: _selectedMortar,
            isExpanded: true,
            decoration: _inputDecoration(label: 'نوع ملات'),
            items: _mortars
                .map(
                  (mortar) => DropdownMenuItem<_Mortar>(
                    value: mortar,
                    child: Text(
                      '${mortar.label} — ${_fa(_formatNumber(mortar.cementKgM3))} kg/m³ سیمان',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedMortar = value);
              _recalculate();
            },
          ),
          const SizedBox(height: 12),
          _buildInfoBox(
            'نسبت حجمی',
            '۱ : ${_formatNumber(_selectedMortar.sandPart)}',
          ),
        ],
      ),
    );
  }

  Widget _buildResultPanel() {
    return _Panel(
      index: '۵',
      title: 'نتایج محاسبه',
      child: Column(
        children: [
          _buildResultCard(
            'تعداد آجر',
            _bricksTotal <= 0
                ? '—'
                : _fa(_formatNumber(_bricksTotal, decimals: 0)),
            'عدد',
          ),
          const SizedBox(height: 10),
          _buildResultCard(
            'حجم ملات',
            _mortarVolume <= 0
                ? '—'
                : _fa(_formatNumber(_mortarVolume, decimals: 3)),
            'مترمکعب',
          ),
          const SizedBox(height: 10),
          _buildResultCard(
            'سیمان',
            _cementKg <= 0 ? '—' : _fa(_formatNumber(_cementKg, decimals: 1)),
            'کیلوگرم',
            extra: _cementBags <= 0
                ? null
                : '≈ ${_fa(_formatNumber(_cementBags, decimals: 2))} کیسه ۵۰ کیلویی',
          ),
          const SizedBox(height: 10),
          _buildResultCard(
            'ماسه',
            _sandTon <= 0 ? '—' : _fa(_formatNumber(_sandTon, decimals: 3)),
            'تن',
          ),
        ],
      ),
    );
  }

  Widget _buildPricePanel() {
    final costPerM2 = _area > 0 ? (_totalCost / _area).toDouble() : 0.0;

    return _Panel(
      index: '۶',
      title: 'برآورد هزینه',
      child: Column(
        children: [
          TextField(
            controller: _brickPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: _inputDecoration(
              label: 'قیمت هر عدد آجر',
              suffixText: 'ریال / عدد',
            ),
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cementPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          const SizedBox(height: 12),
          TextField(
            controller: _sandPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: _inputDecoration(
              label: 'قیمت هر تن ماسه',
              suffixText: 'ریال / تن',
            ),
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildResultCard(
            'هزینه هر مترمربع',
            costPerM2 <= 0 ? '—' : _fa(_formatNumber(costPerM2)),
            'ریال',
          ),
          const SizedBox(height: 10),
          _buildResultCard(
            'هزینه کل دیوار',
            _totalCost <= 0 ? '—' : _fa(_formatNumber(_totalCost)),
            'ریال',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: EstefsariehColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: EstefsariehColors.accent.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 10.5,
              color: EstefsariehColors.textMuted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EstefsariehColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    String label,
    String value,
    String unit, {
    String? extra,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: EstefsariehColors.accent.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: EstefsariehColors.accent.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 11,
              color: EstefsariehColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
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
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: EstefsariehColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: EstefsariehColors.accent,
                ),
              ),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 6),
            Text(
              extra,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 10.5,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'تعداد آجرهای نما از داده‌های bricks.sql خوانده می‌شود و برای بازه‌هایی مانند ۳۷ تا ۴۰ عدد، مقدار بالاتر برای برآورد محافظه‌کارانه استفاده شده است.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 10.5,
          height: 1.8,
          color: EstefsariehColors.textMuted,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? label,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      suffixText: suffixText,
      labelStyle: const TextStyle(
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
        borderSide: const BorderSide(
          color: EstefsariehColors.borderSoft,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: EstefsariehColors.borderSoft,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: EstefsariehColors.accent,
          width: 1.3,
        ),
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EstefsariehColors.borderSoft),
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
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

class _Mortar {
  const _Mortar({
    required this.label,
    required this.cementKgM3,
    required this.cementPart,
    required this.sandPart,
  });

  final String label;
  final double cementKgM3;
  final double cementPart;
  final double sandPart;
}
