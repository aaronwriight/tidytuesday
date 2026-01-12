#!/bin/bash

# Local development setup script that mirrors the GitHub Actions workflow

set -e

echo "Setting up TidyTuesday development environment..."

# Check if renv is available
if command -v R >/dev/null 2>&1; then
    echo "Restoring R packages with renv..."
    R -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv'); renv::restore()"
else
    echo "R not found, skipping R package restoration"
fi

# Check if uv is available
if command -v uv >/dev/null 2>&1; then
    echo "Setting up Python environment with uv..."
    uv venv .venv
    source .venv/bin/activate
    
    if [ -f requirements.txt ]; then
        echo "Installing Python packages..."
        uv pip install -r requirements.txt
    else
        echo "requirements.txt not found, skipping Python package installation"
    fi
else
    echo "uv not found, please install uv: https://docs.astral.sh/uv/getting-started/installation/"
fi

# Check if quarto is available
if command -v quarto >/dev/null 2>&1; then
    echo "Building Quarto website..."
    quarto render
    echo "Website built successfully! Open _site/index.html to view locally."
else
    echo "Quarto not found, please install Quarto: https://quarto.org/docs/get-started/"
fi

echo "Setup complete!"
echo ""
echo "To activate the Python environment: source .venv/bin/activate" or if using fish shell: . .venv/bin/activate.fish
echo "To preview the website: quarto preview"
echo "To render the website: quarto render"
