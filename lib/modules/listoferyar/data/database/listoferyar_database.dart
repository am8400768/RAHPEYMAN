import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ListoferyarDatabase {
  ListoferyarDatabase._();

  static final instance = ListoferyarDatabase._();

  Database? _database;

  static const databaseName = 'listoferyar.db';

  // v1 = projects + project_nodes
  // v2 = + rebar_items
  // v3 = rebar_items اصلاح‌شده:
  //      حذف bar_mark
  //      اضافه شدن spacing
  //      اضافه شدن description
  // v4 = اضافه شدن usage برای محل مصرف میلگرد
  static const version = 4;

  Future<Database> get database async =>
      _database ??= await _open();

  Future<Database> _open() async {
    final root = await getDatabasesPath();

    return openDatabase(
      p.join(root, databaseName),
      version: version,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: (db, _) async {
        await _createProjectsTable(db);
        await _createProjectNodesTable(db);
        await _createRebarItemsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRebarItemsTable(db);
        }

        if (oldVersion < 3) {
          await _migrateRebarItemsToV3(db);
        }

        if (oldVersion < 4) {
          await _migrateRebarItemsToV4(db);
        }
      },
    );
  }

  Future<void> _createProjectsTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        employer TEXT NOT NULL DEFAULT '',
        consultant TEXT NOT NULL DEFAULT '',
        contractor TEXT NOT NULL DEFAULT '',
        resident_supervisor TEXT NOT NULL DEFAULT '',
        contract_date TEXT NOT NULL DEFAULT '',
        contract_number TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_projects_updated_at '
      'ON projects(updated_at DESC)',
    );
  }

  Future<void> _createProjectNodesTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE project_nodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        parent_id INTEGER,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(project_id)
          REFERENCES projects(id)
          ON DELETE CASCADE,
        FOREIGN KEY(parent_id)
          REFERENCES project_nodes(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_project_nodes_project_parent_sort
      ON project_nodes(project_id, parent_id, sort_order)
    ''');
  }

  Future<void> _createRebarItemsTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rebar_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        node_id INTEGER NOT NULL,
        diameter REAL NOT NULL,
        quantity INTEGER NOT NULL,
        length REAL NOT NULL,
        spacing REAL NOT NULL DEFAULT 0,
        usage TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        unit_weight REAL NOT NULL,
        total_length REAL NOT NULL,
        total_weight REAL NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(project_id)
          REFERENCES projects(id)
          ON DELETE CASCADE,
        FOREIGN KEY(node_id)
          REFERENCES project_nodes(id)
          ON DELETE CASCADE
      )
    ''');

    await _createRebarIndexes(db);
  }

  Future<void> _createRebarIndexes(
    Database db,
  ) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_rebar_items_node_sort
      ON rebar_items(node_id, sort_order DESC, id DESC)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_rebar_items_project
      ON rebar_items(project_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_rebar_items_node_diameter
      ON rebar_items(node_id, diameter)
    ''');
  }

  Future<void> _migrateRebarItemsToV3(
    Database db,
  ) async {
    final tableCheck = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'rebar_items'
      ''',
    );

    if (tableCheck.isEmpty) {
      await _createRebarItemsTable(db);
      return;
    }

    await db.transaction(
      (txn) async {
        await txn.execute('''
          CREATE TABLE rebar_items_v3 (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL,
            node_id INTEGER NOT NULL,
            diameter REAL NOT NULL,
            quantity INTEGER NOT NULL,
            length REAL NOT NULL,
            spacing REAL NOT NULL DEFAULT 0,
            description TEXT NOT NULL DEFAULT '',
            unit_weight REAL NOT NULL,
            total_length REAL NOT NULL,
            total_weight REAL NOT NULL,
            sort_order INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(project_id)
              REFERENCES projects(id)
              ON DELETE CASCADE,
            FOREIGN KEY(node_id)
              REFERENCES project_nodes(id)
              ON DELETE CASCADE
          )
        ''');

        await txn.execute('''
          INSERT INTO rebar_items_v3 (
            id,
            project_id,
            node_id,
            diameter,
            quantity,
            length,
            spacing,
            description,
            unit_weight,
            total_length,
            total_weight,
            sort_order,
            created_at,
            updated_at
          )
          SELECT
            id,
            project_id,
            node_id,
            diameter,
            quantity,
            length,
            0,
            '',
            unit_weight,
            total_length,
            total_weight,
            sort_order,
            created_at,
            updated_at
          FROM rebar_items
        ''');

        await txn.execute(
          'DROP TABLE rebar_items',
        );

        await txn.execute('''
          ALTER TABLE rebar_items_v3
          RENAME TO rebar_items
        ''');
      },
    );

    await _createRebarIndexes(db);
  }

  /// نسخه 4:
  ///
  /// اضافه کردن ستون usage برای ثبت محل مصرف میلگرد.
  ///
  /// اطلاعات قبلی کاملاً حفظ می‌شوند.
  /// مقدار اولیه usage برای ردیف‌های قبلی خالی خواهد بود.
  Future<void> _migrateRebarItemsToV4(
    Database db,
  ) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info(rebar_items)',
    );

    final hasUsage = columns.any(
      (column) => column['name'] == 'usage',
    );

    if (!hasUsage) {
      await db.execute('''
        ALTER TABLE rebar_items
        ADD COLUMN usage TEXT NOT NULL DEFAULT ''
      ''');
    }

    await _createRebarIndexes(db);
  }

  Future<void> close() async {
    final db = _database;

    if (db == null) return;

    await db.close();
    _database = null;
  }
}