source("R/simulate_alpha_z.R")
source("R/simulate_sigma_e3.R")

args <- parse_cli_args(commandArgs(trailingOnly = TRUE))
if (is.null(args$nsamp)) args$nsamp <- 2000L
if (is.null(args$nsim)) args$nsim <- 200L
if (is.null(args$seed)) args$seed <- 123L

alpha_results <- run_alpha_z_simulation(
  nsamp = args$nsamp,
  nsim = args$nsim,
  seed = args$seed
)

sigma_results <- run_sigma_e3_simulation(
  nsamp = args$nsamp,
  nsim = args$nsim,
  seed = args$seed
)

alpha_zero <- alpha_results[which.min(abs(alpha_results$scenario_value)), ]
alpha_empirical_matches <- sum(alpha_results$empirical_adjusted >= alpha_results$empirical_crude)
sigma_empirical_matches <- sum(sigma_results$empirical_adjusted >= sigma_results$empirical_crude)
alpha_theory_mad <- mean(abs(alpha_results$empirical_adjusted - alpha_results$theoretical_adjusted))
sigma_theory_mad <- mean(abs(sigma_results$empirical_adjusted - sigma_results$theoretical_adjusted))

checks <- list(
  alpha_grid_rows = nrow(alpha_results) == 21,
  sigma_grid_rows = nrow(sigma_results) == 11,
  alpha_theoretical_amplification = all(alpha_results$theoretical_adjusted >= alpha_results$theoretical_crude),
  sigma_theoretical_amplification = all(sigma_results$theoretical_adjusted >= sigma_results$theoretical_crude),
  alpha_empirical_majority_amplification = alpha_empirical_matches >= 20,
  sigma_empirical_majority_amplification = sigma_empirical_matches >= 10,
  alpha_zero_near_equality = abs(alpha_zero$empirical_adjusted - alpha_zero$empirical_crude) < 0.01,
  truth_near_zero = max(c(alpha_results$truth, sigma_results$truth)) < 0.02,
  alpha_adjusted_theory_close = alpha_theory_mad < 0.01,
  sigma_adjusted_theory_close = sigma_theory_mad < 0.01
)

cat("Paper consistency check\n")
cat(sprintf("nsamp=%d nsim=%d seed=%d\n", args$nsamp, args$nsim, args$seed))
cat(sprintf("alpha empirical adjusted>=crude count: %d/21\n", alpha_empirical_matches))
cat(sprintf("sigma empirical adjusted>=crude count: %d/11\n", sigma_empirical_matches))
cat(sprintf("alpha adjusted-vs-theory mean abs diff: %.6f\n", alpha_theory_mad))
cat(sprintf("sigma adjusted-vs-theory mean abs diff: %.6f\n", sigma_theory_mad))
cat(sprintf("alpha zero crude-adjusted abs diff: %.6f\n", abs(alpha_zero$empirical_adjusted - alpha_zero$empirical_crude)))

failed <- names(checks)[!unlist(checks)]
if (length(failed) > 0) {
  cat("FAILED checks:\n")
  for (name in failed) cat("- ", name, "\n", sep = "")
  quit(status = 1)
}

cat("All qualitative paper checks passed.\n")
