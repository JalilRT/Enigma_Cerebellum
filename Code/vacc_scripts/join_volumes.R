library(tidyverse)
drugs=list.dirs(paste0(getwd(),"/enigma/freesurfer"),recursive=F) %>% basename()

lh.DKTatlas <- drugs %>% map(~ list.files(paste0(getwd(),"/enigma/freesurfer/", .x),pattern="lh.aparc.volume",recursive=F,full.names=T)) %>% map(~ read_table(.x)) %>% reduce(rbind) %>% as_tibble()
rh.DKTatlas <- drugs %>% map(~ list.files(paste0(getwd(),"/enigma/freesurfer/", .x),pattern="rh.aparc.volume",recursive=F,full.names=T)) %>% map(~ read_table(.x)) %>% reduce(rbind) %>% as_tibble()

volumes <- read_table(paste0(getwd(),"/scripts/afni_input.txt"))

lh.volumes.DKTatlas <- volumes %>% left_join(lh.DKTatlas, by=c("Subj"="lh.aparc.volume"))
rh.volumes.DKTatlas <- volumes %>% left_join(rh.DKTatlas, by=c("Subj"="rh.aparc.volume"))

write_csv(lh.volumes.DKTatlas,"enigma/freesurfer/lh_volumes_DKTatlas.csv")
write_csv(rh.volumes.DKTatlas,"enigma/freesurfer/rh_volumes_DKTatlas.csv")

na.lh <- lh.volumes.DKTatlas %>% filter(if_any(everything(), is.na))
na.lh$Substance %>% as_factor() %>% levels() %>% map(~ na.lh %>% filter(Substance == .x) %>% select(Subj) %>% write.table(paste0(.x,"_runFS.txt"),col.names=F,row.names=F,quote=F))
