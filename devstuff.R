##
##                    DEVSTUFFs
##

library(readr)
library(magrittr)
library(usethis)
library(httr)
library(jsonlite)
library(glue)
library(purrr)
library(rvest)

# Homegrown
source("R/utils/github_api_handlers.R")

# Set up git repo
pat <- read_file("~/.ssh/github_pat") %>% gsub("\\n", "", .)
use_git(message = "Initial commit :sunglasses:")
usethis::use_github(credentials = git2r::cred_ssh_key(),
                    auth_token = pat)
usethis::use_readme_md()
