# Bias Amplification Simulations

This repository provides a public, reproducible implementation of the simulation study in Section 3 of the master's thesis:

Dong, Zhejia, "Measuring Bias Amplification in a Linear Model When Instrumental Variables are Related to Measured Confounding" (2023). Biostatistics Theses and Dissertations. Brown Digital Repository. Brown University Library. https://repository.library.brown.edu/studio/item/bdr:kwzzjyx8/

[![Cite thesis](https://img.shields.io/badge/Cite-Master's%20thesis-1f6feb)](https://repository.library.brown.edu/studio/item/bdr:kwzzjyx8/)
[![CI](https://github.com/zhejiadong/bias-amplification-simulations/actions/workflows/ci.yml/badge.svg)](https://github.com/zhejiadong/bias-amplification-simulations/actions/workflows/ci.yml)

## Overview

The repository reproduces two simulation settings from the thesis:
- bias as the instrument-treatment coefficient alpha_z varies from -1 to 1
- bias as the variance of the Z error term sigma_e3^2 varies from 0.5 to 3, with alpha_z fixed at 0.5

For each setting, the code compares:
- empirical crude bias
- empirical adjusted bias
- truth-model bias
- theoretical crude bias
- theoretical adjusted bias

This repository is intentionally limited to the simulation component of the thesis. The real-data application based on NICHD SECCYD is not included.

## Scope

Included in this repository:
- simulation code
- synthetic summary CSV outputs
- generated figure PDFs
- automated tests and reproducibility scripts

Excluded from this repository:
- NICHD SECCYD data and derivatives
- IRB or institutional documentation
- proposal, signature, or administrative materials
- large intermediate `.RData` files from earlier exploratory work

## Repository layout

- `R/parameters.R`: thesis parameters and simulation grids
- `R/utils.R`: helper utilities for model fitting, CLI parsing, and path setup
- `R/simulate_alpha_z.R`: simulation over the alpha_z grid
- `R/simulate_sigma_e3.R`: simulation over the sigma_e3^2 grid
- `R/plot_results.R`: plotting helpers
- `scripts/run_all.R`: end-to-end driver for regenerating outputs
- `scripts/check_paper_consistency.R`: qualitative verification against the thesis results
- `tests/testthat/`: smoke tests and scientific sanity checks
- `outputs/`: lightweight CSV summaries
- `figures/`: generated PDF figures

## Model specification

Simulation 1 uses:
- Y = 0.2 + 0.3 D + 0.2 U + 0.2 X + e1
- D = 0.2 + alpha_z Z + 0.2 U + 0.2 X + e2
- Z = 0.2 + 0.3 X + e3
- U ~ N(0.5, 1), X ~ N(0.5, 1), e1, e2, e3 ~ N(0, 1)

Simulation 2 uses the same model with:
- alpha_z = 0.5
- var(e3) varying from 0.5 to 3 by 0.25

## Improvements over the original thesis code

Compared with the original research directory, this repository:
- computes results one replicate at a time
- stores only compact summary outputs needed for the reported bias curves
- avoids distributing very large intermediate objects
- is easier to rerun, inspect, and reuse

## Requirements

Required R packages:
- testthat
- ggplot2
- tidyr

Install them if needed:

```r
install.packages(c("testthat", "ggplot2", "tidyr"))
```

## Running the tests

```bash
Rscript tests/testthat.R
```

## Checking qualitative agreement with the thesis

```bash
Rscript scripts/check_paper_consistency.R --nsim=200 --nsamp=2000 --seed=123
```

This script checks the main qualitative conclusions discussed in the thesis, including:
- adjusted bias exceeding crude bias across the grids
- theoretical adjusted bias exceeding theoretical crude bias
- truth-model bias remaining near zero
- crude and adjusted bias being nearly equal at alpha_z = 0
- empirical adjusted bias remaining close to theoretical adjusted bias
- the expected shape of the crude bias curves across alpha_z and sigma_e3^2

## Regenerating outputs

Smoke-test run:

```bash
Rscript scripts/run_all.R --nsim=50 --nsamp=1000 --seed=123
```

Thesis-scale run:

```bash
Rscript scripts/run_all.R --nsim=2500 --nsamp=10000 --seed=123
```

Generated files:
- `outputs/alpha_z_results.csv`
- `outputs/sigma_e3_results.csv`
- `figures/alpha_z_bias.pdf`
- `figures/sigma_e3_bias.pdf`

## Citation

Please cite both the repository and the underlying thesis. Machine-readable citation metadata is provided in `CITATION.cff`.

Suggested thesis citation:

Dong, Zhejia, "Measuring Bias Amplification in a Linear Model When Instrumental Variables are Related to Measured Confounding" (2023). Biostatistics Theses and Dissertations. Brown Digital Repository. Brown University Library. https://repository.library.brown.edu/studio/item/bdr:kwzzjyx8/
