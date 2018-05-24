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
first_repo <- r_repos[1]

# Clone repo
project_root <- getwd()

if (!dir.exists("~/Desktop/git")) dir.create("~/Desktop/git")
setwd("~/Desktop/git")
system(glue("git clone https://github.com{first_repo}.git"))
setwd(project_root)
