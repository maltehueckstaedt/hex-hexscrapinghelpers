#' Scraping function for the HIS system
#'
#' This function extracts course information from the HIS system by visiting a given list of URLs
#' and extracting relevant content such as dates, content, modules, and degree programs.
#'
#' @param chunks A list of vectors containing the URLs or selectors to be scraped.
#' @param rmdr An `RSelenium` RemoteDriver object used for the scraping.
#' @param uni_name Name of the University. Important for the filename in the context from data export.

#'
#' @return A `tibble` containing the collected course data. If the function unexpectedly terminates,
#' the data collected up to that point will be returned.
#'
#' @details The function iterates over the `chunks` and calls various scraping functions for each URL or selector:
#' - `scrape_termine()`: Extracts the course dates.
#' - `scrape_inhalte()`: Extracts the course content.
#' - `scrape_module()`: Extracts the associated modules.
#' - `scrape_studiengaenge()`: Extracts the associated degree programs.
#'
#' If an error occurs, it is caught and logged. The function continues running to collect as much
#' data as possible.
#'
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom purrr compact
#' @importFrom readr write_rds
#' @export
scrape_his <- function(rmdr, chunks, uni_name) {

  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Erhebe Basisinformationen
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  semester_element <- rmdr$findElement(using = "css selector", "#genSearchRes\\:genericSearchResult > div.text_white_searchresult > span")
  semester <- semester_element$getElementText()
  scraping_datum <- Sys.Date()

  base_inf <- tibble(semester = semester,
    scraping_datum = scraping_datum
  )

  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Erzeuge leeren Tibble
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

  results <- tibble()

  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Speichere ersten und letzten Selektor, der gelickt
  # werden soll.
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

  first_selector_clicked <- chunks[["1"]][1]
  last_selector <- tail(tail(chunks, 1)[[1]], 1)
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Definiere Bedingungen, was passiert, wenn Funktion
  # abbricht: Export Data!
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

  on.exit({
    first_course <- str_extract(first_selector_clicked, "(?<=\\\\:)(\\d+)(?=\\\\)") |> as.numeric() + 1
    last_course <- str_extract(last_selector_clicked, "(?<=\\\\:)(\\d+)(?=\\\\)") |> as.numeric() + 1
    file_name <-  paste0("course_data_", uni_name, "_", first_course, "_to_", last_course, ".RDS")
    readr::write_rds(results, file_name)
    return(results)
  }, add = TRUE)
  
  i <- "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Table\\:1490\\:tableRowAction"
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Starte Scraping
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

  # Initialisiere den Zähler für die Kurs-URLs
  counter <- 0

  for (chunk in chunks) {
    for (i in chunk) {

      tryCatch({

        # Erhöhe den Zähler bei jedem Schleifendurchlauf
        counter <- counter + 1
        
        # Zeige die Nachricht mit der aktuellen Kurs-URL-Anzahl
        message(yellow("Anzahl der in dieser Iteration betätigten Kurs-Urls: ", counter))
        
        # Überprüfe, ob keine_url TRUE ist, und beende das Scraping
        if (exists("keine_url") && keine_url == TRUE) {
          message("KURS-URL konnte nicht gefunden. Beende das Scraping.")
          return(results)  # Bricht das Scraping ab und gibt die bisher gesammelten Daten zurück
        }
        
        click_course_url(i, rmdr, max_attempts = 10)
        last_selector_clicked <<- i
        termine <- scrape_termine(rmdr, max_attempts = 10)
        Sys.sleep(1)
        inhalte <- scrape_inhalte(rmdr, max_attempts = 10)
        Sys.sleep(1)
        module <- tibble(module = list(scrape_module(rmdr, max_attempts = 10)))
        studiengaenge <- tibble(studiengaenge = list(scrape_studiengaenge(rmdr, max_attempts = 10)))

        new_row <- bind_cols(purrr::compact(list(base_inf, termine, inhalte, module, studiengaenge)))

        results <- bind_rows(results, new_row)
        print(results)
        click_back(rmdr, max_attempts = 10)
        Sys.sleep(3)

      }, error = function(e) {
        message("Fehler aufgetreten: ", e$message)
      })
      
      # Falls der letzte Selektor erreicht wurde, beende die Funktion
      if (i == last_selector) {
        beep(1)
        message(blue("Scrapingprozess erfolgreich beendet"))
        return(results)
      }
    }
    click_next_page(rmdr, max_attempts = 10)
    Sys.sleep(3)
  }
  return(results)
}
