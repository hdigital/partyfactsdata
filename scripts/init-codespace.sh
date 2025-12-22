#!/bin/bash
#
# Initialize codespace with required tools and packages
#

set -e

echo "💻 · Install Debian packages with 'apt'"
sudo apt-get update --quiet --quiet
sudo apt-get install --yes --quiet --quiet libxt6 python-is-python3

echo "🐍 · Install or update 'uv', a Python project manager"
if command -v uv &> /dev/null; then
  uv self update --quiet
else
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo "✨ · Install R code formatter 'air' (if not installed)"
if ! command -v air &> /dev/null; then
  curl -LsSf https://github.com/posit-dev/air/releases/latest/download/air-installer.sh | sh
fi

echo "📊 · Install R packages"
install2.r -s countrycode ggthemes pak
