import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/calendar_log.dart';
import '../models/user_avatar.dart';
import '../models/user_profile.dart';

/// Serviço central de banco de dados SQLite para o Guarda-Roupa Virtual
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      final db = await databaseFactory.openDatabase(
        'wardrobe_ai.db',
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
      await _ensureTablesExist(db);
      return db;
    }

    // Suporte para execução no Desktop (Windows/Linux/macOS) ou Testes
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (Platform.isWindows || Platform.isLinux) {
      final appDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(appDir.path, 'wardrobe_ai.db');
    } else {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, 'wardrobe_ai.db');
    }

    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await _ensureTablesExist(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Peças de Roupa
    await db.execute('''
      CREATE TABLE clothes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        color TEXT,
        imagePath TEXT NOT NULL,
        occasions TEXT,
        season TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tabela de Looks Salvos / Gerados pela IA
    await db.execute('''
      CREATE TABLE outfits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        occasion TEXT NOT NULL,
        itemIds TEXT NOT NULL,
        aiStylistNote TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Tabela de Histórico e Planejamento no Calendário
    await db.execute('''
      CREATE TABLE calendar_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        outfitId TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await _ensureTablesExist(db);

    // Seed com peças iniciais de demonstração (caso vazio)
    await _seedInitialWardrobe(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _ensureTablesExist(db);
  }

  Future<void> _ensureTablesExist(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_avatars (
        id TEXT PRIMARY KEY,
        imagePath TEXT NOT NULL,
        heightCm REAL,
        bodyType TEXT,
        skinTone TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        id TEXT PRIMARY KEY,
        displayName TEXT NOT NULL,
        email TEXT NOT NULL,
        photoUrl TEXT,
        authMethod TEXT NOT NULL,
        isLoggedIn INTEGER DEFAULT 0,
        colorPalette TEXT,
        lastSyncAt TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Migrações dinâmicas para novos recursos (Custo por uso, Peças esquecidas e Paleta)
    try {
      await db.execute('ALTER TABLE clothes ADD COLUMN purchasePrice REAL;');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE clothes ADD COLUMN wearCount INTEGER DEFAULT 0;');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE clothes ADD COLUMN lastWornDate TEXT;');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE user_profiles ADD COLUMN colorPalette TEXT;');
    } catch (_) {}
  }

  Future<void> _seedInitialWardrobe(Database db) async {
    final now = DateTime.now();
    final sampleItems = [
      ClothingItem(
        id: 'seed_top_1',
        name: 'Camisa de Linho Branca',
        category: ClothingCategory.top,
        color: 'Branco',
        imagePath: 'sample_white_shirt',
        occasions: const ['Trabalho', 'Casual', 'Encontro'],
        season: 'Todas',
        isFavorite: true,
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_top_2',
        name: 'Camiseta Básica Preta',
        category: ClothingCategory.top,
        color: 'Preto',
        imagePath: 'sample_black_tee',
        occasions: const ['Casual', 'Balada'],
        season: 'Todas',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_top_3',
        name: 'Suéter de Cashmere Cinza',
        category: ClothingCategory.top,
        color: 'Cinza',
        imagePath: 'sample_grey_sweater',
        occasions: const ['Frio', 'Trabalho', 'Casual'],
        season: 'Inverno',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_bottom_1',
        name: 'Calça Alfaiataria Grafite',
        category: ClothingCategory.bottom,
        color: 'Cinza',
        imagePath: 'sample_tailored_pants',
        occasions: const ['Trabalho', 'Casual'],
        season: 'Todas',
        isFavorite: true,
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_bottom_2',
        name: 'Calça Jeans Slim Azul Escuro',
        category: ClothingCategory.bottom,
        color: 'Azul',
        imagePath: 'sample_dark_jeans',
        occasions: const ['Casual', 'Balada', 'Frio'],
        season: 'Todas',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_bottom_3',
        name: 'Calça Chino Bege Areia',
        category: ClothingCategory.bottom,
        color: 'Bege',
        imagePath: 'sample_beige_chino',
        occasions: const ['Trabalho', 'Casual'],
        season: 'Todas',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_outer_1',
        name: 'Blazer Estruturado Azul Marinho',
        category: ClothingCategory.outerwear,
        color: 'Azul',
        imagePath: 'sample_navy_blazer',
        occasions: const ['Trabalho', 'Balada', 'Encontro'],
        season: 'Todas',
        isFavorite: true,
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_outer_2',
        name: 'Jaqueta Biker Preta Minimalista',
        category: ClothingCategory.outerwear,
        color: 'Preto',
        imagePath: 'sample_biker_jacket',
        occasions: const ['Balada', 'Frio', 'Casual'],
        season: 'Inverno',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_shoes_1',
        name: 'Tênis Couro Branco Clean',
        category: ClothingCategory.shoes,
        color: 'Branco',
        imagePath: 'sample_white_sneakers',
        occasions: const ['Casual', 'Trabalho', 'Balada'],
        season: 'Todas',
        isFavorite: true,
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_shoes_2',
        name: 'Sapato Derby Preto Nobuck',
        category: ClothingCategory.shoes,
        color: 'Preto',
        imagePath: 'sample_black_shoes',
        occasions: const ['Trabalho', 'Balada'],
        season: 'Todas',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_shoes_3',
        name: 'Bota Chelsea Couro Caramelo',
        category: ClothingCategory.shoes,
        color: 'Marrom',
        imagePath: 'sample_chelsea_boots',
        occasions: const ['Frio', 'Casual', 'Encontro'],
        season: 'Inverno',
        createdAt: now,
      ),
      ClothingItem(
        id: 'seed_acc_1',
        name: 'Relógio Cronógrafo Aço Escovado',
        category: ClothingCategory.accessory,
        color: 'Prata',
        imagePath: 'sample_silver_watch',
        occasions: const ['Trabalho', 'Balada', 'Casual'],
        season: 'Todas',
        createdAt: now,
      ),
    ];

    final batch = db.batch();
    for (final item in sampleItems) {
      batch.insert('clothes', item.toMap());
    }

    // Look inicial de demonstração
    final starterOutfit = Outfit(
      id: 'seed_outfit_1',
      name: 'Look Smart Casual Contemporâneo',
      occasion: 'Trabalho',
      itemIds: const ['seed_top_1', 'seed_bottom_1', 'seed_outer_1', 'seed_shoes_1'],
      aiStylistNote: 'Combinação clássica com toque moderno: a camisa de linho branca equilibra a seriedade do blazer marinho, enquanto o tênis minimalista adiciona dinamismo.',
      isFavorite: true,
      createdAt: now,
    );
    batch.insert('outfits', starterOutfit.toMap());

    // Agendamento no calendário para hoje
    final todayLog = CalendarLog(
      id: 'seed_cal_1',
      date: CalendarLog.normalizeDate(now),
      outfitId: starterOutfit.id,
      notes: 'Reunião de apresentação matinal & almoço de equipe.',
      createdAt: now,
    );
    batch.insert('calendar_logs', todayLog.toMap());

    await batch.commit(noResult: true);
  }

  // ==================== CRUD ROUPAS ====================

  Future<List<ClothingItem>> getClothes({ClothingCategory? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (category != null) {
      maps = await db.query(
        'clothes',
        where: 'category = ?',
        whereArgs: [category.toDbString()],
        orderBy: 'createdAt DESC',
      );
    } else {
      maps = await db.query('clothes', orderBy: 'createdAt DESC');
    }
    return maps.map((m) => ClothingItem.fromMap(m)).toList();
  }

  Future<ClothingItem?> getClothingItemById(String id) async {
    final db = await database;
    final maps = await db.query('clothes', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return ClothingItem.fromMap(maps.first);
  }

  Future<void> insertClothingItem(ClothingItem item) async {
    final db = await database;
    await db.insert(
      'clothes',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    final db = await database;
    await db.update(
      'clothes',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteClothingItem(String id) async {
    final db = await database;
    await db.delete('clothes', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CRUD LOOKS ====================

  Future<List<Outfit>> getOutfits() async {
    final db = await database;
    final maps = await db.query('outfits', orderBy: 'createdAt DESC');
    final allClothes = await getClothes();
    final clothesMap = {for (var c in allClothes) c.id: c};

    return maps.map((m) {
      final outfit = Outfit.fromMap(m);
      final hydratedItems = outfit.itemIds
          .map((id) => clothesMap[id])
          .whereType<ClothingItem>()
          .toList();
      return outfit.copyWith(items: hydratedItems);
    }).toList();
  }

  Future<Outfit?> getOutfitById(String id) async {
    final db = await database;
    final maps = await db.query('outfits', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    final outfit = Outfit.fromMap(maps.first);

    final allClothes = await getClothes();
    final clothesMap = {for (var c in allClothes) c.id: c};
    final hydratedItems = outfit.itemIds
        .map((itemId) => clothesMap[itemId])
        .whereType<ClothingItem>()
        .toList();

    return outfit.copyWith(items: hydratedItems);
  }

  Future<void> insertOutfit(Outfit outfit) async {
    final db = await database;
    await db.insert('outfits', outfit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteOutfit(String id) async {
    final db = await database;
    await db.delete('outfits', where: 'id = ?', whereArgs: [id]);
    await db.delete('calendar_logs', where: 'outfitId = ?', whereArgs: [id]);
  }

  // ==================== CRUD CALENDÁRIO ====================

  Future<List<CalendarLog>> getCalendarLogs() async {
    final db = await database;
    final maps = await db.query('calendar_logs', orderBy: 'date DESC');
    final outfits = await getOutfits();
    final outfitMap = {for (var o in outfits) o.id: o};

    return maps.map((m) {
      final log = CalendarLog.fromMap(m);
      return log.copyWith(outfit: outfitMap[log.outfitId]);
    }).toList();
  }

  Future<List<CalendarLog>> getCalendarLogsForDate(DateTime date) async {
    final db = await database;
    final norm = CalendarLog.normalizeDate(date);
    final dateStr = norm.toIso8601String().split('T').first;

    final maps = await db.query(
      'calendar_logs',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    final outfits = await getOutfits();
    final outfitMap = {for (var o in outfits) o.id: o};

    return maps.map((m) {
      final log = CalendarLog.fromMap(m);
      return log.copyWith(outfit: outfitMap[log.outfitId]);
    }).toList();
  }

  Future<void> insertCalendarLog(CalendarLog log) async {
    final db = await database;
    await db.insert('calendar_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Atualiza automaticamente o contador de uso (wearCount) e data do último uso das peças
    if (log.outfit != null && log.outfit!.itemIds.isNotEmpty) {
      final dateStr = log.date.toIso8601String();
      for (final itemId in log.outfit!.itemIds) {
        await db.rawUpdate('''
          UPDATE clothes 
          SET wearCount = COALESCE(wearCount, 0) + 1, 
              lastWornDate = ? 
          WHERE id = ?
        ''', [dateStr, itemId]);
      }
    }
  }

  Future<void> deleteCalendarLog(String id) async {
    final db = await database;
    await db.delete('calendar_logs', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== AVATAR DO USUÁRIO ====================

  Future<UserAvatar?> getUserAvatar() async {
    final db = await database;
    final maps = await db.query('user_avatars', limit: 1);
    if (maps.isEmpty) return null;
    return UserAvatar.fromMap(maps.first);
  }

  Future<void> saveUserAvatar(UserAvatar avatar) async {
    final db = await database;
    await db.insert(
      'user_avatars',
      avatar.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteUserAvatar() async {
    final db = await database;
    await db.delete('user_avatars');
  }

  // ==================== PERFIL DO USUÁRIO ====================

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profiles', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearUserProfile() async {
    final db = await database;
    await db.delete('user_profiles');
  }

  // ==================== BACKUP & CLOUD EXPORT/IMPORT ====================

  Future<Map<String, dynamic>> exportAllUserDataJson() async {
    final db = await database;
    final clothes = await db.query('clothes');
    final outfits = await db.query('outfits');
    final calendarLogs = await db.query('calendar_logs');
    final avatars = await db.query('user_avatars');
    final profiles = await db.query('user_profiles');

    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'clothes': clothes,
      'outfits': outfits,
      'calendar_logs': calendarLogs,
      'user_avatars': avatars,
      'user_profiles': profiles,
    };
  }

  Future<void> importUserDataJson(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      if (data['clothes'] is List) {
        for (var item in data['clothes'] as List) {
          await txn.insert('clothes', Map<String, dynamic>.from(item as Map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['outfits'] is List) {
        for (var item in data['outfits'] as List) {
          await txn.insert('outfits', Map<String, dynamic>.from(item as Map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['calendar_logs'] is List) {
        for (var item in data['calendar_logs'] as List) {
          await txn.insert('calendar_logs', Map<String, dynamic>.from(item as Map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['user_avatars'] is List) {
        for (var item in data['user_avatars'] as List) {
          await txn.insert('user_avatars', Map<String, dynamic>.from(item as Map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['user_profiles'] is List) {
        for (var item in data['user_profiles'] as List) {
          await txn.insert('user_profiles', Map<String, dynamic>.from(item as Map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}
