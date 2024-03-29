% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datasets.R
\name{db_dataset_get_keys}
\alias{db_dataset_get_keys}
\title{Get All Time Series Keys in a Given Set}
\usage{
db_dataset_get_keys(con, set_name = "default", schema = "timeseries")
}
\arguments{
\item{con}{RPostgres connection object.}

\item{set_name}{\strong{character} name of a dataset.}

\item{schema}{\strong{character} name of the database schema. Defaults to 'timeseries'}
}
\value{
character A vector of ts keys contained in the set
}
\description{
Get All Time Series Keys in a Given Set
}
\examples{

\dontrun{

db_dataset_get_keys(
  con = connection,
  set_name = "zrh_airport_data",
  set_description = "Zurich airport arrivals and departures ",
  schema = "schema"
)
}
}
\seealso{
Other datasets functions: 
\code{\link{db_dataset_create}()},
\code{\link{db_dataset_delete}()},
\code{\link{db_dataset_get_last_update}()},
\code{\link{db_dataset_list}()},
\code{\link{db_dataset_trim_history}()},
\code{\link{db_dataset_update_metadata}()},
\code{\link{db_ts_assign_dataset}()},
\code{\link{db_ts_get_dataset}()}
}
\concept{datasets functions}
