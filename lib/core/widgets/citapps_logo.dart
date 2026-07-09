import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class CitAppsLogo extends StatelessWidget {
  final double size;
  final bool monochrome;
  final bool showText;

  const CitAppsLogo({
    super.key,
    this.size = 80,
    this.monochrome = false,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on branding rules
    final String colorC = monochrome
        ? '#1F1F1F'
        : '#B78D3F'; // Dorado Suave
    final String colorA = '#1F1F1F'; // Negro Carbón
    final String colorCross = '#1F1F1F';

    // SVG representation of the monogram "CA"
    final String svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <!-- Curve for C -->
  <path d="M 58 28 A 22 22 0 1 0 58 72" 
        fill="none" 
        stroke="$colorC" 
        stroke-width="10" 
        stroke-linecap="round" />
  
  <!-- Peak for A -->
  <path d="M 48 72 L 70 28 L 92 72" 
        fill="none" 
        stroke="$colorA" 
        stroke-width="10" 
        stroke-linecap="round" 
        stroke-linejoin="round" />
  
  <!-- Crossbar for A -->
  <path d="M 59 52 L 81 52" 
        fill="none" 
        stroke="$colorCross" 
        stroke-width="8" 
        stroke-linecap="round" />
</svg>
''';

    final logoImage = SvgPicture.string(
      svgString,
      width: size,
      height: size,
    );

    if (!showText) {
      return logoImage;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoImage,
        const SizedBox(height: 8),
        Text(
          'CitApps',
          style: AppTextStyles.h1.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontSize: size * 0.32,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'CONTROL • GESTIÓN • CRECIMIENTO',
          style: AppTextStyles.labelSm.copyWith(
            fontSize: size * 0.10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
