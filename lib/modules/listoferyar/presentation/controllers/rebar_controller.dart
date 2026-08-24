import 'package:flutter/foundation.dart';

import '../../data/repositories/rebar_repository_impl.dart';
import '../../domain/models/rebar_item.dart';
import '../../domain/services/rebar_service.dart';

class RebarController extends ChangeNotifier {
  RebarController({
    RebarRepository? repository,
    RebarService? service,
  })  : _repository = repository ?? RebarRepository(),
        _service = service ?? const RebarService();

  final RebarRepository _repository;
  final RebarService _service;

  List<ListoferyarRebarItem> _items =
      const <ListoferyarRebarItem>[];

  bool _loading = false;
  String? _error;

  List<ListoferyarRebarItem> get items => _items;

  bool get loading => _loading;

  String? get error => _error;

  int get itemCount => _items.length;

  double get totalLength {
    return _items.fold<double>(
      0,
      (sum, item) => sum + item.totalLength,
    );
  }

  double get totalWeight {
    return _items.fold<double>(
      0,
      (sum, item) => sum + item.totalWeight,
    );
  }

  /// بارگذاری اطلاعات میلگرد مربوط به یک زیرشاخه.
  Future<void> load(int nodeId) async {
    if (nodeId <= 0) {
      _error = 'شناسه زیرشاخه معتبر نیست.';
      _items = const <ListoferyarRebarItem>[];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getByNode(nodeId);
    } catch (error) {
      _error = error.toString();
      _items = const <ListoferyarRebarItem>[];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// محاسبه یک ردیف میلگرد.
  ///
  /// spacing فقط اطلاعات اجرایی است
  /// و روی طول و وزن تأثیری ندارد.
  ///
  /// usage محل واقعی مصرف میلگرد است
  /// و در فیلد مستقل usage ذخیره می‌شود.
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
    return _service.calculate(
      projectId: projectId,
      nodeId: nodeId,
      diameter: diameter,
      quantity: quantity,
      length: length,
      spacing: spacing,
      usage: usage,
      description: description,
    );
  }

  /// افزودن ردیف جدید میلگرد.
  Future<void> add(
    ListoferyarRebarItem item,
  ) async {
    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.create(item);

      _items = await _repository.getByNode(
        item.nodeId,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// ویرایش ردیف میلگرد.
  Future<void> update(
    ListoferyarRebarItem item,
  ) async {
    if (_loading) return;

    if (item.id == null) {
      throw StateError(
        'شناسه میلگرد برای ویرایش مشخص نیست.',
      );
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.update(item);

      _items = await _repository.getByNode(
        item.nodeId,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// حذف یک ردیف میلگرد.
  Future<void> delete(
    ListoferyarRebarItem item,
  ) async {
    final id = item.id;

    if (id == null) {
      throw StateError(
        'شناسه میلگرد برای حذف مشخص نیست.',
      );
    }

    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.delete(id);

      _items = await _repository.getByNode(
        item.nodeId,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// پاک کردن خطا.
  void clearError() {
    if (_error == null) return;

    _error = null;
    notifyListeners();
  }
}