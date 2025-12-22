#!/usr/bin/env -S uv run
"""Format files added or modified since 2024 according to git."""

import subprocess
from pathlib import Path


def get_modified_files():
    """Get files modified since 2024, excluding automated formatting commits."""
    result = subprocess.run(
        [
            "git",
            "log",
            "--since=2024-01-01",
            "--name-only",
            "--pretty=format:",
            "--diff-filter=AM",
        ],
        capture_output=True,
        text=True,
    )
    all_files = set(f for f in result.stdout.split("\n") if f and Path(f).exists())

    # Get files from formatting commits to exclude
    excluded_files = set()
    for commit in ["40f84ce", "035db5b"]:
        result = subprocess.run(
            ["git", "diff-tree", "--no-commit-id", "--name-only", "-r", commit],
            capture_output=True,
            text=True,
        )
        excluded_files.update(result.stdout.strip().split("\n"))

    # Return unique files not in the excluded list
    return sorted(all_files - excluded_files)


def main():
    print("\n🔍 · Checking for files modified or added since 2024...\n")

    files = get_modified_files()
    print(f"📋 · Files to check:\n\n{chr(10).join(files)}\n\n")

    # Filter by extension, excluding codebook.md
    r_files = [f for f in files if f.endswith(".R")]
    md_files = [f for f in files if f.endswith(".md") and f != "codebook/codebook.md"]

    # Format R files
    if r_files:
        print("📊 · Formatting R files with 'air format'...\n")
        for file in r_files:
            print(f"  - {file}")
            subprocess.run(["air", "format", file])

    # Format Markdown files
    if md_files:
        print("\n\n📝 Formatting Markdown files with 'uvx mdformat'...\n")
        for file in md_files:
            print(f"  - {file}")
            subprocess.run(["uvx", "mdformat", file])

    print("\n\n✅ · Formatting complete!\n")


if __name__ == "__main__":
    main()
