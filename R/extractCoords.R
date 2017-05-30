<<<<<<< HEAD
#Thank you to Xavier Pastor from Bioconductor mailing list for this patch
extractCoords <- function(xx)
{
    coords <- sapply(xx, strsplit, '[:-]')
    coords <- as.data.frame(do.call(rbind, coords), stringsAsFactors=F)
    colnames(coords) <- c('chrom', 'chromStart', 'chromEnd')
    return(coords)
}
=======

extractCoords <-
  function(coords.M)
  {
    M <- length(coords.M)
    A <- 3 # Should be three components
    split <- "[:-]"
    l <- strsplit(coords.M, split = split)
    stopifnot(all(sapply(l, length) == A))
    X.AM <- matrix(unlist(l), A, M)
    df.MA <- data.frame(t(X.AM), stringsAsFactors = FALSE)
    colnames(df.MA) <- c('chrom', 'chromStart', 'chromEnd')
    df.MA
  }
>>>>>>> master
