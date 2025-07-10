// Business type model and mock data for VendorPal
// Represents a business category and its adaptive properties

class BusinessType {
  final String id;
  final String name;
  final List<String> units;
  final List<String> specialFields;
  final List<String> categories;
  final List<String> terminology;
  final List<String> smartFeatures;

  const BusinessType({
    required this.id,
    required this.name,
    required this.units,
    required this.specialFields,
    required this.categories,
    required this.terminology,
    required this.smartFeatures,
  });
}

// Mock data for supported business types
const List<BusinessType> businessTypes = [
  BusinessType(
    id: 'groceries',
    name: 'Groceries & Kiosk',
    units: ['kg', 'grams', 'liters', 'packs', 'pieces'],
    specialFields: ['Expiry dates', 'Perishable alerts', 'Unit types'],
    categories: ['Staples', 'Beverages', 'Snacks', 'Cleaning', 'Personal Care'],
    terminology: ['Stock', 'Unit/Weight', 'Restock Alert', 'Profit Margin'],
    smartFeatures: [
      'Expiry date tracking with alerts',
      'Perishable item rotation reminders',
      'Bulk purchase suggestions',
      'Seasonal demand tracking',
    ],
  ),
  BusinessType(
    id: 'clothing',
    name: 'Boutique & Clothing',
    units: ['pieces', 'pairs', 'sets'],
    specialFields: ['Size', 'Color', 'Gender', 'Brand'],
    categories: ['Tops', 'Bottoms', 'Dresses', 'Shoes', 'Accessories'],
    terminology: ['Inventory', 'Size/Color', 'Reorder Items', 'Markup'],
    smartFeatures: [
      'Size/color combination tracking',
      'Seasonal trend analysis',
      'Popular size monitoring',
      'Style variant management',
    ],
  ),
  BusinessType(
    id: 'cosmetics',
    name: 'Cosmetics & Beauty',
    units: ['pieces', 'ml', 'grams'],
    specialFields: ['Brand', 'Shade', 'Batch number', 'Expiry date'],
    categories: ['Skincare', 'Makeup', 'Haircare', 'Fragrance', 'Tools'],
    terminology: ['Products', 'Shade/Size', 'Reorder Stock', 'Margin'],
    smartFeatures: [
      'Batch number tracking',
      'Shade popularity analysis',
      'Beauty trend alerts',
      'Storage condition reminders',
    ],
  ),
  BusinessType(
    id: 'electronics',
    name: 'Electronics & Accessories',
    units: ['pieces', 'sets', 'packs'],
    specialFields: ['Model compatibility', 'Warranty', 'Brand'],
    categories: ['Phones', 'Accessories', 'Chargers', 'Cases', 'Audio'],
    terminology: ['Stock', 'Model/Type', 'Reorder Alert', 'Markup'],
    smartFeatures: [
      'Device compatibility tracking',
      'Warranty management',
      'Tech trend updates',
      'Model-specific inventory',
    ],
  ),
  BusinessType(
    id: 'hardware',
    name: 'General Hardware',
    units: ['pieces', 'kg', 'meters', 'liters', 'packs'],
    specialFields: ['Unit type', 'Brand', 'Specifications'],
    categories: ['Tools', 'Materials', 'Supplies', 'Parts', 'Equipment'],
    terminology: ['Inventory', 'Unit/Spec', 'Reorder', 'Margin'],
    smartFeatures: [
      'Specification tracking',
      'Bulk pricing analysis',
      'Seasonal demand patterns',
      'Tool category organization',
    ],
  ),
]; 