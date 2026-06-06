# Bias amplification simulations

This repository is a clean, public GitHub-ready rewrite of the simulation study from Section 3 of my master's thesis:

Dong, Zhejia, "Measuring Bias Amplification in a Linear Model When Instrumental Variables are Related to Measured Confounding" (2023). Biostatistics Theses and Dissertations. Brown Digital Repository. Brown University Library. https://repository.library.brown.edu/studio/item/bdr:kwzzjyx8/

[![Cite thesis](https://img.shields.io/badge/Cite-Master's%20thesis-1f6feb)](https://repository.library.brown.edu/studio/item/bdr:kwzzjyx8/)
[![CI](https://github.com/zhejiadong/bias-amplification-simulations/actions/workflows/ci.yml/badge.svg)](https://github.com/zhejiadong/bias-amplification-simulations/actions/workflows/ci.yml)

## How to cite

- Thesis: cite the Brown master's thesis above.
- Code: cite this GitHub repository as the public simulation-only implementation.
- Metadata: GitHub-compatible citation metadata is provided in `CITATION.cff`.

It reproduces the simulation logic behind two thesis results:
- bias as the instrument-treatment coefficient alpha_z varies from -1 to 1
- bias as the variance of the Z error term sigma_e3^2 varies from 0.5 to 3 with alpha_z fixed at 0.5

The repository is intentionally simulation-only. The human-subject data application based on NICHD SECCYD is not included here.

## Why this repo is safe to publish

Included:
- simulation code only
- synthetic summary CSV outputs
- synthetic figure PDFs
- tests and documentation

Excluded:
- NICHD SECCYD data and any derivatives
- IRB / institutional documents
- signature pages and proposal forms
- old exploratory files and giant intermediate `.RData` objects

See `docs/upload_audit.md` for the upload checklist.

## Thesis model used here

Simulation 1:
- Y = 0.2 + 0.3 D + 0.2 U + 0.2 X + e1
- D = 0.2 + alpha_z Z + 0.2 U + 0.2 X + e2
- Z = 0.2 + 0.3 X + e3
- U ~ N(0.5, 1), X ~ N(0.5, 1), e1,e2,e3 ~ N(0,1)

Simulation 2:
- same model, but alpha_z = 0.5
- var(e3) varies from 0.5 to 3 by 0.25

For both simulations, the code compares:
- empirical crude bias
- empirical adjusted bias
- truth model bias
- theoretical crude bias
- theoretical adjusted bias

## Repository layout

- `R/parameters.R`: thesis parameters and grids
- `R/utils.R`: helpers for OLS fitting, CLI parsing, and directories
- `R/simulate_alpha_z.R`: simulation varying alpha_z
- `R/simulate_sigma_e3.R`: simulation varying sigma_e3^2
- `R/plot_results.R`: plotting helpers
- `scripts/run_all.R`: end-to-end driver
- `tests/testthat/`: smoke tests and scientific sanity checks
- `outputs/`: lightweight CSV summaries
- `figures/`: generated PDF figures
- `docs/`: planning and upload audit notes

## Improvements over the original thesis code

The original folder stored very large array-based `.RData` objects (~9.2 GB each, four files total). This rewrite:
- simulates one replicate at a time
- stores only coefficient summaries needed for the final bias curves
- avoids shipping giant intermediates
- is much easier to rerun and publish

## Requirements

R packages:
- testthat
- ggplot2
- tidyr

Install if needed:

```r
install.packages(c("testthat", "ggplot2", "tidyr"))
```

## Run tests

```bash
Rscript tests/testthat.R
```

## Check that results match the paper qualitatively

```bash
Rscript scripts/check_paper_consistency.R --nsim=200 --nsamp=2000 --seed=123
```

This verification script checks the main qualitative conclusions from the thesis paper:
- adjusted bias is larger than crude bias across the grids
- theoretical adjusted bias is larger than theoretical crude bias
- the truth-model bias remains near zero
- at alpha_z = 0, crude and adjusted bias are nearly equal
- empirical adjusted bias stays close to theoretical adjusted bias
- crude alpha_z bias peaks at alpha_z = 0, rising on the negative side and falling on the positive side
- crude sigma_e3^2 bias decreases as sigma_e3^2 increases, while the amplification gap grows
- adjusted curves remain comparatively flat, matching the thesis discussion in Sections 3.1 and 3.2

## Generate outputs

Smoke test run:

```bash
Rscript scripts/run_all.R --nsim=50 --nsamp=1000 --seed=123
```

Thesis-scale run:

```bash
Rscript scripts/run_all.R --nsim=2500 --nsamp=10000 --seed=123
```

Outputs written:
- `outputs/alpha_z_results.csv`
- `outputs/sigma_e3_results.csv`
- `figures/alpha_z_bias.pdf`
- `figures/sigma_e3_bias.pdf`

## Citation

Please cite both this repository and the underlying master's thesis. A machine-readable citation is provided in `CITATION.cff`.

Suggested thesis citation:

Dong, Zhejia, "Measuring Bias Amplification in a Linear Model When Instrumental Variables are Related to Measured Confounding" (2023). Biostatistics Theses and Dissertations. Brown Digital Repository. Brown University Library. https://repository.library.brown.edu/studio/item/bdr:kwzzjyx8/

## Notes on the real-data application

The thesis also contains a NICHD SECCYD application involving maternal depression, child BMI, maternal education, and paternal sensitivity. That part is not included in this public repo because the priority here is a privacy-safe code release. If you later want a second private or access-controlled repo for the real-data workflow, that should be reviewed separately.
