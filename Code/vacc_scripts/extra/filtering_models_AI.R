library(magrittr)
library(dplyr)

setwd("/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info")

args <- commandArgs()
drug <- args[6]

if (drug %in% c("User", "USERS")) {
    data <- read.table(paste0("scripts/afni_input_AI.txt"), header = TRUE) %>%
        mutate(Substance = ifelse(Substance == "HC", "HC", "User"))
} else {
    data <- read.table(paste0("scripts/afni_input_raw.txt"),header=T) %>% 
        filter(Substance == drug | Substance == "HC")
}

dir.create("enigma/models_AI/temp")
write.table(x = data, file = paste0("enigma/models_AI/temp/",drug,".txt"), sep = " ", row.names=FALSE, quote=FALSE)
