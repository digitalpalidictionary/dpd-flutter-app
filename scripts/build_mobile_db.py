"""
Build a stripped mobile.db from the full dpd.db for use in the Flutter app.

Usage:
    python scripts/build_mobile_db.py --source /path/to/dpd.db --output mobile.db

The full dpd.db is ~2.1 GB. This script produces a mobile.db of ~150-250 MB
by retaining only the columns and tables needed by the Flutter app.
"""

import argparse
import sqlite3
from pathlib import Path


HEADWORDS_COLUMNS: list[str] = [
    "id",
    "lemma_1",
    "lemma_2",
    "pos",
    "grammar",
    "derived_from",
    "neg",
    "verb",
    "trans",
    "plus_case",
    "derivative",
    "meaning_1",
    "meaning_lit",
    "meaning_2",
    "root_key",
    "root_sign",
    "root_base",
    "family_root",
    "family_word",
    "family_compound",
    "family_idioms",
    "family_set",
    "construction",
    "compound_type",
    "compound_construction",
    "source_1",
    "sutta_1",
    "example_1",
    "source_2",
    "sutta_2",
    "example_2",
    "antonym",
    "synonym",
    "variant",
    "stem",
    "pattern",
    "suffix",
    "inflections_html",
    "freq_html",
    "ebt_count",
    "notes",
    "commentary",
]

ROOTS_COLUMNS: list[str] = [
    "root",
    "root_in_comps",
    "root_has_verb",
    "root_group",
    "root_sign",
    "root_meaning",
    "root_count",
    "root_example",
    "sanskrit_root",
    "sanskrit_root_meaning",
    "sanskrit_root_class",
    "root_info",
]

LOOKUP_COLUMNS: list[str] = [
    "lookup_key",
    "headwords",
    "roots",
    "variant",
    "see",
    "spelling",
    "grammar",
    "help",
    "abbrev",
]

DB_INFO_COLUMNS: list[str] = [
    "key",
    "value",
]

DB_INFO_KEYS: set[str] = {
    "db_version",
    "dpd_release_date",
}


def get_available_columns(cursor: sqlite3.Cursor, table: str, wanted: list[str]) -> list[str]:
    cursor.execute(f"PRAGMA table_info({table})")
    existing = {row[1] for row in cursor.fetchall()}
    available = [col for col in wanted if col in existing]
    missing = [col for col in wanted if col not in existing]
    if missing:
        print(f"  Warning: {table} missing columns: {missing}")
    return available


def build_mobile_db(source_path: Path, output_path: Path) -> None:
    if not source_path.exists():
        raise FileNotFoundError(f"Source database not found: {source_path}")

    if output_path.exists():
        output_path.unlink()
        print(f"Removed existing {output_path}")

    print(f"Reading from: {source_path} ({source_path.stat().st_size / 1e9:.2f} GB)")
    print(f"Writing to:   {output_path}")

    src = sqlite3.connect(source_path)
    dst = sqlite3.connect(output_path)

    src_cur = src.cursor()
    dst_cur = dst.cursor()

    _copy_headwords(src_cur, dst_cur)
    _copy_roots(src_cur, dst_cur)
    _copy_lookup(src_cur, dst_cur)
    _copy_db_info(src_cur, dst_cur)

    print("Creating indexes...")
    dst_cur.execute("CREATE INDEX IF NOT EXISTS idx_lookup_key ON lookup(lookup_key)")
    dst_cur.execute("CREATE INDEX IF NOT EXISTS idx_headwords_id ON dpd_headwords(id)")
    dst_cur.execute("CREATE INDEX IF NOT EXISTS idx_headwords_lemma ON dpd_headwords(lemma_1)")

    print("Running VACUUM to compact...")
    dst.execute("VACUUM")
    dst.commit()

    dst.close()
    src.close()

    size_mb = output_path.stat().st_size / 1e6
    print(f"\nDone. mobile.db size: {size_mb:.1f} MB")


def _copy_headwords(src_cur: sqlite3.Cursor, dst_cur: sqlite3.Cursor) -> None:
    cols = get_available_columns(src_cur, "dpd_headwords", HEADWORDS_COLUMNS)
    col_list = ", ".join(cols)
    placeholders = ", ".join(["?"] * len(cols))

    print(f"Copying dpd_headwords ({len(cols)} columns)...")

    dst_cur.execute(f"""
        CREATE TABLE dpd_headwords (
            {', '.join(f'{c} TEXT' if c != 'id' and c != 'ebt_count' else f'{c} INTEGER' for c in cols)},
            PRIMARY KEY (id)
        )
    """)

    src_cur.execute(f"SELECT {col_list} FROM dpd_headwords")
    batch: list[tuple] = []
    count = 0
    for row in src_cur:
        batch.append(row)
        if len(batch) >= 5000:
            dst_cur.executemany(f"INSERT INTO dpd_headwords VALUES ({placeholders})", batch)
            count += len(batch)
            batch = []
            print(f"  {count:,} rows...", end="\r")

    if batch:
        dst_cur.executemany(f"INSERT INTO dpd_headwords VALUES ({placeholders})", batch)
        count += len(batch)

    print(f"  {count:,} headword rows copied.          ")


def _copy_roots(src_cur: sqlite3.Cursor, dst_cur: sqlite3.Cursor) -> None:
    try:
        cols = get_available_columns(src_cur, "dpd_roots", ROOTS_COLUMNS)
    except Exception:
        print("  Skipping dpd_roots (table not found)")
        return

    col_list = ", ".join(cols)
    placeholders = ", ".join(["?"] * len(cols))

    print(f"Copying dpd_roots ({len(cols)} columns)...")

    dst_cur.execute(f"""
        CREATE TABLE dpd_roots (
            {', '.join(f'{c} TEXT' for c in cols)},
            PRIMARY KEY (root)
        )
    """)

    src_cur.execute(f"SELECT {col_list} FROM dpd_roots")
    rows = src_cur.fetchall()
    dst_cur.executemany(f"INSERT INTO dpd_roots VALUES ({placeholders})", rows)
    print(f"  {len(rows):,} root rows copied.")


def _copy_lookup(src_cur: sqlite3.Cursor, dst_cur: sqlite3.Cursor) -> None:
    cols = get_available_columns(src_cur, "lookup", LOOKUP_COLUMNS)
    col_list = ", ".join(cols)
    placeholders = ", ".join(["?"] * len(cols))

    print(f"Copying lookup ({len(cols)} columns)...")

    dst_cur.execute(f"""
        CREATE TABLE lookup (
            {', '.join(f'{c} TEXT' for c in cols)},
            PRIMARY KEY (lookup_key)
        )
    """)

    src_cur.execute(f"SELECT {col_list} FROM lookup")
    batch = []
    count = 0
    for row in src_cur:
        batch.append(row)
        if len(batch) >= 10000:
            dst_cur.executemany(f"INSERT INTO lookup VALUES ({placeholders})", batch)
            count += len(batch)
            batch = []
            print(f"  {count:,} rows...", end="\r")

    if batch:
        dst_cur.executemany(f"INSERT INTO lookup VALUES ({placeholders})", batch)
        count += len(batch)

    print(f"  {count:,} lookup rows copied.          ")


def _copy_db_info(src_cur: sqlite3.Cursor, dst_cur: sqlite3.Cursor) -> None:
    try:
        src_cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='db_info'")
        if not src_cur.fetchone():
            print("  Skipping db_info (table not found)")
            _create_placeholder_db_info(dst_cur)
            return
    except Exception:
        _create_placeholder_db_info(dst_cur)
        return

    cols = get_available_columns(src_cur, "db_info", DB_INFO_COLUMNS)
    col_list = ", ".join(cols)
    placeholders = ", ".join(["?"] * len(cols))

    print("Copying db_info...")

    dst_cur.execute("""
        CREATE TABLE db_info (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    """)

    src_cur.execute(f"SELECT {col_list} FROM db_info WHERE key IN ({', '.join('?' * len(DB_INFO_KEYS))})",
                    list(DB_INFO_KEYS))
    rows = src_cur.fetchall()
    dst_cur.executemany(f"INSERT INTO db_info VALUES ({placeholders})", rows)
    print(f"  {len(rows)} db_info rows copied.")


def _create_placeholder_db_info(dst_cur: sqlite3.Cursor) -> None:
    dst_cur.execute("""
        CREATE TABLE IF NOT EXISTS db_info (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    """)
    dst_cur.execute(
        "INSERT INTO db_info VALUES ('db_version', '0.0.0')"
    )
    dst_cur.execute(
        "INSERT INTO db_info VALUES ('dpd_release_date', 'unknown')"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Build stripped mobile.db from dpd.db")
    parser.add_argument(
        "--source",
        type=Path,
        default=Path("../dpd-db/dpd.db"),
        help="Path to full dpd.db (default: ../dpd-db/dpd.db)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/db/mobile.db"),
        help="Output path for mobile.db (default: assets/db/mobile.db)",
    )
    args = parser.parse_args()

    output_path = args.output
    output_path.parent.mkdir(parents=True, exist_ok=True)

    build_mobile_db(args.source, output_path)


if __name__ == "__main__":
    main()
