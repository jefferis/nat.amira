#' Utility functions to locate Amira application
#' @param path The path to the Amira application (defaults to the value of
#'   \code{options('nat.amira.amira'))} or (on MacOS X) tries to find the
#'   application.
#' @export
#' @description \code{amira_app_path} returns the path to the Amira application
#' @examples
#' \donttest{
#' amira_app_path()
#' amira_start_path()
#' amira_version()
#' }
amira_app_path <- function(path = NULL) {
  op = getOption('nat.amira.amira')
  if (is.null(path)) {
    if (is.null(op)) {
      if (ismac()){
        ff = dir("/Applications",
                 pattern = "^Amira-[0-9.]+",
                 full.names = T)
        path <- file.path(rev(ff)[1], 'Amira.app')

      } else if(islinux()){
        ff = dir("/usr/local/Amira",
                 pattern = "[0-9.]+",
                 full.names = TRUE,
                 include.dirs = TRUE
                )
        path <- file.path(rev(ff)[1], 'bin')
      } else {
        stop("I don't know how to start Amira on this platform: ", R.version$os,
             "\nPatches welcome at github.com/jefferis/nat.amira!")
      }

      if (length(path))
        options(nat.amira.amira = path)
      else {
        stop(
          "You must specify path to Amira manually via ",
          "options(nat.amira.amira='/path/to/amira/')"
        )
      }
    } else {
      path <- op
    }
  }
  if (!file.exists(path))
    stop("Amira is not located at: ", path)
  path
}


# alternative way to find path to default version of Amira
# currently unused
default_amira.mac <- function() {
  res <- suppressWarnings(system(
    paste(
      'osascript -e \'tell application "System Events"',
      'to POSIX path of (file of process "Amira" as alias)\''
    ),
    intern = TRUE,
    ignore.stderr = TRUE
  ))
  status <- attr(res, 'status')
  if(length(status) && status>0) NA_character_ else res
}

ismac <- function()
  grepl("darwin", R.version$os, fixed = TRUE)

islinux <- function()
  grepl("linux", R.version$os, fixed = TRUE)

.amira_version <- function(path=getOption('nat.amira.amira')) {
  dir=dirname(amira_app_path(path))
  ver=sub("Amira-", "", basename(dir))
  nver <- numeric_version(ver)
  nver
}

#' @export
#' @rdname amira_app_path
#' @description \code{amira_start_path} returns the current version of Amira
amira_version <- memoise::memoise(.amira_version)

#' @export
#' @rdname amira_app_path
#' @description \code{amira_start_path} returns the path to the Amira startup script
amira_start_path <- function(path=NULL) {
  app <- amira_app_path(path)
  basepath <- dirname(app)
  startpath <- file.path(basepath, 'bin', 'start')
  if(!file.exists(startpath))
    stop(startpath, " executable script does not exist!")
  startpath
}