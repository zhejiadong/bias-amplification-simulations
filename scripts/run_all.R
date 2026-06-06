source("R/plot_results.R")

args <- parse_cli_args(commandArgs(trailingOnly = TRUE))

ensure_dir("outputs")
ensure_dir("figures")

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

write.csv(alpha_results, "outputs/alpha_z_results.csv", row.names = FALSE)
write.csv(sigma_results, "outputs/sigma_e3_results.csv", row.names = FALSE)

plot_simulation_results(
  results = alpha_results,
  x_col = "scenario_value",
  x_label = expression(alpha[z]),
  title = "Bias under different alpha_z values",
  output_file = "figures/alpha_z_bias.pdf"
)

plot_simulation_results(
  results = sigma_results,
  x_col = "scenario_value",
  x_label = expression(sigma[e[3]]^2),
  title = "Bias under different sigma_e3^2 values",
  output_file = "figures/sigma_e3_bias.pdf"
)

cat(sprintf("Done. nsamp=%d nsim=%d seed=%d\n", args$nsamp, args$nsim, args$seed))
