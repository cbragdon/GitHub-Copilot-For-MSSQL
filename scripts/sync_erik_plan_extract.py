#!/usr/bin/env python3
"""Synchronize vendored plan_extract.py from a pinned Erik Darling commit."""

from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
from urllib.error import URLError
from urllib.request import Request, urlopen


OWNER = "erikdarlingdata"
REPOSITORY = "claude-plugins"
SOURCE_PATH = "plugins/sqlserver-query-plans/skills/query-plan-analysis/scripts/extract.py"


def write_output(name: str, value: str) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with Path(output_path).open("a", encoding="utf-8") as output:
            output.write(f"{name}={value}\n")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Synchronize the vendored plan_extract.py from Erik Darling's repository."
    )
    parser.add_argument(
        "--ref",
        required=True,
        help="Immutable upstream commit SHA to retrieve.",
    )
    parser.add_argument(
        "--target",
        type=Path,
        default=Path("plan_extract.py"),
        help="Local vendored extractor path.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Report whether an update is needed without changing the target.",
    )
    args = parser.parse_args()

    url = (
        f"https://raw.githubusercontent.com/{OWNER}/{REPOSITORY}/"
        f"{args.ref}/{SOURCE_PATH}"
    )
    request = Request(url, headers={"User-Agent": "GitHub-Copilot-For-MSSQL-sync"})

    try:
        with urlopen(request, timeout=30) as response:
            source = response.read()
    except URLError as error:
        raise RuntimeError(f"Unable to download pinned upstream source: {url}") from error

    if not source:
        raise RuntimeError(f"Pinned upstream source was empty: {url}")
    if not args.target.is_file():
        raise RuntimeError(f"Vendored target is missing: {args.target}")

    changed = args.target.read_bytes() != source
    source_sha256 = hashlib.sha256(source).hexdigest()

    write_output("changed", str(changed).lower())
    write_output("source_ref", args.ref)
    write_output("source_sha256", source_sha256)
    write_output("source_url", url)

    print(f"source_ref={args.ref}")
    print(f"source_sha256={source_sha256}")
    print(f"changed={str(changed).lower()}")

    if changed and not args.check:
        args.target.write_bytes(source)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
