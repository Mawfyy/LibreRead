import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = LectorDocumentosApp.currentTheme(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle(context, 'Apariencia'),
          RadioGroup<ThemeMode>(
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                LectorDocumentosApp.setTheme(context, value);
              }
            },
            child: Column(
              children: [
                _buildThemeTile(context, 'Sistema', ThemeMode.system),
                _buildThemeTile(context, 'Claro', ThemeMode.light),
                _buildThemeTile(context, 'Oscuro', ThemeMode.dark),
              ],
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle(context, 'Acerca de'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Lector de Documentos'),
            subtitle: const Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Formatos soportados'),
            subtitle: const Text('PDF, Word (.docx), EPUB'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, String label, ThemeMode mode) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: mode,
    );
  }
}
