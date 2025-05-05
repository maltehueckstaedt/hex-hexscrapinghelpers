#' Scrape dates from the "Dates" tab
#'
#' This function searches a given RMD instance for the "Dates" tab, extracts the associated labels and answers, and returns them as a tibble. It makes several attempts in case of errors and checks for network issues.
#'
#' @param rmdr An Rmdr object representing the Selenium WebDriver.
#' @param css_labels A CSS selector for the labels to be extracted from the "Dates" tab. The default value is the selector for the label elements.
#' @param css_answers A CSS selector for the answers to be extracted from the "Dates" tab. The default value is the selector for the answer elements.
#' @param max_attempts The maximum number of attempts to successfully extract the data. The default value is 10.
#'
#' @return A tibble containing the extracted dates (labels and answers) from the "Dates" tab. If no data is found, the function returns an empty tibble.
#' @importFrom tibble tibble
#' @importFrom crayon red blue yellow
#' @importFrom dplyr group_by summarise
#' @importFrom tidyr pivot_wider
#' @export
scrape_termine <- function(rmdr,
                           css_labels = ".labelItemLine label",
                           css_answers = ".labelItemLine .answer",
                           max_attempts = 10) {
  attempt <- 0  # Zaehler fuer die Versuche
  
  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(crayon::blue("Versuch Studiengaenge in Registerkarte >>Termine<< zu finden Nr. ", attempt, " von maximal ", max_attempts, " ..."))
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # ueberpruefe auf Netzwerkprobleme
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    if (check_network_errors(rmdr)) {
    }

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Suche nach Grunddatenelementen
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

    message(crayon::yellow("Starte das Scraping der Registerkarte >>Termine<<"))
   
    label_texts <- NULL
    answer_texts <- NULL
    df_termine <- tibble::tibble()

   
    tryCatch({
      labels <- rmdr$findElements(using = "css selector", ".labelItemLine label")
      label_texts <- sapply(labels, function(el) el$getElementText())
      
      answers <- rmdr$findElements(using = "css selector", ".labelItemLine .answer")
      answer_texts <- sapply(answers, function(el) el$getElementText())
      
    }, error = function(e) {
      message(crayon::red("Fehler beim Scrapen der Informationen des Tabs >>Termine<<", e))
    })

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Wenn keine Grunddatenelemente gefunden: Checke Netzwerk
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

    if (is.null(label_texts) && is.null(answer_texts)) {
      if (check_network_errors(rmdr)) {
        message(crayon::red("Netzwerkfehler. Naechster Versuch..."))
        next  # Wenn Netzwerkfehler, gehe zum naechsten Versuch
      } else {
        message(crayon::blue("Kein Netzwerkfehler, aber keine Daten. Beende den Vorgang."))
        return(df_termine)  # Kein Netzwerkfehler und keine Daten, gebe das DataFrame zurueck
      }
    } else if (!is.null(label_texts) && !is.null(answer_texts)) {
      df_termine <- tibble::tibble(
        Label = label_texts,
        Answer = answer_texts
      ) %>%
        dplyr::group_by(Label) %>%
        dplyr::summarise(
          Answer = list(unique(Answer)),
          .groups = "drop"
        ) %>%
        tidyr::pivot_wider(names_from = Label, values_from = Answer)
      
      check_obj_exist(df_termine)
      return(df_termine)
    }
    
  }
  if (attempt == max_attempts) {
    message(crayon::red("Maximale Anzahl an Versuchen erreicht."))
    return(df_termine)
  }
}
