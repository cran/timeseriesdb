% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calendar.R
\name{db_dataset_get_release}
\alias{db_dataset_get_release}
\title{Get the latest Release for Given Datasets}
\usage{
db_dataset_get_release(
  con,
  set_ids,
  target_year = year(Sys.Date()),
  target_period = month(Sys.Date()),
  schema = "timeseries"
)
}
\arguments{
\item{con}{RPostgres connection object.}

\item{set_ids}{Sets to get release dates for}

\item{target_year}{Year of the desired release}

\item{target_period}{Period of the desired release}

\item{schema}{\strong{character} name of the database schema. Defaults to 'timeseries'}
}
\value{
data.frame with columns `set_id`, `release_id`, `release_date`
}
\description{
Get the latest Release for Given Datasets
}
\seealso{
Other calendar functions: 
\code{\link{db_dataset_get_latest_release}()},
\code{\link{db_dataset_get_next_release}()},
\code{\link{db_release_cancel}()},
\code{\link{db_release_create}()},
\code{\link{db_release_list}()},
\code{\link{db_release_update}()}
}
\concept{calendar functions}
