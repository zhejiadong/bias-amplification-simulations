source("R/utils.R")

run_alpha_z_simulation <- function(nsamp = 10000, nsim = 2500, seed = 123,
                                   alpha_z_values = alpha_z_grid(),
                                   params = default_parameters()) {
  stopifnot(length(alpha_z_values) > 0)

  set.seed(seed)
  nl <- length(alpha_z_values)

  beta_crude <- matrix(0, nrow = nl, ncol = nsim)
  beta_adjusted <- matrix(0, nrow = nl, ncol = nsim)
  beta_truth <- matrix(0, nrow = nl, ncol = nsim)
  theoretical_crude <- matrix(0, nrow = nl, ncol = nsim)
  theoretical_adjusted <- matrix(0, nrow = nl, ncol = nsim)

  for (i in seq_len(nsim)) {
    x <- rnorm(nsamp, 0.5, 1)
    u <- rnorm(nsamp, 0.5, 1)
    e1 <- rnorm(nsamp, 0, 1)
    e2 <- rnorm(nsamp, 0, 1)
    e3 <- rnorm(nsamp, 0, 1)

    z <- params$psi_z + params$gamma_x * x + e3
    sigma2_u <- var(u)
    sigma2_x <- var(x)
    sigma2_e3 <- var(e3)

    for (j in seq_along(alpha_z_values)) {
      alpha_z <- alpha_z_values[j]
      d <- params$psi_d + alpha_z * z + params$alpha_u * u + params$alpha_x * x + e2
      y <- params$psi_y + params$beta_d * d + params$beta_u * u + params$beta_x * x + e1

      beta_crude[j, i] <- fit_treatment_coef(y, d, controls = cbind(x))
      beta_adjusted[j, i] <- fit_treatment_coef(y, d, controls = cbind(x, z))
      beta_truth[j, i] <- fit_treatment_coef(y, d, controls = cbind(x, u))

      sigma2_d <- var(d)
      denom_crude <- sigma2_d - (params$gamma_x * alpha_z + params$alpha_x)^2 * sigma2_x
      denom_adjusted <- denom_crude - alpha_z^2 * sigma2_e3

      theoretical_crude[j, i] <- params$beta_u * params$alpha_u * sigma2_u / denom_crude
      theoretical_adjusted[j, i] <- params$beta_u * params$alpha_u * sigma2_u / denom_adjusted
    }
  }

  summarise_bias_results(
    scenario_values = alpha_z_values,
    beta_crude = beta_crude,
    beta_adjusted = beta_adjusted,
    beta_truth = beta_truth,
    theoretical_crude = theoretical_crude,
    theoretical_adjusted = theoretical_adjusted,
    beta_d = params$beta_d
  )
}
