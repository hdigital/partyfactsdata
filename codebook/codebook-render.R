#!/usr/bin/env Rscript
# Render Party Facts Codebook to all output formats
# This script renders codebook.Rmd to HTML, Markdown (GitHub-flavored), and PDF

library(rmarkdown)

# Set working directory to codebook folder by getting script location
args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("--file=", "", args[grep("--file=", args)])
script_dir <- dirname(normalizePath(script_path))
setwd(script_dir)

# Input file
input_file <- "codebook.Rmd"

# Render to all formats specified in YAML header
cat("\nRendering codebook to all formats...\n")

# Render to HTML
cat("\n\n1. Rendering HTML...")
rmarkdown::render(
  input = input_file,
  output_format = "html_document",
  output_file = "codebook.html"
)

# Render to GitHub-flavored Markdown
cat("\n\n2. Rendering Markdown (GitHub-flavored)...")
rmarkdown::render(
  input = input_file,
  output_format = "md_document",
  output_file = "codebook.md"
)

# Render to PDF (requires LaTeX)
cat("\n\n3. Rendering PDF...")
tryCatch(
  {
    rmarkdown::render(
      input = input_file,
      output_format = "pdf_document",
      output_file = "codebook.pdf"
    )
    cat("PDF rendered successfully.\n")
  },
  error = function(e) {
    cat("Warning: PDF rendering failed. Make sure LaTeX is installed.\n")
    cat("Error message:", conditionMessage(e), "\n")
  }
)

cat("\n\n✓ Codebook rendering complete!\n")
cat("Output files created in:", getwd(), "\n\n")
