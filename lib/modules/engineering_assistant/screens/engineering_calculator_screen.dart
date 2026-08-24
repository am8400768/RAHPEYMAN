import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../estefsarieh/theme/estefsarieh_theme.dart';
import '../services/engineering_calculator_service.dart';

class EngineeringCalculatorScreen extends StatefulWidget {
  const EngineeringCalculatorScreen({super.key});

  @override
  State<EngineeringCalculatorScreen> createState() =>
      _EngineeringCalculatorScreenState();
}

class _EngineeringCalculatorScreenState
    extends State<EngineeringCalculatorScreen> {
  final EngineeringCalculatorService _calculator =
      EngineeringCalculatorService();

  String _expression = '';
  CalculatorAngleMode _angleMode = CalculatorAngleMode.degrees;
  bool _shiftOn = false;
  double _memory = 0;
  double _lastAnswer = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  double? get _liveValue => _calculator.evaluate(_expression, _angleMode);

  String get _liveDisplay {
    if (_expression.isEmpty) {
      return '0';
    }

    return _calculator.format(_liveValue);
  }

  String get _displayExpression {
    return _expression
        .replaceAll('cbrt(', '∛(')
        .replaceAll('sqrt(', '√(')
        .replaceAll('asin(', 'sin⁻¹(')
        .replaceAll('acos(', 'cos⁻¹(')
        .replaceAll('atan(', 'tan⁻¹(')
        .replaceAll('acot(', 'cot⁻¹(');
  }

  String get _angleLabel =>
      _angleMode == CalculatorAngleMode.degrees ? 'DEG' : 'RAD';

  void _insert(String value) {
    setState(() {
      _expression += value;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
    });
  }

  void _delete() {
    if (_expression.isEmpty) {
      return;
    }

    setState(() {
      _expression = _expression.substring(0, _expression.length - 1);
    });
  }

  void _toggleShift() {
    setState(() {
      _shiftOn = !_shiftOn;
    });
  }

  void _toggleAngle() {
    setState(() {
      _angleMode = _angleMode == CalculatorAngleMode.degrees
          ? CalculatorAngleMode.radians
          : CalculatorAngleMode.degrees;
    });
  }

  void _memoryClear() {
    setState(() {
      _memory = 0;
    });
  }

  void _memoryRecall() {
    _insert(_formatRaw(_memory));
  }

  void _memoryAdd() {
    final value = _liveValue;
    if (value == null) {
      return;
    }

    setState(() {
      _memory += value;
    });
  }

  void _memorySubtract() {
    final value = _liveValue;
    if (value == null) {
      return;
    }

    setState(() {
      _memory -= value;
    });
  }

  void _answer() {
    setState(() {
      _expression += _formatRaw(_lastAnswer);
    });
  }

  void _calculate() {
    final value = _liveValue;
    if (value == null) {
      return;
    }

    setState(() {
      _lastAnswer = value;
      _expression = _formatRaw(value);
      _shiftOn = false;
    });
  }

  void _reciprocal() {
    setState(() {
      if (_expression.isEmpty) {
        _expression = '1/(';
      } else {
        _expression = '1/($_expression)';
      }
    });
  }

  void _factorial() {
    _insert('!');
  }

  void _functionPressed(String function) {
    var effectiveFunction = function;

    if (_shiftOn) {
      switch (function) {
        case 'sin':
          effectiveFunction = 'asin';
          break;
        case 'cos':
          effectiveFunction = 'acos';
          break;
        case 'tan':
          effectiveFunction = 'atan';
          break;
        case 'cot':
          effectiveFunction = 'acot';
          break;
        case 'sqrt':
          effectiveFunction = 'cbrt';
          break;
        case 'log':
          _insert('10^(');
          setState(() {
            _shiftOn = false;
          });
          return;
        case 'ln':
          _insert('e^(');
          setState(() {
            _shiftOn = false;
          });
          return;
        case 'sq':
          _insert('^3');
          setState(() {
            _shiftOn = false;
          });
          return;
      }
    }

    switch (effectiveFunction) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'cot':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'acot':
      case 'log':
      case 'ln':
      case 'sqrt':
      case 'cbrt':
        _insert('$effectiveFunction(');
        break;
      case 'sq':
        _insert('^2');
        break;
    }

    if (_shiftOn) {
      setState(() {
        _shiftOn = false;
      });
    }
  }

  String _formatRaw(double value) {
    final formatted = _calculator.format(value);
    if (formatted == '—') {
      return '0';
    }
    return formatted;
  }

  List<_CalculatorKey> get _keys => <_CalculatorKey>[
        const _CalculatorKey('MC', _CalculatorKeyType.memoryClear),
        const _CalculatorKey('MR', _CalculatorKeyType.memoryRecall),
        const _CalculatorKey('M+', _CalculatorKeyType.memoryAdd),
        const _CalculatorKey('M-', _CalculatorKeyType.memorySubtract),
        const _CalculatorKey('AC', _CalculatorKeyType.clear),
        const _CalculatorKey('2nd', _CalculatorKeyType.shift),
        const _CalculatorKey('DEG', _CalculatorKeyType.angle),
        const _CalculatorKey('(', _CalculatorKeyType.insert, '('),
        const _CalculatorKey(')', _CalculatorKeyType.insert, ')'),
        const _CalculatorKey('DEL', _CalculatorKeyType.delete),
        const _CalculatorKey('sin', _CalculatorKeyType.function, 'sin'),
        const _CalculatorKey('cos', _CalculatorKeyType.function, 'cos'),
        const _CalculatorKey('tan', _CalculatorKeyType.function, 'tan'),
        const _CalculatorKey('cot', _CalculatorKeyType.function, 'cot'),
        const _CalculatorKey('log', _CalculatorKeyType.function, 'log'),
        const _CalculatorKey('ln', _CalculatorKeyType.function, 'ln'),
        const _CalculatorKey('x²', _CalculatorKeyType.function, 'sq'),
        const _CalculatorKey('√', _CalculatorKeyType.function, 'sqrt'),
        const _CalculatorKey('x!', _CalculatorKeyType.factorial),
        const _CalculatorKey('1/x', _CalculatorKeyType.reciprocal),
        const _CalculatorKey('7', _CalculatorKeyType.insert, '7'),
        const _CalculatorKey('8', _CalculatorKeyType.insert, '8'),
        const _CalculatorKey('9', _CalculatorKeyType.insert, '9'),
        const _CalculatorKey('×', _CalculatorKeyType.insert, '×'),
        const _CalculatorKey('÷', _CalculatorKeyType.insert, '÷'),
        const _CalculatorKey('4', _CalculatorKeyType.insert, '4'),
        const _CalculatorKey('5', _CalculatorKeyType.insert, '5'),
        const _CalculatorKey('6', _CalculatorKeyType.insert, '6'),
        const _CalculatorKey('+', _CalculatorKeyType.insert, '+'),
        const _CalculatorKey('−', _CalculatorKeyType.insert, '−'),
        const _CalculatorKey('1', _CalculatorKeyType.insert, '1'),
        const _CalculatorKey('2', _CalculatorKeyType.insert, '2'),
        const _CalculatorKey('3', _CalculatorKeyType.insert, '3'),
        const _CalculatorKey('π', _CalculatorKeyType.insert, 'π'),
        const _CalculatorKey('e', _CalculatorKeyType.insert, 'e'),
        const _CalculatorKey('0', _CalculatorKeyType.insert, '0'),
        const _CalculatorKey('.', _CalculatorKeyType.insert, '.'),
        const _CalculatorKey('×10ⁿ', _CalculatorKeyType.insert, '×10^'),
        const _CalculatorKey('Ans', _CalculatorKeyType.answer),
        const _CalculatorKey('=', _CalculatorKeyType.equals),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstefsariehColors.bgBase,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                10,
                compact ? 6 : 10,
                10,
                compact ? 6 : 10,
              ),
              child: Column(
                children: [
                  _buildTopBar(),
                  SizedBox(height: compact ? 7 : 9),
                  _buildDisplayCard(),
                  SizedBox(height: compact ? 7 : 9),
                  Expanded(child: _buildKeypadCard()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          IconButton(
            tooltip: 'بازگشت',
            onPressed: () => Navigator.of(context).pop(),
            color: EstefsariehColors.primary,
            splashRadius: 22,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Text(
              'ماشین‌حساب مهندسی',
              style: TextStyle(
                fontFamily: 'IRANSansWeb(FaNum)',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: EstefsariehColors.textPrimary,
              ),
            ),
          ),
          _StatusChip(label: _angleLabel, active: true),
          const SizedBox(width: 6),
          _StatusChip(label: '2nd', active: _shiftOn),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: EstefsariehColors.accentSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EstefsariehColors.border),
          ),
          child: const Icon(
            Icons.calculate_outlined,
            color: EstefsariehColors.accent,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ماشین‌حساب مهندسی',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: EstefsariehColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'توابع مثلثاتی، لگاریتم، توان و حافظه',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12.5,
                  color: EstefsariehColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayCard() {
    return _CalculatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: EstefsariehColors.panel2,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: EstefsariehColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 24,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _displayExpression.isEmpty ? ' ' : _displayExpression,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 16,
                        color: EstefsariehColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _liveDisplay,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: _liveValue == null && _expression.isNotEmpty
                              ? 18
                              : 34,
                          fontWeight: FontWeight.w800,
                          color: _liveValue == null && _expression.isNotEmpty
                              ? EstefsariehColors.textDim
                              : EstefsariehColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: '2nd',
                active: _shiftOn,
              ),
              _StatusChip(
                label: _angleLabel,
                active: true,
              ),
              _StatusChip(
                label: 'M: ${_calculator.format(_memory)}',
                active: _memory != 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadCard() {
    return _CalculatorCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rows = (_keys.length / 5).ceil();
          const rowSpacing = 7.0;
          const columnSpacing = 7.0;
          final available =
              constraints.maxHeight - (rows - 1) * rowSpacing - 16;
          final keyHeight = (available / rows).clamp(46.0, 78.0);

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: _keys.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: rowSpacing,
              crossAxisSpacing: columnSpacing,
              mainAxisExtent: keyHeight,
            ),
            itemBuilder: (context, index) => _buildKey(_keys[index]),
          );
        },
      ),
    );
  }

  Widget _buildKey(_CalculatorKey key) {
    final isEquals = key.type == _CalculatorKeyType.equals;
    final isMemory = key.type.index <= _CalculatorKeyType.memorySubtract.index;
    final isFunction = key.type == _CalculatorKeyType.function ||
        key.type == _CalculatorKeyType.factorial ||
        key.type == _CalculatorKeyType.reciprocal ||
        key.type == _CalculatorKeyType.answer ||
        key.type == _CalculatorKeyType.shift ||
        key.type == _CalculatorKeyType.angle;
    final isOperator = key.type == _CalculatorKeyType.insert &&
        const <String>['(', ')', '^', '×', '÷', '+', '−', '×10^']
            .contains(key.value);
    final isClear = key.type == _CalculatorKeyType.clear ||
        key.type == _CalculatorKeyType.delete;

    Color foreground = EstefsariehColors.textPrimary;
    Color background = EstefsariehColors.panel;
    Color border = EstefsariehColors.borderSoft;

    if (isEquals) {
      foreground = Colors.white;
      background = EstefsariehColors.accent;
      border = EstefsariehColors.accent;
    } else if (isOperator) {
      foreground = EstefsariehColors.primary;
    } else if (isMemory) {
      foreground = EstefsariehColors.textMuted;
    } else if (isClear) {
      foreground = EstefsariehColors.statusBad;
    } else if (isFunction) {
      foreground = key.label == '2nd' && _shiftOn
          ? EstefsariehColors.accent
          : EstefsariehColors.textPrimary;
    }

    var label = key.label;
    if (key.type == _CalculatorKeyType.angle) {
      label = _angleLabel;
    }
    if (key.type == _CalculatorKeyType.function && key.value != null) {
      label = _functionLabel(key.value!);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleKey(key),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: isEquals
                  ? 22
                  : isMemory
                      ? 13.5
                      : isFunction
                          ? 14.5
                          : 18,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }

  String _functionLabel(String function) {
    if (!_shiftOn) {
      switch (function) {
        case 'sin':
          return 'sin';
        case 'cos':
          return 'cos';
        case 'tan':
          return 'tan';
        case 'cot':
          return 'cot';
        case 'log':
          return 'log';
        case 'ln':
          return 'ln';
        case 'sq':
          return 'x²';
        case 'sqrt':
          return '√';
      }
    }

    switch (function) {
      case 'sin':
        return 'sin⁻¹';
      case 'cos':
        return 'cos⁻¹';
      case 'tan':
        return 'tan⁻¹';
      case 'cot':
        return 'cot⁻¹';
      case 'log':
        return '10ˣ';
      case 'ln':
        return 'eˣ';
      case 'sq':
        return 'x³';
      case 'sqrt':
        return '∛';
      default:
        return function;
    }
  }

  void _handleKey(_CalculatorKey key) {
    switch (key.type) {
      case _CalculatorKeyType.insert:
        _insert(key.value ?? '');
        return;
      case _CalculatorKeyType.function:
        _functionPressed(key.value!);
        return;
      case _CalculatorKeyType.factorial:
        _factorial();
        return;
      case _CalculatorKeyType.reciprocal:
        _reciprocal();
        return;
      case _CalculatorKeyType.answer:
        _answer();
        return;
      case _CalculatorKeyType.equals:
        _calculate();
        return;
      case _CalculatorKeyType.clear:
        _clear();
        return;
      case _CalculatorKeyType.delete:
        _delete();
        return;
      case _CalculatorKeyType.shift:
        _toggleShift();
        return;
      case _CalculatorKeyType.angle:
        _toggleAngle();
        return;
      case _CalculatorKeyType.memoryClear:
        _memoryClear();
        return;
      case _CalculatorKeyType.memoryRecall:
        _memoryRecall();
        return;
      case _CalculatorKeyType.memoryAdd:
        _memoryAdd();
        return;
      case _CalculatorKeyType.memorySubtract:
        _memorySubtract();
        return;
    }
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'برای توابع معکوس، لگاریتم ۱۰ و ریشه سوم، دکمه 2nd را بزنید.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12,
            height: 1.7,
            color: EstefsariehColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 1,
          color: EstefsariehColors.borderHair,
        ),
        const SizedBox(height: 10),
        const Text(
          'رهپیمان — دقت مهندسی در جیب شما',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: EstefsariehColors.textDim,
          ),
        ),
      ],
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: EstefsariehColors.panel,
        borderRadius: EstefsariehDecor.cardRadius,
        border: Border.all(color: EstefsariehColors.borderSoft),
        boxShadow: EstefsariehDecor.cardShadow,
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? EstefsariehColors.accentSoft : EstefsariehColors.panel2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? EstefsariehColors.accent.withValues(alpha: 0.45)
              : EstefsariehColors.borderHair,
        ),
      ),
      child: Text(
        label,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color:
              active ? EstefsariehColors.accent : EstefsariehColors.textMuted,
        ),
      ),
    );
  }
}

enum _CalculatorKeyType {
  insert,
  function,
  factorial,
  reciprocal,
  answer,
  equals,
  clear,
  delete,
  shift,
  angle,
  memoryClear,
  memoryRecall,
  memoryAdd,
  memorySubtract,
}

class _CalculatorKey {
  const _CalculatorKey(this.label, this.type, [this.value]);

  final String label;
  final _CalculatorKeyType type;
  final String? value;
}
