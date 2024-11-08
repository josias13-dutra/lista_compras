class Item {
  int? id;
  String name;
  int quantity;
  bool isBought;

  Item({this.id, required this.name, required this.quantity, this.isBought = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isBought': isBought ? 1 : 0,
    };
  }

  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      isBought: map['isBought'] == 1,
    );
  }
}
