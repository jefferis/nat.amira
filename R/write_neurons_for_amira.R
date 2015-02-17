#' write neurons out in a directory hierarchy suitable for Amira
#' @param nl a neuron list containing projection neurons
#' @param rdir The root directory of the project
#' @import nat
write_neurons_for_amira<-function(nl, rdir){
  tryCatch({
    projectdir=dirname(rdir)
    amiradir=file.path(projectdir, 'amira')
    message(amiradir)

    # write files
    unlink(file.path(amiradir, 'WarpTransformed'), recursive=TRUE)
    message("Writing neurons!")
    gloms=sub("+", "p", with(nl, Glomerulus), fixed=T)
    write.neurons(nl, dir=file.path(amiradir, 'WarpTransformed'), format='hxlineset',
                  subdir=gloms, files=paste0(names(nl),'.am'))

    # write list files
    files=with(nl, by(names(nl), gloms, paste0, '.am') )
    unlink(file.path(amiradir, 'lists'), recursive=TRUE)
    dir.create(file.path(amiradir, 'lists'))
    message("Writing list files!")
    for (g in names(files)){
      f=file.path(amiradir, "lists", paste0(g, '_listfile.txt'))
      t=paste(file.path("../WarpTransformed", g, files[[g]]),4)
      writeLines(t, f)
    }
  }, err=function(e) {
    message("Failed to write files! Detailed error:\n")
    e
  })
}
