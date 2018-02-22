#----------------------------------------------------------------------------#

#' @title Calibration by factor
#'
#' @description Plot calibration curve by factor column with risk quantile as x-axis
#'
#' @export
#' @import ggplot2
#' @import dplyr
#' @import gridExtra
#' @import scales
#' @import grid
#' @import data.table
#'
#' @param data data.table object containing data to be plotted. (data table)
#' @param output_file filepath to which we write plot. (character)
#' @param outcome_col_name column name of outcome for which we want the mean (by factor and risk quantile) plotted on y-axis. (character)
#' @param quantile_col_name column name of risk quantile to go on x-axis (could be something like y_hat_percentile). (character)
#' @param cluster_by_col_name column name of grouping for which we want to cluster standard errors (typically something like empi). (character)
#' @param plot_by_col_name column name of factor variable for which we want separate lines. (character)
#' @param xlabel x-axis label. (character)
#' @param ylabel y-axis label. (character)
#' @param legend_label legend title, should describe element passed to 'plot_by_col_name'. (character)
#' @param SE_line whether or not to include standard error band. (boolean)
#' @param SE_style style of standard error band (either 'ribbon' or 'line'). (character)
#' @param color_palette a single string referring to a palette (see http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3 for details), or a
#'                      vector of hex color codes matching the number of levels in plot_by_col_name. (character)
#' @param ymin minimum of y-axis. (numeric)
#' @param make_footnote whether or not to include a footnote on the plot (boolean)
#' @param return_plot whether or not to return created plot (boolean)'
#'
#' @return g optionally returns created plot
#'
#' @examples \dontrun{
#' data <- copy(ehR_cohort)
#' data[, prediction_decile := add_quantile(prediction, 10)]
#' plot_calibration_by_risk_quantile_by_factor(data = data, output_file = 'calibration_by_factor.png', outcome_col_name = 'treatment',
#'                                             quantile_col_name = 'prediction_decile', cluster_by_col_name = 'empi', plot_by_col_name = 'test',
#'                                             xlabel = 'Predicted risk (decile)', ylabel = 'Proportion treated', legend_label = 'Tested')
#' }

# function to create calibration plot - observed by predicted
plot_calibration_by_risk_quantile_by_factor <- function(
	data,
	output_file,
	outcome_col_name,
	quantile_col_name,
	cluster_by_col_name,
	plot_by_col_name,
	xlabel,
	ylabel,
	legend_label,
	color_palette = 'Oranges',
	SE_line = TRUE,
	SE_style = 'ribbon',
	ymin = 0,
	make_footnote = TRUE,
	return_plot = FALSE) {

	# compute means
	data[, mean_obs_outcome := mean(get(outcome_col_name)), by = c(quantile_col_name, plot_by_col_name)]

	# compute CI clustered by 'cluster_by_col_name' by each value of factor
	for (factor_val in unique(data[, get(plot_by_col_name)])) {
		for (quantile in unique(data[, get(quantile_col_name)])) {
	         mean_plus_minus <- clustered_ci(data = data[get(quantile_col_name) == quantile & get(plot_by_col_name) == factor_val, ], obs_col_name = outcome_col_name, cluster_by_col_name = cluster_by_col_name, ci_level = 0.95)
	         data[get(quantile_col_name) == quantile & get(plot_by_col_name) == factor_val, lower_ci := mean_obs_outcome - mean_plus_minus, ]
	         data[get(quantile_col_name) == quantile & get(plot_by_col_name) == factor_val, upper_ci := mean_obs_outcome + mean_plus_minus, ]
		}
	}

	# table for plot
	plot_dt <- unique(data, by = c(quantile_col_name, plot_by_col_name))
	data[, c('mean_obs_outcome', 'prediction_decile', 'lower_ci', 'upper_ci') := NULL]

	# set minimum y based on plot_dt
	ymin <- ifelse(min(plot_dt$lower_ci) < ymin, NA, ymin) # accout for edge case where CI goes below ymin [if not, keep ymin to original value]

	# extract summary stats by each value of 'plot_by_col_name' to create footnote
	plot_by_col_name_val      <- sort(unique(data[, get(plot_by_col_name)]))
	n_obs            <- unlist(lapply(plot_by_col_name_val, function(v){nrow(data[get(plot_by_col_name) == v, ])}))
	n_cluster        <- unlist(lapply(plot_by_col_name_val, function(v){nrow(unique(data[get(plot_by_col_name) == v, ], by = c(cluster_by_col_name)))}))
	plot_by_col_name_val      <- as.character(plot_by_col_name_val)
	footnote <- sprintf('For %s, total records (events) = %d, Total patients = %d', plot_by_col_name_val, n_obs, n_cluster) %>% paste(., collapse = '\n')

	# determine color scale for a) color and b) fill -- use manual values or colorbrewer?
	# TODO: Find good colorbrewer defaults for factors with few levels, then we can feel better about that as an option
	if(length(color_palette) > 1) {
		if (length(color_palette) != length(levels(data[, factor(get(plot_by_col_name))]))) {
			stop(sprintf('if custom color palette is used, it must be the same length as the number of levels in the column \'%s\'', plot_by_col_name))
		}
		color_scale <- scale_color_manual(values = color_palette, name = legend_label)
		fill_scale  <- scale_fill_manual(values = color_palette, guide = FALSE)
	} else {
		color_scale <- scale_color_brewer(palette = color_palette, name = legend_label)
		fill_scale  <- scale_fill_brewer(palette = color_palette, guide = FALSE)
	}

	# need to set number of x-axis breaks if less than 5 to avoid ticks (quantiles)
	# with decimal point (i.e. for quartiles, default x-axis ticks
	# would be 1.0 1.5 2.0 2.5 3.0 3.5 4.0)
	n_breaks <- ifelse(uniqueN(data[, get(quantile_col_name)]) < 5,
											uniqueN(data[, get(quantile_col_name)]), 5)

	# create calibration plot - with LINES for SE
	if(!SE_line | (SE_line & SE_style == 'line')) {
		calibration_plot <- ggplot(data = plot_dt, aes(y = mean_obs_outcome, x = get(quantile_col_name), color = factor(get(plot_by_col_name)))) +
						   geom_point() +
						   geom_line(aes(group = factor(get(plot_by_col_name)))) +
						   color_scale +
						   theme_bw() +
						   theme(legend.position = 'bottom') +
						   xlab(xlabel) +
						   ylab(ylabel) +
	             # determine where the axes begin, make sure y axis is %
	             scale_y_continuous(labels = scales::percent, limits = c(ymin, NA)) +
	             scale_x_continuous(breaks = pretty_breaks(n = n_breaks))

		# add line segments to plot for confidence intervals
		if (SE_line) {
			for (quantile in unique(plot_dt[, get(quantile_col_name)])) {
		        # gather end points of segment
		        ci_hi <- plot_dt[get(quantile_col_name) == quantile, upper_ci, ][1]
		        ci_lo <- plot_dt[get(quantile_col_name) == quantile, lower_ci, ][1]
		        # x position of segment
		        x_ci <- quantile
		        # plot segment
		        calibration_plot <- calibration_plot + geom_segment(x = x_ci, y = ci_lo, xend = x_ci, yend = ci_hi, color = color_palette, linetype = 'dotted', lineend = 'square')
			}
		}
	}

	# create calibration plot - with RIBBON for SE
	if(SE_line == TRUE & SE_style == 'ribbon'){
		calibration_plot <- ggplot(data = plot_dt, aes(
			y = mean_obs_outcome,
			x = get(quantile_col_name),
			color = factor(get(plot_by_col_name)),
			fill = factor(get(plot_by_col_name)))) +
			geom_line(aes(group = factor(get(plot_by_col_name))), linetype = 'dashed') +
		    geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci), color = 'white', alpha = 0.25) +
		    geom_point() +
		    color_scale +
		    fill_scale +
		    xlab(xlabel) +
		    ylab(ylabel) +
		    theme_bw() +
		    theme(legend.position = 'bottom') +
			scale_y_continuous(labels = scales::percent, limits = c(ymin, NA))+
			scale_x_continuous(breaks = pretty_breaks(n = n_breaks))
	}

	# add footnotes if set to TRUE
	if(make_footnote) {
		g <- arrangeGrob(calibration_plot, bottom = textGrob(footnote, x = 0, hjust = -0.1, vjust=0.3, gp = gpar(fontfamily = 'Helvetica', fontsize = 8, col = '#3A3F3F')))
	} else{
		g <- calibration_plot
	}

	# save
	ggsave(output_file, g)
	if(return_plot){
		return(g)
	}
}

#----------------------------------------------------------------------------#
