---
agent: 'agent'
description: 'Validate CHANGELOG.md structure and content'
---

Validate CHANGELOG.md against these rules:

**Structure**
- Reverse chronological versions with Data and Development sections
- Valid Markdown syntax

**Dataset Keys**
- Match `import/` folder names
- All keys must be included
- Alphabetically sorted in Added/Updated lists

**Data Updates**
- "Added": initial folder creation in version range (manually verify with commit history)
- "Updated": substantive data changes (not formatting/encoding fixes)
- Check for missing: `git log --after="PREV_DATE" --before="CURR_DATE" -- import/*/*.csv`

**Development Entries**
- Present-tense verbs (new entries): Add, Update, Fix, Remove, Migrate, Format, Configure
- Format: `[hash](url)` for commits, `#N` for PRs/issues
- Verify: `git log [hash] -1` and `gh pr view N` / `gh issue view N`
- Check for missing significant commits/PRs (minor changes may be excluded)

**Version Dates**
- Match git tag dates: `git log --tags --simplify-by-decoration --pretty="format:%ci %d" | grep v20`
- All entries between previous and current version dates

Report violations with line numbers.
