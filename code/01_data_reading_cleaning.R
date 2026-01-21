# code/01_data_reading_cleaning.R
# Data reading and cleaning:
# - Read raw data using relative paths
# - Clean and aggregate
# - Produce and save a tidy dataset for analysis

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(here)
})

# Read raw data (relative path)
raw_path <- here::here("data", "raw", "all_stocks_5yr.csv")
prices <- readr::read_csv(raw_path, show_col_types = FALSE)

# Basic cleaning
prices <- prices |>
  dplyr::mutate(date = as.Date(date)) |>
  dplyr::filter(!is.na(date), !is.na(Name), !is.na(close))

# Daily -> monthly last close, then monthly log return
rets <- prices |>
  dplyr::mutate(month = as.Date(cut(date, "month"))) |>
  dplyr::group_by(Name, month) |>
  dplyr::summarise(close = dplyr::last(close), .groups = "drop") |>
  dplyr::arrange(Name, month) |>
  dplyr::group_by(Name) |>
  dplyr::mutate(ret = log(close / dplyr::lag(close))) |>
  dplyr::ungroup() |>
  dplyr::filter(!is.na(ret))

# Save tidy dataset
dir.create(here::here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
readr::write_csv(rets, here::here("data", "clean", "monthly_returns.csv"))

# Expose object: rets
