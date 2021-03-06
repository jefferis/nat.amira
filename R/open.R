#' Open a file or R object in Amira
#'
#' @details When \code{x} is an R object, then a suitable file is written in a
#'   temporary location on disk. For \code{\link{neuronlist}} objects, a script
#'   object will also be generated in Amira that can be used to customise the
#'   display of the neurons (toggle groups, colour, line width). See
#'   \code{\link{write_neurons_for_amira}} and eventually
#'   \code{\link{write.neurons}} for additional arguments you can set here.
#'
#'   Simply opens Amira if no file is specified. Presently only works on MacOS
#'   X.
#'
#'   Uses the package option otions('nat.amira.amira') to specify the path to
#'   Amira when this is set.
#'
#' @param x A file or object to open (optional)
#' @param amira Path to desired Amira version (see details)
#' @param ... Additional arguments passed to methods
#' @param Verbose Whether or not to show the command line output from
#'   communicating with Amira (default=\code{FALSE}, setting \code{TRUE} may
#'   help to debug connections)
#' @export
#' @rdname open_amira
#' @seealso \code{\link{write_neurons_for_amira}}
#' @examples
#' \dontrun{
#' ## Open Amira
#' open_amira()
#'
#' ## Load some scripts
#' open_amira("myscript.scro")
#' open_amira("mynetwork.hx")
#'
#' # Load some neurons and make checkboxes to turn on/off and colour by glomerulus
#' # nb ... is passed to write_neurons_for_amira in this case
#' open_amira(Cell07PNs, subdir=Glomerulus)
#' }
open_amira.default<-function(x=NULL, ..., amira=getOption('nat.amira.amira', 'Amira'), Verbose=FALSE) {
  if(is.null(x)) x=""
  if(!ismac() && !islinux())
    stop("open_amira is presently only defined on macosx and linux. Patches welcome at ",
         "https://github.com/jefferis/nat.amira")
  # FIXME not sure which is actually the minimum version for change of behaviour
  if(amira_version()<'6.5.0'){
    cmd=paste("open -a", amira, shQuote(x))
    system(cmd)
  } else {
    # NB $HOSTNAME is not the same as $(hostname)
    cmd=sprintf("%s -cmd \"load \\\"%s\\\"\" -port 7175 -host $(hostname)",
                shQuote(amira_start_path()),
                x)
    if(Verbose)
      message(cmd)
    res=system(cmd, ignore.stdout = !Verbose, ignore.stderr = !Verbose)
    if (res > 0)
      stop(
        "Error calling Amira.\n",
        "Amira.app must be running and you must tell it to listen for external\n",
        "commands by executing the following in the Console (once per session):\n",
        '  app -listen'
      )
  }

  x
}

#' @export
#' @rdname open_amira
open_amira<-function(x=NULL, ...) UseMethod("open_amira")

#' @export
#' @rdname open_amira
open_amira.neuron<-function(x, ...) {
  tf=tempfile(pattern='open_amira.neuron', fileext = '.am')
  write.neuron(x, file = tf, format = 'hxlineset')
  open_amira(tf)
}

#' @description \code{open_amira.neuronlist} and \code{open_amira.neuron} open
#'   R \code{\link{neuronlist}} or \code{\link{neuron}} objects.
#' @export
#' @rdname open_amira
open_amira.neuronlist<-function(x, ...){
  td<-tempfile(pattern='open_amira.neuronlist')
  master_script=write_neurons_for_amira(x, td, ...)
  open_amira(master_script)
}

#' @description \code{open_amira.matrix} and \code{open_amira.data.frame} open a
#'   set of 3D points as Amira landmark
#' @export
#' @rdname open_amira
open_amira.matrix<-function(x, ...) {
  xyz=xyzmatrix(x)
  tf=tempfile(pattern='open_amira.matrix', fileext = '.am')
  write.landmarks(xyz, file = tf, format = 'amiralandmarks', ...)
  open_amira(tf)
}

#' @export
#' @rdname open_amira
open_amira.data.frame <- open_amira.matrix

#' @description \code{open_amira.hxsurf} opens a 3D surface mesh in Amira
#' @export
#' @rdname open_amira
open_amira.hxsurf<-function(x, ...) {
  tf=tempfile(pattern='open_amira.matrix', fileext = '.surf')
  write.hxsurf(x, filename = tf)
  open_amira(tf)
}

tclQuote=function(string) shQuote(string, type='cmd')

#' Open our Amira Stack viewer script to review a set of files
#'
#' @param stackdir Path to the directory containing stacks
#' @param filenames Character vector specifying restricted set of stacks to
#'   view.
#' @param template Short name of template brain (to show surface)
#' @export
#' @examples
#' \dontrun{
#' # vfbr library can download registered stacks from VFB
#' library(vfbr)
#' open_stack_viewer(getOption("vfbr.stack.downloads"))
#' }
open_stack_viewer<-function(stackdir=".", filenames=NULL,
                            template=c("JFRC2", "FCWB", "IS2", "T1")){
  script=system.file("amira", "StackViewer.scro", package = 'nat.amira')
  template=match.arg(template)
  stackdir=path.expand(stackdir)

  keyfile = if(!is.null(filenames)){
    write_keyfile(filenames)
  } else stackdir

  # FIXME what if there is already a StackViewer.hx script?
  objname=basename(script)
  ll=c(paste("load ", tclQuote(script)),
       paste(objname, " StackDir setFilename", tclQuote(stackdir)),
       paste(objname, " KeyListFile setFilename", tclQuote(keyfile)),
       paste(objname, " RefBrain setValue", tclQuote(template)),
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
