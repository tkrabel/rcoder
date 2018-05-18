##
##                    DEVSTUFFs
##

library(readr)
library(magrittr)
library(usethis)

# Hook up to GitHub, create repo etc.
use_git(message = "Initial commit :sunglasses:")
usethis::use_github(credentials = git2r::cred_ssh_key(),
                    auth_token = read_file("~/.ssh/github_pat"))
usethis::use_readme_md()

