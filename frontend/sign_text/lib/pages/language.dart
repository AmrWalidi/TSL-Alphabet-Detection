import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_text/l10n/app_localizations.dart';
import 'package:sign_text/main.dart';

class MyLanguagePage extends StatefulWidget {
  const MyLanguagePage({super.key});

  @override
  State<StatefulWidget> createState() => _MyLanguagePage();
}

class _MyLanguagePage extends State<MyLanguagePage> {
  int? _selectedValue = 0;

  void _changeLanguage(int langNumber) {
    String langCode = "en";

    if (langNumber == 0) {
      langCode = 'en';
    }
    if (langNumber == 1) {
      langCode = 'tr';
    }
    if (langNumber == 2) {
      langCode = 'ar';
    }
    Locale newLocale = Locale(langCode);
    MyApp.setLocale(context, newLocale);
    setState(() {
      _selectedValue = langNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.indigo.shade400,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            loc.changeLanguage,
            style: GoogleFonts.khula(color: Colors.white),
          )),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 25),
        children: [
          RadioListTile<int>(
            value: 0,
            groupValue: _selectedValue,
            onChanged: (value) {
              _changeLanguage(value!);
            },
            title: Text(loc.english, style: GoogleFonts.khula(fontSize: 20)),
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _selectedValue,
            onChanged: (value) {
              _changeLanguage(value!);
            },
            title: Text(loc.turkish, style: GoogleFonts.khula(fontSize: 20)),
          ),
          RadioListTile<int>(
            value: 2,
            groupValue: _selectedValue,
            onChanged: (value) {
              _changeLanguage(value!);
            },
            title: Text(loc.arabic, style: GoogleFonts.khula(fontSize: 20)),
          )
        ],
      ),
    );
  }
}
