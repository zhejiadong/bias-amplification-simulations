# Bias Amplification Simulation Repository Plan

> For Hermes: Use subagent-driven-development skill to implement this plan task-by-task.

Goal: publish a clean, reproducible GitHub repository for the simulation component of the thesis "Measuring Bias Amplification in a Linear Model When Instrumental Variables are Related to Measured Confounding" without uploading private or restricted materials.

Architecture: build a simulation-only R project with small, composable scripts/functions. Recreate thesis Section 3 results from the structural model in Equations (9) and (10), save only lightweight summary outputs, and document how to regenerate figures. Exclude all human-subject data, IRB files, signatures, institutional paperwork, Dropbox/editor artifacts, and giant intermediate arrays.

Tech stack: R (base + ggplot2 + dplyr + tidyr), testthat, git, GitHub.

---

## What the thesis requires

From the thesis text:
- Structural model:
  - Y = 0.2 + 0.3 D + 0.2 U + 0.2 X + e1
  - D = 0.2 + alpha_z Z + 0.2 U + 0.2 X + e2
  - Z = 0.2 + 0.3 X + e3
- Simulation 1 varies alpha_z from -1 to 1 by 0.1, with e1,e2,e3 ~ N(0,1)
- Simulation 2 fixes alpha_z = 0.5 and varies var(e3) from 0.5 to 3 by 0.25
- Each scenario uses n = 10000 and nsim = 2500 in the thesis
- Outputs compare empirical crude/adjusted bias vs theoretical crude/adjusted bias, plus a truth column
- Key result to preserve: adjusted bias is generally larger than crude bias

## Privacy / sensitivity review

Do NOT upload:
- NICHD SECCYD data or derivatives
- Any human-subject analysis datasets, imputations, codebooks bundled with restricted files, or row-level exports
- IRB materials, protocol numbers if not needed, signature pages, forms, or authorization pages
- Proposal drafts, slides with internal notes, posters, Dropbox clutter
- .Rproj.user, .Rhistory, .DS_Store, local paths, machine-specific files
- Huge .RData files that only store intermediate simulation arrays (~9.2 GB each)
- Reference PDFs unless copyright/license permits and they are necessary

Safe to upload:
- Clean simulation code recreated from thesis equations
- Synthetic summary CSV outputs generated from simulation
- Synthetic figures regenerated from those summaries
- README, LICENSE, tests, .gitignore, session/package instructions
- A short note describing that the real-data application is excluded for privacy/restriction reasons

## Proposed repository contents

Include:
- README.md
- .gitignore
- LICENSE (optional but recommended)
- R/parameters.R
- R/simulate_alpha_z.R
- R/simulate_sigma_e3.R
- R/plot_results.R
- R/utils.R
- scripts/run_all.R
- tests/testthat/test-simulation_shapes.R
- tests/testthat.R
- outputs/alpha_z_results.csv
- outputs/sigma_e3_results.csv
- figures/alpha_z_bias.pdf
- figures/sigma_e3_bias.pdf
- docs/repository_plan.md
- docs/upload_audit.md

Exclude from repo root and from git history:
- ../submission/
- ../proposel&form/
- ../NICHD SECCYD Documents/
- ../data application/
- ../reference/
- ../abstract&poster/
- ../slides/
- ../virtual/
- old exploratory code under ../codes/thesis/RA/
- old giant .RData outputs under ../codes/thesis/data/

## Implementation tasks

### Task 1: Create repository skeleton
Objective: set up a standalone simulation-only repo.
Files:
- Create: README.md
- Create: .gitignore
- Create: R/
- Create: scripts/
- Create: tests/testthat/
- Create: outputs/
- Create: figures/
- Create: docs/upload_audit.md

### Task 2: Add failing tests first
Objective: define expected output schema and scientific sanity checks before implementation.
Files:
- Create: tests/testthat/test-simulation_shapes.R
- Create: tests/testthat.R
Tests should check:
- alpha-z simulation returns 21 rows
- sigma-e3 simulation returns 11 rows
- required columns exist
- truth column is near zero
- adjusted bias is at least crude bias in most tested settings

### Task 3: Implement lightweight simulation functions
Objective: replace giant array-based code with streaming summaries.
Files:
- Create: R/parameters.R
- Create: R/utils.R
- Create: R/simulate_alpha_z.R
- Create: R/simulate_sigma_e3.R
Approach:
- simulate one replicate at a time
- avoid saving nsamp x nsim x grid arrays
- accumulate only coefficient vectors and theoretical bias summaries
- return tidy data frames

### Task 4: Implement plotting and driver script
Objective: reproduce thesis-style figures and summary CSVs.
Files:
- Create: R/plot_results.R
- Create: scripts/run_all.R
Expected outputs:
- outputs/alpha_z_results.csv
- outputs/sigma_e3_results.csv
- figures/alpha_z_bias.pdf
- figures/sigma_e3_bias.pdf

### Task 5: Document upload policy and reproducibility
Objective: make GitHub-safe scope explicit.
Files:
- Create: docs/upload_audit.md
- Create/modify: README.md
Content should explain:
- this repo covers thesis simulation only
- real-data application is omitted due to privacy/restriction concerns
- how to rerun with thesis-scale parameters
- expected runtime and memory benefits over original code

### Task 6: Verify by execution
Objective: prove the repository works.
Run:
- Rscript tests/testthat.R
- Rscript scripts/run_all.R --nsim 50 --nsamp 1000
Expected:
- tests pass
- CSVs and PDFs are written
- no private source data is touched or copied into the repo
