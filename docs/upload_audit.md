# Upload audit for GitHub release

This repository is intentionally limited to the simulation component of the thesis.

Safe to upload:
- all files currently inside this repository root
- synthetic simulation summaries in outputs/
- synthetic figures in figures/
- code in R/ and scripts/
- tests in tests/
- docs in docs/

Do not upload:
- NICHD SECCYD data or any derivatives
- any row-level human-subject data
- restricted data dictionaries bundled with restricted files
- IRB packets, signatures, authorization pages, or proposal forms
- old exploratory folders outside this repo, especially `codes/thesis/data/` and `codes/thesis/RA/`
- giant original `.RData` simulation arrays (~9.2 GB each)
- Dropbox/editor artifacts (.DS_Store, .Rproj.user, .Rhistory)

Why the real-data application is excluded:
- the thesis data application uses NICHD SECCYD human-subject data and related institutional materials
- even when the data source is externally distributed, the safest public GitHub release is a simulation-only repo unless a separate rights/privacy review is completed

Pre-push checklist:
1. `git status` shows only files from this repo root.
2. No `.RData`, `.rds`, `.zip`, `.pdf` from institutional documents, or dataset extracts are staged accidentally.
3. `find . -type f | sort` contains only simulation/repo files.
4. `Rscript tests/testthat.R` passes.
5. `Rscript scripts/run_all.R --nsim=50 --nsamp=1000` regenerates outputs.
