import 'package:flutter/material.dart';
import 'package:circle_flags/circle_flags.dart';

class Language {
  final String name;
  final String code;
  final String nativeName;
  final String flagCode;

  Language({
    required this.name,
    required this.code,
    required this.nativeName,
    required this.flagCode,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English (us)';

  final List<Language> languages = [
    Language(
      name: 'English (us)',
      code: 'en',
      nativeName: '(English)',
      flagCode: 'gb',
    ),
    Language(
      name: 'Egypt (syria)',
      code: 'ar-sy',
      nativeName: '(العربية)',
      flagCode: 'eg',
    ),
    Language(
      name: 'India',
      code: 'hi',
      nativeName: '(हिंदी)',
      flagCode: 'in',
    ),
    Language(
      name: 'Pakistan',
      code: 'ur',
      nativeName: '(اردو)',
      flagCode: 'pk',
    ),
    Language(
      name: 'Bangladesh',
      code: 'bn',
      nativeName: '(বাংলাদেশ)',
      flagCode: 'bd',
    ),
    Language(
      name: 'Philippines',
      code: 'tl',
      nativeName: '(tagalog)',
      flagCode: 'ph',
    ),
    Language(
      name: 'Iran',
      code: 'fa',
      nativeName: '(فارسی)',
      flagCode: 'ir',
    ),
    Language(
      name: 'Nepal',
      code: 'ne',
      nativeName: '(नेपाल)',
      flagCode: 'np',
    ),
    Language(
      name: 'Srilanka (sinhala)',
      code: 'si',
      nativeName: '(sinhala)',
      flagCode: 'lk',
    ),
    Language(
      name: 'United states (tamil)',
      code: 'ta',
      nativeName: '(தமிழ்நாடு)',
      flagCode: 'lk',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Language'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context, selectedLanguage);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = selectedLanguage == language.name;

          return InkWell(
            onTap: () {
              setState(() {
                selectedLanguage = language.name;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleFlag(
                    language.flagCode,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      language.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}