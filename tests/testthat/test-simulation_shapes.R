library(testthat)

setwd(testthat::test_path("../.."))
source("R/simulate_alpha_z.R")
source("R/simulate_sigma_e3.R")

simulation_columns <- c(
  "scenario_value",
  "empirical_crude",
  "empirical_adjusted",
  "truth",
  "theoretical_crude",
  "theoretical_adjusted"
)

test_that("alpha-z simulation returns thesis grid and expected columns", {
  results <- run_alpha_z_simulation(nsamp = 200, nsim = 8, seed = 1)

  expect_equal(nrow(results), 21)
  expect_named(results, simulation_columns)
  expect_equal(results$scenario_value, seq(-1, 1, by = 0.1))
  expect_true(all(is.finite(as.matrix(results))))
  expect_true(max(abs(results$truth)) < 0.05)
})

test_that("sigma-e3 simulation returns thesis grid and expected columns", {
  results <- run_sigma_e3_simulation(nsamp = 200, nsim = 8, seed = 1)

  expect_equal(nrow(results), 11)
  expect_named(results, simulation_columns)
  expect_equal(results$scenario_value, seq(0.5, 3, by = 0.25))
  expect_true(all(is.finite(as.matrix(results))))
  expect_true(max(abs(results$truth)) < 0.05)
})

test_that("adjusted bias is generally amplified relative to crude bias", {
  alpha_results <- run_alpha_z_simulation(nsamp = 500, nsim = 40, seed = 11)
  sigma_results <- run_sigma_e3_simulation(nsamp = 500, nsim = 40, seed = 11)

  expect_equal(sum(alpha_results$empirical_adjusted >= alpha_results$empirical_crude), 21)
  expect_equal(sum(sigma_results$empirical_adjusted >= sigma_results$empirical_crude), 11)
  expect_true(all(alpha_results$theoretical_adjusted >= alpha_results$theoretical_crude))
  expect_true(all(sigma_results$theoretical_adjusted >= sigma_results$theoretical_crude))
})
