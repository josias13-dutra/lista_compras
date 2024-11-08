import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rive/rive.dart';
import '../controller/item_controller.dart';
import '../model/item.dart';

class ShoppingListView extends StatefulWidget {
  @override
  _ShoppingListViewState createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  final ItemController _controller = ItemController();
  final List<Item> _items = [];
  Uint8List? _cartImage;
  final GlobalKey _cartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _controller.fetchItems();
    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  Future<void> _captureCartImage() async {
    // Captura o widget `ShoppingCartAnimation` como uma imagem usando RepaintBoundary
    RenderRepaintBoundary boundary =
    _cartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    setState(() {
      _cartImage = byteData!.buffer.asUint8List();
    });
  }

  Future<void> _addItem(String name, int quantity) async {
    await _controller.addItem(name, quantity);
    _loadItems();
  }

  Future<void> _updateItem(Item item) async {
    await _controller.updateItem(item);
    _loadItems();
  }

  Future<void> _deleteItem(int id) async {
    await _controller.deleteItem(id);
    _loadItems();
  }

  void _showEditDialog(Item item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome do Item'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final updatedItem = Item(
                  id: item.id,
                  name: nameController.text,
                  quantity: int.parse(quantityController.text),
                  isBought: item.isBought,
                );
                _updateItem(updatedItem);
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePDF() async {
    await _captureCartImage(); // Captura a imagem antes de gerar o PDF
    final pdf = pw.Document();

    // Adiciona a imagem capturada ao PDF (se disponível)
    if (_cartImage != null) {
      final cartImage = pw.MemoryImage(_cartImage!);
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              pw.Image(cartImage, width: 100, height: 100), // Imagem do carrinho
              pw.ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return pw.Text('${item.name} - ${item.quantity}');
                },
              ),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Compras')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                RepaintBoundary(
                  key: _cartKey,
                  child: ShoppingCartAnimation(),
                ),
                Expanded(
                  child: ShoppingForm(onAddItem: _addItem),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text('${item.name} - ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditDialog(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item.id!),
                      ),
                      Checkbox(
                        value: item.isBought,
                        onChanged: (value) {
                          setState(() {
                            item.isBought = value!;
                          });
                          _updateItem(item);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _generatePDF,
            child: Text('Gerar PDF'),
          ),
        ],
      ),
    );
  }
}

// Widget da Imagem Animada (Carrinho de Compras)
class ShoppingCartAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: RiveAnimation.asset(
        'assets/animations/new_file.riv',
        fit: BoxFit.contain,
      ),
    );
  }
}

// Widget do Formulário de Entrada
class ShoppingForm extends StatefulWidget {
  final Function(String, int) onAddItem;

  ShoppingForm({required this.onAddItem});

  @override
  _ShoppingFormState createState() => _ShoppingFormState();
}

class _ShoppingFormState extends State<ShoppingForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void _submit() {
    final name = _nameController.text;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    widget.onAddItem(name, quantity);
    _nameController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nome do Item'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantidade'),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _submit,
        ),
      ],
    );
  }
}
