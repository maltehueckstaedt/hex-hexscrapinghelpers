#' Select semester and set courses
#'
#' This function navigates to a specified URL, selects a semester from a dropdown menu, and sets the number of courses displayed on the page. It adjusts the input field for the number of courses.
#'
#' @param rmdr An Rmdr object representing the Selenium WebDriver.
#' @param base_url The base URL to navigate to.
#' @param num_sem_selector The CSS selector for the semester to be selected.
#' @param num_courses The number of courses to be displayed on the page.
#' @param css_sem_dropdown The CSS selector for the dropdown menu to select the semester.
#' @param css_search_field The CSS selector for the "search terms" field.
#' @param num_courses_selector The CSS selector for the input field where the number of courses will be set.
#'
#' @return No return value. The function performs actions on the webpage.
#' @importFrom crayon red blue yellow
#' @export
select_semester_and_set_courses <- function(rmdr,
                                            base_url,
                                            num_sem_selector,
                                            num_courses,
                                            css_sem_dropdown,
                                            css_search_field,
                                            num_courses_selector) {

  rmdr$navigate(base_url)

  # Finde Dropdown-Menue fuer Semesterauswahl
  sem_drop <- rmdr$findElement(using = "css selector", css_sem_dropdown)
  sem_drop$clickElement()

  # Waehle das Semester basierend auf der uebergebenen Zahl
  num_sem_selector <- paste0(substr(css_sem_dropdown, 1, nchar(css_sem_dropdown) - 6), "_", num_sem_selector)
  sem <- rmdr$findElement(using = "css selector", num_sem_selector)
  sem$clickElement()

  # Finde das Feld "Suchbegriffe"
  suchbegriffe <- rmdr$findElement(using = "css selector", css_search_field)

  # Klicke in das Feld "Suchbegriffe" und press Enter
  suchbegriffe$clickElement()
  suchbegriffe$sendKeysToElement(list(key = "enter"))

  rmdr$executeScript("window.scrollTo(0, 0);")

  # Finde das Eingabefeld fuer die Seitenanzahl
  input_field <- rmdr$findElement(using = "css selector", num_courses_selector)

  # Loesche vorherigen Wert und setze neuen Wert
  input_field$sendKeysToElement(list(key = "control", "a", key = "backspace"))
  input_field$sendKeysToElement(list(num_courses, key = "enter"))
}