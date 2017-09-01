#----------------------------------------------------------------------------#

#' Given a list of formulae (as strings), type of regression, and data, 
#' run listed regressions, return formatted results, & optionally  write to f
#' ile. OLS, OLS with clustered SE, logistic regressions currently supported.
#' 
#' Author: Shreyas Lakhtakia (slakhtakia [at] bwh.harvard.edu)
#' 
#' @export
#' @import plm
#' @import data.table
#' @import rowr
#' @param type character string of regression type, one of: "ols", "logistic" [all equations must be for the same class of regression]
#' @param formula_list a list() of character strings specifying regression equations
#' @param data a data.table (or data.frame) containing (among others,) ALL the regression variables specified in all formulae
#' @param output_file the file path (with ".csv" extension) to write the results to, if no value provided, no output file will be created
#' @param title_list optional list of titles for each regression in the list to write atop output file (blank by default)
#' @param ndigit level of precision in output, 5 by default
#' @return matrix containing formatted results from the provided regression list
#' @examples
#' glm_reg_list <- list("died ~ age", "died ~ age + gender", "died ~ age + gender + race")
#' multiformat_regression(type = "logistic", formula_list = reg_list, data = dem)
#' 
#' dem_dia <- merge(x = dem, y = dia, by = "empi", all.y = TRUE)
#' dem_dia[, pt_dia_count := .N, by = "empi"]
#' pt_dem_dia <- unique(dem_dia, by = "empi")
#' lm_reg_list <- list("pt_dia_count ~ age", "pt_dia_count ~ age + gender", "pt_dia_count ~ age + gender + race")
#' multiformat_regression(type = "ols", formula_list = lm_reg_list)

multiformat_regression <- function(type, formula_list, data, output_file = NA,title_list = NA, ndigit = 5, cluster_se_by = NA){
	switch(type,
		ols = {
			############### ORDINARY LEAST SQ REGRESSION ###############
			if(is.na(cluster_se_by)){
				# NOT PANEL DATA / NO CLUSTERING OF STANDARD ERRORS
				regression_list <- lapply(formula_list, function(equation) return(lm(formula(equation), data))) # run all regression
				multiformat_result <- multiformat_lm(lm_list = regression_list, 
								output_file = output_file, 
								formula_list = formula_list, 
								title_list = title_list, 
								ndigit = ndigit) # format
			} else{
				# STANDARD ERRORS CLUSTERED BY `cluster_se_by`
				regression_list <- lapply(formula_list, function(equation) return(plm(formula(equation), data, model = "pooling", index = cluster_se_by)))
				multiformat_result <- multiformat_plm(plm_list = regression_list, 
								output_file = output_file, 
								formula_list = formula_list, 
								title_list = title_list,
								ndigit = ndigit)
			}
		},
		logistic = {
			################### LOGISTIC REGRESSION ################
			if(is.na(cluster_se_by)){
				# NOT PANEL DATA / NO CLUSTERING OF STANDARD ERRORS
				regression_list <- lapply(formula_list, function(equation) return(glm(formula(equation), data, family = binomial()))) # run all regression
				multiformat_result <- multiformat_glm(glm_list = regression_list, 
								output_file = output_file, 
								formula_list = formula_list, 
								title_list = title_list, 
								ndigit = ndigit) # format
			} else{
				# NOT SUPPORTED AT PRESENT
				stop("Clustering of standard errors in logistic regression models is not currently supported.\nConsider contributing to this code; email: slakhtakia@bwh.harvard.edu")
			}
		},
		{
			####### OTHER OPTIONS NOT SUPPORTED CURRENTLY #######
			stop("You seem to have entered an unsupported regression type. Try type = \"ols\" or type = \"logistic\" instead.")
		})
	return(multiformat_result)
}
#----------------------------------------------------------------------------#