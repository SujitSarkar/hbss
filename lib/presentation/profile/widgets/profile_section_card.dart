import 'package:flutter/material.dart';

import 'package:maori_health/core/utils/extensions.dart';

class ProfileSectionCard extends StatelessWidget {
  final IconData icon;
  final String? title;
  final List<Widget> children;

  const ProfileSectionCard({super.key, required this.icon, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: .circular(14),
        border: .all(color: context.theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (title != null)
            Padding(
              padding: const .fromLTRB(16, 14, 16, 4),
              child: Text(
                title!,
                style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.primary, fontWeight: .w600),
              ),
            ),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
