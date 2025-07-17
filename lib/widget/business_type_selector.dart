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
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Let parent handle padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper/progress indicator (optional, can be removed if handled by parent)
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedId == null
                        ? null
                        : () {
                            final selected = businessTypes.firstWhere((t) => t.id == _selectedId);
                            widget.onSelected(selected);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.deepPurple.withOpacity(0.2),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Continue', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
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
    final iconMap = {
      'groceries': Icons.local_grocery_store,
      'clothing': Icons.checkroom,
      'cosmetics': Icons.brush,
      'electronics': Icons.devices_other,
      'hardware': Icons.handyman,
    };
    final isSelected = _selectedId == type.id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedId = type.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: isSelected ? Curves.elasticOut : Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        transform: isSelected ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple[100] : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.deepPurpleAccent : Colors.grey[300]!,
            width: isSelected ? 3.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
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
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ListTile(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 18,
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text('Selected!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 