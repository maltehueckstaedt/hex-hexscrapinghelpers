% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/click_next_10_pages.r
\name{click_next_10_pages}
\alias{click_next_10_pages}
\title{Click ten pages forward in the result navigation}
\usage{
click_next_10_pages(
  rmdr,
  css_next_10_pages =
    "#genSearchRes\\\\:id3f3bd34c5d6b1c79\\\\:id3f3bd34c5d6b1c79Navi2fastf > span",
  max_attempts = 10
)
}
\arguments{
\item{rmdr}{An `RSelenium` Remote WebDriver object.}

\item{css_next_10_pages}{A character string that specifies the CSS selector of the "Ten pages forward" button.}

\item{max_attempts}{The maximum number of attempts to find and click the button.
Default: `10`.}
}
\value{
No return value. The function navigates within the web application.
}
\description{
This function searches for the "Ten pages forward" button on an overview page
and clicks on it. If the button is not found, it checks for any network issues.
}
\seealso{
\code{\link{check_network_errors}}
}
