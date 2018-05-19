##
##                      CLONE R REPOS
##

# Get trending R users
git_api <- "https://api.github.com"

trending_repo <- read_html("https://github.com/trending/r?since=monthly")
trending_repo %<>%
  html_nodes(., "h3") %>%
  html_nodes(., "a") %>%
  html_attr(., "href")

trending_user <- read_html("https://github.com/trending/developers/r?since=monthly") 
trending_user %<>%
  html_nodes(., "h2") %>%
  html_nodes(., "a") %>%
  html_attr(., "href") %>%
  gsub("/", "", .)

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
