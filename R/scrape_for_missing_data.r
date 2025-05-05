#' Scrape fehlende Kursdaten aus dem HIS-System
#'
#' Führt ein halbautomatisiertes Scraping für Kurse durch, deren Informationen fehlen,
#' basierend auf Titel und Nummer. Die Ergebnisse werden in einer RDS-Datei gespeichert.
#'
#' @param rmdr Ein `RSelenium::remoteDriver`-Objekt, das mit dem Browser verbunden ist.
#' @param missing_data Ein `tibble` mit den Spalten `titel` und `nummer`, die gescraped werden sollen.
#' @param num_sem_selector Eine Zeichenkette oder Zahl zur Auswahl des Semesters (z. B. `"2"`).
#'
#' @return Ein `tibble` mit den gesammelten Kursinformationen.
#' @export
scrape_for_missing_data <- function(rmdr, missing_data, num_sem_selector) {
  total <- nrow(missing_data)  # Gesamtzahl der Zeilen
  result_tibble <- tibble()  # Leeres tibble für die Ergebnisse
  
  # Prüfe, ob die RDS-Datei existiert und benenne sie entsprechend um
  file_name <- "course_data_missing.RDS"
  counter <- 1
  while (file.exists(file_name)) {
    file_name <- paste0("course_data_missing", counter, ".RDS")
    counter <- counter + 1
  }
  
  # Exportiere die Daten, wenn die Funktion beendet wird
  on.exit({
    # Ergebnisse als tibble zusammenfassen und als RDS exportieren
    readr::write_rds(result_tibble, file_name)
    message(sprintf("Daten wurden erfolgreich exportiert nach %s.", file_name))
  })
  
  # Iteriere über alle Zeilen von `missing_data`
  for (i in 1:total) {
    titel <- missing_data$titel[i]
    nummer <- missing_data$nummer[i]
    
    # Fortschritt anzeigen
    progress <- (i / total) * 100  # Berechne den prozentualen Fortschritt
    message(sprintf("Fortschritt: %.2f%% - Starte das Scraping für Titel: '%s' (Nummer: %s)", progress, titel, nummer))
    
    # Wähle Semester
    Sys.sleep(1.5)
    drop_down_sem <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_3_abb156a1126282e4cf40d48283b4e76d\\:idabb156a1126282e4cf40d48283b4e76d\\:termSelect_label"
    drop_down_sem <- rmdr$findElement(using = "css selector", drop_down_sem)
    drop_down_sem$clickElement()
    
    css_sem_num <- paste0("#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_3_abb156a1126282e4cf40d48283b4e76d\\:idabb156a1126282e4cf40d48283b4e76d\\:termSelect_", num_sem_selector)
    sem <- rmdr$findElement(using = "css selector", css_sem_num)
    sem$clickElement()

    # Erweiterte Suche
    Sys.sleep(1.5)
    erweit_suche <- "#genericSearchMask\\:buttonsBottom\\:toggleSearchShowAllCriteria"
    search_button <- rmdr$findElement(using = "css selector", erweit_suche)
    search_button$clickElement()

    # Titel eingeben
    Sys.sleep(1.5)
    suchbegriff <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_0_1ad08e26bde39c9e4f1833e56dcce9b5\\:id1ad08e26bde39c9e4f1833e56dcce9b5"
    field_titel <- rmdr$findElement(using = "css selector", suchbegriff)
    field_titel$clickElement()
    field_titel$sendKeysToElement(list(titel))
 
    # Nummer eingeben
    Sys.sleep(1.5)
    ccs_nummer <- "#genericSearchMask\\:search_e4ff321960e251186ac57567bec9f4ce\\:cm_exa_eventprocess_basic_data\\:fieldset\\:inputField_2_7cc364bde72c1b1262427dc431caece3\\:id7cc364bde72c1b1262427dc431caece3"
    ccs_nummer <- rmdr$findElement(using = "css selector", ccs_nummer)
    ccs_nummer$clickElement()
    ccs_nummer$sendKeysToElement(list(nummer))

    # Suchen klicken
    tryCatch({
      ccs_such <- "#genericSearchMask\\:buttonsBottom\\:search"
      ccs_such <- rmdr$findElement(using = "css selector", ccs_such)
      rmdr$executeScript("arguments[0].scrollIntoView(true);", list(ccs_such))
      Sys.sleep(3)
      ccs_such$clickElement()
    }, error = function(e) {
      message("Ein Fehler ist aufgetreten: ", e$message)
    })

    # URL klicken
    Sys.sleep(1.5)
    ccs_find <- "#genSearchRes\\:id3f3bd34c5d6b1c79\\:id3f3bd34c5d6b1c79Table\\:0\\:tableRowAction"
    ccs_find <- rmdr$findElement(using = "css selector", ccs_find)
    ccs_find$clickElement()

    # Scrape Daten
    Sys.sleep(1.5)
    semester_element <- rmdr$findElement(using = "css selector", "#detailViewData\\:tabContainer\\:term-selection-container\\:termPeriodDropDownList_label")
    semester <- semester_element$getElementText()
    scraping_datum <- Sys.Date()

    base_inf <- tibble(semester = semester, scraping_datum = scraping_datum)

    termine <- scrape_termine(rmdr, max_attempts = 10)
    Sys.sleep(1.5)
    inhalte <- scrape_inhalte(rmdr, max_attempts = 10)
    Sys.sleep(1.5)
    module <- tibble(module = list(scrape_module(rmdr, max_attempts = 10)))
    studiengaenge <- tibble(studiengaenge = list(scrape_studiengaenge(rmdr, max_attempts = 10)))

    new_row <- bind_cols(purrr::compact(list(base_inf, termine, inhalte, module, studiengaenge)))
    
    # Füge das Ergebnis direkt zum tibble `result_tibble` hinzu
    result_tibble <- bind_rows(result_tibble, new_row)

    # Zurück gehen
    ccs_find <- "#statusLastLink1"
    ccs_find <- rmdr$findElement(using = "css selector", ccs_find)
    ccs_find$clickElement()
  }

  # Nachricht zum Abschluss des Prozesses
  message("Scraping abgeschlossen. Die Daten werden jetzt exportiert.")
  
  # Rückgabe des gesamten tibble
  return(result_tibble)
}
