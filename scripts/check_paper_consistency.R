source("R/simulate_alpha_z.R")
source("R/simulate_sigma_e3.R")

args <- parse_cli_args(commandArgs(trailingOnly = TRUE))
if (is.null(args$nsamp)) args$nsamp <- 2000L
if (is.null(args$nsim)) args$nsim <- 200L
if (is.null(args$seed)) args$seed <- 123L

curve_range <- function(x) max(x) - min(x)

spearman_corr <- function(x, y) {
  suppressWarnings(cor(x, y, method = "spearman"))
}

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
alpha_peak_empirical <- alpha_results$scenario_value[which.max(alpha_results$empirical_crude)]
alpha_peak_theoretical <- alpha_results$scenario_value[which.max(alpha_results$theoretical_crude)]
alpha_mid <- which.min(abs(alpha_results$scenario_value))
alpha_left <- seq_len(alpha_mid)
alpha_right <- alpha_mid:nrow(alpha_results)

alpha_empirical_matches <- sum(alpha_results$empirical_adjusted >= alpha_results$empirical_crude)
sigma_empirical_matches <- sum(sigma_results$empirical_adjusted >= sigma_results$empirical_crude)
alpha_theory_mad <- mean(abs(alpha_results$empirical_adjusted - alpha_results$theoretical_adjusted))
sigma_theory_mad <- mean(abs(sigma_results$empirical_adjusted - sigma_results$theoretical_adjusted))
alpha_crude_theory_mad <- mean(abs(alpha_results$empirical_crude - alpha_results$theoretical_crude))
sigma_crude_theory_mad <- mean(abs(sigma_results$empirical_crude - sigma_results$theoretical_crude))

alpha_empirical_gap <- alpha_results$empirical_adjusted - alpha_results$empirical_crude
alpha_theoretical_gap <- alpha_results$theoretical_adjusted - alpha_results$theoretical_crude
sigma_empirical_gap <- sigma_results$empirical_adjusted - sigma_results$empirical_crude
sigma_theoretical_gap <- sigma_results$theoretical_adjusted - sigma_results$theoretical_crude

alpha_empirical_flat_ratio <- curve_range(alpha_results$empirical_adjusted) / curve_range(alpha_results$empirical_crude)
alpha_theoretical_flat_ratio <- curve_range(alpha_results$theoretical_adjusted) / curve_range(alpha_results$theoretical_crude)
sigma_empirical_flat_ratio <- curve_range(sigma_results$empirical_adjusted) / curve_range(sigma_results$empirical_crude)
sigma_theoretical_flat_ratio <- curve_range(sigma_results$theoretical_adjusted) / curve_range(sigma_results$theoretical_crude)

alpha_empirical_edge_gap <- mean(alpha_empirical_gap[c(1, nrow(alpha_results))])
alpha_theoretical_edge_gap <- mean(alpha_theoretical_gap[c(1, nrow(alpha_results))])
alpha_empirical_center_gap <- alpha_empirical_gap[alpha_mid]
alpha_theoretical_center_gap <- alpha_theoretical_gap[alpha_mid]

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
  sigma_adjusted_theory_close = sigma_theory_mad < 0.01,
  alpha_crude_theory_close = alpha_crude_theory_mad < 0.01,
  sigma_crude_theory_close = sigma_crude_theory_mad < 0.01,
  alpha_crude_empirical_peaks_at_zero = abs(alpha_peak_empirical) < 1e-9,
  alpha_crude_theoretical_peaks_at_zero = abs(alpha_peak_theoretical) < 1e-9,
  alpha_crude_empirical_increases_then_decreases =
    all(diff(alpha_results$empirical_crude[alpha_left]) >= -1e-6) &&
    all(diff(alpha_results$empirical_crude[alpha_right]) <= 1e-6),
  alpha_crude_theoretical_increases_then_decreases =
    all(diff(alpha_results$theoretical_crude[alpha_left]) >= -1e-6) &&
    all(diff(alpha_results$theoretical_crude[alpha_right]) <= 1e-6),
  alpha_adjusted_empirical_is_flatter_than_crude = alpha_empirical_flat_ratio < 0.25,
  alpha_adjusted_theoretical_is_flatter_than_crude = alpha_theoretical_flat_ratio < 0.25,
  alpha_amplification_stronger_at_edges_empirical = alpha_empirical_edge_gap > alpha_empirical_center_gap + 0.01,
  alpha_amplification_stronger_at_edges_theoretical = alpha_theoretical_edge_gap > alpha_theoretical_center_gap + 0.01,
  sigma_crude_empirical_decreases_with_variance = spearman_corr(sigma_results$scenario_value, sigma_results$empirical_crude) < -0.8,
  sigma_crude_theoretical_decreases_with_variance = spearman_corr(sigma_results$scenario_value, sigma_results$theoretical_crude) < -0.95,
  sigma_gap_empirical_increases_with_variance = spearman_corr(sigma_results$scenario_value, sigma_empirical_gap) > 0.8,
  sigma_gap_theoretical_increases_with_variance = spearman_corr(sigma_results$scenario_value, sigma_theoretical_gap) > 0.95,
  sigma_adjusted_empirical_is_flatter_than_crude = sigma_empirical_flat_ratio < 0.25,
  sigma_adjusted_theoretical_is_flatter_than_crude = sigma_theoretical_flat_ratio < 0.25
)

cat("Paper consistency check\n")
cat(sprintf("nsamp=%d nsim=%d seed=%d\n", args$nsamp, args$nsim, args$seed))
cat(sprintf("alpha empirical adjusted>=crude count: %d/21\n", alpha_empirical_matches))
cat(sprintf("sigma empirical adjusted>=crude count: %d/11\n", sigma_empirical_matches))
cat(sprintf("alpha adjusted-vs-theory mean abs diff: %.6f\n", alpha_theory_mad))
cat(sprintf("sigma adjusted-vs-theory mean abs diff: %.6f\n", sigma_theory_mad))
cat(sprintf("alpha crude-vs-theory mean abs diff: %.6f\n", alpha_crude_theory_mad))
cat(sprintf("sigma crude-vs-theory mean abs diff: %.6f\n", sigma_crude_theory_mad))
cat(sprintf("alpha zero crude-adjusted abs diff: %.6f\n", abs(alpha_zero$empirical_adjusted - alpha_zero$empirical_crude)))
cat(sprintf("alpha crude empirical peak location: %.1f\n", alpha_peak_empirical))
cat(sprintf("alpha crude theoretical peak location: %.1f\n", alpha_peak_theoretical))
cat(sprintf("alpha adjusted flatness ratio (empirical/theoretical): %.4f / %.4f\n", alpha_empirical_flat_ratio, alpha_theoretical_flat_ratio))
cat(sprintf("sigma adjusted flatness ratio (empirical/theoretical): %.4f / %.4f\n", sigma_empirical_flat_ratio, sigma_theoretical_flat_ratio))
cat(sprintf("sigma crude Spearman trend (empirical/theoretical): %.4f / %.4f\n",
            spearman_corr(sigma_results$scenario_value, sigma_results$empirical_crude),
            spearman_corr(sigma_results$scenario_value, sigma_results$theoretical_crude)))
cat(sprintf("sigma amplification-gap Spearman trend (empirical/theoretical): %.4f / %.4f\n",
            spearman_corr(sigma_results$scenario_value, sigma_empirical_gap),
            spearman_corr(sigma_results$scenario_value, sigma_theoretical_gap)))

failed <- names(checks)[!unlist(checks)]
if (length(failed) > 0) {
  cat("FAILED checks:\n")
  for (name in failed) cat("- ", name, "\n", sep = "")
  quit(status = 1)
}

cat("All qualitative paper checks passed, including the shape constraints from Sections 3.1 and 3.2.\n")
