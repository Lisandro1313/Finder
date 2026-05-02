import 'package:flutter/material.dart';

class IdentityAvatar extends StatelessWidget {
  const IdentityAvatar({
    super.key,
    required this.seed,
    required this.label,
    this.radius = 22,
    this.showRing = false,
    this.heroTag,
    this.imageUrl,
  });

  final String seed;
  final String label;
  final double radius;
  final bool showRing;
  final String? heroTag;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = _paletteForSeed(seed);
    final initials = _initialsFromLabel(label);

    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsCircle(radius: radius, colors: colors, initials: initials),
              )
            : _InitialsCircle(radius: radius, colors: colors, initials: initials),
      ),
    );

    Widget result = avatar;

    if (showRing) {
      result = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE11D48), width: 1.4),
        ),
        child: avatar,
      );
    }

    if (heroTag != null) {
      result = Hero(tag: heroTag!, child: result);
    }

    return result;
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({
    required this.radius,
    required this.colors,
    required this.initials,
  });

  final double radius;
  final List<Color> colors;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

String _initialsFromLabel(String label) {
  final parts = label
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

List<Color> _paletteForSeed(String seed) {
  final palettes = <List<Color>>[
    const [Color(0xFFE11D48), Color(0xFFFF8A65)],
    const [Color(0xFF4F46E5), Color(0xFF22C1C3)],
    const [Color(0xFF0F766E), Color(0xFF22C55E)],
    const [Color(0xFF7C3AED), Color(0xFFEC4899)],
    const [Color(0xFFEA580C), Color(0xFFF59E0B)],
    const [Color(0xFF2563EB), Color(0xFF38BDF8)],
  ];
  final hash = seed.codeUnits.fold<int>(0, (acc, value) => acc + value);
  return palettes[hash % palettes.length];
}
