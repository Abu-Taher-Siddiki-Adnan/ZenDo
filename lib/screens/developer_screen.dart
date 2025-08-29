import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/providers/theme_provider.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      decoration: AppTheme.gradientBoxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('About Developer'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(context),
              const SizedBox(height: 25),
              const Text(
                'Abu Taher Siddiki Adnan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Flutter Developer',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              const SizedBox(height: 30),
              _buildLinkCard(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'adnan02802@gmail.com',
                onTap: () => _launchURL('mailto:adnan02802@gmail.com'),
                isDarkMode: isDarkMode,
              ),
              _buildLinkCard(
                icon: Icons.facebook,
                title: 'Facebook',
                subtitle: 'facebook.com/adnan.siddik.282',
                onTap: () =>
                    _launchURL('https://www.facebook.com/adnan.siddik.282'),
                isDarkMode: isDarkMode,
              ),
              _buildLinkCard(
                icon: Icons.work,
                title: 'LinkedIn',
                subtitle: 'linkedin.com/in/abu-taher-siddiki-adnan',
                onTap: () => _launchURL(
                  'https://www.linkedin.com/in/abu-taher-siddiki-adnan/',
                ),
                isDarkMode: isDarkMode,
              ),
              _buildLinkCard(
                icon: Icons.code,
                title: 'GitHub',
                subtitle: 'github.com/Abu-Taher-Siddiki-Adnan',
                onTap: () =>
                    _launchURL('https://github.com/Abu-Taher-Siddiki-Adnan'),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 20),
              const Text(
                'ZenDo App Version: 1.0.0',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 70,
        backgroundImage: const AssetImage('assets/images/adnan.png'),
        onBackgroundImageError: (exception, stackTrace) {},
        child: FutureBuilder<bool>(
          future: _checkIfImageExists(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            }

            if (snapshot.data == false) {
              return const Icon(Icons.person, size: 60, color: Colors.white);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<bool> _checkIfImageExists(BuildContext context) async {
    try {
      await precacheImage(const AssetImage('assets/images/adnan.png'), context);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode
          ? Colors.black.withOpacity(0.7)
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryCyan),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDarkMode ? Colors.white70 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
