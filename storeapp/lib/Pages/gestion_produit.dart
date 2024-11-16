import 'package:flutter/material.dart';

class ProductManagementPage extends StatefulWidget {
  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  // Liste de produits
  List<Map<String, dynamic>> products = [
    {'id': 1, 'name': 'Produit 1', 'purchasePrice': 5.0, 'salePrice': 10.0, 'stock': 50},
    {'id': 2, 'name': 'Produit 2', 'purchasePrice': 7.0, 'salePrice': 14.0, 'stock': 30},
    {'id': 3, 'name': 'Produit 3', 'purchasePrice': 3.0, 'salePrice': 6.0, 'stock': 100},
  ];

  // Méthode pour ajouter un produit
  void _addProduct() {
    // Afficher un formulaire de saisie pour le nouveau produit
  }

  // Méthode pour modifier un produit
  void _editProduct(Map<String, dynamic> product) {
    // Afficher un formulaire de modification pour le produit sélectionné
  }

  // Méthode pour supprimer un produit
  void _deleteProduct(int id) {
    setState(() {
      products.removeWhere((product) => product['id'] == id);
    });
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
              onChanged: (value) {
                // Ajouter la logique de recherche ici
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
                      title: Text(product['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prix d\'achat: ${product['purchasePrice'].toStringAsFixed(2)} \$'),
                          Text('Prix de vente: ${product['salePrice'].toStringAsFixed(2)} \$'),
                          Text('Quantité en stock: ${product['stock']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton Modifier
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editProduct(product),
                          ),
                          // Bouton Supprimer
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product['id']),
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

