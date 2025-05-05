#' Clicks the "Back" button of a webpage
#'
#' This function attempts to click the "Back" button of a webpage to return to the previous page or overview.
#' It makes several attempts in case of errors and checks for network issues to ensure the button is clicked.
#'
#' @param rmdr An Rmdr object representing the Selenium WebDriver.
#' @param max_attempts The maximum number of attempts to successfully click the button. The default value is 10.
#'
#' @return Returns `NULL` since the function does not provide any values. On success, a message is printed indicating that the Back button was clicked. In case of repeated failure, an error message is displayed.
#' @importFrom crayon inverse red bgRed
#' @export
click_back <- function(rmdr, max_attempts = 10) {
  attempt <- 0
  success <- FALSE
  
  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(blue("Versuche >>zurueck<<-Button zu finden Nr. ", attempt, " von maximal ", max_attempts, " ..."))
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # ueberpruefe auf Netzwerkprobleme, wenn ja, reload!
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if (check_network_errors(rmdr)) {
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Versuche den Zurueck-Button zu finden und anzuklicken.
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    tryCatch({
      zurueck <- rmdr$findElement(using = "css selector", "#form\\:dialogHeader\\:backButtonTop")
      
      # Scrollen zum Button
      rmdr$executeScript("arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });", list(zurueck))
      
      Sys.sleep(1)  # Wartezeit fuer stabileren Klick (optional)
      
      zurueck$clickElement()
      message(crayon::inverse("Zurueck zur uebersicht..."))
      
      Sys.sleep(1)  # Wartezeit nach Klick (optional)
      success <- TRUE
      break  # Erfolgreich geklickt -> Schleife verlassen
    }, error = function(e) {
      message(crayon::red("Fehler beim Klicken auf den Zurueck-Button: ", conditionMessage(e)))
    })
    
    # Nach einem fehlgeschlagenen Versuch noch einmal auf Netzwerkfehler pruefen
    if (!success && check_network_errors(rmdr)) {
      message(crayon::bgRed("Erneuter Versuch wegen Netzwerkfehler..."))
      next
    }

    
    Sys.sleep(1)  # Kurze Pause vor neuem Versuch
  }
  
  # Wenn nach allen Versuchen kein Erfolg, Fehlermeldung ausgeben
  if (!success) {
    message(crayon::bgRed("Unaufgeloester Fehler in >>click_zurueck<<-Funktion!"))
  }
}
