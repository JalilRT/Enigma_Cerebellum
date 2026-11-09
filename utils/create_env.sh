#!/bin/bash
# @Author: Alfonso Fajardo
# Date: 2022-08-29
# Description: This script is intended to crete a conda environment with speficic dependencies to reproduce the code of cerebellum 
# 	megaanalysis. Before running it make sure to have an installation of Anaconda or Miniconda in your system.


### a comand to export the envieronment. DO Uncomment this line. 
# conda list --export -n enigma_cerebellum   > enigma-cerebellum_env.txt

 echo -e "\e[0;35m"

 echo 
 echo " ++ I will create the conda environment for ENIGMA CEREBELLUM project" 
 echo

# If conda exist start environment creation

 if [ -z $(which conda) ] ; then 

 echo -e "\e[0;31m" 
 echo " ++ Error: No conda installation was found. Program exits!! "

	exit 1
 else

	conda create --force -y -n enigma -c conda-forge -c r r-irkernel python=3.12 jupyter jupyterlab notebook pip \
		r-base=4.3 r-tidyverse r-rlang r-pacman r-biocmanager r-rstatix  r-devtools r-viridis r-irkernel r-mice r-lme4 \
                r-ggpubr r-cowplot r-readxl r-ggbeeswarm r-vim r-gtsummary r-ff r-ggthemes r-scales r-vtreat r-sjmisc \
                r-SmartEDA r-boot r-MKinfer r-ggcorrplot r-olsrr r-janitor r-coin r-rcartocolor r-ggdist r-gghalves r-ggnewscale \
                r-patchwork r-lsr r-tidyr r-reshape2 r-broom r-irr r-caret r-tidymodels r-foreach r-doParallel r-sparklyr r-magrittr \
                r-lubridate r-colorspace r-tableone r-ggridges

	echo
	echo " ++ Base environment created "
	echo " ++ Installing additional dependencies"
	echo

	#conda activate enigma
	conda config --set remote_read_timeout_secs 120
	conda config --add channels conda-forge
	conda config --set channel_priority strict

	#conda install -c bioconda bioconductor-summarizedexperiment
	conda run -n enigma pip install --upgrade SUITPy
	#conda install -c r r-irkernel

 fi


echo -e "\e[0m"

exit
