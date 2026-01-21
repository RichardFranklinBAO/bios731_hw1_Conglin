#!/usr/bin/env bash
set -euo pipefail

# Render the report that lives in the mounted repository
Rscript -e "rmarkdown::render('/work/R_Project.Rmd', \
  output_file = file.path(Sys.getenv('OUTDIR', '/work/report'), 'R_Project.html'))"