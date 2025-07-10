import 'package:flutter/material.dart';
import 'package:vendorpal/modals/business_type.dart';

/// Bottom sheet for selecting a business type
/// Shows all business types with icons and descriptions
class BusinessTypeSelector extends StatefulWidget {
  /// Optionally pass the currently selected business type id
  final String? selectedBusinessTypeId;
  final void Function(BusinessType) onSelected;

  const BusinessTypeSelector({
    Key? key,
    this.selectedBusinessTypeId,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<BusinessTypeSelector> createState() => _BusinessTypeSelectorState();
}

class _BusinessTypeSelectorState extends State<BusinessTypeSelector>
    with SingleTickerProviderStateMixin {
  String? _selectedId;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedBusinessTypeId;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper/progress indicator
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepCircle(true),
                          _buildStepLine(),
                          _buildStepCircle(false),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Step 1 of 2',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Your Business Type',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // Business type cards
                ...businessTypes.map((type) => _buildTypeTile(type)).toList(),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _selectedId == null
                        ? null
                        : () {
                            final selected = businessTypes.firstWhere((t) => t.id == _selectedId);
                            widget.onSelected(selected);
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                    child: const Text('Continue', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a stepper circle
  Widget _buildStepCircle(bool active) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: active ? Colors.deepPurpleAccent : Colors.grey[300],
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? Colors.deepPurple : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: active
          ? const Center(
              child: Icon(Icons.check, size: 12, color: Colors.white),
            )
          : null,
    );
  }

  /// Builds a stepper line
  Widget _buildStepLine() {
    return Container(
      width: 32,
      height: 2,
      color: Colors.deepPurpleAccent.withOpacity(0.5),
    );
  }

  /// Builds a selectable card for each business type
  Widget _buildTypeTile(BusinessType type) {
    // Icon mapping for business types (expand as needed)
    final iconMap = {
      'groceries': Icons.local_grocery_store,
      'clothing': Icons.checkroom,
      'cosmetics': Icons.brush,
      'electronics': Icons.devices_other,
      'hardware': Icons.handyman,
    };
    final isSelected = _selectedId == type.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple[50] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? Colors.deepPurpleAccent : Colors.grey[300]!,
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.deepPurpleAccent : Colors.deepPurple[100],
          radius: 28,
          child: Icon(iconMap[type.id] ?? Icons.store, color: Colors.white, size: 32),
        ),
        title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            type.smartFeatures.first,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? Colors.deepPurple : Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent, size: 28)
            : null,
        onTap: () => setState(() => _selectedId = type.id),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }
} 