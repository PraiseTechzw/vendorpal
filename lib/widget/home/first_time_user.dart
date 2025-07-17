import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vendorpal/widget/product_form_widget.dart';
import 'package:vendorpal/widget/business_type_selector.dart';
import 'package:vendorpal/modals/business_type.dart';
import 'package:vendorpal/constants/business_type_store.dart';
import 'dart:async';
import 'dart:ui';

class FirstTimeUserPrompt extends StatefulWidget {
  final VoidCallback? onComplete;
  const FirstTimeUserPrompt({Key? key, this.onComplete}) : super(key: key);
  @override
  State<FirstTimeUserPrompt> createState() => _FirstTimeUserPromptState();
}

class _FirstTimeUserPromptState extends State<FirstTimeUserPrompt>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _onboardingComplete = false;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnim;
  bool _showConfetti = false;

  // Animated gradient state
  int _gradientIndex = 0;
  late Timer _gradientTimer;
  final List<List<Color>> _gradients = [
    [Color(0xFFB388FF), Color(0xFF8C9EFF), Color(0xFF80D8FF)],
    [Color(0xFFE1BEE7), Color(0xFFB3E5FC), Color(0xFFD1C4E9)],
    [Color(0xFFF3EFFF), Color(0xFFE1D8FF), Color(0xFFD1C4E9)],
    [Color(0xFFB2EBF2), Color(0xFFB388FF), Color(0xFFD1C4E9)],
  ];

  // Mock state for basic setup
  String? _currency;
  String? _location;
  bool _prefersDark = false;
  bool _loadSampleData = false;

  // Replace _currencies and _locations with richer data for icons/symbols
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$'}, // $
    {'code': 'EUR', 'symbol': '€'}, // €
    {'code': 'ZAR', 'symbol': 'R'},
    {'code': 'NGN', 'symbol': '₦'}, // ₦
    {'code': 'ZWL', 'symbol': '\$'}, // $
  ];

  final List<Map<String, String>> _locations = [
    {'country': 'Zimbabwe', 'flag': '🇿🇼'},
    {'country': 'South Africa', 'flag': '🇿🇦'},
    {'country': 'Nigeria', 'flag': '🇳🇬'},
    {'country': 'Other', 'flag': '🌍'},
  ];

  String? _selectedTypeId;
  bool _isSavingType = false;

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
    // Start animated gradient timer
    _gradientTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradients.length;
      });
    });
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    _gradientTimer.cancel();
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
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
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
      // Onboarding complete, let parent handle navigation
      return const SizedBox.shrink();
    }
    // Make onboarding fill the screen
    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3EFFF), Color(0xFFE1D8FF), Color(0xFFD1C4E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Onboarding content
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepper(),
                  const SizedBox(height: 16),
                  // Remove Expanded here, just show the step content
                  _buildStepContent(),
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
      ],
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
    final isWide = MediaQuery.of(context).size.width > 600;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated gradient background
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradients[_gradientIndex],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Glassmorphism card with blur, border, and shadow
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.2,
                  ),
                ),
                child: isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo with shadow
                          Container(
                            margin: const EdgeInsets.only(right: 32),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo1.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                              semanticLabel: 'VendorPal Logo',
                            ),
                          ),
                          // Lottie animation
                          Lottie.asset(
                            'assets/animations/welcome.json',
                            repeat: true,
                            animate: true,
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(width: 32),
                          // Text content
                          Expanded(child: _buildWelcomeTextAndButton()),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with shadow
                          Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                              semanticLabel: 'VendorPal Logo',
                            ),
                          ),
                          // Lottie animation
        Lottie.asset(
                            'assets/animations/welcome.json',
          repeat: true,
          animate: true,
                            width: 140,
                            height: 140,
                          ),
                          const SizedBox(height: 18),
                          _buildWelcomeTextAndButton(),
                        ],
                      ),
              ),
            ),
          ),
        ),
        // Mock confetti/sparkle overlay
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/empty_state.json', // Use an existing animation as mock confetti
                    width: 180,
                    height: 180,
                    repeat: false,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Extracted text/button for clarity and reuse
  Widget _buildWelcomeTextAndButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Welcome to VendorPal!',
          style: TextStyle(
            fontFamily: 'Roboto-Bold',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Your smart, offline business manager.',
          style: TextStyle(
            fontFamily: 'Roboto-Regular',
            fontSize: 18,
            color: Colors.deepPurple,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Get started in seconds. All features work offline!',
          style: TextStyle(
            fontFamily: 'Roboto-Regular',
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ScaleTransition(
          scale: _buttonScaleAnim,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.deepPurple.withOpacity(0.2),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() => _showConfetti = true);
                Future.delayed(const Duration(seconds: 1), () {
                  setState(() => _showConfetti = false);
                  _nextStep();
                });
              },
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Business Type Selection
  Widget _buildBusinessTypeStep() {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2.2,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Your Business Type',
                      style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    // Animated business type selector
                    BusinessTypeSelector(
                      selectedBusinessTypeId: selectedBusinessType?.id,
                      onSelected: (type) async {
                        await saveSelectedBusinessType(type);
                        setState(() {
                          _selectedTypeId = type.id;
                        });
                        Future.delayed(const Duration(milliseconds: 200), _nextStep);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Remove the Continue button here to avoid duplicate
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     ...
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Step 3: Basic Setup
  Widget _buildBasicSetupStep() {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated gradient background (reuse onboarding background)
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradients[_gradientIndex],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Glassmorphism card with form
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Basic Setup',
                      style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.deepPurpleAccent),
                      ),
                      items: _currencies
                          .map((e) => DropdownMenuItem<String>(
                                value: e['code'],
                                child: Row(
                                  children: [
                                    Text(e['symbol']!, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(e['code']!),
                                  ],
                                ),
                              ))
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
                        prefixIcon: const Icon(Icons.location_on, color: Colors.deepPurpleAccent),
                      ),
                      items: _locations
                          .map((e) => DropdownMenuItem<String>(
                                value: e['country'],
                                child: Row(
                                  children: [
                                    Text(e['flag']!, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(e['country']!),
                                  ],
                                ),
                              ))
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _currency != null && _location != null ? _nextStep : null,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Sample Data
  Widget _buildSampleDataStep() {
    final isWide = MediaQuery.of(context).size.width > 600;
    // Mock sample data preview
    final List<Map<String, String>> sampleProducts = [
      {'name': 'Premium Rice', 'category': 'Groceries'},
      {'name': 'Blue Denim Jeans', 'category': 'Clothing'},
      {'name': 'Shea Butter Cream', 'category': 'Cosmetics'},
      {'name': 'Wireless Earbuds', 'category': 'Electronics'},
      {'name': 'Hammer', 'category': 'Hardware'},
    ];
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated gradient background
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradients[_gradientIndex],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Glassmorphism card with sample data toggle and preview
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.info_outline, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'You can load sample data to explore the app. This will add a few demo products and categories. You can remove them later.',
                            style: TextStyle(fontSize: 15, color: Colors.deepPurple, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SwitchListTile(
                      value: _loadSampleData,
                      onChanged: (val) => setState(() => _loadSampleData = val),
                      title: const Text('Load Demo Data'),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                    if (_loadSampleData) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sample Products:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 90,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: sampleProducts.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, i) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(sampleProducts[i]['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(sampleProducts[i]['category']!, style: const TextStyle(fontSize: 13, color: Colors.deepPurple)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextStep,
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
                  ],
                ),
              ),
            ),
          ),
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
