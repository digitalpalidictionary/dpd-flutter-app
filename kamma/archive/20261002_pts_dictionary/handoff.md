# Handoff — PTS dictionary

State: all `plan.md` tasks `[x]`; `review.md` PASSED. Next: `/kamma:4-finalize`.

- Device test passed (user). After that, the dict name was reverted to plain
  "PTS Pāḷi-English Dictionary" (user: no licence in names). The licence stays
  in the README, GoldenDict/MDict description and docs only.
- The user runs builds and scripts themselves. Do NOT run the exporter or any
  build.
- The memory file `feedback_no_licence_in_dict_name.md` exists but is not yet
  indexed in `MEMORY.md`. Ask the user before adding it, plus a lesson
  "don't run builds/scripts unless asked".
- Commit order (only on the user's "yes"): other-dictionaries submodule →
  dpd-db (exporter, paths, docs, submodule pointer) → app. Don't commit
  `other-dictionaries/dictionaries/mw/source/mwweb1.zip` (an unrelated
  re-download; the user restores or keeps it).
- Pre-existing failures: the MW count test, and ruff in the cone scraper
  (other-dictionaries); 52 flutter analyze infos.
