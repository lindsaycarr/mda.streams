% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/locate_ts.R
\name{locate_ts}
\alias{locate_ts}
\title{Find a timeseries item on ScienceBase}
\usage{
locate_ts(var_src = "doobs_nwis", site_name = "nwis_02322688",
  format = c("id", "url"), by = c("tag", "dir", "either"), limit = 5000,
  browser = (format == "url"))
}
\arguments{
\item{var_src}{the variable name, e.g., "doobs_nwis", for which you want the 
timeseries}

\item{site_name}{the site ID, e.g. "nwis_02322688", whose folder you want to
look in}

\item{format}{character indicating whether the folder should be returned as 
an ID or as a full URL}

\item{by}{character indicating how to search for the item: using tags ("tag",
the default and recommended option), by scanning the parent directory for 
the desired title ("dir"), or both in combination ("either")?}

\item{limit}{number of items to return, as in 
\code{\link[sbtools]{query_item_identifier}} or 
\code{\link[sbtools]{item_list_children}}}

\item{browser}{logical. Should the URL be opened in a browser?}
}
\description{
Find a timeseries item on ScienceBase
}
\examples{
\dontrun{
locate_ts(c("doobs","wtr","disch"), "nwis_02322688")
locate_ts("doobs", "nwis_02322688", format="url")
locate_ts("doobs", "nwis_notasite", format="url")
testthat::expect_error(locate_ts("notavar", "nwis_notasite"))
}
}

