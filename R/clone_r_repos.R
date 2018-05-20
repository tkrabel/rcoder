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

# Homegrown
source("R/utils/github_api_handlers.R")

# Get trending R users
git_api <- "https://api.github.com"
git_url <- "https://github.com"

trending_user <- glue("{git_url}/trending/developers/r?since=monthly") %>%
  read_html() %>%
  html_nodes(., "h2") %>%
  html_nodes(., "a") %>%
  html_attr(., "href") %>%
  gsub("/", "", .)

# Currently dissected
trending_user <- c("hadley", "r-lib", "tidyverse")

# Have to page through to get all repos
max_page <- glue("https://github.com/hadley?tab=repositories") %>%
  read_html() %>%
  html_nodes(".pagination") %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  stringr::str_extract("[[:digit:]]") %>%
  max(.)

# Get all R repos of user
r_repo <- glue("https://github.com/hadley?page=1&tab=repositories") %>%
  read_html() %>% 
  # List items which contain meta data about repos
  html_nodes("[itemprop=owns]") %>%
  {
    # Extract language
    lang <- html_node(., "[itemprop=programmingLanguage]") %>%
      html_text() %>%
      trimws() %>% 
      gsub("\\n", "", .)
    
    # Extract repo names
    name <- html_nodes(., "h3") %>% 
      html_nodes("a") %>% 
      html_attr("href")
    
    # TODO: Extracts forks
    fork <- html_node(r_repo, ".f6") %>%
      html_node(., ".muted-link") %>%
      html_attr("href")
    
    data_frame(name, lang, fork) %>%
      dplyr::filter(lang == "R")
  }

# TODO: Get repos for each user
# TODO: Extract those :user/:repo with language = R
# TODO: Clone :user/:repo and prepare repo (keep *.R only)



# Get repos from github
good_users <- c("tidyverse", "r-lib", "radian")
good_repos <- c("r-lib/testthat", "rstudio/bookdown")


get <- GET("{git_api}/repositories")
json <- content(get, type = "text", encoding = "UTF-8") %>% 
  fromJSON() 
repo_url <- json$html_url
repo_name <- json$full_name

lang <- repo_name %>% map(., get_language) 
lang %>% map(., as.data.frame)


# Clone repo
project_root <- getwd()
dir.create("~/Desktop/git")
setwd("~/Desktop/git")
system2(glue("git clone {first_repo}"))
setwd("")
