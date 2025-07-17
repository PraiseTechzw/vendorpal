import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendorpal/databases/database.dart';
import 'package:vendorpal/modals/packages.dart';
import 'package:vendorpal/modals/business_type.dart';
import 'package:vendorpal/constants/business_type_store.dart';

class ProductFormWidget extends StatefulWidget {
  final StockItem? product;
  final BusinessType? businessType;

  const ProductFormWidget({Key? key, this.product, this.businessType}) : super(key: key);

  @override
  _ProductFormWidgetState createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String itemName;
  late String category;
  late String unit;
  late double purchasePrice;
  late double sellingPrice;
  late int stockQuantity;
  late DateTime dateAdded;
  // Special fields
  String? size;
  String? color;
  String? brand;
  DateTime? expiryDate;
  String? batchNumber;
  String? modelCompatibility;
  String? warranty;
  String? gender;
  String? specifications;

  bool _isLoading = false;

  BusinessType? get businessType => widget.businessType ?? selectedBusinessType;

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
      unit = businessType?.units.first ?? '';
    } else {
      itemName = '';
      category = '';
      purchasePrice = 0.0;
      sellingPrice = 0.0;
      stockQuantity = 0;
      dateAdded = DateTime.now();
      unit = businessType?.units.first ?? '';
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
      // TODO: Save special fields as needed
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
    if (businessType == null) {
      return const Center(child: Text('Please select a business type first.'));
    }
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header: Basic Info
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Basic Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
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
                  showValidation: true,
                ),
                _buildDropdownField(
                  value: category.isNotEmpty ? category : null,
                  labelText: 'Category',
                  icon: Icons.category,
                  items: businessType!.categories,
                  onChanged: (val) => setState(() => category = val ?? ''),
                  onSaved: (val) => category = val ?? '',
                  showValidation: true,
                ),
                _buildDropdownField(
                  value: unit.isNotEmpty ? unit : null,
                  labelText: 'Unit',
                  icon: Icons.straighten,
                  items: businessType!.units,
                  onChanged: (val) => setState(() => unit = val ?? ''),
                  onSaved: (val) => unit = val ?? '',
                  showValidation: true,
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
                  showValidation: true,
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
                  showValidation: true,
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
                  showValidation: true,
                ),
                // Section header: Special Fields
                if (_buildSpecialFields().isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                    child: Text(
                      'Special Fields',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                // Animated special fields
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: _buildSpecialFields(),
                  ),
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
                            borderRadius: BorderRadius.circular(30.0),
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

  // Helper for text fields
  Widget _buildTextFormField({
    required String initialValue,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
    bool showValidation = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    return StatefulBuilder(
      builder: (context, setFieldState) {
        bool isValid = !showValidation || (validator == null ? true : validator(controller.text) == null);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
              suffixIcon: showValidation
                  ? (isValid
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red))
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2.0),
                borderRadius: BorderRadius.circular(30.0),
              ),
              filled: true,
              fillColor: Colors.deepPurple[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            keyboardType: keyboardType,
            onChanged: (val) => setFieldState(() {}),
            onSaved: onSaved,
            validator: validator,
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  // Helper for dropdown fields
  Widget _buildDropdownField({
    required String? value,
    required String labelText,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required void Function(String?) onSaved,
    bool showValidation = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          filled: true,
          fillColor: Colors.deepPurple[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
        onSaved: onSaved,
        validator: (val) => val == null || val.isEmpty ? 'Please select $labelText' : null,
        icon: showValidation && value != null
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Dynamically build special fields based on business type
  List<Widget> _buildSpecialFields() {
    if (businessType == null) return [];
    final fields = <Widget>[];
    for (final field in businessType!.specialFields) {
      switch (field.toLowerCase()) {
        case 'expiry dates':
        case 'expiry date':
        case 'perishable alerts':
          fields.add(_buildDateField(
            labelText: 'Expiry Date',
            icon: Icons.event,
            value: expiryDate,
            onChanged: (date) => setState(() => expiryDate = date),
          ));
          break;
        case 'size':
          fields.add(_buildTextFormField(
            initialValue: size ?? '',
            labelText: 'Size',
            icon: Icons.straighten,
            onSaved: (val) => size = val,
          ));
          break;
        case 'color':
          fields.add(_buildTextFormField(
            initialValue: color ?? '',
            labelText: 'Color',
            icon: Icons.color_lens,
            onSaved: (val) => color = val,
          ));
          break;
        case 'brand':
          fields.add(_buildTextFormField(
            initialValue: brand ?? '',
            labelText: 'Brand',
            icon: Icons.branding_watermark,
            onSaved: (val) => brand = val,
          ));
          break;
        case 'batch number':
          fields.add(_buildTextFormField(
            initialValue: batchNumber ?? '',
            labelText: 'Batch Number',
            icon: Icons.confirmation_number,
            onSaved: (val) => batchNumber = val,
          ));
          break;
        case 'model compatibility':
          fields.add(_buildTextFormField(
            initialValue: modelCompatibility ?? '',
            labelText: 'Model Compatibility',
            icon: Icons.devices_other,
            onSaved: (val) => modelCompatibility = val,
          ));
          break;
        case 'warranty':
          fields.add(_buildTextFormField(
            initialValue: warranty ?? '',
            labelText: 'Warranty',
            icon: Icons.verified_user,
            onSaved: (val) => warranty = val,
          ));
          break;
        case 'gender':
          fields.add(_buildTextFormField(
            initialValue: gender ?? '',
            labelText: 'Gender',
            icon: Icons.wc,
            onSaved: (val) => gender = val,
          ));
          break;
        case 'specifications':
          fields.add(_buildTextFormField(
            initialValue: specifications ?? '',
            labelText: 'Specifications',
            icon: Icons.description,
            onSaved: (val) => specifications = val,
          ));
          break;
        default:
          break;
      }
    }
    return fields;
  }

  // Date picker field for expiry date, etc.
  Widget _buildDateField({
    required String labelText,
    required IconData icon,
    required DateTime? value,
    required void Function(DateTime) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value != null ? value.toShortDateString() : 'Select date',
                style: TextStyle(
                  color: value != null ? Colors.black87 : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
