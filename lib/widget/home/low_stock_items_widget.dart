import 'package:flutter/material.dart';
import 'package:vendorpal/modals/packages.dart';

class LowStockItems extends StatelessWidget {
  final List<StockItem> lowStockItems;

  const LowStockItems({required this.lowStockItems});

  @override
  Widget build(BuildContext context) {
    final bool hasLowStock = lowStockItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Low Stock Items',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 16),
        if (hasLowStock)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStockItems.length,
            itemBuilder: (context, index) {
              final item = lowStockItems[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color:
                    index % 2 == 0 ? Colors.red.shade50 : Colors.orange.shade50,
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      '${item.stockQuantity}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Only ${item.stockQuantity} left in stock!',
                    style: TextStyle(
                      color: index % 2 == 0 ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.warning, color: Colors.redAccent),
                ),
              );
            },
          )
        else
          const Text(
            'All stock levels are adequate.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        const SizedBox(height: 16),
        // Adding an additional card for informational purposes
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: hasLowStock ? Colors.blue.shade50 : Colors.green.shade50,
          elevation: 5,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  hasLowStock ? Colors.blueAccent : Colors.greenAccent,
              child: Icon(
                hasLowStock ? Icons.info : Icons.check_circle,
                color: Colors.white,
              ),
            ),
            title: Text(
              hasLowStock ? 'Stock Management Tips' : 'Stock Levels Good',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              hasLowStock
                  ? 'Ensure to reorder stock before it runs out!'
                  : 'Great! All stock levels are well-maintained. Keep it up!',
              style: TextStyle(
                color: hasLowStock ? Colors.blue : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
