import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class BrickFacade {
  const BrickFacade({
    required this.id,
    required this.brickType,
    required this.dimensions,
    required this.bricksPerSqMeterText,
    required this.bricksPerBox,
  });

  final int id;
  final String brickType;
  final String dimensions;
  final String bricksPerSqMeterText;
  final int bricksPerBox;

  double get defaultBricksPerSqMeter {
    final values = RegExp(r'\d+(?:\.\d+)?')
        .allMatches(bricksPerSqMeterText)
        .map((m) => double.parse(m.group(0)!))
        .toList();

    if (values.isEmpty) return 0;

    if (values.length == 1) {
      return values.first;
    }

    // برای بازه‌هایی مثل «37 الی 40»،
    // مقدار بالاتر برای برآورد محافظه‌کارانه انتخاب می‌شود.
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// استخراج ابعاد قابل استفاده برای فرمول محاسبه.
  ///
  /// نمونه:
  /// 2.5×20×5.5
  /// 3×50×10
  ///
  /// در محاسبه تعداد آجر در سطح نما،
  /// دو بعد نمای آجر استفاده می‌شود.
  List<double> get numericDimensions {
    return RegExp(r'\d+(?:\.\d+)?')
        .allMatches(dimensions)
        .map((m) => double.parse(m.group(0)!))
        .toList();
  }

  double get facadeLengthCm {
    final values = numericDimensions;

    if (values.length < 2) return 0;

    return values[1];
  }

  double get facadeHeightCm {
    final values = numericDimensions;

    if (values.length < 3) return 0;

    return values[2];
  }
}

class BrickWallCount {
  const BrickWallCount({
    required this.wallThicknessCm,
    required this.leftonCount,
    required this.sofaliCount,
    required this.feshariCount,
  });

  final int wallThicknessCm;
  final int leftonCount;
  final int sofaliCount;
  final int feshariCount;
}

class BrickJointOption {
  const BrickJointOption({
    required this.id,
    required this.jointName,
    required this.jointValueCm,
  });

  final int id;
  final String jointName;
  final double jointValueCm;
}

class BrickDatabase {
  BrickDatabase._();

  static final BrickDatabase instance = BrickDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = '$dbPath/bricks_yar.db';

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        final sql = await rootBundle.loadString(
          'assets/data/bricks.sql',
        );

        await _executeSqlScript(db, sql);
      },
    );

    return _database!;
  }

  Future<void> _executeSqlScript(
    Database db,
    String script,
  ) async {
    final statements = script
        .split(';')
        .map(_removeSqlComments)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    for (final statement in statements) {
      await db.execute(statement);
    }
  }

  String _removeSqlComments(String input) {
    return input
        .split('\n')
        .where(
          (line) => !line.trimLeft().startsWith('--'),
        )
        .join('\n');
  }

  Future<List<BrickFacade>> getFacadeBricks() async {
    final db = await database;

    final rows = await db.query(
      'facade_bricks_data',
      orderBy: 'id ASC',
    );

    return rows.map((row) {
      return BrickFacade(
        id: row['id'] as int,
        brickType: row['brick_type'] as String,
        dimensions: row['dimensions'] as String,
        bricksPerSqMeterText: row['bricks_per_sq_meter'] as String,
        bricksPerBox: row['bricks_per_box'] as int,
      );
    }).toList();
  }

  Future<List<int>> getWallThicknesses() async {
    final db = await database;

    final rows = await db.query(
      'calc_wall_thickness_options',
      columns: ['thickness_cm'],
      orderBy: 'thickness_cm ASC',
    );

    return rows.map((row) => row['thickness_cm'] as int).toList();
  }

  Future<BrickWallCount?> getWallBrickCount(
    int thicknessCm,
  ) async {
    final db = await database;

    final rows = await db.query(
      'wall_bricks_data',
      where: 'wall_thickness_cm = ?',
      whereArgs: [thicknessCm],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;

    return BrickWallCount(
      wallThicknessCm: row['wall_thickness_cm'] as int,
      leftonCount: row['lefton_10x20x5_5_count'] as int,
      sofaliCount: row['sofali_count'] as int,
      feshariCount: row['feshari_10x20x5_count'] as int,
    );
  }

  Future<List<BrickJointOption>> getJointOptions() async {
    final db = await database;

    final rows = await db.query(
      'calc_joint_thickness_options',
      orderBy: 'joint_value_cm ASC',
    );

    return rows.map((row) {
      final rawValue = row['joint_value_cm'];

      return BrickJointOption(
        id: row['id'] as int,
        jointName: row['joint_name'] as String,
        jointValueCm: rawValue is int
            ? rawValue.toDouble()
            : (rawValue as num).toDouble(),
      );
    }).toList();
  }

  Future<List<Map<String, Object?>>> getBrickOptions({
    required String category,
  }) async {
    final db = await database;

    return db.query(
      'calc_brick_options',
      where: 'brick_category = ?',
      whereArgs: [category],
      orderBy: 'id ASC',
    );
  }
}
