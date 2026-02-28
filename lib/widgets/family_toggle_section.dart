import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import 'family_state_mixin.dart';

/// Renders all family toggle buttons and their lazy-loaded sections.
///
/// Drop this widget anywhere a headword's family sections should appear.
/// It manages all toggle state and lazy loading internally.
class FamilyToggleSection extends ConsumerStatefulWidget {
  const FamilyToggleSection({super.key, required this.headword});

  final DpdHeadwordWithRoot headword;

  @override
  ConsumerState<FamilyToggleSection> createState() =>
      _FamilyToggleSectionState();
}

class _FamilyToggleSectionState extends ConsumerState<FamilyToggleSection>
    with FamilyStateMixin<FamilyToggleSection> {
  @override
  DpdHeadwordWithRoot get familyHeadword => widget.headword;

  @override
  Widget build(BuildContext context) {
    if (!familyHasAny) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(7, 2, 7, 3),
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            children: buildFamilyButtons(),
          ),
        ),
        ...buildFamilySections(),
      ],
    );
  }
}
