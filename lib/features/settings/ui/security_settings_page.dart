import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/security_service.dart';
import 'security_page.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  void initState() {
    super.initState();
    SecurityService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final securityService = SecurityService.instance;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 1,
        title: Text(
          "Security",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: "Numeric Password",
            themeProvider: themeProvider,
            children: [
              ListTile(
                leading: Icon(Icons.lock, color: themeProvider.accentColor),
                title: Text(
                  "Use Numeric Password",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Switch(
                  value: securityService.isPasswordEnabled(),
                  activeThumbColor: themeProvider.accentColor,
                  onChanged: (value) async {
                    if (value) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SecurityPage(mode: SecurityPageMode.setup),
                        ),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    } else {
                      await _disablePassword(context);
                    }
                  },
                ),
              ),
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(Icons.vpn_key, color: themeProvider.accentColor),
                title: Text(
                  "Change Password",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeProvider.subtitleColor,
                ),
                enabled: securityService.isPasswordEnabled(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SecurityPage(mode: SecurityPageMode.change),
                    ),
                  );
                },
              ),
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(
                  Icons.remove_circle,
                  color: securityService.isPasswordEnabled()
                      ? Colors.red
                      : themeProvider.subtitleColor,
                ),
                title: Text(
                  "Remove Password",
                  style: TextStyle(
                    color: securityService.isPasswordEnabled()
                        ? Colors.red
                        : themeProvider.subtitleColor,
                  ),
                ),
                enabled: securityService.isPasswordEnabled(),
                onTap: () async {
                  final ctx = context;
                  final confirm = await _showConfirmDialog(
                    ctx,
                    "Remove Password",
                    "Are you sure you want to remove the numeric password?",
                  );
                  if (confirm && mounted) {
                    final disableCtx = ctx;
                    await _disablePassword(disableCtx);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (securityService.isPasswordEnabled())
            _buildSection(
              title: "Security Info",
              themeProvider: themeProvider,
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: themeProvider.accentColor),
                  title: Text(
                    "Password is enabled",
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  subtitle: Text(
                    "You will need to enter your numeric password to access the app.",
                    style: TextStyle(color: themeProvider.subtitleColor),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _disablePassword(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final securityService = SecurityService.instance;

    if (securityService.isPasswordEnabled()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final currentPassword = await _showPasswordDialog(
        context,
        "Enter Current Password",
        themeProvider,
      );

      if (currentPassword != null) {
        if (securityService.verifyPassword(currentPassword)) {
          await securityService.disablePassword();
          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Password removed successfully'),
              backgroundColor: themeProvider.accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          setState(() {});
        } else {
          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Incorrect password'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  Future<String?> _showPasswordDialog(
    BuildContext context,
    String title,
    ThemeProvider themeProvider,
  ) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(title, style: TextStyle(color: themeProvider.textColor)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter password",
            hintStyle: TextStyle(color: themeProvider.subtitleColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: themeProvider.accentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: themeProvider.accentColor,
                width: 2,
              ),
            ),
          ),
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: themeProvider.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.accentColor,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              title,
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              message,
              style: TextStyle(color: themeProvider.textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: themeProvider.subtitleColor),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Confirm"),
              ),
            ],
          ),
        )
        as Future<bool>;
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: themeProvider.textColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
