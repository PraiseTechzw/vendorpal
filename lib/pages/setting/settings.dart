import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:vendorpal/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendorpal/main.dart';
import 'package:vendorpal/pages/setting/about.dart';
import 'package:vendorpal/pages/setting/privacypolicy.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Settings"),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              buildSettingsOption(
                  "Theme", Icons.color_lens, _openThemeSettings),
              buildDivider(),
              buildSettingsOption(
                  "Privacy", Icons.privacy_tip, _openPrivacyPolicy),
              buildDivider(),
              buildSettingsOption("Support Us", Icons.support, _openSupportUs),
              buildDivider(),
              buildSettingsOption("Feedback", Icons.feedback, _sendFeedback),
              buildDivider(),
              buildSettingsOption("About", Icons.info, _openAboutPage),
              const SizedBox(height: 30),
              const Text(
                "Follow Us",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  buildSocialIcon(Ionicons.logo_facebook, _openFacebook),
                  const SizedBox(width: 10),
                  buildSocialIcon(Ionicons.logo_whatsapp, _openWhatsApp),
                  const SizedBox(width: 10),
                  buildSocialIcon(Ionicons.logo_github, _openGitHub),
                  const SizedBox(width: 10),
                  buildSocialIcon(Ionicons.logo_linkedin, _openLinkedIn),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildSettingsOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(
              icon,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: black.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return const Divider(
      color: Colors.grey,
      height: 1,
    );
  }

  void _openThemeSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context);
        bool isDarkTheme = themeNotifier.isDarkMode;
        return Container(
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

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PrivacyPolicyPage(), // Ensure proper navigation
      ),
    );
  }

  void _openAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(), // Ensure proper navigation
      ),
    );
  }

  void _openSupportUs() async {
    final Uri url = Uri.parse(
        'https://yourwebsite.com/support-us'); // Replace with your support page URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'praisetechzw@gmail.com', // Replace with your feedback email
      query:
          'subject=App Feedback&body=App Version 1.0.0', // Add any additional query parameters
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _openFacebook() async {
    final Uri url = Uri.parse(
        'https://www.facebook.com/praisetechzw/'); // Replace with your Facebook page URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/+263786223289/'); // Replace with your WhatsApp number
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

//
  void _openGitHub() async {
    final Uri url = Uri.parse(
        'https://github.com/yourprofile'); // Replace with your GitHub profile URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openLinkedIn() async {
    final Uri url = Uri.parse(
        'https://www.linkedin.com/in/yourprofile'); // Replace with your LinkedIn profile URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
