% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{index_to_date}
\alias{index_to_date}
\title{Helper Function for Date Operations}
\usage{
index_to_date(x, as.string = FALSE)
}
\arguments{
\item{x}{numeric A vector of time series time indices (e.g. from stats::time)}

\item{as.string}{logical If as.string is TRUE the string representation of the
Date is returned, otherwise a Date object.}
}
\description{
This function is not exported.
Helper function to convert time series indices of the form 2005.75
to a date representation like 2005-07-01.
Does not currently support sub-monthly frequencies.
}
\examples{
\dontrun{index_to_date(2020.25)}
}
