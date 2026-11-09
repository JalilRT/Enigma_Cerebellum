library(magrittr)
library(dplyr)

setwd("/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info")

args <- commandArgs()
drug <- args[6]

if (drug %in% c("User", "USERS")) {
    data <- read.table(paste0("scripts/match_id/",drug,"/afni_input_harmonized.txt"), header = TRUE) %>%
        mutate(Substance = ifelse(Substance == "HC", "HC", "User"))
    data_user <- data %>% filter(Substance == "User") %>% select(InputFile)
    data_hc <- data %>% filter(Substance == "HC") %>% select(InputFile)
} else {
    data <- read.table(paste0("scripts/match_id/",drug,"/afni_input_harmonized.txt"),header=T) %>% 
        filter(Substance == drug | Substance == "HC")
    data_hc <- data %>% filter(Substance == "HC") %>% select(InputFile)
    data_drug <- data %>% filter(Substance == drug) %>% select(InputFile)
}

dir.create(paste0("enigma/models_matchid/temp/",drug), showWarnings = FALSE)
write.table(x = data, file = paste0("enigma/models_matchid/temp/",drug,".txt"), sep = " ", row.names=FALSE, quote=FALSE)
if (drug %in% c("User", "USERS")) {
    write.table(x = data_user, file = paste0("enigma/models_matchid/temp/",drug,"/drug.txt"), sep = " ", row.names=FALSE, col.names=FALSE, quote=FALSE)
    write.table(x = data_hc, file = paste0("enigma/models_matchid/temp/",drug,"/hc.txt"), sep = " ", row.names=FALSE, col.names=FALSE, quote=FALSE)
} else {
    write.table(x = data_drug, file = paste0("enigma/models_matchid/temp/",drug,"/drug.txt"), sep = " ", row.names=FALSE, col.names=FALSE, quote=FALSE)
    write.table(x = data_hc, file = paste0("enigma/models_matchid/temp/",drug,"/hc.txt"), sep = " ", row.names=FALSE, col.names=FALSE, quote=FALSE)
}
