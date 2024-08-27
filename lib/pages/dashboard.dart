import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Map<String, double>? pieChartData;

  DashboardWidget({
    required this.child,
    this.isLoading = false,
    this.pieChartData,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashboardBackgroundPainter(),
      child: Column(
        children: [
          child,
          if (isLoading)
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text('Loading...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class DashboardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.4, 0, size.height * 0.3)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
