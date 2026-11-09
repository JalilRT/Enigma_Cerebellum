library(magrittr)
library(dplyr)

setwd("/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info")

args <- commandArgs()
drug <- args[6]

if (drug == "User") {
    data <- read.table("scripts/afni_input_raw.txt",header=T) %>% mutate(Substance = ifelse(Substance == "HC", "HC", "User")) 
} else {
    data <- read.table("scripts/afni_input_raw.txt",header=T) %>% filter(Substance == drug | Substance == "HC")
}

dir.create("enigma/models/temp")
write.table(x = data, file = paste0("enigma/models/temp/",drug,".txt"), sep = " ", row.names=FALSE, quote=FALSE)
