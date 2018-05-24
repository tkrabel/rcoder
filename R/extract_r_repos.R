##
##                      EXCTRACT R REPOS
##

library(magrittr)

# Get repos
trending_user <- readRDS("data/trending_users.RDS")
repos <- list()
for (user in trending_user) {
  cat("User: ", user, "\n")
  repos[[user]] <- get_r_repos(user)
}
repos %<>% unlist() %>% unique()
saveRDS(repos, "data/r_repos.rds")