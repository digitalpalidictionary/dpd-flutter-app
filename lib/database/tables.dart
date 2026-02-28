import 'package:drift/drift.dart';

class DpdHeadwords extends Table {
  IntColumn get id => integer()();
  TextColumn get lemma1 => text().named('lemma_1')();
  TextColumn get lemma2 => text().named('lemma_2').nullable()();
  TextColumn get pos => text().nullable()();
  TextColumn get grammar => text().nullable()();
  TextColumn get derivedFrom => text().named('derived_from').nullable()();
  TextColumn get neg => text().nullable()();
  TextColumn get verb => text().nullable()();
  TextColumn get trans => text().nullable()();
  TextColumn get plusCase => text().named('plus_case').nullable()();
  TextColumn get derivative => text().nullable()();
  TextColumn get meaning1 => text().named('meaning_1').nullable()();
  TextColumn get meaningLit => text().named('meaning_lit').nullable()();
  TextColumn get meaning2 => text().named('meaning_2').nullable()();
  TextColumn get rootKey =>
      text().named('root_key').references(DpdRoots, #root).nullable()();
  TextColumn get rootSign => text().named('root_sign').nullable()();
  TextColumn get rootBase => text().named('root_base').nullable()();
  TextColumn get familyRoot => text().named('family_root').nullable()();
  TextColumn get familyWord => text().named('family_word').nullable()();
  TextColumn get familyCompound => text().named('family_compound').nullable()();
  TextColumn get familyIdioms => text().named('family_idioms').nullable()();
  TextColumn get familySet => text().named('family_set').nullable()();
  TextColumn get construction => text().nullable()();
  TextColumn get compoundType => text().named('compound_type').nullable()();
  TextColumn get compoundConstruction =>
      text().named('compound_construction').nullable()();
  TextColumn get source1 => text().named('source_1').nullable()();
  TextColumn get sutta1 => text().named('sutta_1').nullable()();
  TextColumn get example1 => text().named('example_1').nullable()();
  TextColumn get source2 => text().named('source_2').nullable()();
  TextColumn get sutta2 => text().named('sutta_2').nullable()();
  TextColumn get example2 => text().named('example_2').nullable()();
  TextColumn get antonym => text().nullable()();
  TextColumn get synonym => text().nullable()();
  TextColumn get variant => text().nullable()();
  TextColumn get stem => text().nullable()();
  TextColumn get pattern => text().nullable()();
  TextColumn get suffix => text().nullable()();
  TextColumn get inflectionsHtml =>
      text().named('inflections_html').nullable()();
  TextColumn get freqHtml => text().named('freq_html').nullable()();
  IntColumn get ebtCount => integer().named('ebt_count').nullable()();
  TextColumn get nonIa => text().named('non_ia').nullable()();
  TextColumn get sanskrit => text().nullable()();
  TextColumn get cognate => text().nullable()();
  TextColumn get link => text().nullable()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get varPhonetic => text().named('var_phonetic').nullable()();
  TextColumn get varText => text().named('var_text').nullable()();
  TextColumn get origin => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get commentary => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Lookup extends Table {
  TextColumn get lookupKey => text().named('lookup_key')();
  TextColumn get headwords => text().nullable()();
  TextColumn get roots => text().nullable()();
  TextColumn get variant => text().nullable()();
  TextColumn get see => text().nullable()();
  TextColumn get spelling => text().nullable()();
  TextColumn get grammar => text().nullable()();
  TextColumn get help => text().nullable()();
  TextColumn get abbrev => text().nullable()();

  @override
  Set<Column> get primaryKey => {lookupKey};
}

class DpdRoots extends Table {
  TextColumn get root => text()();
  TextColumn get rootInComps => text().named('root_in_comps').nullable()();
  TextColumn get rootHasVerb => text().named('root_has_verb').nullable()();
  IntColumn get rootGroup => integer().named('root_group').nullable()();
  TextColumn get rootSign => text().named('root_sign').nullable()();
  TextColumn get rootMeaning => text().named('root_meaning').nullable()();
  IntColumn get rootCount => integer().named('root_count').nullable()();
  TextColumn get rootExample => text().named('root_example').nullable()();
  TextColumn get sanskritRoot => text().named('sanskrit_root').nullable()();
  TextColumn get sanskritRootMeaning =>
      text().named('sanskrit_root_meaning').nullable()();
  TextColumn get sanskritRootClass =>
      text().named('sanskrit_root_class').nullable()();
  TextColumn get rootInfo => text().named('root_info').nullable()();

  @override
  Set<Column> get primaryKey => {root};
}

class DbInfo extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
