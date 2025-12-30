#!/bin/sh
#
# Run all scripts formatting, linting, or generating content
#

# Exit on error and check run from project root
set -e && cd scripts/../

# Generate figures in 'codebook' directory
cd ./codebook
Rscript figure_linking-activity.R
Rscript figure_worldmap.R
cd ..

# Create codebook files (.md, .html, .pdf)
./codebook/codebook-render.R

# Format R/Markdown files added/modified since April 2024
./scripts/format-changed-files.py

# Format codebook Rmd file ('air' not working)
Rscript -e "styler::style_file('codebook/codebook.Rmd')"
sed -i 's/[[:space:]]*$//' codebook/codebook.md  # Remove trailing space

# Check shell scripts
uvx --from shellcheck-py shellcheck --external-sources ./scripts/*.sh

# Fix spelling mistakes
uvx typos --write-changes .

# Run pre-commit hooks on all files (see '.pre-commit-config.yaml')
uvx pre-commit run --all-files

printf "\n\n🚨 · Artifacts generated - only commit if content changed\n"
