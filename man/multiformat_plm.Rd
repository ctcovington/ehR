% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multiformat_plm.R
\name{multiformat_plm}
\alias{multiformat_plm}
\title{: Format a given list of plm() regression objects for easy presentation.}
\usage{
multiformat_plm(plm_list, output_file = NA, formula_list = NA,
  title_list = "", ndigit = 5)
}
\arguments{
\item{plm_list}{a list() of plm model objects (list of plm objects)}

\item{output_file}{the file path (with ".csv" extension) to write the results to, if no value provided, no output file will be created (character)}

\item{formula_list}{optional list of custom formulae to provide to print in results (code pulls regression formula call by default) (list of character)}

\item{title_list}{optional list of titles for each regression in the list to write atop output file (blank by default) (list of character)}

\item{ndigit}{level of precision in output, 5 by default (integer)}
}
\value{
matrix containing formatted results from the provided regression list (matrix)
}
\description{
:Given a list of OLS regressions on panel data, *performed using plm()* (in order to obtain clustered SEs), format, return and optionally, write the results side-by-side in a csv.
}
\examples{
\dontrun{
plm_income_age_gender <- plm (monthly_income ~ age , index = "gender", data=dem, model="pooling") 
plm_income_dob_gender <- plm (monthly_income ~ date_of_birth, index = "gender", data=dem, model="pooling") 
plm_list <- list(plm_income_age_gender, plm_income_dob_gender)
multiformat_plm(plm_list = plm_list, output_file = "income_plm_variation.csv")
}
}
