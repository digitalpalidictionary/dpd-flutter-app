import 'database.dart';

// Strips Pāḷi diacritical marks to plain ASCII — for SC URL slug construction.
// Unlike stripDiacritics in utils/diacritics.dart, this does NOT strip aspirates
// or double consonants, matching Python's NFD-decompose + strip-Mn approach.
String _paliSlug(String s) {
  const map = <int, String>{
    0x0101: 'a', // ā
    0x0100: 'a', // Ā
    0x012B: 'i', // ī
    0x012A: 'i', // Ī
    0x016B: 'u', // ū
    0x016A: 'u', // Ū
    0x1E45: 'n', // ṅ
    0x1E44: 'n', // Ṅ
    0x00F1: 'n', // ñ
    0x00D1: 'n', // Ñ
    0x1E6D: 't', // ṭ
    0x1E6C: 't', // Ṭ
    0x1E0D: 'd', // ḍ
    0x1E0C: 'd', // Ḍ
    0x1E47: 'n', // ṇ
    0x1E46: 'n', // Ṇ
    0x1E41: 'm', // ṁ
    0x1E40: 'm', // Ṁ
    0x1E43: 'm', // ṃ
    0x1E42: 'm', // Ṃ
    0x1E37: 'l', // ḷ
    0x1E36: 'l', // Ḷ
    0x1E3B: 'l', // ḻ
    0x1E25: 'h', // ḥ
    0x1E24: 'h', // Ḥ
  };
  final buf = StringBuffer();
  for (final rune in s.runes) {
    buf.write(map[rune] ?? String.fromCharCode(rune));
  }
  return buf.toString().toLowerCase();
}

extension SuttaInfoExtensions on SuttaInfoData {
  bool _notEmpty(String? s) => s != null && s.isNotEmpty;

  // ── Sutta Central links ──────────────────────────────────────────────────

  String? get scCardLink =>
      _notEmpty(scCode) ? 'https://suttacentral.net/$scCode' : null;

  String? get scPaliLink =>
      _notEmpty(scCode) ? 'https://suttacentral.net/$scCode/pli/ms' : null;

  String? get scEngLink => _notEmpty(scCode)
      ? 'https://suttacentral.net/$scCode/en/sujato'
      : null;

  String? get scGithub => _notEmpty(scFilePath)
      ? 'https://github.com/suttacentral/sc-data/blob/main/$scFilePath'
      : null;

  String? get scExpressLink => _notEmpty(scCode)
      ? 'https://suttacentral.express/${scCode!.toLowerCase()}/en/sujato'
      : null;

  String? get scVoiceLink => _notEmpty(scCode)
      ? 'https://www.sc-voice.net/#/sutta/${scCode!.toLowerCase()}/en/sujato'
      : null;

  String? get dhammaGift => _notEmpty(scCode)
      ? 'https://find.dhamma.gift/read/?q=$scCode'
      : null;

  // ── The Buddha's Words links ─────────────────────────────────────────────

  static const _tbwBookCodes = {
    'DN', 'MN', 'SN', 'AN', 'KHP', 'DHP', 'UD', 'ITI', 'SNP', 'TH', 'THI',
  };

  String? get _scBookCode {
    if (!_notEmpty(scCode)) return null;
    return scCode!.replaceAll(RegExp(r'\d+\.*-*\d*'), '');
  }

  String? get tbw {
    if (!_notEmpty(scCode) || !_tbwBookCodes.contains(bookCode)) return null;
    final code = _scBookCode!.toLowerCase();
    if (code == 'iti') return 'https://thebuddhaswords.net/it/it.html';
    return 'https://thebuddhaswords.net/$code/${scCode!.toLowerCase()}.html';
  }

  String? get tbwLegacy {
    if (!_notEmpty(scCode) || !_tbwBookCodes.contains(bookCode)) return null;
    final code = _scBookCode!.toLowerCase();
    if (code == 'iti') return 'https://find.dhamma.gift/bw/it/it.html';
    return 'https://find.dhamma.gift/bw/$code/${scCode!.toLowerCase()}.html';
  }

  // ── CST links ──────────────────────────────────────────────────────────

  String? get cstGithubLink => _notEmpty(cstFile)
      ? 'https://github.com/VipassanaTech/tipitaka-xml/tree/main/$cstFile'
      : null;

  String? get tprLink {
    if (!_notEmpty(dpdCode)) return null;
    return 'tpr.pali.tools://open/?sutta=${dpdCode!.toLowerCase()}';
  }

  // ── CST / TPP links ─────────────────────────────────────────────────────

  String? get tppOrg {
    if (!_notEmpty(cstCode) || !_notEmpty(cstFile)) return null;
    final tppCode = cstFile!.replaceAll(RegExp(r'romn/|\.xml'), '');
    return 'https://tipitakapali.org/book/$tppCode#para$cstParanum';
  }

  // ── BJT links ────────────────────────────────────────────────────────────

  String? get bjtGithubLink => _notEmpty(bjtFilename)
      ? 'https://github.com/pathnirvana/tipitaka.lk/blob/master/public/static/text/$bjtFilename.json'
      : null;

  String? get bjtTipitakaLkLink =>
      _notEmpty(bjtWebCode) ? 'https://tipitaka.lk/$bjtWebCode' : null;

  String? get bjtOpenTipitakaLkLink =>
      _notEmpty(bjtWebCode) ? 'https://open.tipitaka.lk/latn/$bjtWebCode' : null;

  String? get bjtOpenTipitakaLkDevanagariLink =>
      _notEmpty(bjtWebCode) ? 'https://open.tipitaka.lk/deva/$bjtWebCode' : null;

  // ── DV existence checks ──────────────────────────────────────────────────

  bool get dvExists =>
      _notEmpty(dvPts) ||
      _notEmpty(dvMainTheme) ||
      _notEmpty(dvSubtopic) ||
      _notEmpty(dvSummary) ||
      _notEmpty(dvSimiles) ||
      _notEmpty(dvKeyExcerpt1) ||
      _notEmpty(dvKeyExcerpt2) ||
      _notEmpty(dvStage) ||
      _notEmpty(dvTraining) ||
      _notEmpty(dvAspect) ||
      _notEmpty(dvTeacher) ||
      _notEmpty(dvAudience) ||
      _notEmpty(dvMethod) ||
      _notEmpty(dvLength) ||
      _notEmpty(dvProminence) ||
      _notEmpty(dvSuggestedSuttas) ||
      dvParallelsExists;

  bool get dvParallelsExists =>
      _notEmpty(dvNikayasParallels) ||
      _notEmpty(dvAgamasParallels) ||
      _notEmpty(dvTaishoParallels) ||
      _notEmpty(dvSanskritParallels) ||
      _notEmpty(dvVinayaParallels) ||
      _notEmpty(dvOthersParallels) ||
      _notEmpty(dvPartialParallelsNa) ||
      _notEmpty(dvPartialParallelsAll);

  // ── Entry-type classifiers (mirrors Python SuttaInfo.is_vagga / is_samyutta) ─

  bool get isVagga {
    final names = [dpdSutta, dpdSuttaVar ?? ''];
    if (names.any((n) => n.contains('vagga') || n.contains('vaggo'))) return true;
    return (dpdCode ?? '').contains('-') &&
        (_notEmpty(cstVagga) || _notEmpty(scVagga) || _notEmpty(bjtVagga));
  }

  bool get isSamyutta {
    if (dpdSutta.isEmpty || !_notEmpty(dpdCode)) return false;
    if (dpdCode!.contains('.') || dpdCode!.contains('-')) return false;
    // Strip trailing homonym number (e.g. "jhānasaṃyutta 1" → "jhānasaṃyutta")
    final base = dpdSutta.replaceFirst(RegExp(r' \d+$'), '');
    return base.endsWith('saṃyutta');
  }

  // Mirrors Python SuttaInfo.sc_vagga_link — constructs SC vagga/saṃyutta URL.
  String? get scVaggaLink {
    final bookCode = _scBookCode;
    if (bookCode == null) return null;
    final bc = bookCode.toLowerCase();

    // DHP: verse range directly in dpd_code (e.g. dhp76-89)
    if (bc == 'dhp' && _notEmpty(dpdCode)) {
      return 'https://suttacentral.net/${dpdCode!.toLowerCase()}';
    }

    // SN individual saṃyutta: pitaka path with parent-vagga slug + saṃyutta number
    if (bc == 'sn' && isSamyutta && _notEmpty(dpdCode)) {
      final m = RegExp(r'^SN(\d+)$', caseSensitive: false).firstMatch(dpdCode!);
      if (m != null) {
        final n = int.parse(m.group(1)!);
        String? slug;
        if (n >= 1 && n <= 11) { slug = 'sagathavaggasamyutta'; }
        else if (n >= 12 && n <= 21) { slug = 'nidanavaggasamyutta'; }
        else if (n >= 22 && n <= 34) { slug = 'khandhavaggasamyutta'; }
        else if (n >= 35 && n <= 44) { slug = 'salayatanavaggasamyutta'; }
        else if (n >= 45 && n <= 56) { slug = 'mahavaggasamyutta'; }
        if (slug != null) {
          return 'https://suttacentral.net/pitaka/sutta/linked/sn/sn-$slug/sn$n';
        }
      }
      return null;
    }

    // SN vaggasaṃyuttapāḷi: slug from dpdSutta minus "pāḷi" suffix
    if (bc == 'sn' && dpdSutta.endsWith('saṃyuttapāḷi')) {
      final name = dpdSutta.replaceFirst(RegExp(r'pāḷi$'), '');
      return 'https://suttacentral.net/pitaka/sutta/linked/sn/sn-${_paliSlug(name)}';
    }

    // MN paṇṇāsapāḷi: slug from dpdSutta minus "pāḷi" suffix
    if (bc == 'mn' && dpdSutta.endsWith('paṇṇāsapāḷi')) {
      final name = dpdSutta.replaceFirst(RegExp(r'pāḷi$'), '');
      return 'https://suttacentral.net/pitaka/sutta/middle/mn/mn-${_paliSlug(name)}';
    }

    // DN vaggapāḷi: slug from dpdSutta minus "pāḷi" suffix
    if (bc == 'dn' && dpdSutta.endsWith('vaggapāḷi')) {
      final name = dpdSutta.replaceFirst(RegExp(r'pāḷi$'), '');
      return 'https://suttacentral.net/dn-${_paliSlug(name)}';
    }

    // Generic: derive slug from sc_vagga (strip leading "N. " numbering)
    if (!_notEmpty(scVagga)) return null;
    final vaggaName = scVagga!.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    final slug = _paliSlug(vaggaName);
    // SN/AN include section number in prefix (e.g. SN12.1-10 → sn12)
    final m2 = RegExp(r'^([A-Za-z]+)(\d+)\.(\d+)').firstMatch(dpdCode ?? '');
    final prefix = m2 != null ? '${m2.group(1)!}${m2.group(2)!}'.toLowerCase() : bc;
    return 'https://suttacentral.net/$prefix-$slug';
  }
}
