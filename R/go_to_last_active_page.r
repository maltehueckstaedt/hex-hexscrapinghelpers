#' Navigate to the target page based on a selector
#'
#' This function calculates how many pages need to be flipped through to reach a specific page,
#' determined by the `selector` value. If the selector is greater than 100, navigation occurs in steps of 10,
#' otherwise in steps of 1.
#'
#' @param rmdr An RSelenium driver object used for interaction with the webpage.
#' @param selector A numeric value representing the target selector.
#'
#' @return Does not return any values. The function navigates through the pages and prints messages
#' to document the progress.
#' @seealso \code{\link{click_next_page}}, \code{\link{click_next_10_pages}}
#' @importFrom crayon red blue yellow green
#' @importFrom beepr beep
#' @export
go_to_last_active_page <- function(rmdr, selector) {
  
  message(blue(paste0("Zielseite des spezifizierten Selectors:", " Seite ", ceiling(selector / 10) + 1)))
  message(blue("Seite wird angesteuert..."))
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Wenn Selector >100: Berechne anhand des Selektors, wie
  # oft man click_next_10_pages betaetigen muss, um moeglichst
  # nahe an den Selector zu gelangen.
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
   
  if (selector > 100) {
    target_page_ten_step <- ceiling(selector / 10) + 1
    target_page_ten_step <- floor(target_page_ten_step / 10) * 10

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Berechne weiterhin anhand des Selektors, wie oft man click_next_page
    # betaetigen muss, um im weiteren Verlauf moeglichst nahe an
    # den Selector zu gelangen.
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    target_page_single_step <- ceiling(selector %% 100 / 10) + 1
  
  }

  current_page <- 1

  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Wenn der Selektor unter 100 liegt, berechne in target_page
  # wie oft click_next_page betaetigt werden muss um auf die
  # Seite zu gelangen, auf der der Selector leigt.
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

  if (selector < 100) {
    # Navigiere direkt zur Seite
    target_page <- round(selector, -1) / 10  # Berechne die Seite basierend auf dem Selektor
    while (current_page < target_page) {
      Sys.sleep(1)
      click_next_page(rmdr)  # Eine Seite weiter
      current_page <- current_page + 1
      message(paste("Weiter zu Seite", current_page))
    }

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Wenn der Selektor >= 100 ist, betaetige so lange
    # click_next_10_pages() bis current_page nicht mehr kleiner
    # als target_page_ten_step ist.
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

  } else {
    step_10 <- 0

    while (step_10 < target_page_ten_step) {
      click_next_10_pages(rmdr)
      step_10 <- step_10 + 10
      message(paste("Springe zu Seite", step_10))
    }


    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Kommen wir in 10er Schritten nicht mehr naeher an den
    # Selector, fahren wir mit click_next_page() fort, bis
    # single_page nicht mehr kleiner target_page_single_step ist
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    step_1 <- 1
    while (step_1 < target_page_single_step) {
      Sys.sleep(1)
      click_next_page(rmdr)  # Eine Seite weiter
      step_1 <- step_1 + 1
      message(paste("Weiter zu Seite", step_10 + step_1))
    }
  }
  
  message(green("Ziel (Seite ", step_10 + step_1, ") fuer Selector", selector, "erreicht"))
  beep(1)
}