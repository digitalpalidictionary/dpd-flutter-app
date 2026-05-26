import 'dpd_palette.dart';
import 'schemes/purana.dart';
import 'schemes/kapila.dart';

enum DpdScheme { nila, kapila }

extension DpdSchemeLabel on DpdScheme {
  String get label => switch (this) {
    DpdScheme.nila => 'nīḷa',
    DpdScheme.kapila => 'kapila',
  };
}

({DpdPalette light, DpdPalette dark}) palettesFor(DpdScheme scheme) =>
    switch (scheme) {
      DpdScheme.nila => (light: puranaLight, dark: puranaDark),
      DpdScheme.kapila => (light: kapilaLight, dark: kapilaDark),
    };
