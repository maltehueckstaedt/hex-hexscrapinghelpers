#' Generates CSS selectors for course links
#'
#' This function creates a list of CSS selectors that can be used to select course links
#' on a webpage. The maximum number of selectors is extracted from the total number of search results.
#'
#' @param rmdr An RSelenium remote driver object to control the web browser.
#' @param selector_start A numeric value indicating the starting index of the selectors (default: 0).
#' @param css_first_selector A format string for the CSS selector of the course links, with \code{\%d} as a placeholder for the index.
#' @param css_max_selector A CSS selector to extract the maximum number of search results.
#'
#' @return A vector of CSS selectors for the course links.
#' @importFrom stringr str_extract str_remove_all
#' @export
generate_url_selectors <- function(rmdr,
                                   selector_start = 0,
                                   css_first_selector,
                                   css_max_selector = "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Navi2_div > div > span.dataScrollerResultText") {
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Scrollt zum Seitenende
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

  rmdr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
  
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Extrahiere unten rechts: Suchergebnis: >>Anzahl<< Ergebnisse
  # um die maximale Anzahl der Kurse und somit Selektoren
  # zu bestimmen
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

  selector <- rmdr$findElement(using = "css selector", css_max_selector)
  
  selector_text <- selector$getElementText()
  
  select_end <- as.numeric(stringr::str_remove_all(stringr::str_extract(selector_text, "[0-9\\.]+"), "\\."))

  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # Erzeuge Kursselektoren
  #:::::::::::::::::::::::::::::::::::::::::::::::::::::::::

  css_selectors <- sprintf(css_first_selector,
    selector_start:select_end
  )
  
  return(css_selectors)
}