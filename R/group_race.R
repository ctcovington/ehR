#----------------------------------------------------------------------------#

#' @title: Classify given race as one of the conventional medical groups- white, black, hispanic, other.
#' 
#' @description Convert a column in a data.table containing nuanced, specific races into the aggregated set: {white, black, hispanic, other} that is more commonly found in US medical literature.
#' 
#' @export
#' @import data.table
#' @param race_col data table column name pertaining to race. (object) 
#' @examples
#' dt <- copy(dem)
#' dt[, race := group_race(race)]
#' 
#' dt2 <- copy(dem)
#' dt2[, grouped_race := group_race(race)]

group_race <- function(race_col) {
	# race regular expressions
	black_race_regex    <- "black|african"
	hispanic_race_regex <- "hispanic"
	other_race_regex    <- "asian|native|indian"
	white_race_regex    <- "white|european"

	# create data table of old race and new race vectors
	# NOTE: this is a bit of an awkward way to do it (it'd be easy with a for loop), but I thought data table might be faster
	#       than a for loop for very large data
	dt <- data.table(race = tolower(race_col))
	dt[, race_group := 'none']

	dt[(race %like% black_race_regex & race_group == "none"), race_group := "black"]
	dt[(race %like% hispanic_race_regex & race_group == "none"), race_group := "hispanic"]
	dt[(race %like% other_race_regex & race_group == "none"), race_group := "other"]
	dt[(race %like% white_race_regex & race_group == "none"), race_group := "white"]
	dt[race_group == "none", race_group := "other"]

	return(dt[, race_group])
}
#----------------------------------------------------------------------------#