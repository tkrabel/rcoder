#' Get all repos that are assotiated with a user. If s/he has a forked
#' repo, the original repo will be used
#'
#' @param user string indicating the user name
#'
#' @return
#' @export
#'
#' @examples
get_r_repos <- function(user) {
  
  library(glue)
  
  if (grepl("/", user)) stop("No '/' allowed in username!")
  
  # Have to page through to get all repos
  max_page <- glue("https://github.com/{user}?tab=repositories") %>%
    read_html() %>%
    html_nodes(".pagination") %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    stringr::str_extract("[[:digit:]]") %>%
    max(.)
  
  if (is.na(max_page)){
    warning(glue("max_page = NA. I'll try my best to get all repos. ",
                 "You should still check www.github.com/{user} ",
                 "to see if I missed some repos."))
    max_page <- 1
  } 
  if (max_page < 0) {
    warning(glue("Negative max_page for user '{user}'"))
    return(NULL)
  }
  if (!length(max_page)) { 
    warning("Could not extract max pagination")
    return(NULL)
  }
  
  # Get all R repos of user
  r_repo <- map(seq_len(max_page), function(page) {
    glue("https://github.com/{user}?page={page}&tab=repositories") %>%
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
        
        # Extracts forks
        fork <- html_node(., ".f6") %>%
          html_node(., ".muted-link") %>%
          html_attr("href") %>%
          str_extract("/[^/]+/[^/]+")
        
        data_frame(name, lang, fork) %>%
          dplyr::filter(lang == "R") %>%
          dplyr::mutate(name = ifelse(name != fork & !is.na(fork), 
                                      fork, name)) %>%
          pull(name)
      }                  
  }) %>%
    unlist()
  
  return(r_repo)
}