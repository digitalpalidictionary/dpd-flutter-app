import 'database.dart';

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
}
