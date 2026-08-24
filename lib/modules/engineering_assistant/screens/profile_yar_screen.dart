// profile_yar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/profile_data.dart';
import 'profile_shape_painter.dart';

class ProfileYarColors {
  static const bgBase = Color(0xFF080E17);
  static const bgPanel = Color(0xFF0E1D2F);
  static const bgPanel2 = Color(0xFF122740);
  static const bgPanel3 = Color(0xFF0A1826);
  static const border = Color(0x269AC2E0);
  static const borderSoft = Color(0x159AC2E0);
  static const textPrimary = Color(0xFFEEF5FA);
  static const textMuted = Color(0xFF84A2B8);
  static const textDim = Color(0xFF4F6579);
  static const textFaint = Color(0xFF374A5C);
  static const steel = Color(0xFFFF7A45);
  static const steelDim = Color(0x22FF7A45);
  static const gold = Color(0xFFEFBE5C);
  static const goldDim = Color(0x23EFBE5C);
}

class ProfileTypeMeta {
  final String name;
  final List<String> dims;
  const ProfileTypeMeta(this.name, this.dims);
}

const Map<String, ProfileTypeMeta> profileMeta = {
  'IPE': ProfileTypeMeta('تیرآهن IPE (نیم‌پهن)', ['h', 'b', 't', 'tg']),
  'IPB': ProfileTypeMeta('تیرآهن IPB (عریض)', ['h', 'b', 't', 'tg']),
  'INP': ProfileTypeMeta('تیرآهن INP (باریک)', ['h', 'b', 't', 'tg']),
  'UNP': ProfileTypeMeta('ناودانی UNP', ['h', 'b', 't', 'tg']),
  'L': ProfileTypeMeta('نبشی L (بال مساوی)', ['a', 't']),
  'T': ProfileTypeMeta('سپری T', ['a', 't']),
  'REBAR': ProfileTypeMeta('میلگرد', ['d']),
  'BOX': ProfileTypeMeta('قوطی چهارگوش', ['h', 'b', 's']),
};

const Map<String, String> dimLabels = {
  'h': 'h — ارتفاع',
  'b': 'b — عرض بال',
  't': 's — ضخامت جان',
  'tg': 'tg — ضخامت بال',
  'a': 'a — طول بال',
  'd': 'قطر اسمی',
  's': 's — ضخامت دیواره',
};

enum CalcMode { weightToLength, lengthToWeight }

class ProfileYarScreen extends StatefulWidget {
  const ProfileYarScreen({super.key});
  @override
  State<ProfileYarScreen> createState() => _ProfileYarScreenState();
}

class _ProfileYarScreenState extends State<ProfileYarScreen> {
  String _selectedType = 'IPE';
  int _selectedSizeIndex = 0;
  CalcMode _calcMode = CalcMode.weightToLength;
  final _calcController = TextEditingController();
  final _priceController = TextEditingController();
  double? _currentWeightPerMeter, _currentTotalWeightKg, _lastResult;

  List<Map<String, dynamic>> get _sizes => profileData[_selectedType]!;
  Map<String, dynamic> get _selectedItem => _sizes[_selectedSizeIndex];

  @override
  void initState() {
    super.initState();
    _syncWeight();
    _calcController.addListener(_runCalc);
    _priceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _calcController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _syncWeight() {
    _currentWeightPerMeter = (_selectedItem['w'] as num).toDouble();
    _runCalc();
  }

  void _runCalc() {
    final val = double.tryParse(_calcController.text);
    final w = _currentWeightPerMeter;
    if (w == null || w == 0 || val == null || val <= 0) {
      setState(() => _currentTotalWeightKg = null);
      return;
    }
    if (_calcMode == CalcMode.weightToLength) {
      _lastResult = val / w;
      _currentTotalWeightKg = val;
    } else {
      _lastResult = val * w;
      _currentTotalWeightKg = _lastResult;
    }
    setState(() {});
  }

  String _fmt(num? n, {int decimals = 2}) {
    if (n == null) return '—';
    return n.toStringAsFixed(decimals).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _sizeLabel(Map<String, dynamic> item) {
    if (_selectedType == 'REBAR') return 'Ø${_fmt(item['d'])} mm';
    final dims = profileMeta[_selectedType]!.dims;
    return '$_selectedType ' + dims.map((d) => _fmt(item[d])).join('×');
  }

  @override
  Widget build(BuildContext context) {
    final meta = profileMeta[_selectedType]!;
    final priceVal = double.tryParse(_priceController.text);
    final totalPrice = (_currentTotalWeightKg != null && priceVal != null)
        ? _currentTotalWeightKg! * priceVal
        : null;

    return Scaffold(
      backgroundColor: ProfileYarColors.bgBase,
      appBar: AppBar(
          backgroundColor: ProfileYarColors.bgBase,
          elevation: 0,
          title: const Text('پروفیل‌یار',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPanel(
                index: '۱',
                title: 'انتخاب مقطع',
                child: Column(children: [
                  _dropdown(
                      'نوع پروفیل',
                      _selectedType,
                      profileMeta.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value.name)))
                          .toList(),
                      (v) => setState(() {
                            _selectedType = v!;
                            _selectedSizeIndex = 0;
                            _syncWeight();
                          })),
                  const SizedBox(height: 12),
                  _dropdown(
                      'سایز',
                      _selectedSizeIndex,
                      List.generate(
                          _sizes.length,
                          (i) => DropdownMenuItem(
                              value: i, child: Text(_sizeLabel(_sizes[i])))),
                      (v) => setState(() {
                            _selectedSizeIndex = v!;
                            _syncWeight();
                          })),
                ])),
            _buildPanel(
                index: '۲',
                title: 'مشخصات فنی',
                child: Column(children: [
                  ProfileShapeCard(
                      type: _selectedType,
                      item: _selectedItem,
                      accent: ProfileYarColors.steel),
                  const SizedBox(height: 12),
                  GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.5,
                      children: [
                        ...meta.dims.map((d) => _statTile(
                            dimLabels[d]!, _fmt(_selectedItem[d]), 'mm')),
                        _statTile('وزن واحد',
                            _fmt(_selectedItem['w'], decimals: 3), 'kg/m',
                            hero: true),
                      ]),
                ])),
            _buildPanel(
                index: '۳',
                title: 'محاسبه‌گر',
                child: Column(children: [
                  _segmentedToggle(),
                  const SizedBox(height: 12),
                  _numberField(
                      _calcController,
                      _calcMode == CalcMode.weightToLength ? 'kg' : 'm',
                      'مقدار را وارد کنید'),
                  _resultReadout(
                      'نتیجه',
                      _fmt(_lastResult),
                      _calcMode == CalcMode.weightToLength ? 'm' : 'kg',
                      ProfileYarColors.steel),
                ])),
            _buildPanel(
                index: '۴',
                title: 'قیمت',
                child: Column(children: [
                  _numberField(_priceController, 'ریال/kg', 'قیمت هر کیلوگرم'),
                  _resultReadout(
                      'قیمت کل',
                      totalPrice != null ? _formatRial(totalPrice) : '—',
                      'ریال',
                      ProfileYarColors.gold),
                ])),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(
          {required String index,
          required String title,
          required Widget child}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: ProfileYarColors.bgPanel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ProfileYarColors.borderSoft)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ProfileYarColors.steel,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(index,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    color: ProfileYarColors.textMuted, fontSize: 13)),
          ]),
          const SizedBox(height: 16),
          child,
        ]),
      );

  Widget _dropdown(String label, dynamic value,
          List<DropdownMenuItem<dynamic>> items, Function(dynamic) onChanged) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: ProfileYarColors.textMuted, fontSize: 12)),
        DropdownButtonFormField(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: ProfileYarColors.bgPanel2,
            decoration: InputDecoration(
                filled: true,
                fillColor: ProfileYarColors.bgPanel3,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)))),
      ]);

  Widget _statTile(String label, String value, String unit,
          {bool hero = false}) =>
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: hero ? ProfileYarColors.steelDim : ProfileYarColors.bgPanel3,
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: ProfileYarColors.textDim, fontSize: 10)),
          Text('$value $unit',
              style: TextStyle(
                  color: hero
                      ? ProfileYarColors.steel
                      : ProfileYarColors.textPrimary,
                  fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _segmentedToggle() => Row(children: [
        _segBtn('وزن → متر', CalcMode.weightToLength),
        const SizedBox(width: 8),
        _segBtn('متر → وزن', CalcMode.lengthToWeight),
      ]);

  Widget _segBtn(String label, CalcMode mode) {
    final active = _calcMode == mode;
    return Expanded(
        child: InkWell(
            onTap: () => setState(() {
                  _calcMode = mode;
                  _calcController.clear();
                  _lastResult = null;
                }),
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color:
                        active ? ProfileYarColors.steelDim : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: active
                            ? ProfileYarColors.steel
                            : ProfileYarColors.borderSoft)),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: active
                            ? ProfileYarColors.steel
                            : ProfileYarColors.textMuted)))));
  }

  Widget _numberField(TextEditingController ctrl, String suffix, String hint) =>
      TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              filled: true,
              fillColor: ProfileYarColors.bgPanel3,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))));

  Widget _resultReadout(String label, String val, String unit, Color color) =>
      Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: ProfileYarColors.bgPanel3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Column(children: [
            Text(label,
                style: const TextStyle(
                    color: ProfileYarColors.textMuted, fontSize: 12)),
            Text('$val $unit',
                style: TextStyle(
                    color: ProfileYarColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ]));

  String _formatRial(double v) => v.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
