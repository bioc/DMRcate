\name{DMR.plot}
\alias{DMR.plot}
\alias{plot}
\title{
  Plotting DMRs
}
\description{
  Plots an individual DMR (in context of possibly other DMRs) as found by \code{dmrcate}. 
  Heatmaps are shown as well as proximal coding regions, smoothed group means and chromosome ideogram.
}
\usage{
DMR.plot(ranges, dmr, CpGs, what = c("Beta", "M"), arraytype = c("EPIC", "450K"), 
                    phen.col, genome = c("hg19", "hg38", "mm10"), labels=names(ranges), 
                    group.means=FALSE, extra.ranges=NULL, extra.title=names(extra.ranges))
}
\arguments{
  \item{ranges}{
    A GRanges object (ostensibly created by \code{extractRanges()}) 
    describing DMR coordinates.
  }
  \item{dmr}{
    Index of \code{ranges} (one integer only) indicating which DMR to be
    plotted.
  }
  \item{CpGs}{
    Either:
    
    - A matrix of beta values for plotting, with unique Illumina probe IDs
    as rownames.
    
    - A GenomicRatioSet, annotated with the appropriate array and data types
    
    - A BSseq object containing per-CpG methylation and coverage counts for
    the samples to be plotted
  }
  \item{what}{
    Does \code{CpGs} (if a matrix) contain Beta or M-values? Not needed
    if object is a GenomicRatioSet or BSseq object.
  }
  \item{arraytype}{
    Is \code{CpGs} (if a matrix) sourced from EPIC or 450K data? Not needed
    if object is a GenomicRatioSet or BSseq object.
  }
  \item{phen.col}{
    Vector of colors denoting phenotypes of \emph{all} samples described in
    \code{CpGs}. See vignette for worked example.
  }
  \item{genome}{
    Reference genome for annotating DMRs. Can be one of \code{"hg19"},
    \code{"hg38"} or \code{"mm10"}
  }
  \item{labels}{
    Vector of DMR names to be displayed. Defaults to \code{names(ranges)}.
  }
  \item{group.means}{
    Whether to plot smoothed methylation by individual sample (\code{FALSE}) or by groups defined in \code{phen.col} (\code{TRUE}).
  }
  \item{extra.ranges}{
    Optional GRanges object. Will plot any range overlapping a DMR..
  }
  \item{extra.title}{
    Vector of names for ranges from \code{extra.ranges}. Defaults to \code{names(extra.ranges)}.
  }
}
\value{
  A plot to the current device.
}
\author{
  Tim J. Peters <t.peters@garvan.org.au>, Aaron Statham <a.statham@garvan.org.au>
}
\examples{
library(ExperimentHub)
library(limma)
eh <- ExperimentHub()
FlowSorted.Blood.EPIC <- eh[["EH1136"]]
tcell <- FlowSorted.Blood.EPIC[,colData(FlowSorted.Blood.EPIC)$CD4T==100 |
                                colData(FlowSorted.Blood.EPIC)$CD8T==100]
detP <- minfi::detectionP(tcell)
remove <- apply(detP, 1, function (x) any(x > 0.01))
tcell <- tcell[!remove,]
tcell <- minfi::preprocessFunnorm(tcell)
#Subset to chr2 only
tcell <- tcell[seqnames(tcell) == "chr2",]
tcellms <- minfi::getM(tcell)
tcellms.noSNPs <- rmSNPandCH(tcellms, dist=2, mafcut=0.05)
tcell$Replicate[tcell$Replicate==""] <- tcell$Sample_Name[tcell$Replicate==""]
tcellms.noSNPs <- avearrays(tcellms.noSNPs, tcell$Replicate)
tcell <- tcell[,!duplicated(tcell$Replicate)]
tcell <- tcell[rownames(tcellms.noSNPs),]
colnames(tcellms.noSNPs) <- colnames(tcell)
assays(tcell)[["M"]] <- tcellms.noSNPs
assays(tcell)[["Beta"]] <- minfi::ilogit2(tcellms.noSNPs)
type <- factor(tcell$CellType)
design <- model.matrix(~type) 
myannotation <- cpg.annotate("array", tcell, arraytype = "EPIC",
                             analysis.type="differential", design=design, coef=2)
dmrcoutput <- dmrcate(myannotation, lambda=1000, C=2)
results.ranges <- extractRanges(dmrcoutput, genome = "hg19")
groups <- c(CD8T="magenta", CD4T="forestgreen")
cols <- groups[as.character(type)]
DMR.plot(ranges=results.ranges, dmr=1, CpGs=minfi::getBeta(tcell), what="Beta", 
         arraytype = "EPIC", phen.col=cols, genome="hg19")
}
