import 'package:flutter/material.dart';

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  bool isArabic = true;

  void _toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
    });
    // TODO: implémenter persistance ou Localizations
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isArabic ? Icons.language : Icons.translate),
      onPressed: _toggleLanguage,
    );
  }
}
