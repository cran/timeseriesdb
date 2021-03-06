% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tsSetFunctions.R
\name{overwriteTsSet}
\alias{overwriteTsSet}
\title{Overwrite a Time Series set with a new one}
\usage{
overwriteTsSet(con, set_name, ts_keys, user_name = Sys.info()["user"],
  description = "", active = TRUE, tbl = "timeseries_sets",
  schema = "timeseries")
}
\arguments{
\item{con}{PostgreSQL connection}

\item{set_name}{The name of the set to be overwritten}

\item{ts_keys}{The keys in the new set}

\item{user_name}{The owner of the set to be overwritten}

\item{description}{The description of the new set}

\item{active}{Should the new set be active?}

\item{tbl}{Name of the time series sets table}

\item{schema}{Schema of the time series database to use}
}
\description{
Completely replaces the set set_name of user_name with the new values
(keys, description, active) of the new one.
If the set does not yet exist for the given user it will be created.
}
\author{
Severin Thöni
}
