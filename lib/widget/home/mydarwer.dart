import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendorpal/main.dart';
import 'package:vendorpal/pages/setting/about.dart';
import 'package:vendorpal/pages/setting/privacypolicy.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo1.png', height: 60),
                const SizedBox(width: 15),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildSettingsOption(context, "Theme", Ionicons.color_palette,
                    () => _openThemeSettings(context)),
                buildDivider(),
                buildSettingsOption(
                    context,
                    "Privacy",
                    Ionicons.shield_checkmark,
                    () => _openPrivacyPolicy(context)),
                buildDivider(),
                buildSettingsOption(context, "Support Us", Ionicons.heart,
                    () => _openSupportUs(context)),
                buildDivider(),
                buildSettingsOption(context, "Feedback",
                    Ionicons.chatbox_ellipses, () => _sendFeedback(context)),
                buildDivider(),
                buildSettingsOption(context, "About",
                    Ionicons.information_circle, () => _openAboutPage(context)),
              ],
            ),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Follow Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildSocialIconButton(
                  Ionicons.logo_whatsapp,
                  'https://wa.me/+263786223289/',
                  Colors.green,
                ),
                buildSocialIconButton(
                  Ionicons.logo_facebook,
                  'https://www.facebook.com/praisetechzw/',
                  Colors.blueAccent,
                ),
                buildSocialIconButton(
                  Ionicons.logo_github,
                  'https://github.com/PraiseTechzw',
                  Colors.black,
                ),
                buildSocialIconButton(
                  Ionicons.logo_linkedin,
                  'https://www.linkedin.com/in/praise-masunga-264288297/',
                  Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildSettingsOption(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Ionicons.chevron_forward, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget buildDivider() {
    return const Divider(
      color: Colors.grey,
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget buildSocialIconButton(IconData icon, String url, Color color) {
    return IconButton(
      onPressed: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      icon: Icon(icon, color: color, size: 30),
    );
  }

  void _openThemeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        final themeNotifier =
            Provider.of<ThemeNotifier>(context, listen: false);
        bool isDarkTheme = themeNotifier.isDarkMode;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dark Theme',
                    style: TextStyle(fontSize: 18),
                  ),
                  CupertinoSwitch(
                    value: isDarkTheme,
                    onChanged: (value) {
                      themeNotifier.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Light Theme',
                    style: TextStyle(fontSize: 18),
                  ),
                  CupertinoSwitch(
                    value: !isDarkTheme,
                    onChanged: (value) {
                      themeNotifier.toggleTheme(!value);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  void _openAboutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(),
      ),
    );
  }

  void _openSupportUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Support Us',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'If you enjoy using our app, consider buying us a coffee! '
            'Your support helps us keep the development going. '
            'Ecocash on +263786223289.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendFeedback(BuildContext context) {
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Send Feedback',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: feedbackController,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String feedback = feedbackController.text.trim();
                if (feedback.isNotEmpty) {
                  _sendToWhatsApp(feedback);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _sendToWhatsApp(String feedback) async {
    String phoneNumber = '+263786223289'; // Replace with the desired number
    String url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(feedback)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
