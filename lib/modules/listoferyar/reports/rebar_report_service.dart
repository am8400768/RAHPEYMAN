import '../domain/models/rebar_item.dart';

class RebarReportService {
  const RebarReportService();

  List<RebarDiameterSummary> summarizeByDiameter(
    Iterable<ListoferyarRebarItem> items,
  ) {
    final summaries = <double, RebarDiameterSummary>{};

    for (final item in items) {
      final current = summaries[item.diameter];
      summaries[item.diameter] = RebarDiameterSummary(
        diameter: item.diameter,
        quantity: (current?.quantity ?? 0) + item.quantity,
        totalLength: (current?.totalLength ?? 0) + item.totalLength,
        totalWeight: (current?.totalWeight ?? 0) + item.totalWeight,
      );
    }

    final result = summaries.values.toList(growable: false)
      ..sort((a, b) => a.diameter.compareTo(b.diameter));
    return result;
  }

  List<RebarUsageSummary> summarizeByUsage(
    Iterable<ListoferyarRebarItem> items,
  ) {
    final summaries = <String, RebarUsageSummary>{};

    for (final item in items) {
      final usage = item.usage.trim().isEmpty ? 'بدون محل مصرف' : item.usage;
      final current = summaries[usage];
      summaries[usage] = RebarUsageSummary(
        usage: usage,
        quantity: (current?.quantity ?? 0) + item.quantity,
        totalLength: (current?.totalLength ?? 0) + item.totalLength,
        totalWeight: (current?.totalWeight ?? 0) + item.totalWeight,
      );
    }

    final result = summaries.values.toList(growable: false)
      ..sort((a, b) => b.totalWeight.compareTo(a.totalWeight));
    return result;
  }
}

class RebarDiameterSummary {
  const RebarDiameterSummary({
    required this.diameter,
    required this.quantity,
    required this.totalLength,
    required this.totalWeight,
  });

  final double diameter;
  final int quantity;
  final double totalLength;
  final double totalWeight;
}

class RebarUsageSummary {
  const RebarUsageSummary({
    required this.usage,
    required this.quantity,
    required this.totalLength,
    required this.totalWeight,
  });

  final String usage;
  final int quantity;
  final double totalLength;
  final double totalWeight;
}
