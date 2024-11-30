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

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final db = DatabaseHelper.instance;
    final productsFromDb = await db.queryAllProduits();
    setState(() {
      allProducts = productsFromDb;
      filteredProducts = productsFromDb; // Initialisation des produits filtrés
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) =>
              product['nom'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

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
                if (nameController.text.isEmpty ||
                    typeController.text.isEmpty ||
                    salePriceController.text.isEmpty ||
                    purchasePriceController.text.isEmpty ||
                    stockController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                  return;
                }

                final newProduct = Produit(
                  id: 0,
                  nom: nameController.text,
                  type: typeController.text,
                  pvente: double.tryParse(salePriceController.text) ?? 0.0,
                  pachat: double.tryParse(purchasePriceController.text) ?? 0.0,
                  qte: int.tryParse(stockController.text) ?? 0,
                );

                final db = DatabaseHelper.instance;
                await db.insertUser(newProduct);
                await _loadProducts();
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
    final TextEditingController nameController =
        TextEditingController(text: product['nom']);
    final TextEditingController typeController =
        TextEditingController(text: product['type']);
    final TextEditingController salePriceController =
        TextEditingController(text: product['p_vente'].toString());
    final TextEditingController purchasePriceController =
        TextEditingController(text: product['prix_achat'].toString());
    final TextEditingController stockController =
        TextEditingController(text: product['qte_stock'].toString());

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
                final updatedProduct = Produit(
                  id: product['id'],
                  nom: nameController.text,
                  type: typeController.text,
                  pvente: double.tryParse(salePriceController.text) ?? 0.0,
                  pachat: double.tryParse(purchasePriceController.text) ?? 0.0,
                  qte: int.tryParse(stockController.text) ?? 0,
                );

                final db = DatabaseHelper.instance;
                await db.updateUser(updatedProduct);
                await _loadProducts();
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
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = DatabaseHelper.instance;
                await db.deleteProduct(product['id']);
                await _loadProducts();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Supprimer'),
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) => _filterProducts(query),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(product['nom']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prix d\'achat: ${product['prix_achat']} \DA'),
                          Text('Prix de vente: ${product['p_vente']} \DA'),
                          Text('Quantité en stock: ${product['qte_stock']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editProduct(product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Ajouter un produit'),
              onPressed: _addProduct,
            ),
          ],
        ),
      ),
    );
  }
}
