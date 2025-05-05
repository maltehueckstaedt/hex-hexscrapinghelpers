#' Load Course Data
#'
#' This function loads all RDS files that match the pattern "course_data*.rds" from the specified directory.
#' It reads each RDS file and combines them into a single data frame.
#'
#' @param path A character string specifying the directory path where the RDS files are located. Default is the current directory.
#' @return A data frame containing the combined data from all matching RDS files.
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
#' @export
#'
#' @examples
#' \dontrun{
#'   all_data <- load_course_data( "C:/Users/mhu/Documents/gitlab/hex-hexscrapinghelpers")
#'   head(all_data)
#' }
load_course_data <- function(path = ".") {
  list.files(path, pattern = "^course_data.*\\.RDS$", full.names = TRUE, ignore.case = TRUE) %>%
    map(readRDS) %>%
    bind_rows()
}