#' Click on a course URL and check page transition
#'
#' This function searches for a course url, scrolls it into view,
#' extracts the title, clicks on the element, and checks if the transition
#' to the course page was successful. If not, it checks whether the `remoteDriver`
#' is still on the overview page and attempts to navigate again if necessary.
#'
#' @param i A `character` string with the CSS selector for the course URL.
#' @param rmdr A `remoteDriver` object from `RSelenium` that controls the browser instance.
#' @param max_attempts An `integer` specifying the maximum number of attempts (default: 10).
#'
#' @return Does not return a value but prints console messages to document the progress.
#'
#' @importFrom RSelenium remoteDriver
#' @importFrom crayon red green blue magenta
#'
#' @export
click_course_url <- function(i, rmdr, max_attempts = 10) {
  attempt <- 0
  titel <- NULL
  
  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(red("///////////////////////////////////////"))
    message(red("VERSUCH NUMMER:", attempt))
    message(red("///////////////////////////////////////"))

    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Überprüfe auf Netzwerkprobleme, wenn ja, neuer Versuch
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    if (check_network_errors(rmdr)) {
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Finde Kurs-URL, scrolle hin, ziehe den titel und
    # klicke das Element. Warte dann mit Sys.sleep().
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    tryCatch({
      elem <- rmdr$findElement(using = "css selector", i)
      rmdr$executeScript(
        "arguments[0].scrollIntoView({ behavior: 'smooth', block: 'center' });",
        list(elem)
      )
      titel <- elem$getElementText()[[1]]
      elem$clickElement()
      message(blue("Link wurde erfolgreich betätigt"))
      Sys.sleep(1)
    }, error = function(e) {
      message(red("Fehler beim Finden oder Scrollen der URL. Fehler: ", e$message))
      if (check_network_errors(rmdr)) {
      }
    })
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Prüfe ob die Kursseite erfolgreich betreten wurde,
    # in dem die Registerkarte >>Termine<< gesucht wird.
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    reg_termine <- tryCatch({
      rmdr$findElement(using = "css selector",
                       "#detailViewData\\:tabContainer\\:term-planning-container\\:tabs\\:parallelGroupsTab > span:nth-child(1)")
    }, error = function(e) {
      message(red("URL wurde nicht betreten. Fehler: ", e))
      if (check_network_errors(rmdr)) {
      }
      NULL
    })
    
    if (!is.null(reg_termine)) {
      message(green("Kursseite erfolgreich betreten. Starte das Scraping des Kurses: ", titel))
      message(magenta("Kurs-URL-Selector: ", i))
      break
      
      #:::::::::::::::::::::::::::::::::::::::::::::::::::::
      # Wenn erfolgreich, Funktion verlassen
      #:::::::::::::::::::::::::::::::::::::::::::::::::::::
      
    } else {
      #:::::::::::::::::::::::::::::::::::::::::::::::::::::
      # Prüfe ob Driver noch auf der Übersichtsseite ist
      #:::::::::::::::::::::::::::::::::::::::::::::::::::::
      kurs_select <- tryCatch({
        rmdr$findElement(using = "css selector", i)
      }, error = function(e) {
        NULL
      })
      
      if (!is.null(kurs_select)) {
        message(blue("Der Driver befindet sich auf der Übersichtsseite. Kurs-URL wird erneut gesucht und betätigt..."))
        if (attempt == max_attempts) {
          stop(red("Maximale Anzahl an Versuchen erreicht. Abbruch für Kurs-URL: ", i))
        }
        next
      } else {
        keine_url <<- TRUE
        break()
      }
    }
  }
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Schleife durchgelaufen, kein Erfolg
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  if (attempt == max_attempts) {
    stop(red("Maximale Anzahl an Versuchen erreicht. Abbruch für Kurs-URL: ", i))
  }
}