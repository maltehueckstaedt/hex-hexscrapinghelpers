#' Scrape Base Information from Multiple Pages
#'
#' Diese Funktion extrahiert Tabellen von mehreren Seiten einer Webseite, die mit einem CSS-Selektor definiert sind. 
#' Sie liest den HTML-Code der Tabelle, extrahiert ihn mit `rvest` und fügt ihn zu einem `tibble` zusammen. Der 
#' Prozess wiederholt sich für alle Seiten, die durch den maximalen Seitenwert bestimmt werden.
#'
#' @param rmdr Ein WebDriver-Objekt, das für die Interaktion mit der Webseite verwendet wird. Wird durch `RSelenium` erzeugt.
#' @param css_max_selector Ein CSS-Selektor, der auf das Element zeigt, das die maximale Seitenzahl enthält
#'        die zum Scraping verwendet wird.
#'
#' @return Ein `tibble`, das die extrahierten Tabellen von allen Seiten enthält.
#'         Jede Tabelle wird zu einer `data.frame` innerhalb des `tibble` zusammengefügt.
#'
#' @export
scrape_base_info <- function(rmdr, css_max_selector) {
  # Extrahiere die maximale Seitenzahl
  selector <- rmdr$findElement(using = "css selector", css_max_selector)
  selector_text <- selector$getElementText() |> as.character()
  select_end <- as.numeric(str_extract(selector_text, "\\d+$"))
  
  # Leeres tibble, um die extrahierten Tabellen zu speichern
  all_tables <- tibble()
  
  # Wiederhole den Prozess für alle Seiten
  for (i in 1:select_end) {
    message(paste0("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"))
    message(paste0("Starte scraping der Base-Informationen für Seite: ", i))
    message(paste0("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"))
    
    # Suche die Tabelle mit der entsprechenden ID
    table_element <- rmdr$findElement(using = "css selector", "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Table")
    
    # Extrahiere den HTML-Code der Tabelle
    table_html <- table_element$getElementAttribute("outerHTML")[[1]]
    
    # Verwende rvest, um die Tabelle aus dem HTML-Code zu extrahieren
    table <- read_html(table_html) %>%
      html_table(fill = TRUE) %>%
      .[[1]] %>%
      select(where(~ !all(is.na(.)))) %>%
      remove_column_names_from_values()  # Wenn diese Funktion existiert
    
    # Füge die extrahierte Tabelle zum bestehenden tibble hinzu
    all_tables <- bind_rows(all_tables, table)
    
    # Klicke auf die nächste Seite (falls verfügbar)
    click_next_page(rmdr)
    
    # Warten, um sicherzustellen, dass die Seite vollständig geladen ist
    Sys.sleep(3)
  }
  
  return(all_tables)
}