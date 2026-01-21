# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 rocker/verse:4.4.1

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /work
ENV OUTDIR=/work/report

# LaTeX: fix booktabs.sty and common PDF deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-extra texlive-fonts-recommended lmodern \
 && rm -rf /var/lib/apt/lists/*


# Install required R packages into the image (no runtime installs)
RUN R -q -e "install.packages(c( \
  'rmarkdown','knitr','here', \
  'dplyr','tidyr','purrr','ggplot2', \
  'readr','slider','xts','zoo','PerformanceAnalytics','scales' \
), repos='https://cloud.r-project.org')"

# Render script in image
COPY code/01_render_report.R /usr/local/bin/01_render_report.R
ENTRYPOINT ["Rscript", "/usr/local/bin/01_render_report.R"]
