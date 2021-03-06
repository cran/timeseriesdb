% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setAttrListWise.R
\name{setAttrListWise}
\alias{setAttrListWise}
\title{Set Attributes to Each Element of List According to a Given Vector}
\usage{
setAttrListWise(li, attrib, vec)
}
\arguments{
\item{li}{a list}

\item{attrib}{character name of the attribute}

\item{vec}{vector containing all instances of the attribute}
}
\description{
An attribute is set to all elements of a list given a vector of possible instances of the
the attribute. Note that this function fails to excecute if the vector is not of the same length
list.
}
