import 'package:dpd_flutter_app/database/database.dart';
import 'package:dpd_flutter_app/providers/dict_provider.dart';
import 'package:dpd_flutter_app/providers/search_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Helpers to build AsyncValue states for testing
AsyncValue<List<DpdHeadwordWithRoot>> _loadingHw() =>
    const AsyncValue<List<DpdHeadwordWithRoot>>.loading();

AsyncValue<List<DpdHeadwordWithRoot>> _emptyHw() =>
    const AsyncValue.data([]);

AsyncValue<List<RootWithFamilies>> _loadingRoot() =>
    const AsyncValue<List<RootWithFamilies>>.loading();

AsyncValue<List<RootWithFamilies>> _emptyRoot() =>
    const AsyncValue.data([]);

AsyncValue<List<Object>> _loadingSec() =>
    const AsyncValue<List<Object>>.loading();

AsyncValue<List<Object>> _emptySec() =>
    const AsyncValue.data([]);

AsyncValue<DictSearchResults> _loadingDict() =>
    const AsyncValue<DictSearchResults>.loading();

AsyncValue<DictSearchResults> _emptyDict() =>
    const AsyncValue.data(DictSearchResults());

AsyncValue<DictSearchResults> _dictWithResults() =>
    AsyncValue.data(DictSearchResults(
      exact: [DictResult(dictId: 'cone', dictName: 'Cone', entries: [])],
    ));

AsyncValue<DictSearchResults> _dictWithPartialResults() =>
    AsyncValue.data(DictSearchResults(
      partial: [DictResult(dictId: 'cone', dictName: 'Cone', entries: [])],
    ));

AsyncValue<List<DpdHeadwordWithRoot>> _errorHw() =>
    AsyncValue<List<DpdHeadwordWithRoot>>.error(Exception('fail'), StackTrace.empty);

AsyncValue<DictSearchResults> _errorDict() =>
    AsyncValue<DictSearchResults>.error(Exception('fail'), StackTrace.empty);

SearchAggregateState _compute({
  String query = 'test',
  AsyncValue<List<DpdHeadwordWithRoot>>? exact,
  AsyncValue<List<DpdHeadwordWithRoot>>? partial,
  AsyncValue<List<RootWithFamilies>>? root,
  AsyncValue<List<Object>>? secondary,
  AsyncValue<DictSearchResults>? dict,
  AsyncValue<List<DpdHeadwordWithRoot>>? fuzzy,
}) {
  return computeSearchState(
    query: query,
    exact: exact ?? _emptyHw(),
    partial: partial ?? _emptyHw(),
    root: root ?? _emptyRoot(),
    secondary: secondary ?? _emptySec(),
    dict: dict ?? _emptyDict(),
    fuzzy: fuzzy ?? _emptyHw(),
  );
}

void main() {
  group('computeSearchState', () {
    test('no results not allowed while any source is still loading', () {
      final state = _compute(
        exact: _loadingHw(),
        partial: _loadingHw(),
        root: _loadingRoot(),
        secondary: _loadingSec(),
        dict: _loadingDict(),
        fuzzy: _loadingHw(),
      );
      expect(state.shouldShowNoResults, isFalse);
      expect(state.status, SearchStatus.loading);
    });

    test('fuzzy loading blocks no-results', () {
      final state = _compute(fuzzy: _loadingHw());
      expect(state.shouldShowNoResults, isFalse);
    });

    test('dict loading blocks no-results', () {
      final state = _compute(dict: _loadingDict());
      expect(state.shouldShowNoResults, isFalse);
    });

    test('all providers loaded and empty produces no-results', () {
      final state = _compute();
      expect(state.shouldShowNoResults, isTrue);
      expect(state.status, SearchStatus.noResults);
    });

    test('dict results arriving after fuzzy produces has-results', () {
      final state = _compute(dict: _dictWithResults());
      expect(state.hasResults, isTrue);
      expect(state.status, SearchStatus.hasResults);
      expect(state.shouldShowNoResults, isFalse);
    });

    test('progressive rendering: exact has results, dict still loading', () {
      final state = _compute(
        exact: AsyncValue.data([_dummyHeadword()]),
        dict: _loadingDict(),
      );
      expect(state.hasResults, isTrue);
      expect(state.status, SearchStatus.hasResults);
    });

    test('empty query returns initial state', () {
      final state = _compute(query: '');
      expect(state.status, SearchStatus.initial);
      expect(state.shouldShowNoResults, isFalse);
    });

    test('any populated source produces has-results', () {
      final state = _compute(
        exact: AsyncValue.data([_dummyHeadword()]),
      );
      expect(state.hasResults, isTrue);
      expect(state.status, SearchStatus.hasResults);
    });

    test('stale prior query cannot drive current query state', () {
      final stateA = _compute(query: 'queryA');
      final stateB = _compute(query: 'queryB');
      expect(stateA.query, 'queryA');
      expect(stateB.query, 'queryB');
    });

    test('provider error is not treated as loaded-empty', () {
      final state = _compute(exact: _errorHw());
      expect(state.anyError, isTrue);
      expect(state.shouldShowNoResults, isFalse);
    });

    test('provider error with no visible results blocks no-results', () {
      final state = _compute(dict: _errorDict());
      expect(state.shouldShowNoResults, isFalse);
      expect(state.status, SearchStatus.error);
    });

    test('hasResults is true when only dictionary partial exists', () {
      final state = _compute(dict: _dictWithPartialResults());
      expect(state.hasResults, isTrue);
      expect(state.status, SearchStatus.hasResults);
      expect(state.shouldShowNoResults, isFalse);
    });

    test('hasResults is true when only DPD fuzzy results exist', () {
      final state = _compute(fuzzy: AsyncValue.data([_dummyHeadword()]));
      expect(state.hasResults, isTrue);
      expect(state.status, SearchStatus.hasResults);
      expect(state.shouldShowNoResults, isFalse);
    });

    test('shouldShowNoResults is false whenever any tier has content', () {
      for (final state in [
        _compute(exact: AsyncValue.data([_dummyHeadword()])),
        _compute(partial: AsyncValue.data([_dummyHeadword()])),
        _compute(fuzzy: AsyncValue.data([_dummyHeadword()])),
        _compute(dict: _dictWithResults()),
        _compute(dict: _dictWithPartialResults()),
      ]) {
        expect(state.shouldShowNoResults, isFalse);
      }
    });

    test('SearchAggregateState has no shouldShowFuzzyFallback field', () {
      final state = _compute();
      expect(
        () => (state as dynamic).shouldShowFuzzyFallback,
        throwsNoSuchMethodError,
      );
    });
  });
}

DpdHeadwordWithRoot _dummyHeadword() {
  return DpdHeadwordWithRoot(
    const DpdHeadword(id: 1, lemma1: 'test'),
    null,
  );
}
