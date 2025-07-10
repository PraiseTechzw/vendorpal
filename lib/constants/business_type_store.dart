import 'package:vendorpal/modals/business_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory store for the selected business type (mock logic)
BusinessType? selectedBusinessType;

/// Key for storing business type id in shared preferences
const String _businessTypeKey = 'selected_business_type_id';

/// Save the selected business type id to persistent storage
Future<void> saveSelectedBusinessType(BusinessType type) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_businessTypeKey, type.id);
  selectedBusinessType = type;
}

/// Load the selected business type from persistent storage
Future<void> loadSelectedBusinessType(List<BusinessType> allTypes) async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getString(_businessTypeKey);
  if (id != null) {
    selectedBusinessType = allTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => allTypes.first,
    );
  }
}

/// Key for storing onboarding completion in shared preferences
const String _onboardingCompleteKey = 'onboarding_complete';

/// Mark onboarding as complete in persistent storage
Future<void> setOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingCompleteKey, true);
}

/// Check if onboarding is complete
Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingCompleteKey) ?? false;
} 