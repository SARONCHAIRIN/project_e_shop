import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageBottomSheet extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onSelected;

  const LanguageBottomSheet({
    required this.currentLocale,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final languages = [
      _LangOption(locale: const Locale('en'), flag: '🇬🇧', label: 'English', subtitle: 'English'),
      _LangOption(locale: const Locale('km'), flag: '🇰🇭', label: 'ខ្មែរ', subtitle: 'Khmer'),
    ];

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'language'.tr(),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...languages.map((lang) {
            final isSelected = currentLocale.languageCode == lang.locale.languageCode;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelected(lang.locale),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigoAccent.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.indigoAccent.withOpacity(0.4)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Text(lang.flag, style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.label,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                lang.subtitle,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                              color: Colors.indigoAccent, key: ValueKey('checked'))
                              : const SizedBox(width: 24, height: 24, key: ValueKey('unchecked')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LangOption {
  final Locale locale;
  final String flag;
  final String label;
  final String subtitle;

  _LangOption({
    required this.locale,
    required this.flag,
    required this.label,
    required this.subtitle,
  });
}