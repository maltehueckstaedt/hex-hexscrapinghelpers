#' Check if columns exist in a DataFrame and print colnames with success message
#'
#' This helper function iterates over all column names of a DataFrame and prints a message confirming that each column has been successfully retrieved.
#' The function is intended for internal use only and is not exported.
#'
#' @param df A DataFrame whose column names are to be checked.
#' @return No return value. A message is printed for each column of the DataFrame.
#' @noRd
check_obj_exist <- function(df) {
  # Iteriere ueber die Spaltennamen
  for (col_name in names(df)) {
    cat("\033[33m>>", col_name, "<<\033[0m", "erfolgreich erhoben\n")
  }
}
