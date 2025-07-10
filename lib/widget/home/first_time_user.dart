import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vendorpal/widget/product_form_widget.dart';
import 'package:vendorpal/widget/business_type_selector.dart';
import 'package:vendorpal/modals/business_type.dart';
import 'package:vendorpal/constants/business_type_store.dart';

class FirstTimeUserPrompt extends StatefulWidget {
  @override
  State<FirstTimeUserPrompt> createState() => _FirstTimeUserPromptState();
}

class _FirstTimeUserPromptState extends State<FirstTimeUserPrompt>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _onboardingComplete = false;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;

  // Mock state for basic setup
  String? _currency;
  String? _location;
  bool _prefersDark = false;
  bool _loadSampleData = false;

  final List<String> _currencies = ['USD', 'EUR', 'ZAR', 'NGN', 'ZWL'];
  final List<String> _locations = ['Zimbabwe', 'South Africa', 'Nigeria', 'Other'];

  @override
  void initState() {
    super.initState();
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _buttonScaleAnim = CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
      } else {
        _onboardingComplete = true;
      }
    });
    if (_currentStep == 4) {
      // On last step, mark onboarding complete
      await setOnboardingComplete();
    }
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete) {
      // Onboarding complete, show nothing or main app content
      return const Center(child: Text('Onboarding Complete!'));
    }
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3EFFF), Color(0xFFE1D8FF), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepper(),
                const SizedBox(height: 16),
                Expanded(child: _buildStepContent()),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _prevStep,
                    child: const Text('Back'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Stepper/progress indicator
  Widget _buildStepper() {
    const steps = [
      'Welcome',
      'Business Type',
      'Setup',
      'Sample Data',
      'Tutorial',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final active = i == _currentStep;
        return Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: active ? Colors.deepPurpleAccent : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? Colors.deepPurple : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (i < steps.length - 1)
              Container(
                width: 32,
                height: 2,
                color: Colors.deepPurpleAccent.withOpacity(0.5),
              ),
          ],
        );
      }),
    );
  }

  // Step content
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildBusinessTypeStep();
      case 2:
        return _buildBasicSetupStep();
      case 3:
        return _buildSampleDataStep();
      case 4:
        return _buildTutorialStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Welcome
  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/welcome.json',
          repeat: true,
          animate: true,
          width: 180,
          height: 180,
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to VendorPal!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        const Text(
          'Your smart, offline business manager. Get started in seconds!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.deepPurple,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        const Text(
          'Start by selecting your business type and adding your first product. All features work offline!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        ScaleTransition(
          scale: _buttonScaleAnim,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: Colors.deepPurple.withOpacity(0.2),
            ),
            onPressed: _nextStep,
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Business Type Selection
  Widget _buildBusinessTypeStep() {
    return BusinessTypeSelector(
      selectedBusinessTypeId: selectedBusinessType?.id,
      onSelected: (type) async {
        await saveSelectedBusinessType(type);
        setState(() {});
        Future.delayed(const Duration(milliseconds: 400), _nextStep);
      },
    );
  }

  // Step 3: Basic Setup
  Widget _buildBasicSetupStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Basic Setup',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _currency,
          decoration: InputDecoration(
            labelText: 'Currency',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: Colors.deepPurple[50],
          ),
          items: _currencies
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => _currency = val),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _location,
          decoration: InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: Colors.deepPurple[50],
          ),
          items: _locations
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => _location = val),
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          value: _prefersDark,
          onChanged: (val) => setState(() => _prefersDark = val),
          title: const Text('Enable Dark Mode'),
          activeColor: Colors.deepPurpleAccent,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _currency != null && _location != null ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }

  // Step 4: Sample Data
  Widget _buildSampleDataStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sample Data',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
        ),
        const SizedBox(height: 18),
        const Text(
          'Would you like to load some demo data to explore the app?',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          value: _loadSampleData,
          onChanged: (val) => setState(() => _loadSampleData = val),
          title: const Text('Load Demo Data'),
          activeColor: Colors.deepPurpleAccent,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }

  // Step 5: Tutorial
  Widget _buildTutorialStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty_state.json',
          repeat: true,
          animate: true,
          width: 160,
          height: 160,
        ),
        const SizedBox(height: 24),
        const Text(
          'Quick Tips',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
        ),
        const SizedBox(height: 14),
        const Text(
          '• Use the dashboard for a daily overview\n• Add products and sales easily\n• Get smart notifications and tips\n• All features work offline!',
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Finish', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }
}
