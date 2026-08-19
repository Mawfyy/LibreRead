import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/reader_settings.dart';
import '../../data/services/reader_settings_service.dart';
import '../../app.dart';
import 'widgets/update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  ReaderFormat _selectedFormat = ReaderFormat.epub;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = LibreReadApp.currentTheme(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionTitle(context, 'Appearance'),
          RadioGroup<ThemeMode>(
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                LibreReadApp.setTheme(context, value);
              }
            },
            child: Column(
              children: [
                _buildThemeTile(context, 'System', ThemeMode.system),
                _buildThemeTile(context, 'Light', ThemeMode.light),
                _buildThemeTile(context, 'Dark', ThemeMode.dark),
              ],
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle(context, 'Reading settings'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ReaderFormat>(
              segments: const [
                ButtonSegment(
                  value: ReaderFormat.epub,
                  label: Text(AppStrings.epubFormat),
                ),
                ButtonSegment(
                  value: ReaderFormat.pdf,
                  label: Text(AppStrings.pdfFormat),
                ),
                ButtonSegment(
                  value: ReaderFormat.txt,
                  label: Text(AppStrings.txtFormat),
                ),
              ],
              selected: {_selectedFormat},
              onSelectionChanged: (selection) {
                setState(() => _selectedFormat = selection.first);
              },
            ),
          ),
          _buildSectionTitle(context, AppStrings.readingLayout),
          RadioGroup<ReadingLayout>(
            groupValue: _settings.layout,
            onChanged: (value) async {
              if (value != null) {
                await _updateSettings(_settings.copyWith(layout: value));
              }
            },
            child: Column(
              children: [
                _buildLayoutTile(context, AppStrings.verticalLayout, ReadingLayout.vertical),
                _buildLayoutTile(context, AppStrings.horizontalLayout, ReadingLayout.horizontal),
              ],
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle(context, AppStrings.eyeCare),
          SwitchListTile(
            title: const Text(AppStrings.blueLightFilter),
            value: _settings.blueLightEnabled,
            onChanged: (value) async {
              await _updateSettings(_settings.copyWith(blueLightEnabled: value));
            },
          ),
          if (_settings.blueLightEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 20),
                  Expanded(
                    child: Slider(
                      value: _settings.blueLightIntensity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: '${(_settings.blueLightIntensity * 100).round()}%',
                      onChanged: (value) async {
                        await _updateSettings(
                          _settings.copyWith(blueLightIntensity: value),
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.wb_sunny, size: 20),
                ],
              ),
            ),
          _buildReadingBackgroundPicker(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.text_fields, size: 20),
                Expanded(
                  child: Slider(
                    value: _settings.fontSize,
                    min: 12.0,
                    max: 28.0,
                    divisions: 16,
                    label: '${_settings.fontSize.round()} px',
                    onChanged: (value) async {
                      await _updateSettings(_settings.copyWith(fontSize: value));
                    },
                  ),
                ),
                const Text('Aa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('LibreRead'),
            subtitle: Text(_appVersion.isEmpty ? '...' : 'Version $_appVersion'),
          ),
          ListTile(
            leading: const Icon(Icons.system_update_alt),
            title: const Text(AppStrings.checkForUpdates),
            subtitle: const Text('Latest version from GitHub'),
            onTap: () => UpdateDialogs.checkAndPrompt(context),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Supported formats'),
            subtitle: const Text('EPUB, PDF, Text'),
          ),
        ],
      ),
    );
  }

  ReaderSettings get _settings =>
      ReaderSettingsService.settingsFor(_selectedFormat);

  Future<void> _updateSettings(ReaderSettings settings) async {
    await ReaderSettingsService.update(_selectedFormat, settings);
    if (mounted) setState(() {});
  }

  Widget _buildReadingBackgroundPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.readingBackground),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBgOption(Colors.white, const Color(0xFF212121), ReadingBackground.white, AppStrings.whiteBg),
              const SizedBox(width: 12),
              _buildBgOption(const Color(0xFFF5E6C8), const Color(0xFF5B4636), ReadingBackground.sepia, AppStrings.sepiaBg),
              const SizedBox(width: 12),
              _buildBgOption(const Color(0xFF1A1A1A), const Color(0xFFE0E0E0), ReadingBackground.dark, AppStrings.darkBg),
              const SizedBox(width: 12),
              _buildBgOption(Colors.black, Colors.white, ReadingBackground.highContrast, AppStrings.highContrastBg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBgOption(Color bg, Color fg, ReadingBackground value, String label) {
    final isSelected = _settings.background == value;
    return GestureDetector(
      onTap: () async {
        await _updateSettings(_settings.copyWith(background: value));
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Center(
              child: Text('Aa', style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
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

  Widget _buildLayoutTile(BuildContext context, String label, ReadingLayout layout) {
    return RadioListTile<ReadingLayout>(
      title: Text(label),
      value: layout,
    );
  }
}
