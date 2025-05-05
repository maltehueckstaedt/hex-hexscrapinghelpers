#' Check for network errors in the RSelenium session
#'
#' This internal helper function checks for known network errors in an RSelenium web session.
#' If an error is found, the page is refreshed.
#'
#' @param rmdr An `RSelenium` Remote WebDriver object.
#'
#' @return A `logical` value:
#' \describe{
#'   \item{TRUE}{If a network error is found and the page has been refreshed.}
#'   \item{FALSE}{If no network error is detected.}
#' }
#'
#' @details
#' The function looks for typical network error messages on the webpage and refreshes
#' the page if any of these errors occur. If no errors are found, the function ends without action.
#'
#' @importFrom crayon red green
#' @import RSelenium
check_network_errors <- function(rmdr) {
  error_messages <- c()

  server_error_typ1 <- suppressMessages(suppressWarnings(tryCatch({
    rmdr$findElement(using = "css selector", "#message")$getElementText()
  }, error = function(e) NULL)))

  if (!is.null(server_error_typ1)) {
    error_messages <- c(error_messages, server_error_typ1)
  }

  server_error_typ2 <- suppressMessages(suppressWarnings(tryCatch({
    rmdr$findElement(using = "css selector", "#main-message > h1 > span")$getElementText()
  }, error = function(e) NULL)))

  if (!is.null(server_error_typ2)) {
    error_messages <- c(error_messages, server_error_typ2)
  }

  server_error_typ3 <- suppressMessages(suppressWarnings(tryCatch({
    rmdr$findElement(using = "css selector", "#lang-de > div > div.rowEnd > h4.lang.de")$getElementText()
  }, error = function(e) NULL)))

  if (!is.null(server_error_typ3)) {
    error_messages <- c(error_messages, server_error_typ3)
  }

  server_error_typ4 <- suppressMessages(suppressWarnings(tryCatch({
    rmdr$findElement(using = "css selector", "body > h1")$getElementText()
  }, error = function(e) NULL)))

  if (!is.null(server_error_typ4)) {
    error_messages <- c(error_messages, server_error_typ4)
  }

  # Falls bekannte Fehler auftreten, dann Seite aktualisieren und TRUE zurueckgeben
  if (any(error_messages %in% c(
    "Das Netzwerk oder der Server ist nicht erreichbar",
    "Kein Internet",
    "The network is offline or the server is not reachable",
    "Die Webseite ist nicht erreichbar",
    "Die Website ist nicht erreichbar",
    "Die Verbindung wurde unterbrochen",
    "Sie haben keine Internetverbindung oder der Server reagiert nicht",
    "Error 503 Backend fetch failed"
  ))) {
    message(red("Netzwerkfehler gefunden: ", paste(error_messages, collapse = " / "), " Refreshing..."))
    rmdr$refresh()  # Browser wird aktualisiert
    Sys.sleep(10)  # Kurze Pause vor dem naechsten Versuch
    return(TRUE)  # Signalisiert, dass ein Fehler aufgetreten ist
  }
  return(FALSE)  # Kein Fehler aufgetreten
}
