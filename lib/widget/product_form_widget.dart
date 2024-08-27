import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/modals/packages.dart';

class ProductFormWidget extends StatefulWidget {
  final StockItem? product;

  const ProductFormWidget({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormWidgetState createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String itemName;
  late String category;
  late double purchasePrice;
  late double sellingPrice;
  late int stockQuantity;
  late DateTime dateAdded;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      itemName = widget.product!.itemName;
      category = widget.product!.category;
      purchasePrice = widget.product!.purchasePrice;
      sellingPrice = widget.product!.sellingPrice;
      stockQuantity = widget.product!.stockQuantity;
      dateAdded = widget.product!.dateAdded;
    } else {
      itemName = '';
      category = '';
      purchasePrice = 0.0;
      sellingPrice = 0.0;
      stockQuantity = 0;
      dateAdded = DateTime.now();
    }
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1).toLowerCase()}';
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      itemName = _capitalize(itemName);
      category = _capitalize(category);

      final newProduct = StockItem(
        itemName: itemName,
        category: category,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stockQuantity: stockQuantity,
        dateAdded: dateAdded,
      );
      setState(() {
        _isLoading = true;
      });
      try {
        if (widget.product != null) {
          newProduct.id = widget.product!.id;
          await IsarService().updateStockItem(newProduct);
        } else {
          await IsarService().addStockItem(newProduct);
        }
        _showToast('Product added successfully!');
        Navigator.pop(context);
      } catch (e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred!'),
            content:
                const Text('Something went wrong. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(
                  initialValue: itemName,
                  labelText: 'Product Name',
                  icon: Icons.label,
                  onSaved: (value) => itemName = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item name';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  initialValue: category,
                  labelText: 'Category',
                  icon: Icons.category,
                  onSaved: (value) => category = value!,
                ),
                _buildTextFormField(
                  initialValue: purchasePrice.toString(),
                  labelText: 'Purchase Price',
                  icon: Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => purchasePrice = double.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the purchase price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  initialValue: sellingPrice.toString(),
                  labelText: 'Selling Price',
                  icon: Icons.monetization_on,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => sellingPrice = double.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the selling price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  initialValue: stockQuantity.toString(),
                  labelText: 'Stock Quantity',
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  onSaved: (value) => stockQuantity = int.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the stock quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _saveForm,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Save Product',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              const Color(0xFF6200EE), // Purple color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 8.0, // Added shadow for depth
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String initialValue,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
