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

# Homegrown
source("code/utils/github_api_handlers.R")

# Hook up to GitHub, create repo etc.
pat <- read_file("~/.ssh/github_pat")
# use_git(message = "Initial commit :sunglasses:")
# usethis::use_github(credentials = git2r::cred_ssh_key(),
#                     auth_token = pat)
# usethis::use_readme_md()

# Get repos from github
git_api <- "https://api.github.com"

get <- GET("{git_api}/repositories")
json <- content(get, type = "text", encoding = "UTF-8") %>% 
  fromJSON() 
repo_url <- json$html_url
repo_name <- json$full_name

lang <- repo_name %>% map(., get_language) 
lang %>% map(., as.data.frame)

GET(glue("{git_api}/rate_limit"))

project_root <- getwd()
dir.create("~/Desktop/git")
setwd("~/Desktop/git")
system2(glue("git clone {first_repo}"))
setwd("")
