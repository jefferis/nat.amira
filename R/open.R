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

tclQuote=function(string) shQuote(string, type='cmd')

#' Open our Amira Stack viewer script to review a set of files
#'
#' @param stackdir Path to the directory containing stacks
#' @param filenames Character vector specifying restricted set of stacks to
#'   view.
#' @export
#' @examples
#' \dontrun{
#' # vfbr library can download registered stacks from VFB
#' library(vfbr)
#' open_stack_viewer(getOption("vfbr.stack.downloads"))
#' }
open_stack_viewer<-function(stackdir, filenames=NULL){
  script=system.file("amira", "StackViewer.hx", package = 'nat.amira')

  keyfile = if(!is.null(filenames)){
    write_keyfile(filenames)
  } else stackdir

  # FIXME what if there is already a StackViewer.hx script?
  objname="StackViewer.hx"
  ll=c(paste("load ", tclQuote(script)),
       paste(objname, " StackDir setFilename", tclQuote(stackdir)),
       paste(objname, " KeyListFile setFilename", tclQuote(keyfile)),
       paste(objname, "fire"))

  opensc<-write_amira_script(ll)
  open_amira(opensc)
  invisible(opensc)
}

write_keyfile<-function(keys, file=tempfile(pattern='keyfile', fileext = '.txt')){
  writeLines(keys, con = file)
  invisible(file)
}


#' Write a simple Amira script
#'
#' @param lines Tcl code (not including Amira's header line)
#' @param file Output file (defaults to a temporary location). Should normally
#'   have suffix \code{'.hx'}.
#'
#' @return The path to the output file (invisibly)
#' @export
#'
#' @examples
#' \donttest{
#' open_amira(opensc<-write_amira_script("echo Hello!"))
#' }
write_amira_script<-function(lines, file=tempfile(fileext = '.hx')){
  cat("# Amira Script\n", file = file)
  cat(lines, sep="\n", file = file, append = TRUE)
  invisible(file)
}
