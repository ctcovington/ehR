#----------------------------------------------------------------------------#

#' @title Clustered confidence intervals
#'
#' @description Calculate confidence intervals based on standard errors clustered by group. This was done using formula and explanations at
#'              http://www.fao.org/wairdocs/ILRI/x5436E/x5436e07.htm
#'              [NOTE formula SE = m/n*sqrt(1-f)..] in bold in section 5.2.1 has a mistake. The correct version is the one with numbers filled in below it.
#'
#' @export
#' @import data.table
#' 
#' @param data data.table consisting, at minimum, of a column with the identifier
#              to cluster by, and a column containing the samples whose x% CI
#              values are to be returned. Each row must represent a single sample. (data table)
#' @param obs_col_name` name of the column in the data data.table that contains raw sample
#'                     values for which CI is desired (character)
#' @param cluster_by_col_name column name by which to cluster. (character)
#' @param ci_level level of confidence for confidence intervals (provided as a decimal < 1). (numeric)
#'
#' @return value that should be added and subtracted from the raw mean to yield the x% CIs
#' 
#' @examples \dontrun{
#' data <- copy(ehR_cohort)
#' cis <- clustered_ci(data, obs = 'test', cluster_by_col_name = 'empi', ci_level = 0.95)
#' }

clustered_ci <- function(data, obs_col_name, cluster_by_col_name, ci_level = 0.95) {
	if (ci_level <= 0 | ci_level >= 1) {
		stop('please provide a confidence level in the range (0,1)')
	}
	obs_dt <- copy(data[, c(cluster_by_col_name, obs_col_name), with = FALSE]) # data at the sample level -- each row is a sample
	setnames(obs_dt, c(cluster_by_col_name, obs_col_name), c('id', 'obs'))
	obs_dt <- obs_dt[!is.na(obs), ] # remove rows without valid samples

	# populate formula: SE = (m/n)sqrt(W/((m-1)*m))
	m <- n_id  <- nrow(unique(obs_dt, by = 'id')) # number of 'clusters'
	n <- n_obs <- nrow(obs_dt) # number of total observations
	R <- est_mean <- mean(obs_dt[, obs, ]) # 'raw' mean / estimated mean

	# prep data at cluster level
	cluster_dt <- obs_dt
	cluster_dt[, n_obs_from_id := .N, by = 'id'] #X
	cluster_dt[, sum_obs_from_id := sum(obs), by = 'id'] #Y
	cluster_dt[, mean_obs_from_id := mean(obs), by = 'id']
	cluster_dt <- unique(cluster_dt, by = 'id')
	cluster_dt[, Xsq := (n_obs_from_id)^2, ]
	cluster_dt[, Ysq := (sum_obs_from_id)^2, ]
	cluster_dt[, XY := n_obs_from_id*sum_obs_from_id, ]

	# compute 'W', W = (R^2)(sum(X^2)) - 2(R)(sum(XY)) + sum(Y^2)
	sum_Xsq <- sum(cluster_dt[, Xsq, ])
	sum_Ysq <- sum(cluster_dt[, Ysq, ])
	sum_XY  <- sum(cluster_dt[, XY, ])
	W <- (R*R*sum_Xsq) - (2*R*sum_XY) + sum_Ysq

	# compute SE, SE = (m/n)sqrt(W/((m-1)*m))
	SE <- (m/n)*sqrt(W/((m-1)*m))
	multiplier <- qnorm(1-((1-ci_level)/2))

	# CI
	estimate_plus_minus <- multiplier*SE
	return(estimate_plus_minus)
}






