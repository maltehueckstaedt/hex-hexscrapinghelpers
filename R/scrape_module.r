#' Scrape modules/degree programs from a tab
#'
#' This function searches a given RMD instance for the "Modules/Degree Programs" tab, clicks on it, and extracts data from the corresponding HTML table. It makes several attempts in case of errors and returns the extracted data as a tibble. If no modules are found, it returns `NULL`.
#'
#' @param rmdr An Rmdr object representing the Selenium WebDriver.
#' @param css_module_tab The CSS selector for the tab containing the modules/degree programs.
#' @param css_module_content The CSS selector for the area displaying the modules/degree programs.
#' @param max_attempts The maximum number of attempts to successfully extract the data. The default value is 10.
#'
#' @return A tibble containing the extracted data from the "Modules/Degree Programs" tab. If no modules are found, the function returns `NULL`.
#' @importFrom rvest read_html html_table
#' @importFrom tibble as_tibble
#' @importFrom dplyr rename_with mutate cur_column
#' @importFrom stringr str_remove_all
#' @importFrom janitor clean_names
#' @importFrom crayon blue cyan red yellow
#' @export
scrape_module <- function(rmdr,
                          css_module_tab = "#detailViewData\\:tabContainer\\:term-planning-container\\:tabs\\:modulesCourseOfStudiesTab > span:nth-child(1)",
                          css_module_content = "#detailViewData\\:tabContainer\\:term-planning-container\\:modules\\:moduleAssignments",
                          max_attempts = 10) {
  attempt <- 0
  zugeordnete_module_tibble <- tibble()
  zugeordnete_module <- NULL

  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(blue("Versuch Module in Registerkarte >>Module/Studiengaenge<< zu finden Nr. ", attempt, " von maximal ", max_attempts, " ..."))
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Überprüfe auf Netzwerkprobleme
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if (check_network_errors(rmdr)) {
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Checke, ob Module-Tab vorhanden ist, und klicke darauf
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

    module_tab <- tryCatch({
      module_tab <- rmdr$findElement(using = "css selector", css_module_tab)
      module_tab$clickElement()
    })

    if (is.null(module_tab)) {  # Richtige Prüfung, ob Tab existiert
      if (check_network_errors(rmdr)) {
      }
    }

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Finde Module-Table oder andere Nachricht
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    message(crayon::yellow("Starte das Scraping der Registerkarte >>Module/Studiengaenge<<"))

    zugeordnete_module <- tryCatch({
      rmdr$findElement(using = "css selector", css_module_content)
    }, error = function(e) {
      NULL
    })
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Falls Module vorhanden sind, in Tibble umwandeln
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if (!is.null(zugeordnete_module)) {  # Korrekte Prüfung auf NULL
      message(crayon::yellow("Module gefunden..."))
      
      zugeordnete_module_html <- zugeordnete_module$getElementAttribute("outerHTML")[[1]]
      zugeordnete_module_tibble <- zugeordnete_module_html %>%
        rvest::read_html() %>%
        rvest::html_table(fill = TRUE) %>%
        .[[2]] %>%
        as_tibble() %>%
        remove_column_names_from_values() %>%
        janitor::clean_names()
      
      check_obj_exist(zugeordnete_module_tibble)
      return(zugeordnete_module_tibble)
    } else {
      message(crayon::yellow("Keine Module gefunden. Rueckgabe eines leeren Tibbles."))
      return(zugeordnete_module_tibble)  # Leeres Tibble zurückgeben
    }
  }
  
  # Falls die Schleife beendet wurde, weil max_attempts erreicht wurde
  message(crayon::red("Maximale Anzahl an Versuchen (", max_attempts, ") erreicht. Scraping wird abgebrochen."))
  return(zugeordnete_module_tibble)
}