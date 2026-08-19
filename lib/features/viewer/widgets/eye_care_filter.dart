import 'package:flutter/material.dart';
import '../../../data/models/reader_settings.dart';

class EyeCareFilter extends StatelessWidget {
  final Widget child;
  final ReaderSettings settings;

  const EyeCareFilter({super.key, required this.child, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (settings.blueLightEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Color.fromRGBO(
                  255,
                  147,
                  41,
                  settings.blueLightIntensity * 0.45,
                ),
              ),
            ),
          ),
      ],
    );
  }
}