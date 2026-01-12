# load_tidytuesday_data.R

# function to load and prepare all Tidytuesday datasets and save them as individual data frames
prepare_tidytuesday_data <- function(date) {
  library(tidytuesdayR)
  library(readr)
  library(tibble)
  
  # load all datasets for the specified date
  tt_data <- tt_load(date)

  if (length(tt_data) == 0) {
    stop("No datasets found for this date. Check the availability of datasets.")
  }

  # define a helper function to check for parsing issues
  check_parsing_issues <- function(dataset, dataset_name) {
    if (inherits(dataset, "tbl_df")) { # ensure dataset is a tibble
      issues <- problems(dataset)
      if (nrow(issues) > 0) {
        cat("\n--- Parsing issues found in dataset:", dataset_name, "---\n")
        print(issues)
      }
    }
  }

  # if there's only one dataset, tt_data might not be a named list
  if (!is.list(tt_data) || is.null(names(tt_data))) {
    dataset_name <- "tidytuesday_dataset"
    dataset <- tt_data
    # print structure for EDA
    cat("\n--- Structure of single dataset ---\n")
    print(str(dataset))
    # check for parsing issues
    check_parsing_issues(dataset, dataset_name)
    # assign the dataset to the global environment
    assign(dataset_name, dataset, envir = .GlobalEnv)
    data_dir <- file.path(dirname(rstudioapi::getSourceEditorContext()$path), "data")
    dir.create(data_dir, showWarnings = FALSE)
    write_csv(dataset, file.path(data_dir, paste0(dataset_name, ".csv")))
  } else {
    # for multiple datasets
    cat("Datasets found for this date:", paste(names(tt_data), collapse = ", "), "\n")

    # iterate over each dataset
    lapply(seq_along(tt_data), function(i) {
      dataset_name <- names(tt_data)[i]
      dataset <- tt_data[[i]]

      # print structure for EDA
      cat("\n--- Structure of dataset:", dataset_name, "---\n")
      print(str(dataset))

      # check for parsing issues
      check_parsing_issues(dataset, dataset_name)

      # assign the dataset to the global environment
      assign(paste0(dataset_name), dataset, envir = .GlobalEnv)
      data_dir <- file.path(dirname(rstudioapi::getSourceEditorContext()$path), "data")
      dir.create(data_dir, showWarnings = FALSE)
      write_csv(dataset, file.path(data_dir, paste0(dataset_name, ".csv")))
    })
  }

  # return all datasets as a named list for further manipulation if needed
  return(tt_data)
}
