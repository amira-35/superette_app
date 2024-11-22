import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Controller/produit.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

Future<Database> initDb() async {
  String databasesPath = await getDatabasesPath();
  return openDatabase(
    join(databasesPath, 'database.db'),
    version: 2, // Increment the version number
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Add the missing column
        await db.execute('ALTER TABLE produit ADD COLUMN prix_achat REAL');
      }
    },
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE produit (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          type TEXT NOT NULL,
          p_vente REAL NOT NULL,
          prix_achat REAL NOT NULL, -- Ensure this column is present
          qte_stock INTEGER NOT NULL
        )
      ''');
    },
  );
}


  Future<int> insertUser(Produit p) async {
    Database db = await instance.db;
    return await db.insert('produit', p.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAllProduits() async {
    Database db = await instance.db;
    return await db.query('produit');
  }

  Future<int> updateUser(Produit p) async {
    Database db = await instance.db;
    return await db.update('produit', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deleteProduct(int id) async {
    Database db = await instance.db;
    return await db.delete('produit', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> initializeProduits() async {
    List<Produit> produitToAdd = [
    Produit(id: 1,nom: 'p1', type: 't1',pvente:10.0,pachat:5.0,qte: 11),
    Produit(id: 2,nom: 'p2', type: 't2',pvente:10.0,pachat:5.0,qte: 11),
    Produit(id: 3,nom: 'p3', type: 't3',pvente:10.0,pachat:5.0,qte: 11),
    Produit(id: 4,nom: 'p4', type: 't4',pvente:10.0,pachat:5.0,qte: 11),
    ];

    for (Produit p in produitToAdd) {
      await insertUser(p);
    }
  }
}
