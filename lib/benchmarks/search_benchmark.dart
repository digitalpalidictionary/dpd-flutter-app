/// Benchmark script for search performance optimization.
/// 
/// Run this script to measure search query performance.
/// It will test various query types and output timing results.
///
/// Usage: dart run lib/benchmarks/search_benchmark.dart

import 'dart:io';

import 'package:drift/native.dart';

import '../database/database.dart';
import '../utils/search_timing.dart';

// Test queries for benchmarking
const testQueries = {
  'exact_short': 'dhamma',
  'exact_long': 'dhammapada',
  'partial_short': 'dha',
  'partial_long': 'dham',
  'fuzzy_simple': 'dhama', // without diacritics
  'fuzzy_complex': 'dhammaa',
  'no_results': 'xyznonexistent',
  'broad_query': 'a',
};

/// Mock path provider for testing
class MockPathProvider {
  static Future<Directory> getApplicationDocumentsDirectory() async {
    // Use current directory for testing
    return Directory.current;
  }
}

/// Benchmark runner
class SearchBenchmark {
  final AppDatabase db;
  final DpdDao dao;
  final Map<String, Map<String, Duration>> results = {};

  SearchBenchmark(this.db, this.dao);

  /// Run a single benchmark for a query type
  Future<void> runBenchmark(String name, String query) async {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Testing: "$name" - "$query"');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final queryResults = <String, Duration>{};

    // Enable timing
    enableSearchTiming = true;
    clearTimingLog();

    // Warm up
    await dao.searchExact(query);
    clearTimingLog();

    // Test exact match
    print('  Running exact match...');
    var sw = Stopwatch()..start();
    final exactResults = await dao.searchExact(query);
    sw.stop();
    queryResults['exact'] = sw.elapsed;
    print('    Found ${exactResults.length} results in ${sw.elapsedMilliseconds}ms');

    // Test partial match
    print('  Running partial match...');
    sw = Stopwatch()..start();
    final partialResults = await dao.searchPartial(query);
    sw.stop();
    queryResults['partial'] = sw.elapsed;
    print('    Found ${partialResults.length} results in ${sw.elapsedMilliseconds}ms');

    // Test fuzzy match
    print('  Running fuzzy match...');
    sw = Stopwatch()..start();
    final fuzzyResults = await dao.searchFuzzy(query);
    sw.stop();
    queryResults['fuzzy'] = sw.elapsed;
    print('    Found ${fuzzyResults.length} results in ${sw.elapsedMilliseconds}ms');

    // Test root search
    print('  Running root search...');
    sw = Stopwatch()..start();
    final rootResults = await dao.searchRoots(query);
    sw.stop();
    queryResults['roots'] = sw.elapsed;
    print('    Found ${rootResults.length} results in ${sw.elapsedMilliseconds}ms');

    results[name] = queryResults;

    // Disable timing
    enableSearchTiming = false;
  }

  /// Print summary table
  void printSummary() {
    print('\n\n');
    print('=' * 70);
    print('SEARCH PERFORMANCE BENCHMARK SUMMARY');
    print('=' * 70);
    print('');

    // Header
    print('Query Type'.padRight(20) +
        'Exact'.padRight(12) +
        'Partial'.padRight(12) +
        'Fuzzy'.padRight(12) +
        'Roots'.padRight(12));
    print('-' * 70);

    // Results
    for (final entry in results.entries) {
      final name = entry.key.padRight(20);
      final exact = entry.value['exact']?.inMilliseconds.toString().padRight(11) ?? 'N/A'.padRight(11);
      final partial = entry.value['partial']?.inMilliseconds.toString().padRight(11) ?? 'N/A'.padRight(11);
      final fuzzy = entry.value['fuzzy']?.inMilliseconds.toString().padRight(11) ?? 'N/A'.padRight(11);
      final roots = entry.value['roots']?.inMilliseconds.toString().padRight(11) ?? 'N/A'.padRight(11);

      print('$name${exact}ms${partial}ms${fuzzy}ms${roots}ms');
    }

    print('=' * 70);
    print('');

    // Statistics
    final allExact = results.values
        .map((e) => e['exact']?.inMilliseconds ?? 0)
        .where((e) => e > 0)
        .toList();
    
    if (allExact.isNotEmpty) {
      final avgExact = allExact.reduce((a, b) => a + b) / allExact.length;
      final maxExact = allExact.reduce((a, b) => a > b ? a : b);
      final minExact = allExact.reduce((a, b) => a < b ? a : b);
      
      print('Exact Match Statistics:');
      print('  Average: ${avgExact.toStringAsFixed(1)}ms');
      print('  Min: ${minExact}ms');
      print('  Max: ${maxExact}ms');
      print('');
    }

    final allPartial = results.values
        .map((e) => e['partial']?.inMilliseconds ?? 0)
        .where((e) => e > 0)
        .toList();
    
    if (allPartial.isNotEmpty) {
      final avgPartial = allPartial.reduce((a, b) => a + b) / allPartial.length;
      print('Partial Match Statistics:');
      print('  Average: ${avgPartial.toStringAsFixed(1)}ms');
      print('');
    }

    final allFuzzy = results.values
        .map((e) => e['fuzzy']?.inMilliseconds ?? 0)
        .where((e) => e > 0)
        .toList();
    
    if (allFuzzy.isNotEmpty) {
      final avgFuzzy = allFuzzy.reduce((a, b) => a + b) / allFuzzy.length;
      print('Fuzzy Match Statistics:');
      print('  Average: ${avgFuzzy.toStringAsFixed(1)}ms');
      print('');
    }
  }
}

/// Main entry point
Future<void> main() async {
  print('╔═══════════════════════════════════════════════════════════╗');
  print('║     DPD Search Performance Benchmark                     ║');
  print('╚═══════════════════════════════════════════════════════════╝');
  print('');
  print('Initializing database...');

  // Initialize database
  // Use the mobile database from the dpd-db sibling directory
  final dbPath = '/home/bodhirasa/MyFiles/3_Active/dpd-db/exporter/mobile/dpd-mobile.db';

  if (!File(dbPath).existsSync()) {
    print('ERROR: Database file not found at: $dbPath');
    print('Please ensure the database file exists before running this benchmark.');
    exit(1);
  }

  final db = AppDatabase.forTesting(NativeDatabase(File(dbPath)));
  final dao = DpdDao(db);

  print('Database loaded successfully.');
  print('Starting benchmark...');

  final benchmark = SearchBenchmark(db, dao);

  // Run benchmarks for each test query
  for (final entry in testQueries.entries) {
    await benchmark.runBenchmark(entry.key, entry.value);
  }

  // Print summary
  benchmark.printSummary();

  // Cleanup
  await db.close();
  print('\nBenchmark complete. Database closed.');
}
