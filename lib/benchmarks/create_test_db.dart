/// Create a small test database for benchmarking.
/// 
/// This creates a minimal database with sample data for performance testing.
/// Run with: dart run lib/benchmarks/create_test_db.dart

import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = '/home/bodhirasa/MyFiles/3_Active/dpd-flutter-app/test_benchmark.db';
  
  // Delete existing test database
  if (File(dbPath).existsSync()) {
    File(dbPath).deleteSync();
  }

  print('Creating test database at: $dbPath');
  
  final db = sqlite3.open(dbPath);

  // Create lookup table
  db.execute('''
    CREATE TABLE lookup (
      lookup_key TEXT PRIMARY KEY,
      fuzzy_key TEXT,
      headwords TEXT,
      roots TEXT
    )
  ''');

  // Create dpd_headwords table
  db.execute('''
    CREATE TABLE dpd_headwords (
      id INTEGER PRIMARY KEY,
      lemma1 TEXT NOT NULL,
      lemma2 TEXT,
      pos TEXT,
      grammar TEXT,
      root_key TEXT,
      meaning1 TEXT,
      construction TEXT
    )
  ''');

  // Create dpd_roots table  
  db.execute('''
    CREATE TABLE dpd_roots (
      root TEXT PRIMARY KEY,
      meaning TEXT
    )
  ''');

  // Insert sample headwords
  print('Inserting sample data...');
  
  final headwords = [
    (1, 'dhamma', 'dharma', 'noun', 'm.', '√dham', 'dhamma, phenomenon'),
    (2, 'dhammapada', '', 'noun', 'n.', '', 'Dhammapada'),
    (3, 'dhammaṃ', '', 'noun', 'm.', '√dham', 'dhamma (acc.)'),
    (4, 'dhammā', '', 'noun', 'm.', '√dham', 'dhammas (pl.)'),
    (5, 'dhamme', '', 'noun', 'm.', '√dham', 'in dhamma'),
    (6, 'dīgha', '', 'adj', '', '', 'long'),
    (7, 'dīghaṃ', '', 'adj', '', '', 'long (acc.)'),
    (8, 'dvā', '', 'num', '', '', 'two'),
    (9, 'deva', '', 'noun', 'm.', '', 'god, deity'),
    (10, 'devā', '', 'noun', 'm.', '', 'gods'),
    (11, 'a', '', 'particle', '', '', 'not, non-'),
    (12, 'anatta', '', 'adj', '', '√attā', 'not-self'),
    (13, 'anicca', '', 'adj', '', '', 'impermanent'),
    (14, 'dukkha', '', 'noun', 'n.', '', 'suffering'),
    (15, 'nibbāna', '', 'noun', 'n.', '', 'extinguishment'),
  ];

  for (final hw in headwords) {
    db.execute(
      '''INSERT INTO dpd_headwords 
         (id, lemma1, lemma2, pos, grammar, root_key, meaning1) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [hw.$1, hw.$2, hw.$3, hw.$4, hw.$5, hw.$6, hw.$7],
    );
  }

  // Insert lookup entries
  final lookups = [
    ('dhamma', 'dhamma', '[1]'),
    ('dhammapada', 'dhammapada', '[2]'),
    ('dhammaṃ', 'dhammam', '[3]'),
    ('dhammā', 'dhamma', '[4]'),
    ('dhamme', 'dhamme', '[5]'),
    ('dīgha', 'digha', '[6]'),
    ('dīghaṃ', 'digham', '[7]'),
    ('dvā', 'dva', '[8]'),
    ('deva', 'deva', '[9]'),
    ('devā', 'deva', '[10]'),
    ('a', 'a', '[11]'),
    ('anatta', 'anatta', '[12]'),
    ('anicca', 'anicca', '[13]'),
    ('dukkha', 'dukkha', '[14]'),
    ('nibbāna', 'nibbana', '[15]'),
  ];

  for (final lu in lookups) {
    db.execute(
      'INSERT INTO lookup (lookup_key, fuzzy_key, headwords) VALUES (?, ?, ?)',
      [lu.$1, lu.$2, lu.$3],
    );
  }

  // Create indexes
  db.execute('CREATE INDEX idx_lookup_fuzzy ON lookup(fuzzy_key)');
  db.execute('CREATE INDEX idx_headword_lemma ON dpd_headwords(lemma1)');

  print('Test database created with ${lookups.length} lookup entries');
  print('Database file: $dbPath');
  print('File size: ${File(dbPath).lengthSync()} bytes');
  
  db.dispose();
}
