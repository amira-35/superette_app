import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Controller/produit.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final tableAchats = 'achats';
  static final tableProduits = 'produit';
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

// Méthode pour récupérer les achats et les informations de prix de vente et d'achat
  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    final db = await database;

    // Requête SQL avec jointure pour récupérer la date, le prix d'achat, le prix de vente et la quantité
    final result = await db.rawQuery('''
      SELECT a.date, a.quantity, p.prix_achat, p.p_vente
      FROM $tableAchats a
      JOIN $tableProduits p ON a.id = p.id
    ''');

    return result;
  }


  Future<void> _onCreate(Database db, int version) async {
    // Création de la table produit
    await db.execute(''' 
      CREATE TABLE produit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        p_vente REAL NOT NULL,
        prix_achat REAL NOT NULL,
        qte_stock INTEGER NOT NULL
      )
    ''');

    // Création de la table transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        date DATE NOT NULL
      )
    ''');

    // Création de la table achats avec un champ transactionId
    await db.execute('''
      CREATE TABLE achats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        date DATETIME NOT NULL,
        transactionId INTEGER NOT NULL,
        FOREIGN KEY (productId) REFERENCES produit (id),
        FOREIGN KEY (transactionId) REFERENCES transactions (id)
      )
    ''');

    // Création de la table cart
    await db.execute(''' 
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (productId) REFERENCES produit (id)
      )
    ''');
  }
// Méthode pour insérer une transaction et récupérer son ID
Future<int> insertTransaction(double total) async {
  final db = await instance.database;
  return await db.insert('transactions', {
    'total': total,
    'date': DateTime.now().toIso8601String().split('T')[0], // Date actuelle
  });
}

// Méthode pour insérer un achat avec l'ID de la transaction
Future<void> insertPurchaseWithTransaction(Map<String, dynamic> purchase, double totalPrice) async {
  final db = await instance.database;
  // Insérer un achat avec le transactionId
  await db.insert('achats', {
    'productId': purchase['productId'],
    'quantity': purchase['quantity'],
    'date': purchase['date'],
    'transactionId': purchase['transactionId'], // ID de la transaction
  });
}
Future<List<Map<String, dynamic>>> getPurchasesBetweenDates(DateTime startDate, DateTime endDate) async {
  final db = await instance.database;

  // Convertir les dates au format 'yyyy-MM-dd' pour la comparaison dans la base de données
  String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
  String endDateString = DateFormat('yyyy-MM-dd').format(endDate);

  // Requête SQL pour récupérer les achats entre deux dates
  return await db.query(
    'achats',
    where: 'date BETWEEN ? AND ?',
    whereArgs: [startDateString, endDateString],
  );
}


  // Méthode pour rechercher des produits
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await instance.database;
    return await db.query(
      'produit',
      where: 'nom LIKE ?',
      whereArgs: ['%$query%'],
    );
  }
 // Exemple de mise à jour du stock
Future<void> updateProductStock(int productId, int quantity) async {
  final db = await instance.database;
  await db.rawUpdate(
    'UPDATE produit SET qte_stock = ? WHERE id = ?',
    [quantity, productId],
  );
}
Future<void> updateStockAfterPurchase(int productId, int quantityPurchased) async {
  final db = await instance.database;

  // Query the product
  final product = await db.query(
    'produit',
    where: 'id = ?',
    whereArgs: [productId],
  );

  if (product.isNotEmpty) {
    // Cast the stock value to int
    int currentStock = product.first['qte_stock'] as int;

    // Calculate the new stock
    int newStock = currentStock - quantityPurchased;

    // Update the stock in the database
    await db.rawUpdate(
      'UPDATE produit SET qte_stock = ? WHERE id = ?',
      [newStock, productId],
    );
  } else {
    print('Product with ID $productId not found.');
  }
}




  // Méthodes pour la table produit
  Future<int> insertUser(Produit p) async {
    final db = await instance.database;
    return await db.insert('produit', p.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAllProduits() async {
    final db = await instance.database;
    return await db.query('produit');
  }

  Future<int> updateUser(Produit p) async {
    final db = await instance.database;
    return await db.update('produit', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('produit', where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes pour la table cart
  Future<void> addToCart(int productId) async {
    final db = await instance.database;

    // Vérifier si le produit existe déjà dans le panier
    final existingCartItem = await db.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );

    if (existingCartItem.isNotEmpty) {
      // Incrémenter la quantité
      final cartItem = existingCartItem.first;
      final updatedQuantity = (cartItem['quantity'] as int) + 1;
      await db.update(
        'cart',
        {'quantity': updatedQuantity},
        where: 'id = ?',
        whereArgs: [cartItem['id']],
      );
    } else {
      // Ajouter un nouveau produit
      await db.insert('cart', {'productId': productId, 'quantity': 1});
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await instance.database;

    // Charger les produits du panier avec leurs détails
    return await db.rawQuery('''
      SELECT cart.id, produit.nom, produit.p_vente, cart.quantity
      FROM cart
      INNER JOIN produit ON cart.productId = produit.id
    ''');
  }

  Future<void> updateCartQuantity(int cartId, int newQuantity) async {
    final db = await instance.database;

    if (newQuantity <= 0) {
      // Supprimer l'article si la quantité est 0
      await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
    } else {
      // Mettre à jour la quantité
      await db.update(
        'cart',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [cartId],
      );
    }
  }

  Future<void> removeFromCart(int cartId) async {
    final db = await instance.database;
    await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }
}
