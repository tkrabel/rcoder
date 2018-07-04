##
##                  EXCTRACT TRENDING R USERS
##

library(glue)
library(rvest)
library(magrittr)

git_url <- "https://github.com"

trending_user <- glue("{git_url}/trending/developers/r?since=monthly") %>%
  read_html() %>%
  html_nodes(., "h2") %>%
  html_nodes(., "a") %>%
  html_attr(., "href") %>%
  gsub("/", "", .) %>%
  union(., readRDS("data/trending_users.rds"))
saveRDS(trending_user, file = "data/trending_users.rds")

