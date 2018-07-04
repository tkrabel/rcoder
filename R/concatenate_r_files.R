##
##                        CONCATENATE R FILES
##

library(purrr)
library(magrittr)
library(readr)

select_users <- c("rstudio", "tidyverse", "topepo", "hadley", "ColinFay", "r-lib")
select_repos <- readRDS("data/r_repos.rds") %>%
  grep(x = ., pattern = paste(select_users, collapse = "|"), val = TRUE) %>%
  gsub(x = ., pattern = "/.*/", repl = "")

r_files <- list.files(path = "data/repos", pat = "\\.r", ignore.case = TRUE,
                      recursive = TRUE, full.names = TRUE) %>%
  grep(x = ., pattern = paste(select_repos, collapse = "|"), val = TRUE)

text_train <- map_chr(r_files, readr::read_file) %>% 
  paste(collapse = "") %>%
  iconv(., "UTF-8", "ASCII", sub = '')

# R data format
saveRDS(text_train, "data/r_scripts_text.rds")

# Plain text format
write(text_train, "data/r_scripts_text.txt")

