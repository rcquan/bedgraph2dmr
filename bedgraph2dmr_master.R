# source("http://bioconductor.org/biocLite.R")
# biocLite("bsseq")
library(bsseq)
library(stringr)

source("R/bedgraph2dmr_helper.R")
## creates "results" directory if it does not exist
dir.create("results")
dir.create("results/tables")
dir.create("results/plots")

## read bedgraph files
BSmooth_obj <- read_bismark()
## apply smoothing algorithm 
BSmooth_obj <- BSmooth(BSmooth_obj, 
                       ns = 20,
                       h = 80,
                       maxGap = 100,
                       mc.cores = 2)
## assign labels
sampleNames <- BSmooth_obj@colData@rownames
normal <- sampleNames[seq(1, length(sampleNames) - 1, 2)]
tumor <- sampleNames[seq(2, length(sampleNames), 2)]

## fisher tests
fTests <- fisherTests(BSmooth_obj, 
                      group1 = normal, 
                      group2 = tumor)
fTests <- fTests$lookup
write.csv(fTests, "results/fTests.csv")

# define groups and set cutoff for coverage
BSmooth_subset <- subset_by_type(BSmooth_obj, 
                                 min_cov = 300)

BSmooth_tstat_obj <- get_tstat(BSmooth_subset, 
                               est_var = "group2") # other options: "same", "paired"

export_tstat_data(BSmooth_tstat_obj)

export_dmr_data(BSmooth_subset, 
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
