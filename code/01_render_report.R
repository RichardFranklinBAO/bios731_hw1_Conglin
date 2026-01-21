# code/01_render_report.R

# Disable renv autoloader in container
Sys.setenv(RENV_CONFIG_AUTOLOADER_ENABLED = "FALSE")

# Force system libraries (avoid project renv/library when repo is bind-mounted)
.libPaths(c(
  "/usr/local/lib/R/site-library",
  "/usr/lib/R/site-library",
  "/usr/lib/R/library"
))

outdir <- Sys.getenv("OUTDIR", unset = "report")
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

rmarkdown::render(
  input = "R_Project.Rmd",
  output_file = file.path(outdir, "R_Project.pdf")
)
