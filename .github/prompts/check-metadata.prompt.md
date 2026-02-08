---
agent: 'agent'
description: 'Check metadata consistency.'
---

# Metadata Coherence Check Prompt

Check metadata consistency across Party Facts project files. `codemeta.json` is the **single source of truth** — all other files must be consistent with it.

## Files to Analyze

1. `codemeta.json` (CodeMeta 3.0) — **authoritative source**
2. `CITATION.cff` (CFF 1.2.0)
3. `README.md`
4. `LICENSE.md`
5. `CHANGELOG.md`
6. `codebook/codebook.Rmd`

## Metadata Fields to Check

For each field in `codemeta.json`, extract the authoritative value and verify consistency in the other files: title/name, description, authors, keywords, license, URLs, version, dates, references, contact.

### Field-Specific Notes

These are intentional and should NOT be flagged as issues:
- **Title:** codebook.Rmd uses "Party Facts Codebook" (intentional, distinct document)
- **Authors:** Sven Regel has no ORCID (not available)
- **License:** Copyright year 2022 in LICENSE.md is intentional (do not update)
- **URLs:** Both partyfacts.org and herokuapp.com are valid; http:// for partyfacts.org is correct (redirects to HTTPS)
- **Version:** Development version "0", intentional despite tagged releases
- **Dates:** ISO dates (YYYY-MM-DD) in metadata, years only in docs (intentional)
- **References:** Self-reference year in CITATION.cff should be current year (no date-released for development version)
- **Contact:** Present in README.md and codebook.Rmd — NOT in CITATION.cff

## URL and API Verification

### URLs to Verify
```bash
# Project URLs
curl -4 -I http://partyfacts.org  # Expect: 301 → https://partyfacts.herokuapp.com (use -4 for IPv4; bot protection may return 403 instead — verify 301 with -4 flag)
curl -I https://partyfacts.herokuapp.com  # Expect: 200
curl -I https://partyfacts.herokuapp.com/documentation/about/  # Expect: 200
curl -I https://partyfacts.herokuapp.com/documentation/news/feed/  # Expect: 200 (RSS feed, Content-Type: application/rss+xml)

# API Endpoints (test data retrieval)
curl -s "https://partyfacts.herokuapp.com/download/core-parties-csv/" | head -3
curl -s "https://partyfacts.herokuapp.com/download/external-parties-csv/" | head -3

# Repository, DOI, Dataverse, ORCIDs
curl -I https://github.com/hdigital/partyfactsdata  # Expect: 200
curl -I -L https://doi.org/10.1177/1354068818820671  # Expect: 200 (may be 403)
curl -I https://dataverse.harvard.edu/dataverse/partyfacts  # Expect: 202 (Dataverse collection pages return 202)
curl -I https://orcid.org/0000-0001-7555-8656  # Expect: 200
curl -I https://orcid.org/0000-0002-6616-8805  # Expect: 200

# Standards
curl -I https://spdx.org/licenses/MIT  # Expect: 200
curl -I https://w3id.org/codemeta/3.0  # Expect: 303 (redirect)
```

**Status codes:** 200=OK, 202=Accepted, 301/302=Redirect, 303=See Other, 403=Forbidden (bot blocking, not an error), 404=Not Found (ERROR)

**Troubleshooting:** partyfacts.org bot protection may return 403 even with `curl -4`; report as "unable to verify redirect from CLI" — do not assume browser access works. Use `-L` to follow redirects where possible

## Severity Levels

- **CRITICAL** - Incorrect data, missing essential information, significant confusion (e.g., wrong affiliation, missing institutional context)
- **WARNING** - Inconsistency with moderate impact (e.g., formatting differences, unclear documentation)
- **INFO** - Observation or potential improvement, not an actual problem

## Execution Steps

1. **Read codemeta.json:** Extract all metadata fields as authoritative values
2. **Compare Fields:** For each field, compare values in other files against codemeta.json, note differences, check if intentional
3. **Identify Issues:** Document affected files, exact values, line numbers, severity, impact, recommendations
4. **Verify URLs/APIs:** Test all URLs and API endpoints for accessibility and correct responses
5. **Validate:** Run `uvx cffconvert --validate` on CITATION.cff
6. **Generate Report:** Include executive summary, detailed findings by severity (with line numbers), metadata coverage table, compliance checks, URL verification results, recommended actions

## Expected Output Format

```markdown
# Party Facts Data Project - Metadata Coherence Report
Generated: YYYY-MM-DD

## Executive Summary
✅ CITATION.cff validation: [PASS/FAIL]
Issues: X CRITICAL, Y WARNING, Z INFO

## Critical Issues
### [Issue Name]
**Files:** [list]
**Issue:** [description]
**Impact:** [statement]
**Recommendation:** [action]
**Lines:** [references]

## Warning Issues
[same structure]

## Metadata Coverage Summary
| Field | codemeta | CFF | README | LICENSE | CHANGELOG | codebook | Status |
[...table...]

## Compliance with Standards
- CodeMeta 3.0: [✅/❌]
- CFF 1.2.0: [✅/❌]
- SPDX: [✅/❌]
- ORCID: [✅/❌]

## URL and API Verification
| Category | URL | Status | Notes |
[...table...]

## Recommended Actions
### High Priority
### Medium Priority
### Low Priority
```

## Update Strategy

When project metadata changes:
1. Update codemeta.json first (authoritative)
2. Update CITATION.cff to match
3. Update human-readable docs (README, codebook)
4. Run this coherence check
5. Update CHANGELOG.md
