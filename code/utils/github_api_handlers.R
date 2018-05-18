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