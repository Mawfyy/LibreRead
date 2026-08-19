import 'package:flutter/material.dart';
import '../../../data/services/eye_care_service.dart';

class EyeCareFilter extends StatelessWidget {
  final Widget child;

  const EyeCareFilter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (EyeCareService.blueLightFilterEnabled)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Color.fromRGBO(255, 147, 41,
                    EyeCareService.blueLightIntensity * 0.45),
              ),
            ),
          ),
      ],
    );
  }
}
