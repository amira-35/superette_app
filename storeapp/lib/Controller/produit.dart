class Produit {
  final int id;
  final String nom;
  final String type;
  final double pvente;  // Use double, not Double
  final double pachat;  // Use double, not Double
  final int qte;

  Produit({
    required this.id,
    required this.nom,
    required this.type,
    required this.pvente,
    required this.pachat,
    required this.qte,
  });

  // Map the object to a map for database insert
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'Type': type,
      'p_vente': pvente, // This should be a double
      'prix_achat': pachat, // This should be a double
      'qte_stock': qte,
    };
  }
 factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'] as int,
      nom: map['nom'] ?? '', // Handle null values
      type: map['type'] ?? '', // Handle null values
      pvente: (map['p_vente'] as num?)?.toDouble() ?? 0.0, // Handle null and convert num to double
      pachat: (map['prix_achat'] as num?)?.toDouble() ?? 0.0, // Handle null and convert num to double
      qte: map['qte_stock'] as int? ?? 0, // Handle null values
    );
  }
}
