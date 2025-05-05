#' Click ten pages forward in the result navigation
#'
#' This function searches for the "Ten pages forward" button on an overview page
#' and clicks on it. If the button is not found, it checks for any network issues.
#'
#' @param rmdr An `RSelenium` Remote WebDriver object.
#' @param css_next_10_pages A character string that specifies the CSS selector of the "Ten pages forward" button.
#' @param max_attempts The maximum number of attempts to find and click the button.
#'   Default: `10`.
#'
#' @return No return value. The function navigates within the web application.
#'
#' @importFrom crayon yellow red
#' @seealso \code{\link{check_network_errors}}
#'
#' @export
click_next_10_pages  <- function(rmdr,
                                 css_next_10_pages = "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Navi2fastf > span",
                                 max_attempts = 10) {

  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Scrolle nach ganz unten. Versuch Weiterbutton zu
  # finden und zu klicken.
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  rmdr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
  
  tryCatch({
    weiter_button <- rmdr$findElement(using = "css selector", css_next_10_pages)
    message(yellow("clicke zehn Seiten weiter..."))
    weiter_button$clickElement()
    Sys.sleep(3)
  }, error = function(e) {
    message(red("Keiner Weiter-Button gefunden."))
    if (check_network_errors(rmdr)) {
    }
  })
  
}