import 'dpd_palette.dart';
import 'schemes/purana.dart';
import 'schemes/suriya.dart';
import 'schemes/dhuma.dart';
import 'schemes/tina.dart';

enum DpdScheme { nila, suriya, tina, dhuma }

extension DpdSchemeLabel on DpdScheme {
  String get label => switch (this) {
    DpdScheme.nila => 'nīla',
    DpdScheme.suriya => 'sūriya',
    DpdScheme.tina => 'tiṇa',
    DpdScheme.dhuma => 'dhūma',
  };
}

({DpdPalette light, DpdPalette dark}) palettesFor(DpdScheme scheme) =>
    switch (scheme) {
      DpdScheme.nila => (light: puranaLight, dark: puranaDark),
      DpdScheme.suriya => (light: suriyaLight, dark: suriyaDark),
      DpdScheme.tina => (light: tinaLight, dark: tinaDark),
      DpdScheme.dhuma => (light: dhumaLight, dark: dhumaDark),
    };
