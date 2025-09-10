import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ZenDo/providers/theme_provider.dart';
import 'package:ZenDo/utils/responsive.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri);
    } catch (e) {
      print('Error launching URL: $e');
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
          title: Text(
            'About Developer',
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.textSize(18, context),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: Responsive.textSize(24, context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.width(5, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(context),
              SizedBox(height: Responsive.height(3, context)),
              Text(
                'Abu Taher Siddiki Adnan',
                style: TextStyle(
                  fontSize: Responsive.textSize(22, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.height(1.5, context)),
              Text(
                'Flutter Developer',
                style: TextStyle(
                  fontSize: Responsive.textSize(16, context),
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: Responsive.height(3, context)),
              _buildLinkCard(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'adnan02802@gmail.com',
                onTap: () => _launchURL('mailto:adnan02802@gmail.com'),
                isDarkMode: isDarkMode,
                context: context,
              ),
              _buildLinkCard(
                icon: Icons.facebook,
                title: 'Facebook',
                subtitle: 'facebook.com/adnan.siddik.282',
                onTap: () =>
                    _launchURL('https://www.facebook.com/adnan.siddik.282'),
                isDarkMode: isDarkMode,
                context: context,
              ),
              _buildLinkCard(
                icon: Icons.work,
                title: 'LinkedIn',
                subtitle: 'linkedin.com/in/abu-taher-siddiki-adnan',
                onTap: () => _launchURL(
                  'https://www.linkedin.com/in/abu-taher-siddiki-adnan/',
                ),
                isDarkMode: isDarkMode,
                context: context,
              ),
              _buildLinkCard(
                icon: Icons.code,
                title: 'GitHub',
                subtitle: 'github.com/Abu-Taher-Siddiki-Adnan',
                onTap: () =>
                    _launchURL('https://github.com/Abu-Taher-Siddiki-Adnan'),
                isDarkMode: isDarkMode,
                context: context,
              ),
              SizedBox(height: Responsive.height(2, context)),
              Text(
                'ZenDo App Version: 1.1.0+2',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: Responsive.textSize(14, context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Container(
      width: Responsive.width(50, context),
      height: Responsive.width(50, context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: Responsive.width(0.7, context),
        ),
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
        radius: Responsive.width(17, context),
        backgroundImage: const AssetImage('assets/images/adnan.png'),
        onBackgroundImageError: (exception, stackTrace) {},
        child: FutureBuilder<bool>(
          future: _checkIfImageExists(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: Responsive.width(0.5, context),
              );
            }

            if (snapshot.data == false) {
              return Icon(
                Icons.person,
                size: Responsive.textSize(40, context),
                color: Colors.white,
              );
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
    required BuildContext context,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: Responsive.height(1, context)),
      color: isDarkMode
          ? Colors.black.withOpacity(0.7)
          : Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.width(3, context)),
      ),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryCyan,
          size: Responsive.textSize(24, context),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: Responsive.textSize(16, context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: Responsive.textSize(14, context),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: Responsive.textSize(16, context),
          color: isDarkMode ? Colors.white70 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
