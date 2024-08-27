import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vendorpal/widget/product_form_widget.dart';

class FirstTimeUserPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/w.json',
          repeat: true,
          animate: true,
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome to VendorPal!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Start by adding your sales and stock data to see analytics here.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            shadowColor: Colors.purpleAccent,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const ProductFormWidget(),
            );
          },
          child: const Text(
            'Get Started',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
