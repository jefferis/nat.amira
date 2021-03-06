% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/open.R
\name{open_amira.default}
\alias{open_amira.default}
\alias{open_amira}
\alias{open_amira.neuron}
\alias{open_amira.neuronlist}
\alias{open_amira.matrix}
\alias{open_amira.data.frame}
\alias{open_amira.hxsurf}
\title{Open a file or R object in Amira}
\usage{
\method{open_amira}{default}(x = NULL, ...,
  amira = getOption("nat.amira.amira", "Amira"), Verbose = FALSE)

open_amira(x = NULL, ...)

\method{open_amira}{neuron}(x, ...)

\method{open_amira}{neuronlist}(x, ...)

\method{open_amira}{matrix}(x, ...)

\method{open_amira}{data.frame}(x, ...)

\method{open_amira}{hxsurf}(x, ...)
}
\arguments{
\item{x}{A file or object to open (optional)}

\item{...}{Additional arguments passed to methods}

\item{amira}{Path to desired Amira version (see details)}

\item{Verbose}{Whether or not to show the command line output from
communicating with Amira (default=\code{FALSE}, setting \code{TRUE} may
help to debug connections)}
}
\description{
\code{open_amira.neuronlist} and \code{open_amira.neuron} open
  R \code{\link{neuronlist}} or \code{\link{neuron}} objects.

\code{open_amira.matrix} and \code{open_amira.data.frame} open a
  set of 3D points as Amira landmark

\code{open_amira.hxsurf} opens a 3D surface mesh in Amira
}
\details{
When \code{x} is an R object, then a suitable file is written in a
  temporary location on disk. For \code{\link{neuronlist}} objects, a script
  object will also be generated in Amira that can be used to customise the
  display of the neurons (toggle groups, colour, line width). See
  \code{\link{write_neurons_for_amira}} and eventually
  \code{\link{write.neurons}} for additional arguments you can set here.

  Simply opens Amira if no file is specified. Presently only works on MacOS
  X.

  Uses the package option otions('nat.amira.amira') to specify the path to
  Amira when this is set.
}
\examples{
\dontrun{
## Open Amira
open_amira()

## Load some scripts
open_amira("myscript.scro")
open_amira("mynetwork.hx")

# Load some neurons and make checkboxes to turn on/off and colour by glomerulus
# nb ... is passed to write_neurons_for_amira in this case
open_amira(Cell07PNs, subdir=Glomerulus)
}
}
\seealso{
\code{\link{write_neurons_for_amira}}
}
