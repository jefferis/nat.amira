#' Open a file in Amira
#'
#' Simply opens Amira if no file is specified. Presently only works on MacOS X.
#'
#' Uses the package option otions('nat.amira.amira') to specify the path to
#' Amira when this is set.
#'
#' @param x A file to open (optional)
#' @param amira Path to desired Amira version (see details)
#' @export
#' @examples
#' \dontrun{
#' ## Open Amira
#' open_amira()
#'
#' ##
#' open_amira("myscript.scro")
#' open_amira("mynetwork.hx")
#' }
open_amira<-function(x=NULL, amira=getOption('nat.amira.amira', 'Amira')) {
  ismac=grepl("darwin", R.version$os, fixed = TRUE)
  if(ismac) {
    system(paste("open -a", amira, shQuote(x)))
  } else {
    stop("open_amira is presently only defined on macosx. Patches welcome at ",
         "https://github.com/jefferis/nat.amira!")
  }
}
