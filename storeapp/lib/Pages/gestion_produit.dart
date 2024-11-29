import 'package:flutter/material.dart';
import '../BD.dart';
import '../Controller/produit.dart'; // Importez la classe Produit.

class ProductManagementPage extends StatefulWidget {
  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  // Liste des produits (à mettre à jour avec les données de la base)
  List<Map<String, dynamic>> products = [];
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchProducts('');
   
  }

  Future<void> _loadProducts() async {
    final db = DatabaseHelper.instance;
    final allProducts = await db.queryAllProduits();
    setState(() {
      products = allProducts;
      print(products);
      
      filteredProducts = products; 
    });
  }
  void _filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) =>
              product['nom'].toLowerCase().contains(query.toLowerCase())) // Recherche insensible à la casse
          .toList();
    });
  }
    Future<void> _searchProducts(String query) async {
    final products = await DatabaseHelper.instance.searchProducts(query);
    setState(() {
      filteredProducts = products;
    });
  }
  // Méthode pour afficher un formulaire et ajouter un produit
  void _addProduct() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController salePriceController = TextEditingController();
    final TextEditingController purchasePriceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un produit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: salePriceController,
                  decoration: InputDecoration(labelText: 'Prix de vente'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: purchasePriceController,
                  decoration: InputDecoration(labelText: 'Prix d\'achat'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: 'Quantité en stock'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Créer un nouvel objet Produit
                final newProduct = Produit(
                  id: 0, // L'ID sera généré automatiquement
                  nom: nameController.text,
                  type: typeController.text,
                  pvente: double.tryParse(salePriceController.text) ?? 0.0,
                  pachat: double.tryParse(purchasePriceController.text) ?? 0.0,
                  qte: int.tryParse(stockController.text) ?? 0,
                );

                // Ajouter à la base de données
                final db = DatabaseHelper.instance;
                await db.insertUser(newProduct);

                // Recharger la liste des produits
                await _loadProducts();

                // Fermer la boîte de dialogue
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
  void _editProduct(Map<String, dynamic> product) {
  final TextEditingController nameController = TextEditingController(text: product['nom']);
  final TextEditingController typeController = TextEditingController(text: product['type']);
  final TextEditingController salePriceController = TextEditingController(text: product['p_vente'].toString());
  final TextEditingController purchasePriceController = TextEditingController(text: product['prix_achat'].toString());
  final TextEditingController stockController = TextEditingController(text: product['qte_stock'].toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Modifier le produit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: salePriceController,
                decoration: InputDecoration(labelText: 'Prix de vente'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: purchasePriceController,
                decoration: InputDecoration(labelText: 'Prix d\'achat'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Quantité en stock'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Créer un objet Produit mis à jour
              final updatedProduct = Produit(
                id: product['id'], // Utiliser l'ID existant pour la mise à jour
                nom: nameController.text,
                type: typeController.text,
                pvente: double.tryParse(salePriceController.text) ?? 0.0,
                pachat: double.tryParse(purchasePriceController.text) ?? 0.0,
                qte: int.tryParse(stockController.text) ?? 0,
              );

              // Mettre à jour la base de données
              final db = DatabaseHelper.instance;
              await db.updateUser(updatedProduct);

              // Recharger la liste des produits
              await _loadProducts();

              // Fermer la boîte de dialogue
              Navigator.pop(context);
            },
            child: Text('Modifier'),
          ),
        ],
      );
    },
  );
}
void _deleteProduct(Map<String, dynamic> product) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le produit "${product['nom']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Ferme la boîte de dialogue
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Supprimer le produit de la base de données
              final db = DatabaseHelper.instance;
              await db.deleteProduct(product['id']); // Passe l'ID du produit

              // Recharger la liste des produits
              await _loadProducts();

              // Fermer la boîte de dialogue
              Navigator.pop(context);
            },
            child: Text('Supprimer'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Produits'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
           onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
                _searchProducts(searchQuery);
              },
            ),
            SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(product['nom']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prix d\'achat: ${product['prix_achat'].toStringAsFixed(2)} \DA'),
                          Text('Prix de vente: ${product['p_vente'].toStringAsFixed(2)} \DA'),
                          Text('Quantité en stock: ${product['qte_stock']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton Modifier
                        IconButton(
  icon: Icon(Icons.edit, color: Colors.blue),
  onPressed: () {
    _editProduct(product); // Appelle la méthode pour modifier le produit
  },
),
                          // Bouton Supprimer
                         IconButton(
  icon: Icon(Icons.delete, color: Colors.red),
  onPressed: () {
    _deleteProduct(product); // Appelle la méthode pour supprimer le produit
  },
),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bouton Ajouter un produit
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Ajouter un produit'),
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
