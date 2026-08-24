import 'dart:math' as math;

enum CalculatorAngleMode { degrees, radians }

class EngineeringCalculatorService {
  static const List<String> _functions = <String>[
    'asin',
    'acos',
    'atan',
    'acot',
    'sin',
    'cos',
    'tan',
    'cot',
    'log',
    'ln',
    'sqrt',
    'cbrt',
  ];

  double? evaluate(String expression, CalculatorAngleMode angleMode) {
    if (expression.trim().isEmpty) {
      return null;
    }

    try {
      final tokens = _tokenize(expression);
      if (tokens.isEmpty) {
        return null;
      }

      final parser = _Parser(tokens, angleMode);
      final value = parser.parse();

      if (!parser.isAtEnd || value.isNaN || value.isInfinite) {
        return null;
      }

      return value;
    } catch (_) {
      return null;
    }
  }

  String format(double? value) {
    if (value == null || value.isNaN || value.isInfinite) {
      return '—';
    }

    if (value == 0) {
      return '0';
    }

    final absolute = value.abs();
    if (absolute < 1e-9 || absolute >= 1e15) {
      final scientific = value.toStringAsExponential(6);
      return scientific
          .replaceFirst('e+', ' × 10^')
          .replaceFirst('e-', ' × 10^-')
          .replaceFirst('e', ' × 10^');
    }

    var result = value.toStringAsFixed(10);
    result = result.replaceFirst(RegExp(r'0+$'), '');
    result = result.replaceFirst(RegExp(r'\.$'), '');

    if (result.length > 16) {
      result = value.toStringAsPrecision(11);
    }

    return result;
  }

  double? factorial(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return null;
    }

    if (value != value.roundToDouble()) {
      return null;
    }

    if (value > 170) {
      return double.infinity;
    }

    var result = 1.0;
    for (var i = 2; i <= value.toInt(); i++) {
      result *= i;
    }
    return result;
  }

  List<_Token> _tokenize(String expression) {
    final tokens = <_Token>[];
    var index = 0;

    while (index < expression.length) {
      final char = expression[index];

      if (char.trim().isEmpty) {
        index++;
        continue;
      }

      if (_isDigit(char) || char == '.') {
        final start = index;
        var dotCount = 0;

        while (index < expression.length) {
          final current = expression[index];
          if (_isDigit(current)) {
            index++;
            continue;
          }
          if (current == '.') {
            dotCount++;
            if (dotCount > 1) {
              break;
            }
            index++;
            continue;
          }
          break;
        }

        final text = expression.substring(start, index);
        final value = double.tryParse(text);
        if (value == null) {
          throw const FormatException('Invalid number');
        }
        tokens.add(_Token.number(value));
        continue;
      }

      if (char == 'π') {
        tokens.add(_Token.constant(math.pi));
        index++;
        continue;
      }

      if (char == '√') {
        tokens.add(_Token.function('sqrt'));
        index++;
        continue;
      }

      if (char == '∛') {
        tokens.add(_Token.function('cbrt'));
        index++;
        continue;
      }

      if (char == '×') {
        tokens.add(_Token.operator('*'));
        index++;
        continue;
      }

      if (char == '÷') {
        tokens.add(_Token.operator('/'));
        index++;
        continue;
      }

      if (char == '−') {
        tokens.add(_Token.operator('-'));
        index++;
        continue;
      }

      if ('+-*/^!%()'.contains(char)) {
        if (char == '(') {
          tokens.add(_Token.leftParenthesis());
        } else if (char == ')') {
          tokens.add(_Token.rightParenthesis());
        } else if (char == '!') {
          tokens.add(_Token.factorial());
        } else if (char == '%') {
          tokens.add(_Token.percent());
        } else {
          tokens.add(_Token.operator(char));
        }
        index++;
        continue;
      }

      if (_isLetter(char)) {
        final start = index;
        while (index < expression.length && _isLetter(expression[index])) {
          index++;
        }

        final word = expression.substring(start, index).toLowerCase();
        if (word == 'e') {
          tokens.add(_Token.constant(math.e));
          continue;
        }

        if (_functions.contains(word)) {
          tokens.add(_Token.function(word));
          continue;
        }

        throw const FormatException('Unknown identifier');
      }

      throw const FormatException('Unknown character');
    }

    return _insertImplicitMultiplication(tokens);
  }

  List<_Token> _insertImplicitMultiplication(List<_Token> source) {
    if (source.length < 2) {
      return source;
    }

    final result = <_Token>[];
    for (var i = 0; i < source.length; i++) {
      final current = source[i];
      result.add(current);

      if (i == source.length - 1) {
        continue;
      }

      final next = source[i + 1];
      if (_endsValue(current) && _startsValue(next)) {
        if (current.type == _TokenType.function &&
            next.type == _TokenType.leftParenthesis) {
          continue;
        }
        result.add(_Token.operator('*'));
      }
    }

    return result;
  }

  bool _endsValue(_Token token) {
    return token.type == _TokenType.number ||
        token.type == _TokenType.constant ||
        token.type == _TokenType.rightParenthesis ||
        token.type == _TokenType.factorial ||
        token.type == _TokenType.percent;
  }

  bool _startsValue(_Token token) {
    return token.type == _TokenType.number ||
        token.type == _TokenType.constant ||
        token.type == _TokenType.function ||
        token.type == _TokenType.leftParenthesis;
  }

  bool _isDigit(String value) =>
      value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;

  bool _isLetter(String value) {
    final code = value.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}

enum _TokenType {
  number,
  constant,
  function,
  operator,
  leftParenthesis,
  rightParenthesis,
  factorial,
  percent,
}

class _Token {
  const _Token(this.type, {this.value, this.text});

  factory _Token.number(double value) =>
      _Token(_TokenType.number, value: value);
  factory _Token.constant(double value) =>
      _Token(_TokenType.constant, value: value);
  factory _Token.function(String value) =>
      _Token(_TokenType.function, text: value);
  factory _Token.operator(String value) =>
      _Token(_TokenType.operator, text: value);
  factory _Token.leftParenthesis() => const _Token(_TokenType.leftParenthesis);
  factory _Token.rightParenthesis() =>
      const _Token(_TokenType.rightParenthesis);
  factory _Token.factorial() => const _Token(_TokenType.factorial);
  factory _Token.percent() => const _Token(_TokenType.percent);

  final _TokenType type;
  final double? value;
  final String? text;
}

class _Parser {
  _Parser(this.tokens, this.angleMode);

  final List<_Token> tokens;
  final CalculatorAngleMode angleMode;
  var position = 0;

  bool get isAtEnd => position == tokens.length;

  double parse() {
    final value = _parseExpression();
    return value;
  }

  _Token? _peek() => position < tokens.length ? tokens[position] : null;

  _Token _next() {
    if (position >= tokens.length) {
      throw const FormatException('Unexpected end');
    }
    return tokens[position++];
  }

  double _parseExpression() {
    var value = _parseTerm();

    while (true) {
      final token = _peek();
      if (token == null || token.type != _TokenType.operator) {
        break;
      }
      if (token.text != '+' && token.text != '-') {
        break;
      }

      final operator = _next().text!;
      final right = _parseTerm();
      value = operator == '+' ? value + right : value - right;
    }

    return value;
  }

  double _parseTerm() {
    var value = _parseUnary();

    while (true) {
      final token = _peek();
      if (token == null) {
        break;
      }

      if (token.type == _TokenType.operator &&
          (token.text == '*' || token.text == '/')) {
        final operator = _next().text!;
        final right = _parseUnary();
        value = operator == '*' ? value * right : value / right;
        continue;
      }

      if (_startsPrimary(token)) {
        final right = _parseUnary();
        value *= right;
        continue;
      }

      break;
    }

    return value;
  }

  double _parseUnary() {
    final token = _peek();
    if (token != null &&
        token.type == _TokenType.operator &&
        token.text == '-') {
      _next();
      return -_parseUnary();
    }
    return _parsePower();
  }

  double _parsePower() {
    var value = _parsePostfix();
    final token = _peek();
    if (token != null &&
        token.type == _TokenType.operator &&
        token.text == '^') {
      _next();
      final exponent = _parseUnary();
      value = math.pow(value, exponent).toDouble();
    }
    return value;
  }

  double _parsePostfix() {
    var value = _parsePrimary();

    while (true) {
      final token = _peek();
      if (token == null) {
        break;
      }

      if (token.type == _TokenType.factorial) {
        _next();
        final result = EngineeringCalculatorService().factorial(value);
        if (result == null) {
          throw const FormatException('Invalid factorial');
        }
        value = result;
        continue;
      }

      if (token.type == _TokenType.percent) {
        _next();
        value /= 100;
        continue;
      }

      break;
    }

    return value;
  }

  double _parsePrimary() {
    final token = _peek();
    if (token == null) {
      throw const FormatException('Missing value');
    }

    switch (token.type) {
      case _TokenType.number:
      case _TokenType.constant:
        _next();
        return token.value!;
      case _TokenType.leftParenthesis:
        _next();
        final value = _parseExpression();
        final closing = _next();
        if (closing.type != _TokenType.rightParenthesis) {
          throw const FormatException('Missing closing parenthesis');
        }
        return value;
      case _TokenType.function:
        return _parseFunction();
      case _TokenType.operator:
      case _TokenType.rightParenthesis:
      case _TokenType.factorial:
      case _TokenType.percent:
        throw const FormatException('Invalid primary');
    }
  }

  double _parseFunction() {
    final function = _next().text!;
    double argument;

    final next = _peek();
    if (next != null && next.type == _TokenType.leftParenthesis) {
      _next();
      argument = _parseExpression();
      final closing = _next();
      if (closing.type != _TokenType.rightParenthesis) {
        throw const FormatException('Missing closing parenthesis');
      }
    } else {
      argument = _parsePostfix();
    }

    switch (function) {
      case 'sin':
        return math.sin(_toRadians(argument));
      case 'cos':
        return math.cos(_toRadians(argument));
      case 'tan':
        return math.tan(_toRadians(argument));
      case 'asin':
        return _fromRadians(math.asin(argument));
      case 'acos':
        return _fromRadians(math.acos(argument));
      case 'atan':
        return _fromRadians(math.atan(argument));
      case 'cot':
        return _cotangent(argument);
      case 'acot':
        return _inverseCotangent(argument);
      case 'log':
        return math.log(argument) / math.ln10;
      case 'ln':
        return math.log(argument);
      case 'sqrt':
        return math.sqrt(argument);
      case 'cbrt':
        return _cubeRoot(argument);
      default:
        throw const FormatException('Unknown function');
    }
  }

  double _toRadians(double value) {
    return angleMode == CalculatorAngleMode.degrees
        ? value * math.pi / 180
        : value;
  }

  double _fromRadians(double value) {
    return angleMode == CalculatorAngleMode.degrees
        ? value * 180 / math.pi
        : value;
  }

  double _cotangent(double value) {
    final radians = _toRadians(value);
    final sine = math.sin(radians);

    if (sine.abs() < 1e-12) {
      throw const FormatException('Cotangent undefined');
    }

    return math.cos(radians) / sine;
  }

  double _inverseCotangent(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const FormatException('Invalid acot argument');
    }

    // Principal value in (0, pi), a common engineering convention.
    final radians = value > 0
        ? math.atan(1 / value)
        : value < 0
            ? math.atan(1 / value) + math.pi
            : math.pi / 2;

    return _fromRadians(radians);
  }

  double _cubeRoot(double value) {
    if (value == 0) {
      return 0;
    }
    return value.isNegative
        ? -math.pow(-value, 1 / 3).toDouble()
        : math.pow(value, 1 / 3).toDouble();
  }

  bool _startsPrimary(_Token token) {
    return token.type == _TokenType.number ||
        token.type == _TokenType.constant ||
        token.type == _TokenType.function ||
        token.type == _TokenType.leftParenthesis;
  }
}
