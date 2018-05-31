##
##                      CLONE R REPOS
##

# Libs
library(readr)
library(magrittr)
library(usethis)
library(httr)
library(jsonlite)
library(glue)
library(purrr)
library(rvest)
library(tibble)
library(dplyr)
library(stringr)

# Homegrown
source("R/utils/github_api_handlers.R")
source("R/utils/get_r_repos.R")

# Get trending R users
git_api <- "https://api.github.com"
r_repos <- readRDS("data/r_repos.rds")

# Clone repo
project_root <- getwd()
clone_dir <- "data/repos"
if (!dir.exists(clone_dir)) dir.create(clone_dir)
setwd(clone_dir)

for (repo in r_repos) {
  cat("- Cloning repo", repo, "-\n")
  folder <- str_replace(repo, "/[^/]+/", "")
  if (!dir.exists(folder)) {
    system(glue("git clone https://github.com{repo}.git"),
           wait = TRUE)
    # Delete unnecessary files
    all_files <-
      list.files(
        path = folder,
        recursive = TRUE,
        full.names = TRUE,
        all.files = TRUE
      )
    r_files <-
      list.files(
        path = folder,
        recursive = TRUE,
        all.files = TRUE,
        full.names = TRUE,
        ignore.case = TRUE,
        pat = "\\.R$"
      )
    unlink(setdiff(all_files, r_files))
    
    # Delete empty folders
    non_empty_dirs <-
      list.files(
        path = folder,
        recursive = TRUE,
        full.names = TRUE,
        all.files = TRUE
      ) %>%
      dirname() %>%
      unique()
    all_dirs <- list.dirs(folder) %>% setdiff(folder)
    empty_dirs <- all_dirs %>% setdiff(non_empty_dirs)
    unlink(empty_dirs, recursive = TRUE)
    
    # Wait
    secs <- sample(0, 1, TRUE)
    cat("Sleep for", secs, "seconds ... -.- zZz \n")
    Sys.sleep(secs)
  } else {
    cat("Repo already cloned\n")
  } # !dir.exists(folder)
}

setwd(project_root)

# Delete all empty repos
non_empty_dirs <-
  list.files(
    path = folder,
    recursive = TRUE,
    full.names = TRUE,
    all.files = TRUE
  ) %>%
  dirname() %>%
  unique()
all_dirs <- list.dirs(folder) %>% setdiff(folder)
empty_dirs <- all_dirs %>% setdiff(non_empty_dirs)
unlink(empty_dirs, recursive = TRUE)
