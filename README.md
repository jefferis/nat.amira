[![Travis build status](https://travis-ci.org/jefferis/nat.amira.svg?branch=master)](https://travis-ci.org/jefferis/nat.amira)

# nat.amira
Simple R package for interaction with [Amira](https://www.fei.com/software/amira-for-life-sciences/)
3D visualisation software originally developed by [Zuse Institute Berlin ](http://www.zib.de/software/amira).

The main functionality is to allow neuron and surface objects in R to be opened
in Amira for 3D visualisation and rendering.

## Installation
Currently there isn't a released version on [CRAN](http://cran.r-project.org/), 
but you can use the **devtools** package to install the development version:

```r
if (!require("devtools")) install.packages("devtools")
devtools::install_github("jefferis/nat.amira")
```

Note: Windows users need [Rtools](http://www.murdoch-sutherland.com/Rtools/) and [devtools](http://CRAN.R-project.org/package=devtools) to install this way.
