#' Scrape degree programs from the "Modules/Degree Programs" tab
#'
#' This function searches a given tab on a webpage for degree programs and extracts the relevant data into a `tibble`. It makes several attempts in case of errors and checks for network issues.
#'
#' @param rmdr An Rmdr object representing the Selenium WebDriver.
#' @param css_zugeordnete_studiengaenge The CSS selector for the HTML element containing the degree programs.
#' @param max_attempts The maximum number of attempts to successfully extract the degree programs. The default value is 10.
#'
#' @return A `tibble` containing the extracted degree program data. If no degree programs are found, an empty `tibble` is returned.
#' @importFrom rvest read_html html_table
#' @importFrom tibble as_tibble
#' @importFrom dplyr rename_with select
#' @importFrom stringr str_remove_all
#' @importFrom janitor clean_names
#' @importFrom crayon blue cyan red yellow
#' @export
scrape_studiengaenge <- function(rmdr,
                                 css_zugeordnete_studiengaenge = "#detailViewData\\:tabContainer\\:term-planning-container\\:courseOfStudies\\:courseOfStudyAssignments\\:courseOfStudyAssignmentsTable",
                                 max_attempts = 10) {
  attempt <- 0
  zugeord_studgaenge_tibble <- tibble()
  
  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(crayon::blue("Versuch Studiengaenge in Registerkarte >>Module/Studiengaenge<< zu finden Nr. ", attempt, " von maximal ", max_attempts, " ..."))

    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # ueberpruefe auf Netzwerkprobleme
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    if (check_network_errors(rmdr)) {
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Finde Studiengang-Table oder andere Nachricht
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    zugeordnete_studiengaenge <- tryCatch({
      zugeordnete_studiengaenge <- rmdr$findElement(using = "css selector", css_zugeordnete_studiengaenge)
    })

    if (is.null(zugeordnete_studiengaenge)) {
      if (check_network_errors(rmdr)) {
      }
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Falls Studiengaenge vorhanden sind, in Tibble umwandeln
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    if (!is.null(zugeordnete_studiengaenge)) {
      
      zugeordnete_studiengaenge_html <- zugeordnete_studiengaenge$getElementAttribute("outerHTML")[[1]]
      
      zugeord_studgaenge_tibble <- zugeordnete_studiengaenge_html |>
        rvest::read_html() |>
        rvest::html_table() %>%
        .[[1]] |>
        tibble::as_tibble() |>
        remove_column_names_from_values() |>
        janitor::clean_names() |>
        dplyr::rename_with(~ stringr::str_remove_all(.x, "_sortierbare_spalte")) |>
        dplyr::rename_with(~ stringr::str_remove_all(.x, "_aufwarts_sortieren"))
      
      if (any(!is.na(zugeord_studgaenge_tibble))) {
        message(crayon::yellow("Starte das Scraping des HTML-Tables >>Studiengaenge<<"))
        check_obj_exist(zugeord_studgaenge_tibble)
        return(zugeord_studgaenge_tibble)
      } else {
        message(crayon::red("Keine Studiengaenge in der Registerkarte >>Module/Studiengaenge<< gelistet"))
        return(zugeord_studgaenge_tibble)
      }
    }
  }
  return(zugeord_studgaenge_tibble)
}