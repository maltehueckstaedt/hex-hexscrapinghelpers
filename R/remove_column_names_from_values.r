#' Removes column names from the cells of a DataFrame
#'
#' This function removes the column names from the cell values of the respective column
#' in a DataFrame. It is used as an internal helper function.
#'
#' @param df A DataFrame from which the column names should be removed from the cells.
#'
#' @return A DataFrame with the column names removed from the cells.
#' @importFrom dplyr rename_with mutate cur_column
#' @importFrom stringr str_remove_all fixed

#' @keywords internal
remove_column_names_from_values <- function(df) {
  df %>%
    dplyr::mutate(across(everything(), ~ {
      # Entferne den Spaltennamen aus den Zellen der jeweiligen Spalte
      col_name <- dplyr::cur_column()  # Holt den aktuellen Spaltennamen
      stringr::str_remove_all(., stringr::fixed(col_name))
    }))
}
