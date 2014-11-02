# source("http://bioconductor.org/biocLite.R")
# biocLite("bsseq")
library(bsseq)
library(stringr)
library(magrittr)

source("R/bedgraph2dmr_helper.R")
# creates "results" directory if it does not exist
dir.create("results")
dir.create("results/tables")
dir.create("results/plots")

run_program <- function(){
    BSmooth_obj <- read_bismark() %>%
        # apply smoothing algorithm - ?BSmooth for details
        BSmooth(ns = 20,
                h = 80,
                maxGap = 100,
                mc.cores = 2) %>%
        # define groups and set cutoff for coverage
        subset_by_type(min_cov = 300)
    
    ##### fix to pause for input
    
    BSmooth_tstat_obj <- get_tstat(BSmooth_obj, 
                                   est_var = "group2") # other options: "same", "paired"
    
    export_tstat_data(BSmooth_tstat_obj)
    export_dmr_data(BSmooth_obj, 
                    BSmooth_tstat_obj,
                    # settings for dmrFinder
                    FDR = 0.05, 
                    max_gap = 100,
                    # subsetting DMR results
                    cg_num = 1,
                    mean_diff = 0.1,
                    # settings for plots
                    batch_num = c(1,2),
                    min_cov = 300)
}

run_program()
