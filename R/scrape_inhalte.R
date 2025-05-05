#' Scrape content from a tab
#'
#' This function searches a given RMD instance for the "Content" tab, clicks on it, and extracts data from the container elements found on the page. It makes several attempts in case of errors and returns the extracted data as a tibble.
#'
#' @param rmdr An Rmdr object representing the Selenium WebDriver.
#' @param css_inhalte_tab A CSS selector for the "Content" tab. The default value is the selector for the "Content" tab.
#' @param css_container A CSS selector for the containers from which the data will be extracted. The default value is the selector for container elements.
#' @param css_title_selector A CSS selector for the titles of the containers. The default value is the selector for container titles.
#' @param css_content_selector A CSS selector for the content of the containers. The default value is the selector for container contents.
#' @param max_attempts The maximum number of attempts to successfully extract the content. The default value is 10.
#'
#' @return A tibble containing the extracted data from the "Content" tab. If no content is found, the function returns NULL.
#' @importFrom tibble as_tibble
#' @importFrom crayon red blue yellow
#' @importFrom janitor clean_names
#' @export
scrape_inhalte <- function(rmdr,
                           css_inhalte_tab = "#detailViewData\\:tabContainer\\:term-planning-container\\:tabs\\:contentsTab > span:nth-child(1)",
                           css_container = "#detailViewData\\:tabContainer\\:term-planning-container\\:j_id_6s_13_2_%d_1",
                           css_title_selector = "#detailViewData\\:tabContainer\\:term-planning-container\\:j_id_6s_13_2_%d_1\\:collapsiblePanel > div.box_title > div > div.layoutFieldsetTitle.collapseTitle > h2",
                           css_content_selector = "#detailViewData\\:tabContainer\\:term-planning-container\\:j_id_6s_13_2_%d_1\\:collapsiblePanel > div.box_content > fieldset",
                           max_attempts = 10) {
  attempt <- 0  # Zaehler fuer die Versuche
 
  container_data <- tibble::tibble()
  
  while (attempt < max_attempts) {
    attempt <- attempt + 1
    message(blue("Versuch Registerkarte >>Inhalte<< zu finden Nr. ", attempt, " von maximal ", max_attempts, " ..."))
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # ueberpruefe auf Netzwerkprobleme
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if (check_network_errors(rmdr)) {
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Checke, ob Inhalte-Tab vorhanden ist, und klicke darauf
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    tryCatch({
      inhalte_tab <- rmdr$findElement(
        using = "css selector", css_inhalte_tab
      )
      
      inhalte_tab$clickElement()
      
    }, error = function(e) {
      message("Fehler beim Klicken auf das Inhalte-Tab-Element: ", conditionMessage(e))
    })

    if (!exists("inhalte_tab")) {
      if (check_network_errors(rmdr)) {
        next
      }
    }

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    #Klappe Inhalte aus
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::

    # Versuche zuerst, den Button zu finden, wenn der Abschnitt bereits offen ist
    elem_open <- rmdr$findElements(using = "css selector", "button[aria-label='Zuklappen des Abschnitts: Inhalte']")

    # Falls nicht vorhanden: versuche das <a>-Element zum Öffnen zu finden
    if (length(elem_open) == 0) {
      elem_closed <- rmdr$findElements(using = "css selector", "a[aria-label='Öffnen des Abschnitts: Inhalte']")
      if (length(elem_closed) > 0) {
        elem_closed[[1]]$clickElement()
        Sys.sleep(1)
      } else {
        message("Weder offener noch geschlossener Zustand gefunden – Abschnitt evtl. nicht vorhanden.")
      }
    }

    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Falls Inhalte vorhanden sind, Container auszaehlen
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    message(blue("Starte das Scraping der Registerkarte >>Inhalte<<"))
    
    found_containers <- 0
    
    tryCatch({
      # Generiert Selektoren fuer moegliche Container-IDs
      container_ids <- sprintf(
        css_container,
        0:20
      )
      
      # Zaehle gefundene Container
      for (css in container_ids) {
        elements <- rmdr$findElements(using = "css selector", css)
        if (length(elements) > 0) {
          found_containers <- found_containers + 1
        }
      }
      
    }, error = function(e) {
      message("Fehler beim Zaehlen der Container im Registerblatt >>Inhalte<<: ", conditionMessage(e))
    })
    
    # Falls keine Container gefunden wurden, Funktion beenden
    if (found_containers == 0) {
      message(crayon::yellow("Keine Container in der Registerkarte >>Inhalte<< gefunden"))
      return(container_data)  # Beendet die Funktion mit leerem Tibble
    }
    
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Inhalte der gefundenen Container extrahieren
    #:::::::::::::::::::::::::::::::::::::::::::::::::::::::
    
    if (found_containers > 0) {
      
      message(crayon::yellow("Anzahl gefundener Container in der Registerkarte >>Inhalte<<:", found_containers))
      
      container_list <- list()  # Initialisiere eine Liste
      
      for (i in 0:(found_containers - 1)) {
        # Dynamische Selektoren fuer Titel und Inhalt generieren
        title_selector <- sprintf(css_title_selector, i)
        content_selector <- sprintf(css_content_selector, i)
        
        # Variablen initialisieren
        title_text <- NA
        content_text <- NA
        
        # Versuche, den Titel zu extrahieren
        tryCatch({
          titel <- rmdr$findElement(using = "css selector", title_selector)
          title_text <- titel$getElementText()[[1]]
        }, error = function(e) {
          message(sprintf("Fehler: Kein Titelelement fuer Container %d gefunden", i))
        })

        if (!exists("titel")) {
          if (check_network_errors(rmdr)) {
            next
          }
        }
        
        # Versuche, den Inhalt zu extrahieren
        tryCatch({
          inh <- rmdr$findElement(using = "css selector", content_selector)
          content_text <- inh$getElementText()[[1]]
        }, error = function(e) {
          message(sprintf("Fehler: Kein Inhaltselement fuer Container %d gefunden", i))
        })

        if (!exists("inh")) {
          if (check_network_errors(rmdr)) {
            next
          }
        }
        
        # Speichere die Ergebnisse als Liste mit Titel als Spaltennamen
        if (!is.na(title_text) && !is.na(content_text)) {
          container_list[[title_text]] <- content_text
        }
      }
      
      # Konvertiere die Liste in ein tibble mit einer Zeile
      container_data <- as_tibble(container_list) |> janitor::clean_names()
      check_obj_exist(container_data)
      return(container_data)
    }
  }
  
  # Falls max_attempts erreicht wurde
  message(crayon::red("Maximale Anzahl an Versuchen (", max_attempts, ") erreicht. Scraping wird abgebrochen."))
  return(NULL)
}
