#' Extract the languages that are used in a git repo
#' 
#' @param repo_name string of the form :user:/:repo: that identifies a repo
#' @param git_api the url of the github api to access
#'
#' @return a list containing the languages and number of bytes of codes written
#' @export
#'
#' @examples
#' \dontrun{
#' get_languages(repo_name = "tkrabel/rcoder)
#' }
get_language <- function(repo_name, git_api = "https://api.github.com") {
  "{git_api}/repos/{repo_name}/languages" %>%
    glue() %>%
    GET() %>%
    content(., type = "text", encoding = "UTF-8") %>%
    fromJSON()
}

#' Get the rate limit on the github api
#'
#' @param git_api string defining the api's url
#'
#' @return list containing the total and remainign hits allowed as well as the time the counter for the ratelimit will reset 
#' @export
#'
#' @examples
#' \dontrun{
#' get_ratelimit()
#' }
get_ratelimit <- function(git_api = "https://api.github.com") {
  info <- GET(glue("{git_api}/rate_limit")) %>% 
    content(., type = "text", encoding = "UTF-8") %>% 
    fromJSON() %$% 
    rate
  info$reset <- info$reset %>% as.POSIXct(origin = "1970-01-01 00:00:00")
  info
}
