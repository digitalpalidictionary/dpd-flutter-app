import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;

const _simpleEntry =
    '<div id="gd3definition" class="gd3definition"><div class="lemPanel"><div class="lemma"><span id="spanHomLem"><span id="gd3form_hom" class="lemsuper">4</span><span id="gd3form_lem" class="lemma">a-</span></span></div><div></div><div><p><span id="gd3form_etymology"></span><span id="gd3form_phonetic"></span><span id="gd3form_pos" class="morph"></span><span id="gd3form_def"><i>the base of some pronouns and adverbs</i>; \u2014 <i>see</i> aya\u1E43, asu, atra, ato.</span></p></div><div id="crossrefs"></div><p>&nbsp;<br><br></p></div></div>';

const _mediumEntry =
    '<div id="gd3definition" class="gd3definition"><div class="lemPanel"><div class="lemma"><span id="spanHomLem"><span id="gd3form_hom" class="lemsuper"></span><span id="gd3form_lem" class="lemma">kakkha\u1E37a</span></span></div><div></div><div><p><span id="gd3form_etymology"></span><span id="gd3form_phonetic"></span><span id="gd3form_pos" class="morph"></span><span id="gd3form_def"><i>mfn.</i> [<i>S. lex., BHS</i> kakkha\u1E6Da; <i>AMg</i> kakkha\u1E0Da], <i>hard, solid; harsh, severe, cruel</i>; Abh 714; Vin II 299,<span class="subscript">12</span> (ida\u1E43 kho adhikara\u1E47a\u1E43 ~a\u1E43 ca v\u0101la\u1E43 ca); M I 185,<span class="subscript">16</span> (~a\u1E43 kharigata\u1E43 up\u0101di\u1E47\u1E47a\u1E43); A IV 171,<span class="subscript">8</span> (y\u0101ni t\u0101ni rukkh\u0101ni da\u1E37h\u0101ni s\u0101ravant\u0101ni t\u0101ni \u2026 \u0101ko\u1E6Ditani ~a\u1E43 pa\u1E6Dinadanti); Ja I 187,<span class="subscript">9</span> (~ena pharusena s\u0101hasikena bhavitabba\u1E43); IV 427,<span class="subscript">17</span> (r\u0101j\u0101no n\u0101ma s\u0101mi ~\u0101); V 167,<span class="subscript">29\u00B4</span> (\u00B0-t\u0101ya); VI 186,<span class="subscript">23</span> (may\u0101 ~o p\u0101pasupino di\u1E6D\u1E6Dho); Dhs 962 (katama\u1E43 \u2026 pathav\u012Bdh\u0101tu, ya\u1E43 ~a\u1E43 kharagata\u1E43 \u00B0-tta\u1E43 \u00B0-bh\u0101vo) \u2260 Vibh 82,<span class="subscript">8</span>; Mil 67,<span class="subscript">14</span> (~\u0101ni p\u0101s\u0101\u1E47\u0101ni); As 203,<span class="subscript">33</span> (visa\u1E43 n\u0101ma ~a\u1E43, yo ta\u1E43 kh\u0101dati so marati); 332,<span class="subscript">22</span> (~an ti thaddha\u1E43, <i>Be, Ce, Se so; Ee wr</i> kakha\u1E37an); Ps III 138,<span class="subscript">3</span> (garahuppattito \u00B0-tar\u0101 p\u012B\u1E37\u0101 n\u0101ma n\u2019 atthi, <i>Be, Se so; Ce, Ee</i> \u00B0-kar\u0101); Pv-a 243,<span class="subscript">19</span> (asaddho ~o bhikkh\u016Bna\u1E43 akkosakak\u0101rako); \u2014     <span id="15014836" class="subsense H3 highlight"><b>akakkha\u1E37a</b>,   <i>mfn.</i>, <i>not hard; mild, soft</i>; Dhs 859 (~-t\u0101); Vv a 214,<span class="subscript">7</span> (~-t\u0101ya);</span> \u2014      <span id="15014837" class="subsense H3"><b>atikakkha\u1E37a</b>,   <i>mfn.</i>, <i>too harsh, too cruel</i>; Ja VI 162,<span class="subscript">3</span>; Mp I 142,<span class="subscript">3</span>. </span></span></p></div><div id="crossrefs"></div><p>&nbsp;<br><br></p></div></div>';

const _largeEntry =
    '<div id="gd3definition" class="gd3definition"><div class="lemPanel"><div class="lemma"><span id="spanHomLem"><span id="gd3form_hom" class="lemsuper">1</span><span id="gd3form_lem" class="lemma">dhamma</span></span></div><div></div><div><p><span id="gd3form_etymology"></span><span id="gd3form_phonetic"></span><span id="gd3form_pos" class="morph"></span><span id="gd3form_def"><i>m.</i> (<i>and n.</i>) [<i>S.</i>, <i>BHS</i> dharma], dhamma <i>denotes (an interpretation of) the essential nature and reality of existence and experience, the way things are: it is descriptive and prescriptive; it denotes also an essential attribute of men or animals; a quality or characteristic</i>; Abh 784 (~o sabh\u0101ve pariyattipaññ\u0101ñ\u0101yesu saccappakatisu puññe ñeyye gu\u1E47\u0101c\u0101rasamadhis\u016B pi nissattat\u0101pattisu k\u0101ra\u1E47\u0101do); <i>see also</i> Sv 99,<span class="subscript">3</span> <i>foll.</i>, Ps I 17,<span class="subscript">16</span> <i>foll.</i>, It-a I 37,<span class="subscript">20</span> <i>foll.</i>, Pa\u1E6Dis-a 18,<span class="subscript">1</span> <i>foll.</i>, Bv-a 13,<span class="subscript">4</span> <i>foll.</i>, As 38,<span class="subscript">23</span> <i>foll. and</i> Sadd 560,<span class="subscript">25</span> <i>foll.</i>; \u2014 <i>for Buddhists</i> dhamma <i>is used to denote an interlocking and interdependent assembly of concepts: the true nature of the world of experience, how that world works, and the way to transcend it, as understood by the Buddha; the progressive stages of understanding and</i> nibb\u0101na <i>; the behaviour, the practice, required to achieve understanding of the way the world of experience works, ie the way to reach arhatship,</i> nibb\u0101na <i>; the understanding and practice taught by the Buddha, the substance of his teaching, the texts of the Canon, especially the</i> Suttapi\u1E6Daka <i>; all constituents of the world of experience, physical and mental, external and internal, progressively more and more minutely analysed; all constituents of prescribed practice, appropriate and beneficial actions; prescriptions for the members of the</i> sa\u1E45gha <i>; \u2014 for people generally</i> dhamma <i>is an interpretation of the essential nature of existence and experience; the way one should act, depending on who one is, to maintain the way things are and should be; duty; right; justice; normative and beneficial actions</i>; \u2014 <b>1.</b> (<b>i</b>) <i>how the world of experience works, the processes by which it works and is explained (especially as formulated in</i> catt\u0101ri ariyasacc\u0101ni <i>and</i> pa\u1E6Diccasamupp\u0101da <i>), and the possibility and way of transcending it, as understood by the Buddha and taught by him (so that knowledge and understanding of it might bring enlightenment, arhatship, to others)</i>; Vin I 2,<span class="subscript">3*</span> (yad\u0101 have p\u0101tubhavanti ~\u0101 \u0101t\u0101pino jh\u0101yato br\u0101hma\u1E47assa ath\u2019 assa ka\u1E45kh\u0101 vapayanti sabb\u0101 yato paj\u0101n\u0101ti sahetudhamma\u1E43; Sp 954,<span class="subscript">19</span>)</span></p></div></div></div></div>';

Map<String, String>? _coneStylesBuilder(dom.Element element) {
  final classes = element.classes;
  final tag = element.localName;

  if (tag == 'div' && classes.contains('lemma')) {
    return {
      'font-size': '15pt',
      'line-height': '17pt',
      'font-weight': '600',
      'color': 'orange',
    };
  }
  if (classes.contains('lemma') && tag == 'span') {
    return {'color': 'orange', 'font-weight': '600'};
  }
  if (classes.contains('lemsuper')) {
    return {'font-size': '10px', 'vertical-align': 'super'};
  }
  if (classes.contains('morph')) {
    return {'font-style': 'italic'};
  }
  if (classes.contains('super') || classes.contains('qsuper')) {
    return {'font-size': '8px', 'vertical-align': 'super'};
  }
  if (classes.contains('subscript')) {
    return {'font-size': '8px', 'vertical-align': 'sub'};
  }
  if (classes.contains('subsense')) {
    return {'display': 'inline'};
  }
  if (classes.contains('highlight')) {
    return {'background-color': '#fbff00', 'color': 'black'};
  }
  if (classes.contains('bold') || classes.contains('sb') ||
      classes.contains('attestedform') || classes.contains('cref')) {
    return {'font-weight': 'bold'};
  }
  if (classes.contains('italic') || classes.contains('s') ||
      classes.contains('cognate')) {
    return {'font-style': 'italic'};
  }
  if (classes.contains('smallcaps') || classes.contains('scaps') ||
      classes.contains('txtabbrev') || classes.contains('easian')) {
    return {'font-variant': 'small-caps'};
  }
  if (classes.contains('blue')) {
    return {'color': 'rgb(0, 115, 177)'};
  }
  if (classes.contains('orange')) {
    return {'color': '#ba4200'};
  }
  if (classes.contains('green')) {
    return {'color': 'green'};
  }
  if (classes.contains('red')) {
    return {'color': 'red'};
  }
  if (classes.contains('purple')) {
    return {'color': 'purple'};
  }
  if (classes.contains('dim')) {
    return {'color': '#648cc8'};
  }
  if (classes.contains('kharHide')) {
    return {'display': 'none'};
  }
  if (classes.contains('id')) {
    return {'font-size': '10px'};
  }
  if (classes.contains('more')) {
    return {'color': 'gray', 'font-style': 'italic', 'font-size': '12px'};
  }
  return null;
}

class ConeHtmlPocScreen extends StatelessWidget {
  const ConeHtmlPocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cone HTML PoC')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Simple entry (4a)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HtmlWidget(
                _simpleEntry,
                customStylesBuilder: _coneStylesBuilder,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Medium entry with subsenses (kakkhaḷa)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HtmlWidget(
                _mediumEntry,
                customStylesBuilder: _coneStylesBuilder,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Large entry excerpt (1dhamma)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HtmlWidget(
                _largeEntry,
                customStylesBuilder: _coneStylesBuilder,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('CSS Feature Checklist'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Check the following render correctly:'),
                  SizedBox(height: 8),
                  Text('  \u2022 Orange lemma headwords (div.lemma)'),
                  Text('  \u2022 Italic POS/morph text (span.morph)'),
                  Text('  \u2022 Superscript homonym numbers (span.lemsuper)'),
                  Text('  \u2022 Subscript line references (span.subscript)'),
                  Text('  \u2022 Bold subsense headwords in orange (.subsense b)'),
                  Text('  \u2022 Yellow highlight on searched term (.highlight)'),
                  Text('  \u2022 Small-caps abbreviations (span.smallcaps)'),
                  Text('  \u2022 P\u0101li diacritics (\u0101, \u012B, \u016B, \u1E43, \u1E47, \u1E6D, \u1E37, \u00F1)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
