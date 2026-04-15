## Overview
Fix search bar input behavior for sutta codes and punctuation.

## What it should do
1. Typing "sn12.1" must not auto-insert a space after the dot
2. Numbers and dots must pass through transliteration unchanged
3. Searching "ko?" or "ko!" must find "ko" — strip ? and ! from queries

## Assumptions & uncertainties
- Auto-space is caused by Android keyboard autocorrect (Flutter TextField default: true)
- ScriptDetector.getLanguage() may mishandle digit+dot input — safe to short-circuit
- Stripping ?! in _normalizeQuery covers all DB search paths
- Also strip in UI layer before autocomplete uses the query

## Constraints
- Don't break Velthuis conversion (.t → ṭ, .m → ṃ, etc.)
- Don't break non-Roman script detection (only short-circuit clearly Roman+digit input)

## How we'll know it's done
- Type "sn12.1" → no space inserted, search works
- Type "ko?" → finds same results as "ko"
- Type "dhamma" → still works normally
- Velthuis ".t" still converts to ṭ

## What's not included
- Changes to database lookup logic beyond stripping ?!
