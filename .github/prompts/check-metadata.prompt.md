---
agent: 'agent'
description: 'Check metadata coherence across project files'
---

# Metadata Coherence Check Prompt

Check metadata consistency across Party Facts project files: codemeta.json, CITATION.cff, README.md, LICENSE.md, CHANGELOG.md, and codebook/codebook.Rmd.

## Files to Analyze

1. `codemeta.json` (CodeMeta 3.0)
2. `CITATION.cff` (CFF 1.2.0)
3. `README.md`
4. `LICENSE.md`
5. `CHANGELOG.md`
6. `codebook/codebook.Rmd`

## Metadata Fields to Check

### 1. Title/Name
- **Expected:** "Party Facts data import"
- **Exception:** codebook.Rmd uses "Party Facts Codebook" (intentional)

### 2. Description/Abstract
- **Expected:** "Data import scripts and infrastructure for the Party Facts project, a gateway to empirical data about political parties worldwide."

### 3. Authors
**Expected order:**
1. Paul Bederke - GESIS Leibniz Institute for the Social Sciences, Germany - ORCID: 0000-0001-7555-8656 - since 2019
2. Holger Döring - SOCIUM Research Center, University of Bremen, Germany - ORCID: 0000-0002-6616-8805 - since 2012
3. Sven Regel - WZB Berlin Social Science Center, Germany - NO ORCID - 2012-2023

**CRITICAL:** Döring's affiliation must include "University of Bremen" not just "SOCIUM Research Center"

### 4. Keywords
**Expected (codemeta.json & CITATION.cff):** political science, comparative politics, political parties, data linking, data harmonization, research software

### 5. License
- **Expected:** MIT license
- codemeta.json: `https://spdx.org/licenses/MIT`
- CITATION.cff: `MIT`
- LICENSE.md: Full MIT text with "Copyright (c) 2022 Party Facts authors"
- **Note:** Copyright year 2022 is intentional (do not update)

### 6. URLs
- **Repository:** `https://github.com/hdigital/partyfactsdata`
- **Primary project:** `http://partyfacts.org` (redirects 301 to herokuapp.com)
- **Secondary:** `https://partyfacts.herokuapp.com`
- **RSS Feed:** `https://partyfacts.herokuapp.com/documentation/news/feed/`
- **DOI:** `https://doi.org/10.1177/1354068818820671`
- **Dataverse:** `https://dataverse.harvard.edu/dataverse/partyfacts`
- **ORCIDs:** `https://orcid.org/0000-0001-7555-8656` (Bederke), `https://orcid.org/0000-0002-6616-8805` (Döring)

### 7. Version
- **Expected:** "0" (development version, intentional despite tagged releases)

### 8. Dates
- codemeta.json: `"dateCreated": "2015-11-09"`
- **Note:** ISO dates (YYYY-MM-DD) in metadata, years only in docs (intentional)

### 9. References
1. **Journal:** Döring & Regel. 2019. Party Politics 25(2): 97–109. DOI: 10.1177/1354068818820671
2. **Dataverse:** Bederke, Döring & Regel. 2018. Harvard Dataverse
3. **Self-reference** (CITATION.cff): Year should match date-released for development versions

### 10. Contact
- Present in README.md and codebook.Rmd (paul.bederke gesis org)
- NOT in CITATION.cff (per project guidance)

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

**Troubleshooting:** partyfacts.org has bot protection that returns 403 for browser-like User-Agents and IPv6 requests; use `curl -4` (IPv4, curl default UA) to get the actual 301 redirect. Use `-L` to follow redirects, test 403s manually in browser

## Intentional Design Choices

These should NOT be flagged as issues:
1. Version "0" - Marks development version despite tagged releases
2. Copyright year 2022 - License assignment date, not to be updated
3. Dual URLs - Both partyfacts.org and herokuapp.com are valid
4. Sven Regel without ORCID - Not available
5. Date precision differences - ISO in metadata, years in docs
6. Codebook title - "Party Facts Codebook" is correct for distinct document
7. http:// for partyfacts.org - Redirects to HTTPS; HTTP protocol is correct
8. Self-reference year matches date-released - Acceptable for development versions

## Severity Levels

- **CRITICAL** - Incorrect data, missing essential information, significant confusion (e.g., wrong affiliation, missing institutional context)
- **WARNING** - Inconsistency with moderate impact (e.g., formatting differences, unclear documentation)
- **INFO** - Observation or potential improvement, not an actual problem

## Execution Steps

1. **Extract Metadata:** Read all 6 files and extract metadata fields (1-10 above)
2. **Compare Fields:** For each field, compare values across files, note differences, check if intentional
3. **Identify Issues:** Document affected files, exact values, line numbers, severity, impact, recommendations
4. **Verify URLs/APIs:** Test all URLs and API endpoints for accessibility and correct responses
5. **Validate:** Run `uvx cffconvert --validate` on CITATION.cff
6. **Generate Report:** Include executive summary, detailed findings by severity, metadata coverage table, compliance checks, URL verification results, recommended actions

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

## Common Issues

**High Priority:**
- Incomplete affiliations (especially Döring missing "University of Bremen")
- Date inconsistencies in CITATION.cff
- License mismatches

**Medium Priority:**
- Contact format variations
- URL protocol issues (http vs https)
- API endpoint accessibility
- CFF validation failures

**Low Priority:**
- Historical contributors not in metadata
- Date precision documentation
- Development status clarity

## Validation Checklist

- [ ] All 6 files analyzed
- [ ] All 10 metadata fields checked
- [ ] All URLs and API endpoints tested
- [ ] Redirect behavior documented (partyfacts.org)
- [ ] Intentional design choices excluded
- [ ] Severity levels appropriate
- [ ] Line numbers provided
- [ ] Recommendations actionable
- [ ] CITATION.cff validates: `uvx cffconvert --validate`
- [ ] API endpoints return valid CSV data

## Update Strategy

When project metadata changes:
1. Update codemeta.json first (authoritative)
2. Update CITATION.cff to match
3. Update human-readable docs (README, codebook)
4. Run this coherence check
5. Update CHANGELOG.md

---

**Last Updated:** 2026-02-07
**Related Files:** codemeta.json, CITATION.cff, README.md, LICENSE.md, CHANGELOG.md, codebook/codebook.Rmd
