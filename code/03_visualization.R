# code/03_visualization.R
# Visualization:
# - Produce at least one meaningful plot supporting the analysis

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
})

if (!exists("port_tbl")) {
  stop("Object 'port_tbl' not found. Run code/02_modeling.R first.")
}

cum_df <- port_tbl |>
  dplyr::mutate(
    cum     = exp(cumsum(ls)),
    cum_net = exp(cumsum(ls_net))
  ) |>
  dplyr::select(month, cum, cum_net) |>
  tidyr::pivot_longer(-month, names_to = "series", values_to = "value")

p_cum <- ggplot(cum_df, aes(month, value, linetype = series)) +
  geom_line(linewidth = 0.8) +
  scale_linetype_manual(
    values = c("solid", "dashed"),
    labels = c("Gross", "Net of costs")
  ) +
  labs(
    title = "Cross-Sectional Momentum (12–1): Cumulative Return",
    x = "Year",
    y = "Growth of $1",
    linetype = NULL
  ) +
  theme_minimal(base_size = 12)

# Expose object:
# - p_cum
