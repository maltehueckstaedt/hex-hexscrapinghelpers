#' Display a countdown with remaining seconds
#'
#' This function performs a countdown and displays the remaining seconds in the console. The output is shown in a single line, which is updated every second to inform the user about the remaining time until the next step.
#'
#' @param seconds A numeric value specifying the number of seconds the countdown should last.
#'
#' @details
#' The countdown is displayed in the console, with each remaining second shown as an updated number. Once the countdown is finished, a message is displayed indicating that the waiting time is over.
#'
#' @export
countdown_sleep <- function(seconds) {
  for (t in seq(seconds, 1, by = -1)) {
    # '\r' bewirkt, dass die Zeile überschrieben wird
    cat(paste("\rWartezeit bis zum nächsten Schritt:", t, "Sekunden"),
        sep = "")
    Sys.sleep(1)
  }
  cat("\rWartezeit beendet!\n")  # Zeile nach dem Countdown beenden
}
