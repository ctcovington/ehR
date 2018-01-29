#----------------------------------------------------------------------------#

#' @title Quantile-based discretization of column.
#'
#' @description Discretize column values into equal-sized bins
#'
#' @export
#' @import data.table
#'
#' @param col column of data.table to be discretized
#' @param n_quantile an integer specifying the number of quantiles
#'
#' @return vector of integer indicators of bins
#'
#' @examples \dontrun{
#' dem_dt <- copy(dem)
#' dem_dt[, monthly_income_quartile:=add_quantile(monthly_income, n_quantile=4)]
#'
#' dt <- as.data.table(rep(10, 100))
#' dt[, decile:=add_quantile(V1, n_quantile=10)]
#' }

add_quantile <- function(col, n_quantile) {
  quantile <- tryCatch(
    {
      # try assigning n_pctile
      return(cut(col, quantile(col, probs = (0:n_quantile)/n_quantile),
                                    include.lowest = TRUE, labels = FALSE))
    },
    error = function(error_cond){
      # randomize assignment into n_quantile where breaks are equal
      message("Warning: cannot create unique cuts")
      message("Randomizing assignment to create equal breaks")
      return(cut(rank(col, ties.method = "random"),
                 quantile(rank(col, ties.method = "random"),
                 probs = (0:n_quantile)/n_quantile), include.lowest = TRUE,
                 labels = FALSE))
    }
  )
  # return assigned quantile
  return (quantile)
}

#----------------------------------------------------------------------------#
