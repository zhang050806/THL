import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';
import '../widgets/connect_section.dart';

class ConnectDevicePage extends StatelessWidget {
  const ConnectDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.connectDevice),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConnectSection(),
        ),
      ),
    );
  }
}
