import 'package:flutter/material.dart';

import '../theme/dpd_colors.dart';

class AutocompleteDropdown extends StatelessWidget {
  const AutocompleteDropdown({
    super.key,
    required this.suggestions,
    required this.onSelected,
    required this.layerLink,
    required this.width,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final LayerLink layerLink;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CompositedTransformFollower(
      link: layerLink,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(DpdColors.borderRadiusValue),
          bottomRight: Radius.circular(DpdColors.borderRadiusValue),
        ),
        color: isDark ? DpdColors.darkShade : DpdColors.light,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 300,
            maxWidth: width,
            minWidth: width,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(DpdColors.borderRadiusValue),
              bottomRight: Radius.circular(DpdColors.borderRadiusValue),
            ),
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: DpdColors.grayTransparent,
            ),
            itemBuilder: (context, index) {
              final term = suggestions[index];
              return InkWell(
                onTap: () => onSelected(term),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    term,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
