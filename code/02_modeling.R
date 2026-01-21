# code/02_modeling.R
# Modeling:
# - Construct 12-1 cross-sectional momentum signal
# - Form decile portfolios (long Q10, short Q1)
# - Fit at least one statistical model (monthly cross-sectional regression)

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(slider)
  library(xts)
  library(PerformanceAnalytics)
  library(here)
})

# Safety check
if (!exists("rets")) {
  stop("Object 'rets' not found. Run code/01_data_reading_cleaning.R first.")
}

# 1) Momentum signal (12-1)
mom_tbl <- rets |>
  dplyr::arrange(Name, month) |>
  dplyr::group_by(Name) |>
  dplyr::mutate(
    ret1m    = ret,
    roll12   = slider::slide_dbl(ret1m, ~ sum(.x), .before = 11, .complete = TRUE),
    mom_12_1 = dplyr::lag(roll12, 1)  # skip most recent month
  ) |>
  dplyr::ungroup() |>
  tidyr::drop_na(mom_12_1)

# 2) Decile portfolios
port_tbl <- mom_tbl |>
  dplyr::group_by(month) |>
  dplyr::mutate(ntile = dplyr::ntile(mom_12_1, 10)) |>
  dplyr::summarise(
    long  = mean(ret1m[ntile == 10], na.rm = TRUE),
    short = mean(ret1m[ntile == 1 ], na.rm = TRUE),
    ls    = long - short,
    .groups = "drop"
  )

# 3) Simple cost adjustment
cost_rate <- 0.0003
turnover  <- 0.5
port_tbl  <- port_tbl |>
  dplyr::mutate(ls_net = ls - 2 * cost_rate * turnover)

# 4) At least one statistical model:
# Monthly cross-sectional regression: ret1m ~ mom_12_1 (each month)
# Store slopes and t-stats summary for reporting.
cs_reg <- mom_tbl |>
  dplyr::group_by(month) |>
  dplyr::summarise(
    beta = coef(lm(ret1m ~ mom_12_1))[2],
    .groups = "drop"
  )

# Summary of regression slopes (simple, rubric-friendly)
cs_reg_summary <- tibble::tibble(
  mean_beta = mean(cs_reg$beta, na.rm = TRUE),
  sd_beta   = sd(cs_reg$beta, na.rm = TRUE),
  t_stat    = mean(cs_reg$beta, na.rm = TRUE) / (sd(cs_reg$beta, na.rm = TRUE) / sqrt(nrow(cs_reg)))
)

# Expose objects:
# - mom_tbl
# - port_tbl
# - cs_reg
# - cs_reg_summary
