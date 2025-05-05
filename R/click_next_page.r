#' Click on the "Next" button to display the next overview page
#'
#' This function searches for the "Next" button on an overview page and clicks on it.
#' If the button is not found or a network issue occurs, several attempts are made to load the next page.
#' If the next page cannot be loaded successfully, it checks whether the WebDriver is still on an event page.
#'
#' @param rmdr An `RSelenium` Remote WebDriver object.
#' @param css_next_page A character string specifying the CSS selector of the "Next" button.
#' @param max_attempts The maximum number of attempts to find and click the "Next" button.
#'   Default: `10`.
#'
#' @details The function proceeds as follows:
#' - Checks for potential network issues and reloads the page if necessary.
#' - Scrolls down and looks for the "Next" button.
#' - If the button is found, it clicks it and reloads the page.
#' - Checks if the next overview page was successfully reached by searching for an element with
#'   search results.
#' - If the next page is not successfully loaded, it checks if the WebDriver is still on an event page.
#'   If so, it goes back to the previous page.
#' - If the WebDriver is neither on a course page nor an overview page, the process is aborted.
#'
#' @return No return value. The function interacts with the `RSelenium` WebDriver and controls
#'   navigation within the web application.
#'
#' @importFrom crayon blue green red yellow bgGreen
#' @seealso [check_network_errors()], [click_back()]
#' @export
click_next_page <- function(rmdr,
                         css_next_page = "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Navi2next",
                         max_attempts = 10) {

  attempt <- 0
  
  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(crayon::blue("Versuche >>weiter<<-Button zu finden Nr. ", attempt, " von maximal ", max_attempts, " ..."))
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # ueberpruefe auf Netzwerkprobleme, wenn ja, Reload
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    if (check_network_errors(rmdr)) {
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Scrolle nach ganz unten. Versuch Weiterbutton zu
    # finden und zu klicken.
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    rmdr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    
    weiter_button <- tryCatch({
      weiter_button <- rmdr$findElement(using = "css selector", css_next_page)
      message(yellow(">>weiter<<-Button gefunden. Zeige die naechste uebersichtsseite an..."))
      weiter_button$clickElement()
      Sys.sleep(3)
    }, error = function(e) {
      message(crayon::red("Kein >>weiter<<-Button gefunden. Sammle weitere Informationen..."))
    })

    if (is.null(weiter_button)) {
      if (check_network_errors(rmdr)) {
      }
    }
    
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Pruefe, ob uebersichtsseite erfolgreich angesteuert
    # wurde, in dem testweise das Element >>Semester: WiSe 2020<<
    # oben links auf der uebersichtsseite gesucht wird
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    sem_un_titel <- tryCatch({
      rmdr$findElement(using = "css selector",
                       "#genSearchRes\\:genericSearchResult > div.text_white_searchresult > span")
    }, error = function(e) {
      message(crayon::red("Driver befindet sich nicht auf einer uebersichtsseite!"))
    })
    
    if (!is.null(sem_un_titel)) {
      message(crayon::green("Naechste uebersichtseite erfolgreich angesteuert!"))
      break
    } else {
      if (check_network_errors(rmdr)) {
      }
    }
    
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Wenn naechste uebersichtsseite nicht ansteuerbar, pruefe
    # ob sich der Driver noch auf einer Veranstalltungs-
    # seite befindet in dem die Registerkarte >>Termine<<
    # gesucht wird:
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    reg_termine <- tryCatch({
      rmdr$findElement(using = "css selector",
                       "#detailViewData\\:tabContainer\\:term-planning-container\\:tabs\\:parallelGroupsTab")
    }, error = function(e) {
      message(crayon::red("Driver befindet sich auch nicht auf einer Veranstaltungsseite! Netzwerkfehler?"))
      if (check_network_errors(rmdr)) {
      }
    })
    
    if (!is.null(reg_termine)) {
      message(crayon::blue("Driver befindet sich noch auf einer Kursseite. Gehe zurueck zur uebersichtsseite..."))
      click_back(rmdr, max_attempts = 10)
      Sys.sleep(3)
      next
    } else {
      message(crayon::red("Driver befindet sich weder auf Kursseite, noch auf uebersichtsseite. Beende den Vorgang."))
      break
    }
  }
}