source("R/parameters.R")

fit_treatment_coef <- function(y, d, controls) {
  design <- cbind(1, d, controls)
  fit <- lm.fit(x = design, y = y)
  unname(fit$coefficients[2])
}

summarise_bias_results <- function(scenario_values, beta_crude, beta_adjusted, beta_truth,
                                   theoretical_crude, theoretical_adjusted, beta_d) {
  data.frame(
    scenario_value = scenario_values,
    empirical_crude = abs(rowMeans(beta_crude) - beta_d),
    empirical_adjusted = abs(rowMeans(beta_adjusted) - beta_d),
    truth = abs(rowMeans(beta_truth) - beta_d),
    theoretical_crude = rowMeans(abs(theoretical_crude)),
    theoretical_adjusted = rowMeans(abs(theoretical_adjusted)),
    row.names = NULL,
    check.names = FALSE
  )
}

parse_cli_args <- function(args) {
  out <- list(nsamp = 10000L, nsim = 2500L, seed = 123L)
  if (length(args) == 0) return(out)

  for (arg in args) {
    if (!grepl("^--", arg)) next
    parts <- strsplit(sub("^--", "", arg), "=", fixed = TRUE)[[1]]
    key <- parts[1]
    value <- if (length(parts) > 1) parts[2] else NULL
    if (is.null(value) || !nzchar(value)) next
    if (key %in% c("nsamp", "nsim", "seed")) out[[key]] <- as.integer(value)
  }

  out
}

ensure_dir <- function(path) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}
