source("R/simulate_alpha_z.R")
source("R/simulate_sigma_e3.R")

plot_simulation_results <- function(results, x_col, x_label, title, output_file) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for plotting.")
  }
  if (!requireNamespace("tidyr", quietly = TRUE)) {
    stop("Package 'tidyr' is required for plotting.")
  }

  df <- tidyr::pivot_longer(
    results,
    cols = -all_of(x_col),
    names_to = "type",
    values_to = "bias"
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[x_col]], y = bias, color = type)) +
    ggplot2::geom_line() +
    ggplot2::geom_point(size = 1.5) +
    ggplot2::labs(x = x_label, y = "Absolute bias", title = title, color = NULL) +
    ggplot2::theme_minimal(base_size = 12)

  ggplot2::ggsave(filename = output_file, plot = p, width = 8, height = 4.5)
  invisible(p)
}
