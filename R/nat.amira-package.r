#' A simple interface beween Amira and the neuronatomy toolbox (nat)
#'
#' The main function is \code{\link{open_amira}} which will open a variety of R
#' objects in the current running version of Amira. This works by writing a file
#' to disk in a suitable AmiraMesh file format and then opening it. The
#' following data types are supported:
#'
#' \itemize{
#'
#' \item points
#'
#' \item neurons (as single objects)
#'
#' \item \code{\link[nat]{neuronlist}} objects containing many neurons
#'
#' \item surface objects
#'
#' }
#'
#' Package options:
#'
#' #' \itemize{
#'
#' \item nat.amira.amira The path to the Amira application (see
#' \code{\link{amira_app_path}} and \code{\link{open_amira}})
#'
#' }
#'
#' @keywords internal
"_PACKAGE"
