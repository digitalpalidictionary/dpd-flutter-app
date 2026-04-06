/// Standalone benchmark script for search performance.
///
/// This script benchmarks the DAO layer directly without Flutter dependencies.
/// Run with: dart run lib/benchmarks/search_benchmark_standalone.dart

import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

// Test queries for benchmarking
const testQueries = {
  'exact_short': 'dhamma',
  'exact_long': 'dhammapada',
  'partial_short': 'dha',
  'partial_long': 'dham',
  'fuzzy_simple': 'dhama',
  'no_results': 'xyznonexistent',
  'broad_query': 'a',
};

/// Simple DAO for benchmarking
class SimpleDao {
  final Database db;

  SimpleDao(this.db);

  /// Current: LIKE query (does NOT use index)
  Duration searchPartialCurrent(String query) {
    final normalized = _normalizeQuery(query);
    final sw = Stopwatch()..start();

    final results = db.select(
      '''SELECT * FROM lookup
         WHERE lookup_key LIKE ?
         AND lookup_key != ?
         LIMIT 30''',
      ['$normalized%', normalized],
    );

    sw.stop();
    return sw.elapsed;
  }

  /// Optimized: Range query (uses index)
  Duration searchPartialOptimized(String query) {
    final normalized = _normalizeQuery(query);
    final sw = Stopwatch()..start();

    // Use range query instead of LIKE - uses the index
    final results = db.select(
      '''SELECT * FROM lookup
         WHERE lookup_key >= ?
         AND lookup_key < ?
         LIMIT 30''',
      [normalized, _nextString(normalized)],
    );

    sw.stop();
    return sw.elapsed;
  }

  /// Current: LIKE query (does NOT use index)
  Duration searchFuzzyCurrent(String query) {
    final normalized = _stripDiacritics(_normalizeQuery(query));
    final sw = Stopwatch()..start();

    final results = db.select(
      'SELECT * FROM lookup WHERE fuzzy_key LIKE ? LIMIT 50',
      ['$normalized%'],
    );

    sw.stop();
    return sw.elapsed;
  }

  /// Optimized: Range query (uses index)
  Duration searchFuzzyOptimized(String query) {
    final normalized = _stripDiacritics(_normalizeQuery(query));
    final sw = Stopwatch()..start();

    final results = db.select(
      '''SELECT * FROM lookup
         WHERE fuzzy_key >= ?
         AND fuzzy_key < ?
         LIMIT 50''',
      [normalized, _nextString(normalized)],
    );

    sw.stop();
    return sw.elapsed;
  }

  /// Exact match (now uses index after adding idx_lookup_key)
  Duration searchExact(String query) {
    final normalized = _normalizeQuery(query);
    final sw = Stopwatch()..start();

    final results = db.select(
      'SELECT * FROM lookup WHERE lookup_key = ?',
      [normalized],
    );

    sw.stop();
    return sw.elapsed;
  }

  String _normalizeQuery(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll('-', '')
        .replaceAll('ṁ', 'ṃ')
        .replaceAll('ŋ', 'ṃ');
  }

  String _stripDiacritics(String input) {
    return input
        .replaceAll('ā', 'a')
        .replaceAll('ī', 'i')
        .replaceAll('ū', 'u')
        .replaceAll('ṃ', 'm')
        .replaceAll('ṅ', 'n')
        .replaceAll('ṇ', 'n')
        .replaceAll('ṭ', 't')
        .replaceAll('ḍ', 'd')
        .replaceAll('ñ', 'n')
        .replaceAll('ḷ', 'l');
  }

  /// Get next string lexicographically (for range queries)
  String _nextString(String s) {
    if (s.isEmpty) return '{'; // '{' is after 'z' in ASCII
    return s.substring(0, s.length - 1) +
        String.fromCharCode(s.codeUnitAt(s.length - 1) + 1);
  }
}

/// Run benchmark comparing current vs optimized
void runBenchmark(SimpleDao dao, String name, String query) {
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Testing: "$name" - "$query"');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  const iterations = 5;

  // Warm up
  dao.searchExact(query);
  dao.searchPartialCurrent(query);
  dao.searchPartialOptimized(query);

  // Exact match
  final exactTimes = List.generate(
    iterations,
    (_) => dao.searchExact(query).inMicroseconds,
  );
  final avgExact = exactTimes.reduce((a, b) => a + b) / exactTimes.length;
  print('  Exact match: ${avgExact.toStringAsFixed(0)}μs');

  // Partial - current
  final partialCurrentTimes = List.generate(
    iterations,
    (_) => dao.searchPartialCurrent(query).inMicroseconds,
  );
  final avgPartialCurrent =
      partialCurrentTimes.reduce((a, b) => a + b) / partialCurrentTimes.length;

  // Partial - optimized
  final partialOptTimes = List.generate(
    iterations,
    (_) => dao.searchPartialOptimized(query).inMicroseconds,
  );
  final avgPartialOpt =
      partialOptTimes.reduce((a, b) => a + b) / partialOptTimes.length;

  final partialImprovement = avgPartialCurrent > 0
      ? ((avgPartialCurrent - avgPartialOpt) / avgPartialCurrent * 100)
      : 0;
  print(
    '  Partial (LIKE):     ${avgPartialCurrent.toStringAsFixed(0)}μs',
  );
  print(
    '  Partial (Range):    ${avgPartialOpt.toStringAsFixed(0)}μs (${partialImprovement.toStringAsFixed(0)}% faster)',
  );

  // Fuzzy - current
  final fuzzyCurrentTimes = List.generate(
    iterations,
    (_) => dao.searchFuzzyCurrent(query).inMicroseconds,
  );
  final avgFuzzyCurrent =
      fuzzyCurrentTimes.reduce((a, b) => a + b) / fuzzyCurrentTimes.length;

  // Fuzzy - optimized
  final fuzzyOptTimes = List.generate(
    iterations,
    (_) => dao.searchFuzzyOptimized(query).inMicroseconds,
  );
  final avgFuzzyOpt =
      fuzzyOptTimes.reduce((a, b) => a + b) / fuzzyOptTimes.length;

  final fuzzyImprovement = avgFuzzyCurrent > 0
      ? ((avgFuzzyCurrent - avgFuzzyOpt) / avgFuzzyCurrent * 100)
      : 0;
  print(
    '  Fuzzy (LIKE):       ${avgFuzzyCurrent.toStringAsFixed(0)}μs',
  );
  print(
    '  Fuzzy (Range):      ${avgFuzzyOpt.toStringAsFixed(0)}μs (${fuzzyImprovement.toStringAsFixed(0)}% faster)',
  );
}

void main() {
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║     DPD Search Performance Benchmark (Standalone)        ║');
  print('║     LIKE vs Range Query Comparison                       ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print('');

  final dbPath = '/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/share/dpd-mobile.db';

  if (!File(dbPath).existsSync()) {
    print('ERROR: Database file not found at: $dbPath');
    exit(1);
  }

  print('Loading database from: $dbPath');
  final db = sqlite3.open(dbPath);
  final dao = SimpleDao(db);

  print('Starting benchmark...\n');

  for (final entry in testQueries.entries) {
    runBenchmark(dao, entry.key, entry.value);
  }

  db.dispose();
  print('\n\nBenchmark complete.');
}
