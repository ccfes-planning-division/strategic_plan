# scripts/clean-webr.R
dir <- ".quarto/_webr/appdir"
if (dir.exists(dir)) {
  unlink(dir, recursive = TRUE, force = TRUE)
  message("Removed old shinylive appdir to address OneDrive lock issue")
}
