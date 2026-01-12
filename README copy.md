<h1 style="font-weight:normal" align="center">
  &nbsp;#TidyTuesday&nbsp;
</h1>

A collection of visualizations for Tidy Tuesdays, built as a Quarto website with R and Python support. Forked from Guillaume Noblet @ [gnoblet/TidyTuesday](https://github.com/gnoblet/TidyTuesday) and adapted from Cédric Scherer @ [z3tt/TidyTuesday](https://github.com/z3tt/TidyTuesday).

## Website

Visit the live gallery on my personal website [here](https://aaronwriight.github.io/tidy_tuesday/).

## Contributions

My contributions to the [#TidyTuesday challenge](https://github.com/rfordatascience/tidytuesday), a weekly social data project focused on crafting meaningful and beautiful visualizations using tools from the `{tidyverse}` ecosystem.

<details>
  <summary>Contributions in chronological order (click to expand)</summary>

<!-- toc -->
* **Challenges 2025**
  - _No contributions yet — stay tuned!_

<!-- tocstop -->
</details>

## Development Setup

### Prerequisites

- [R](https://www.r-project.org/) (≥4.4.0)
- [Python](https://www.python.org/) (≥3.13)
- [Quarto](https://quarto.org/)
- [uv](https://docs.astral.sh/uv/) (Python package manager)

### Quick Start

1. Clone the original repository:
   ```bash
   git clone https://github.com/gnoblet/TidyTuesday.git
   cd TidyTuesday
   ```

2. Run the setup script:
   ```bash
   ./setup-dev.sh
   ```

3. Preview the website:
   ```bash
   quarto preview
   ```

## Creating New Visualizations

### Quick Template Creation

Use the included script `new-viz-from-template.sh` to generate a new visualization from the template (from the top-level directory):

```bash
# Usage: ./new-viz-from-template.sh <date> <week> <language> <title>

# Create a new R analysis
./new-viz-from-template.sh 2025-07-22 29 r "MTA Permanent Art Catalog"

# Create a new Python analysis  
./new-viz-from-template.sh 2025-01-09 2 python "posit::conf talks"

# Example with single-word title
./new-viz-from-template.sh 2024-09-24 39 r "Olympiad"
```

**Arguments:**
- `date`: ISO date for the challenge (YYYY-MM-DD), e.g., `2024-12-15`
- `week`: TidyTuesday week number (e.g., 29)
- `language`: Programming language (`r` or `python`)
- `title`: Title for the analysis (wrap in quotes if it contains spaces)

This will create:
- A `.qmd` file inside a structured folder: `challenges/YYYY/YYYY-MM-DD_WW_Title/language/`
- All placeholders automatically replaced with your specified values
- Ready-to-edit analysis structure

### Template Structure

Each generated visualization includes:

- **Overview**: Brief summary of the dataset, analysis goals, and main findings
- **Dataset**: Description of the data source, structure, and how the data is loaded
- **Analysis**: Data cleaning, wrangling, and any exploratory steps
- **Plotting**: Code and explanation for generating the main visualization(s)
- **Technical Summary**: Tools, packages, and libraries used in the analysis
- **Visualization**: The final rendered plot or output image
- **Future Directions**: Suggestions for further analysis, improvements, or data limitations
- **TidyTuesday References**: Links to relevant TidyTuesday repositories and resources

### Manual Creation

You can also manually create new visualizations:

1. Copy `template.qmd` to your desired location
2. Replace all `{{PLACEHOLDER}}` values
3. Add your analysis code
4. Render with `quarto render filename.qmd`

### Automatic Gallery Integration

- **New analyses automatically appear** in the gallery when you render the site
- **No manual updates needed** - the gallery scans for .qmd files dynamically
- **Consistent formatting** across all projects

### Manual Setup

#### R Environment (renv)
```bash
# Restore R packages
R -e "renv::restore()"
```

#### Python Environment (uv)
```bash
# Create virtual environment
uv venv .venv
source .venv/bin/activate

# if using fish instead of bash
source .venv/bin/activate.fish

# Install dependencies
uv sync
```

#### Build Website
```bash
# Render the website
quarto render

# Preview locally
quarto preview
```

## Project Structure

```
├── .github/workflows/        # GitHub Actions for deployment
├── challenges/               # Challenge folders by year and week
│   └── 2025/
│       └── 2025-07-22_29_MTA_Permanent_Art_Catalog/
│           └── r/ | python/  # R or Python analysis
│               ├── 2025-07-22_29_MTA_Permanent_Art_Catalog.qmd
│               ├── data/
│               ├── gif/
│               ├── plots/
│               └── images/
├── load_tidytuesday_data.py  # Script to load TidyTuesday data in Python-based .qmds
├── load_tidytuesday_data.R   # Script to load TidyTuesday data in R-based .qmds
├── new-viz-from-template.sh  # Script to create a new project
├── _quarto.yml               # Quarto configuration
├── README.md                 # Project README
├── references.bib            # Bibliography file for citations
├── renv/                     # R environment directory
├── renv.lock                 # R package lockfile
├── setup-dev.sh              # Development setup script
├── _site/                    # Quarto rendered website (ignored)
├── template.qmd              # Starter Quarto template
├── tidytuesdayR.pdf          # TidyTuesday cheat sheet
├── .venv/                    # Python virtual environment (ignored)
├── _quarto.yml               # Quarto configuration
```

## Deployment

The website is automatically deployed to GitHub Pages when changes are pushed to the main branch. The GitHub Actions workflow:

1. Sets up R with renv for package management
2. Sets up Python with uv for package management
3. Installs system dependencies
4. Renders the Quarto website
5. Deploys to GitHub Pages

## Adding New Projects

Use the `new-viz-from-template.sh` script to add new projects. It creates the proper folder structure and updates `_quarto.yml` automatically.

- R projects go in `challenges/YYYY/YYYY-MM-DD_WW_Title/r/`
- Python projects go in `challenges/YYYY/YYYY-MM-DD_WW_Title/python/`

## Package Management

- **R packages**: Managed by [renv](https://rstudio.github.io/renv/)
- **Python packages**: Managed by [uv](https://docs.astral.sh/uv/)
- **Repository**: Fast Linux binaries from [p3m.dev](https://p3m.dev/)

## License

This project is open source and available under the [MIT License](LICENSE).