#!/bin/bash

# Script to create a new TidyTuesday visualization from template
# Usage: ./scripts/new-viz-from-template.sh <date> <week> <language> <title>
# Example: ./scripts/new-viz-from-template.sh 2024-12-10 12 r "Coffee Data Analysis"
# Creates structure: challenges/YYYY/YYYY-MM-DD_WW_Title/language/YYYY-MM-DD_WW_Title.qmd

set -e

# find the directory where this script lives and treat its parent as project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
YAML_FILE="${ROOT_DIR}/_quarto.yml"

# Check arguments
if [ $# -ne 4 ]; then
    echo "Usage: $0 <date> <week> <language> <title>"
    echo "Example: $0 2025-07-22 29 r 'MTA Permanent Art Catalog'"
    echo "Language options: r, python"
    echo ""
    echo "Creates structure: challenges/YYYY/YYYY-MM-DD_WW_Title/language/YYYY-MM-DD_WW_Title.qmd"
    exit 1
fi

DATE=$1
WEEK_NUM=$2
LANGUAGE=$3
TITLE=$4

# extract year and pad week number
YEAR=$(echo "$DATE" | cut -d'-' -f1)
printf -v WEEK_PAD "%02d" $WEEK_NUM

# sanitize title
TITLE_SAFE=$(echo "$TITLE" | sed -E 's/[^a-zA-Z0-9]+/_/g' | sed -E 's/^_+|_+$//g')

# define directories and filenames (relative, for quarto)
WEEK_DIR="${DATE}_${WEEK_PAD}_${TITLE_SAFE}"
CHALLENGE_DIR_REL="challenges/${YEAR}/${WEEK_DIR}"
LANG_DIR_REL="${CHALLENGE_DIR_REL}/${LANGUAGE}"
QMD_FILE_REL="${LANG_DIR_REL}/${WEEK_DIR}.qmd"

# absolute paths on disk
LANG_DIR="${ROOT_DIR}/${LANG_DIR_REL}"
QMD_FILE="${ROOT_DIR}/${QMD_FILE_REL}"

# Create directories
mkdir -p "$LANG_DIR"

if [ -f "$QMD_FILE" ]; then
    echo "Error: File $QMD_FILE already exists"
    exit 1
fi

# Copy template and replace placeholders
cp "${SCRIPT_DIR}/template.qmd" "$QMD_FILE"

# Replace placeholders based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/{{TITLE}}/$TITLE/g" "$QMD_FILE"
    sed -i '' "s/{{DATE}}/$DATE/g" "$QMD_FILE"
    sed -i '' "s/{{LANGUAGE}}/$LANGUAGE/g" "$QMD_FILE"
    if [ "$LANGUAGE" = "r" ]; then
        sed -i '' "s/{{LANGUAGE_UPPER}}/R/g" "$QMD_FILE"
        sed -i '' "s/{{LANGUAGE_CODE}}/r/g" "$QMD_FILE"
        sed -i '' "s/{{LANGUAGE_EXT}}/R/g" "$QMD_FILE"
        sed -i '' "s/{{CATEGORIES}}/ggplot2, tidyverse, data-viz/g" "$QMD_FILE"
        sed -i '' "s/{{TOOLS_USED}}/R, ggplot2, tidyverse/g" "$QMD_FILE"
        sed -i '' "s/{{KEY_LIBRARIES}}/ggplot2, dplyr, tidyr/g" "$QMD_FILE"
        sed -i '' "s/{{IMAGE_FILE}}/plot.svg/g" "$QMD_FILE"
        # Update image path to use new structure
        sed -i '' "s|../R/${DATE}/plot.svg|../R/${YEAR}/${WEEK_DIR}/plot.svg|g" "$QMD_FILE"
    else
        sed -i '' "s/{{LANGUAGE_UPPER}}/Python/g" "$QMD_FILE"
        sed -i '' "s/{{LANGUAGE_CODE}}/python/g" "$QMD_FILE"
        sed -i '' "s/{{LANGUAGE_EXT}}/py/g" "$QMD_FILE"
        sed -i '' "s/{{CATEGORIES}}/matplotlib, pandas, data-viz/g" "$QMD_FILE"
        sed -i '' "s/{{TOOLS_USED}}/Python, pandas, matplotlib, seaborn/g" "$QMD_FILE"
        sed -i '' "s/{{KEY_LIBRARIES}}/pandas, matplotlib, seaborn/g" "$QMD_FILE"
        sed -i '' "s/{{IMAGE_FILE}}/plot.png/g" "$QMD_FILE"
        # Update image path to use new structure
        sed -i '' "s|../Python/${DATE}/plot.png|../Python/${YEAR}/${WEEK_DIR}/plot.png|g" "$QMD_FILE"
    fi
else
    # Linux
    sed -i "s/{{TITLE}}/$TITLE/g" "$QMD_FILE"
    sed -i "s/{{DATE}}/$DATE/g" "$QMD_FILE"
    sed -i "s/{{LANGUAGE}}/$LANGUAGE/g" "$QMD_FILE"
    if [ "$LANGUAGE" = "r" ]; then
        sed -i "s/{{LANGUAGE_UPPER}}/R/g" "$QMD_FILE"
        sed -i "s/{{LANGUAGE_CODE}}/r/g" "$QMD_FILE"
        sed -i "s/{{LANGUAGE_EXT}}/R/g" "$QMD_FILE"
        sed -i "s/{{CATEGORIES}}/ggplot2, tidyverse, data-viz/g" "$QMD_FILE"
        sed -i "s/{{TOOLS_USED}}/R, ggplot2, tidyverse/g" "$QMD_FILE"
        sed -i "s/{{KEY_LIBRARIES}}/ggplot2, dplyr, tidyr/g" "$QMD_FILE"
        sed -i "s/{{IMAGE_FILE}}/plot.svg/g" "$QMD_FILE"
        # Update image path to use new structure
        sed -i "s|../R/${DATE}/plot.svg|../R/${YEAR}/${WEEK_DIR}/plot.svg|g" "$QMD_FILE"
    else
        sed -i "s/{{LANGUAGE_UPPER}}/Python/g" "$QMD_FILE"
        sed -i "s/{{LANGUAGE_CODE}}/python/g" "$QMD_FILE"
        sed -i "s/{{LANGUAGE_EXT}}/py/g" "$QMD_FILE"
        sed -i "s/{{CATEGORIES}}/matplotlib, pandas, data-viz/g" "$QMD_FILE"
        sed -i "s/{{TOOLS_USED}}/Python, pandas, matplotlib, seaborn/g" "$QMD_FILE"
        sed -i "s/{{KEY_LIBRARIES}}/pandas, matplotlib, seaborn/g" "$QMD_FILE"
        sed -i "s/{{IMAGE_FILE}}/plot.png/g" "$QMD_FILE"
        # Update image path to use new structure
        sed -i "s|../Python/${DATE}/plot.png|../Python/${YEAR}/${WEEK_DIR}/plot.png|g" "$QMD_FILE"
    fi
fi

# Add the new file to _quarto.yml contents
if [ "$LANGUAGE" = "r" ]; then
    # Add to R Projects section
    if grep -q "R Projects" "$YAML_FILE"; then
        # Find the last R project line and add after it
        LAST_R_LINE=$(grep -n "r/.*\.qmd" "$YAML_FILE" | tail -1 | cut -d: -f1)
        if [ -n "$LAST_R_LINE" ]; then
            sed -i '' "${LAST_R_LINE}a\\
            - ${QMD_FILE_REL}" "$YAML_FILE"
        else
            # If no R files found, add after the R Projects contents line
            R_CONTENTS_LINE=$(grep -n "R Projects" "$YAML_FILE" | cut -d: -f1)
            R_CONTENTS_LINE=$((R_CONTENTS_LINE + 2))
            sed -i '' "${R_CONTENTS_LINE}a\\
            - ${QMD_FILE_REL}" "$YAML_FILE"
        fi
    fi
else
    # Add to Python Projects section
    if grep -q "Python Projects" "$YAML_FILE"; then
        # Find the last Python project line and add after it
        LAST_PY_LINE=$(grep -n "python/.*\.qmd" "$YAML_FILE" | tail -1 | cut -d: -f1)
        if [ -n "$LAST_PY_LINE" ]; then
            sed -i '' "${LAST_PY_LINE}a\\
            - ${QMD_FILE_REL}" "$YAML_FILE"
        else
            # If no Python files found, add after the Python Projects contents line
            PY_CONTENTS_LINE=$(grep -n "Python Projects" "$YAML_FILE" | cut -d: -f1)
            PY_CONTENTS_LINE=$((PY_CONTENTS_LINE + 2))
            sed -i '' "${PY_CONTENTS_LINE}a\\
            - ${QMD_FILE_REL}" "$YAML_FILE"
        fi
    fi
fi

echo "Created new visualization: $QMD_FILE"
echo "Added to _quarto.yml sidebar"
echo "Folder structure: ${LANG_DIR}/"
echo ""
echo "Next steps:"
echo "   1. Edit $QMD_FILE to add your analysis"
echo "   2. Save visualizations to ${LANG_DIR}/ directory"
echo "   3. Update the image path in YAML if needed"
echo "   4. Run 'quarto render' to build the site"
echo ""
echo "Week info:"
echo "   - Date: $DATE (Week $WEEK_NUM of $YEAR)"
echo "   - Structure: challenges/${YEAR}/${WEEK_DIR}/${LANGUAGE}/${WEEK_DIR}.qmd"
