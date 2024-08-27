import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'VendorPal is committed to protecting your privacy. This privacy policy explains how we collect, use, and protect your personal information, even though the app operates entirely offline and requires no sign-in or registration.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildSectionTitle('1. Information Collection'),
                    const SizedBox(height: 15),
                    const Text(
                      'Since VendorPal operates offline and doesn’t require sign-in or registration, we do not collect any personal information from users.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildSectionTitle('2. Use of Information'),
                    const SizedBox(height: 15),
                    const Text(
                      'As no personal information is collected, there is no data to use. VendorPal is designed to function entirely on your device, keeping your data private and secure.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildSectionTitle('3. Sharing of Information'),
                    const SizedBox(height: 15),
                    const Text(
                      'VendorPal does not share any information because no personal data is collected or stored. Your usage remains completely private and offline.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildSectionTitle('4. Data Security'),
                    const SizedBox(height: 15),
                    const Text(
                      'Although VendorPal operates offline, we ensure that all operations within the app are secure. Your data stays on your device, fully under your control.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildSectionTitle('5. Changes to This Policy'),
                    const SizedBox(height: 15),
                    const Text(
                      'We may update this privacy policy periodically. Since the app does not connect to the internet, any updates will be provided with app updates.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildSectionTitle('6. Contact Us'),
                    const SizedBox(height: 15),
                    const Text(
                      'If you have any questions or concerns about our privacy policy, please contact us at praisetechzw@gmail.com.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
