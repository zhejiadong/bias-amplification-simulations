default_parameters <- function() {
  list(
    psi_d = 0.2,
    psi_z = 0.2,
    psi_y = 0.2,
    gamma_x = 0.3,
    beta_d = 0.3,
    beta_u = 0.2,
    beta_x = 0.2,
    alpha_u = 0.2,
    alpha_x = 0.2
  )
}

alpha_z_grid <- function() seq(-1, 1, by = 0.1)
sigma_e3_grid <- function() seq(0.5, 3, by = 0.25)
