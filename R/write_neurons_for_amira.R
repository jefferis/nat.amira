#' write neurons out in a directory hierarchy suitable for Amira
#'
#' Note that this function only works for neuron (rather than dotprops) objects
#' and is limited to a single level directory hierarchy to organise the neurons.
#'
#' The \code{score} of a neuron was traditionally used to limit which neurons
#' were displayed in Amira by recording a user-defined assessment of how well
#' registered each brain was on a 1 to 5 scale. It may also be used to define a
#' display hierarchy such that no more than n neurons should be displayed.
#' @param nl a neuron list containing traced neurons
#' @param rdir The root directory of the project
#' @param score Default integer score for each neuron, or a function to be
#'   applied to the path of each output neuron file which returns integer
#'   scores. See details.
#' @param ... Additional arguments for write.neurons
#' @seealso \code{\link{write.neurons}}
#' @import nat
#' @importFrom nat.utils abs2rel
#' @export
#' @examples
#' td=tempdir()
#' write_neurons_for_amira(Cell07PNs, td, subdir=Glomerulus)
write_neurons_for_amira<-function(nl, rdir, score=4, ...){
  tryCatch({
    # make rdir
    dir.create(rdir, showWarnings = FALSE, recursive = TRUE)

    # copy scripts to amira directory
    amiradir=system.file("amira", package = 'nat.amira')
    amira_scro=dir(amiradir, pattern = "\\.scro$", full.names = TRUE)
    file.copy(amira_scro, rdir)

    # write neurons
    unlink(file.path(rdir, 'neurons'), recursive=TRUE)
    message("Writing neurons!")
    neuron_files=write.neurons(nl, dir=file.path(rdir, 'neurons'),
                               format='hxlineset', files=paste0(names(nl),'.am'),
                               ...)

    # write list files
    unlink(file.path(rdir, 'lists'), recursive = TRUE)
    dir.create(file.path(rdir, 'lists'))
    message("Writing list files!")
    df=data.frame(file=neuron_files, dir=dirname(neuron_files), stringsAsFactors = F)
    for (d in unique(df$dir)){
      subdir=basename(d)
      listfile=file.path(rdir, "lists", paste0(subdir, '_listfile.txt'))
      neuron_files=df$file[df$dir==d]
      if(is.function(score)) {
        scores=score(neuron_files)
      } else {
        scores=score
      }
      relpaths=file.path("..", abs2rel(neuron_files, stempath = rdir))
      t=paste(relpaths, scores)
      writeLines(t, listfile)
    }
  }, err=function(e) {
    message("Failed to write files! Detailed error:\n")
    e
  })
}
