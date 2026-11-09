# **Cerebellum Mega Analysis**
---
<div align="center"> 

<img src="https://i.pinimg.com/originals/ff/a9/9a/ffa99abb82974dd8e1885edfa94a5bd5.jpg" alt="cerebellum" width="500"/>

</div>

---

## Data Availability

Individual-level participant data are **not** included in this repository and cannot be shared publicly.

The analyses draw on pooled neuroimaging data contributed by the ENIGMA Addiction working group sites. Participant-level records (scan identifiers, demographics, regional volumes, and subject-wise QC tables) are governed by the data sharing agreements and ethics approvals of each contributing site, and are therefore withheld.

What **is** included:

- All analysis code (Jupyter notebooks, R scripts, and cluster/AFNI pipelines)
- Group-level statistical maps and results (e.g. `Statistics/VBM`)
- Aggregate summary tables (sample sizes, demographic summaries, normality and homogeneity tests, PLS latent variable results)
- Figures reported in the manuscript

The scripts expect a `Data/` directory that is not distributed here. Researchers seeking access to the underlying data should contact the ENIGMA Addiction working group and the relevant contributing sites directly.

---

**Important Notes:**
- This repo is still under construction.
- If you wish to reproduce our code,  first make sure to have an [Anaconda](https://www.anaconda.com/) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html) installation on your computer. if you already fulfill this requirement then you are ready to go on. 

---

## Instructions: 

1. Launch a conda or bash terminal

2. Clone this repository and navigate into it:

  ```{shell}
  # clone the repo
  git clone https://github.com/JalilRT/Enigma_Cerebellum
 
  # navigate to the directory
  cd Enigma_Cerebellum
  ```
3. Create the Conda environment:

  ```{shell}
conda create --force -y -v --name enigma_cerebellum --file utils/enigma-cerebellum_env.txt 

4. Activate the Conda environment:
  
  ```{shell}
  conda activate enigma_cerebellum
  ```
5. Launch the Jupyter notebook: \
  *Bear in mind that you will need to authenticate with your google drive credentials at the beginning of the script.* 

  ```{shell}
  jupyter-lab code/Cerebellum_megaanalysis.ipynb 
  ```
  

  
