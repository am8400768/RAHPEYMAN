import '../models/rebar_item.dart';

class RebarService {
  const RebarService();

  /// وزن استاندارد یک متر میلگرد:
  ///
  /// kg/m = d² / 162
  ///
  /// d بر حسب میلی‌متر است.
  double calculateUnitWeight(double diameter) {
    if (diameter <= 0) {
      throw ArgumentError(
        'قطر میلگرد باید بیشتر از صفر باشد.',
      );
    }

    return diameter * diameter / 162.0;
  }

  double calculateTotalLength({
    required int quantity,
    required double length,
  }) {
    if (quantity <= 0) {
      throw ArgumentError(
        'تعداد باید بیشتر از صفر باشد.',
      );
    }

    if (length <= 0) {
      throw ArgumentError(
        'طول باید بیشتر از صفر باشد.',
      );
    }

    return quantity * length;
  }

  double calculateTotalWeight({
    required double totalLength,
    required double unitWeight,
  }) {
    if (totalLength < 0) {
      throw ArgumentError(
        'طول کل نمی‌تواند منفی باشد.',
      );
    }

    if (unitWeight < 0) {
      throw ArgumentError(
        'وزن واحد نمی‌تواند منفی باشد.',
      );
    }

    return totalLength * unitWeight;
  }

  /// گرد کردن به روش Half-Up.
  double roundTo(
    double value,
    int decimals,
  ) {
    final factor = _pow10(decimals);
    final scaled = value * factor;

    if (scaled >= 0) {
      return (scaled + 0.5).floorToDouble() / factor;
    }

    return (scaled - 0.5).ceilToDouble() / factor;
  }

  /// تعداد رقم اعشار وزن بر اساس سایز میلگرد.
  ///
  /// تا سایز 12 → سه رقم
  /// از سایز 14 به بالا → دو رقم
  int weightDecimals(double diameter) {
    return diameter <= 12 ? 3 : 2;
  }

  double roundWeight(
    double value,
    double diameter,
  ) {
    return roundTo(
      value,
      weightDecimals(diameter),
    );
  }

  /// محاسبه کامل یک ردیف میلگرد.
  ///
  /// نکته مهم:
  /// spacing فقط اطلاعات اجرایی است
  /// و در محاسبه طول و وزن استفاده نمی‌شود.
  ListoferyarRebarItem calculate({
    required int projectId,
    required int nodeId,
    required double diameter,
    required int quantity,
    required double length,
    required double spacing,
    String usage = '',
    String description = '',
  }) {
    if (projectId <= 0) {
      throw ArgumentError(
        'شناسه پروژه معتبر نیست.',
      );
    }

    if (nodeId <= 0) {
      throw ArgumentError(
        'شناسه محل مصرف معتبر نیست.',
      );
    }

    if (diameter <= 0) {
      throw ArgumentError(
        'قطر میلگرد معتبر نیست.',
      );
    }

    if (quantity <= 0) {
      throw ArgumentError(
        'تعداد باید بیشتر از صفر باشد.',
      );
    }

    if (length <= 0) {
      throw ArgumentError(
        'طول واحد باید بیشتر از صفر باشد.',
      );
    }

    if (spacing < 0) {
      throw ArgumentError(
        'فاصله میلگرد نمی‌تواند منفی باشد.',
      );
    }

    final normalizedUsage = usage.trim();
    final normalizedDescription = description.trim();

    final unitWeightRaw =
        calculateUnitWeight(diameter);

    // spacing فقط اطلاعات فنی است
    // و در هیچ‌یک از محاسبات استفاده نمی‌شود.
    final totalLength = calculateTotalLength(
      quantity: quantity,
      length: length,
    );

    final totalWeightRaw = calculateTotalWeight(
      totalLength: totalLength,
      unitWeight: unitWeightRaw,
    );

    final weightDecimalsValue =
        weightDecimals(diameter);

    return ListoferyarRebarItem(
      projectId: projectId,
      nodeId: nodeId,
      diameter: roundTo(diameter, 0),
      quantity: quantity,
      length: roundTo(length, 3),
      spacing: roundTo(spacing, 2),
      usage: normalizedUsage,
      description: normalizedDescription,
      unitWeight: roundTo(
        unitWeightRaw,
        weightDecimalsValue,
      ),
      totalLength: roundTo(
        totalLength,
        3,
      ),
      totalWeight: roundTo(
        totalWeightRaw,
        weightDecimalsValue,
      ),
    );
  }

  double _pow10(int decimals) {
    var result = 1.0;

    for (var i = 0; i < decimals; i++) {
      result *= 10;
    }

    return result;
  }
}