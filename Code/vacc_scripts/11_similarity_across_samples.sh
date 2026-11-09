#!/bin/bash
#SBATCH --job-name=sim_maps
#SBATCH --time=06:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --error=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/sim_maps.%J.err
#SBATCH --output=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info/logs/sim_maps.%J.out

#################################
## 2026-07-01
## Created by JalilRT
##
## Cross-strategy similarity analysis for VBM maps.
## Compares cluster-corrected significant maps and continuous effect-size maps
## across four sample strategies:
##
##   1. Full sample          (models/)
##   2. Matched sample       (models_matchid/)
##   3. Complete cases  (CC) (models_CC/)
##   4. Alt. imputation (AI) (models_AI/)
##
## AFNI tools used
## ───────────────
##  3dbucket          extract a single brick from a multi-brick volume
##  3dcalc            arithmetic / thresholding on volumes
##  3dBrickStat       count non-zero voxels in a volume
##  3dTcat            concatenate volumes along the time/sub-brick axis
##  3dTstat           voxelwise statistics across a 4D stack
##                    (-cvar, -mean, -stdev)
##  3dROIstats        extract mean statistics within a mask
##  3ddot             dot-product-based similarity metrics:
##                      -docoef  → Pearson r   (continuous maps)
##                      -dodice  → Dice coeff  (binary masks)
##                      -doeta2  → η² overlap  (effect-size maps)
##  @chauffeur_afni   montage visualisation of conjunction maps
##  ccalc             t-to-p conversion via critical t-value threshold
##
## Outputs (per group) in:
##   $outdir/<GROUP>/
##     tstat_<strat>.nii.gz               t-stat brick 5 (full brain, all voxels)
##     mask_<strat>.nii.gz                binary significant mask (from Cohen's d, cluster-corrected)
##     tstat_p05_mask_<strat>.nii.gz      binary mask of t-values at p<0.05 uncorrected (for flatmaps)
##     intersect_X_Y.nii.gz               intersection of two masks
##     union_X_Y.nii.gz                   union of two masks
##     conjunction_all4.nii.gz            significant in ALL 4 strategies (cluster-corrected)
##     conjunction_all4_p05.nii.gz        significant in ALL 4 strategies (uncorrected p<0.05)
##     conjunction_all4_cohen_d           full-sample d restricted to conjunction (cluster-corrected)
##     effectsize_4strat.nii.gz           4-brick stack of effect-size maps
##     mean_effectsize.nii.gz             mean Cohen's d across strategies
##     stdev_effectsize.nii.gz            stdev Cohen's d across strategies
##     cov_effectsize.nii.gz              CoV of Cohen's d across strategies
##     conj_view/                         montage images of conjunction map
##     similarity_<GROUP>.txt             per-group detailed log
##   $outdir/similarity_summary.txt       machine-readable table of all metrics
#################################

module load afni-full

path=/gpfs2/scratch/jrasgado/ENIGMA_Data_Transfer/Analysis_MRI_info
outdir=${path}/enigma/similarity_analysis
mkdir -p ${outdir}
mkdir -p ${path}/logs

# ── Critical t-value for p < 0.05 (uncorrected, two-tailed) ────────────────
# For df > 30, t_crit ≈ 1.96. For df ≈ 100+, t_crit ≈ 1.96 (approaches normal)
# EDIT THIS LINE if you know the exact df from your 3dLMEr model
# Formula: compute via t.crit(α=0.05, df=your_df, two.tailed=TRUE) in R
# Common values: df=50 → t≈2.01, df=100 → t≈1.98, df=150 → t≈1.975
t_crit=1.96

# ── Strategy root directories ─────────────────────────────────────────────────
dir_full=${path}/enigma/models
dir_match=${path}/enigma/models_matchid
dir_CC=${path}/enigma/models_CC
dir_AI=${path}/enigma/models_AI

# ── Cerebellar reference image for visualisation ──────────────────────────────
mask=${path}/scripts/SUIT.nii

# ── Initialise summary table ──────────────────────────────────────────────────
summary_file=${outdir}/similarity_summary.txt
echo "group metric strategy_pair value" > ${summary_file}

###############################################################################
# GROUP LOOP
###############################################################################
for group in USERS ALC ATS CANN COC NIC; do

    if [ "$group" == "USERS" ]; then
        label="User"
    else
        label="${group}"
    fi

    gdir=${outdir}/${group}
    mkdir -p ${gdir}

    log=${gdir}/similarity_${group}.txt
    echo "================================================================" > ${log}
    echo "  Cross-strategy VBM similarity — group: ${group}  (${label})" >> ${log}
    echo "  Date : $(date)" >> ${log}
    echo "================================================================" >> ${log}

    # ── File paths ────────────────────────────────────────────────────────────
    #   effect-size maps  → non-zero voxels = cluster-corrected significant
    #   Model files       → brick 5 = GLT t-statistic (all voxels)

    map_full=${dir_full}/${group}/uncorrected_05/${group}_HC/${group}_effect_size.nii.gz
    map_match=${dir_match}/${group}/uncorrected_05/${group}_HC/${group}_effect_size.nii.gz
    map_CC=${dir_CC}/${group}/uncorrected_05/${group}_HC/${group}_effect_size.nii.gz
    map_AI=${dir_AI}/${group}/uncorrected_05/${group}_HC/${group}_effect_size.nii.gz

    model_full=${dir_full}/${group}/Model_${group}.nii.gz
    model_match=${dir_match}/${group}/Model_${group}.nii.gz
    model_CC=${dir_CC}/${group}/Model_${group}.nii.gz
    model_AI=${dir_AI}/${group}/Model_${group}.nii.gz

    # ── Check all required files ──────────────────────────────────────────────
    missing=0
    for f in "$map_full"  "$map_match"  "$map_CC"  "$map_AI" \
              "$model_full" "$model_match" "$model_CC" "$model_AI"; do
        if [ ! -f "$f" ]; then
            echo "  [WARNING] Missing: $f" >> ${log}
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        echo "  Skipping ${group} — one or more required files not found." >> ${log}
        continue
    fi

    ###########################################################################
    # STEP 1 — Extract the GLT t-statistic (brick 5) from 3dLMEr outputs
    #          Brick index 5 corresponds to the contrast:
    #          ${label}_HC 'Substance : 1*${label} -1*HC'
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 1: Extracting t-statistic maps (brick 5 of 3dLMEr) ──────────" >> ${log}

    for strat in full match CC AI; do
        out=${gdir}/tstat_${strat}.nii.gz
        if [ ! -f ${out} ]; then
            eval src=\${model_${strat}}
            3dbucket -prefix ${out} "${src}[5]" 2>> ${log} \
                && echo "  tstat_${strat}.nii.gz created." >> ${log} \
                || echo "  [ERROR] 3dbucket failed for ${strat}." >> ${log}
        else
            echo "  tstat_${strat}.nii.gz already exists." >> ${log}
        fi
    done

    ###########################################################################
    # STEP 2 — Binary significance masks (cluster-corrected)
    #          Non-zero voxels in the effect-size map = cluster-corrected sig.
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 2: Binary significance masks from effect-size maps (cluster-corrected) ──" >> ${log}

    for strat in full match CC AI; do
        out=${gdir}/mask_${strat}.nii.gz
        if [ ! -f ${out} ]; then
            eval src=\${map_${strat}}
            3dcalc -a "${src}" -expr 'step(abs(a))' \
                -prefix ${out} 2>> ${log} \
                && echo "  mask_${strat}.nii.gz created." >> ${log} \
                || echo "  [ERROR] 3dcalc failed for mask_${strat}." >> ${log}
        fi
    done

    # Count significant voxels per strategy (cluster-corrected)
    for strat in full match CC AI; do
        n=$(3dBrickStat -count -non-zero ${gdir}/mask_${strat}.nii.gz 2>/dev/null)
        echo "  n_sig_clustcorr (${strat}) = ${n}" >> ${log}
        echo "${group} n_sig_clustcorr ${strat} ${n}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 2.5 — Binary masks from t-value thresholding (uncorrected p<0.05)
    #            Useful for flatmap visualization showing more liberal threshold
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 2.5: Binary masks from t-values at p<0.05 uncorrected (flatmap) ──" >> ${log}
    echo "   Critical t-value: t_crit = ${t_crit}" >> ${log}

    for strat in full match CC AI; do
        out=${gdir}/tstat_p05_mask_${strat}.nii.gz
        if [ ! -f ${out} ]; then
            3dcalc -a ${gdir}/tstat_${strat}.nii.gz \
                -expr "step(abs(a)-${t_crit})" \
                -prefix ${out} 2>> ${log} \
                && echo "  tstat_p05_mask_${strat}.nii.gz created (|t| > ${t_crit})." >> ${log} \
                || echo "  [ERROR] 3dcalc failed for tstat_p05_mask_${strat}." >> ${log}
        fi
    done

    # Count voxels at uncorrected p<0.05 threshold
    for strat in full match CC AI; do
        n=$(3dBrickStat -count -non-zero ${gdir}/tstat_p05_mask_${strat}.nii.gz 2>/dev/null)
        echo "  n_sig_uncorr_p05 (${strat}) = ${n}" >> ${log}
        echo "${group} n_sig_uncorr_p05 ${strat} ${n}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 3 — Pearson r between continuous t-statistic maps
    #          3ddot -docoef uses all voxels within an automask
    #          (i.e. the full cerebellar image) — not restricted to sig voxels
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 3: Pearson r of continuous t-statistic maps ─────────────────" >> ${log}
    echo "   (3ddot -docoef; full-brain, all voxels within auto-mask)" >> ${log}

    for pair in "full_match" "full_CC" "full_AI" "match_CC" "match_AI" "CC_AI"; do
        s1=$(echo $pair | cut -d_ -f1)
        s2=$(echo $pair | cut -d_ -f2)
        r=$(3ddot -docoef -automask \
            ${gdir}/tstat_${s1}.nii.gz \
            ${gdir}/tstat_${s2}.nii.gz 2>/dev/null)
        echo "  r_tstat(${s1}, ${s2}) = ${r}" >> ${log}
        echo "${group} pearsonr_tstat ${s1}_vs_${s2} ${r}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 4 — Dice coefficient between binary significance masks
    #          3ddot -dodice = 2*|A∩B| / (|A|+|B|)
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 4: Dice coefficient of significant-voxel masks ─────────────" >> ${log}

    for pair in "full_match" "full_CC" "full_AI" "match_CC" "match_AI" "CC_AI"; do
        s1=$(echo $pair | cut -d_ -f1)
        s2=$(echo $pair | cut -d_ -f2)
        dice=$(3ddot -dodice \
            ${gdir}/mask_${s1}.nii.gz \
            ${gdir}/mask_${s2}.nii.gz 2>/dev/null)
        echo "  Dice(${s1}, ${s2}) = ${dice}" >> ${log}
        echo "${group} dice ${s1}_vs_${s2} ${dice}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 5 — Jaccard index (manual)
    #          J = |A∩B| / |A∪B|
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 5: Jaccard index of significant-voxel masks ─────────────────" >> ${log}

    for pair in "full_match" "full_CC" "full_AI" "match_CC" "match_AI" "CC_AI"; do
        s1=$(echo $pair | cut -d_ -f1)
        s2=$(echo $pair | cut -d_ -f2)

        inter=${gdir}/intersect_${s1}_${s2}.nii.gz
        union=${gdir}/union_${s1}_${s2}.nii.gz

        # Intersection
        3dcalc -a ${gdir}/mask_${s1}.nii.gz \
               -b ${gdir}/mask_${s2}.nii.gz \
               -expr 'a*b' \
               -prefix ${inter} -overwrite 2>> ${log}

        # Union
        3dcalc -a ${gdir}/mask_${s1}.nii.gz \
               -b ${gdir}/mask_${s2}.nii.gz \
               -expr 'step(a+b)' \
               -prefix ${union} -overwrite 2>> ${log}

        n_inter=$(3dBrickStat -count -non-zero ${inter} 2>/dev/null)
        n_union=$(3dBrickStat -count -non-zero ${union} 2>/dev/null)

        if [ -n "${n_union}" ] && [ "${n_union}" -gt 0 ] 2>/dev/null; then
            jaccard=$(echo "scale=6; ${n_inter} / ${n_union}" | bc)
        else
            jaccard=0
        fi

        echo "  Jaccard(${s1}, ${s2}) = ${jaccard}  [∩=${n_inter}, ∪=${n_union}]" >> ${log}
        echo "${group} jaccard ${s1}_vs_${s2} ${jaccard}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 6 — η² similarity (normalised dot product) of effect-size maps
    #          3ddot -doeta2 is insensitive to sign and reflects spatial
    #          colocalisation of large effects
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 6: η² (eta-squared) of effect-size maps ────────────────────" >> ${log}

    for pair in "full_match" "full_CC" "full_AI" "match_CC" "match_AI" "CC_AI"; do
        s1=$(echo $pair | cut -d_ -f1)
        s2=$(echo $pair | cut -d_ -f2)
        eval m1=\${map_${s1}}
        eval m2=\${map_${s2}}
        eta2=$(3ddot -doeta2 "${m1}" "${m2}" 2>/dev/null)
        echo "  η²(${s1}, ${s2}) = ${eta2}" >> ${log}
        echo "${group} eta2 ${s1}_vs_${s2} ${eta2}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 7 — Conjunction analysis: voxels significant in ALL 4 strategies
    #          (CLUSTER-CORRECTED using effect-size masks)
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 7: Conjunction map (cluster-corrected) — all 4 strategies ───" >> ${log}

    conj_all4=${gdir}/conjunction_all4.nii.gz
    conj_d=${gdir}/conjunction_all4_cohen_d.nii.gz

    # Conjunction: product of the 4 binary masks (cluster-corrected)
    if [ ! -f ${conj_all4} ]; then
        3dcalc \
            -a ${gdir}/mask_full.nii.gz \
            -b ${gdir}/mask_match.nii.gz \
            -c ${gdir}/mask_CC.nii.gz \
            -d ${gdir}/mask_AI.nii.gz \
            -expr 'a*b*c*d' \
            -prefix ${conj_all4} 2>> ${log} \
            && echo "  conjunction_all4.nii.gz created." >> ${log} \
            || echo "  [ERROR] 3dcalc for conjunction failed." >> ${log}
    fi

    # Partial conjunctions (at least 3 of 4)
    conj_3of4=${gdir}/conjunction_3of4.nii.gz
    if [ ! -f ${conj_3of4} ]; then
        3dcalc \
            -a ${gdir}/mask_full.nii.gz \
            -b ${gdir}/mask_match.nii.gz \
            -c ${gdir}/mask_CC.nii.gz \
            -d ${gdir}/mask_AI.nii.gz \
            -expr 'step(a+b+c+d-2)' \
            -prefix ${conj_3of4} 2>> ${log}
    fi

    # Conjunction restricted to full-sample Cohen's d (for visualisation)
    if [ ! -f ${conj_d} ]; then
        3dcalc -a ${map_full} -b ${conj_all4} \
            -expr 'a*b' \
            -prefix ${conj_d} 2>> ${log}
    fi

    n_conj=$(3dBrickStat -count -non-zero ${conj_all4} 2>/dev/null)
    n_3of4=$(3dBrickStat -count -non-zero ${conj_3of4} 2>/dev/null)
    echo "  n_sig conjunction_clustcorr (all 4)    = ${n_conj}" >> ${log}
    echo "  n_sig conjunction_clustcorr (≥3 of 4)  = ${n_3of4}" >> ${log}
    echo "${group} n_sig conjunction_all4_clustcorr ${n_conj}" >> ${summary_file}
    echo "${group} n_sig conjunction_3of4_clustcorr ${n_3of4}" >> ${summary_file}

    ###########################################################################
    # STEP 7.5 — Conjunction analysis (UNCORRECTED p<0.05 t-value threshold)
    #            For flatmap visualization with more liberal threshold
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 7.5: Conjunction map (uncorrected p<0.05) — all 4 strategies ─" >> ${log}

    conj_all4_p05=${gdir}/conjunction_all4_p05.nii.gz

    if [ ! -f ${conj_all4_p05} ]; then
        3dcalc \
            -a ${gdir}/tstat_p05_mask_full.nii.gz \
            -b ${gdir}/tstat_p05_mask_match.nii.gz \
            -c ${gdir}/tstat_p05_mask_CC.nii.gz \
            -d ${gdir}/tstat_p05_mask_AI.nii.gz \
            -expr 'a*b*c*d' \
            -prefix ${conj_all4_p05} 2>> ${log} \
            && echo "  conjunction_all4_p05.nii.gz created." >> ${log} \
            || echo "  [ERROR] 3dcalc for conjunction_p05 failed." >> ${log}
    fi

    n_conj_p05=$(3dBrickStat -count -non-zero ${conj_all4_p05} 2>/dev/null)
    echo "  n_sig conjunction_p05_uncorr (all 4)   = ${n_conj_p05}" >> ${log}
    echo "${group} n_sig conjunction_all4_p05_uncorr ${n_conj_p05}" >> ${summary_file}

    ###########################################################################
    # STEP 7.7 — Conjunction-masked t-value maps
    #            Show t-statistics restricted to conjunction_all4_p05 voxels
    #            Useful for: detailed examination of which regions drive the conjunction
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 7.7: Conjunction-masked t-value maps (for visualization) ────" >> ${log}

    for strat in full match CC AI; do
        out=${gdir}/tstat_conj_p05_${strat}.nii.gz
        if [ ! -f ${out} ]; then
            3dcalc -a ${gdir}/tstat_${strat}.nii.gz \
                   -b ${conj_all4_p05} \
                   -expr 'a*b' \
                   -prefix ${out} 2>> ${log} \
                && echo "  tstat_conj_p05_${strat}.nii.gz created (t-values at conjunction voxels)." >> ${log} \
                || echo "  [ERROR] 3dcalc failed for tstat_conj_p05_${strat}." >> ${log}
        fi
    done

    ###########################################################################
    # STEP 7.8 — FDR-corrected t-value maps (voxelwise FDR control)
    #            3dFDR converts t-statistics to q-values; FDR q < 0.05 = FDR-significant
    #            Note: FDR is voxelwise; different from cluster-correction approach
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 7.8: FDR-corrected t-values (voxelwise FDR q<0.05) ──────────" >> ${log}
    echo "   Note: FDR controls false discovery rate at voxel level (not cluster level)" >> ${log}

    for strat in full match CC AI; do
        out=${gdir}/tstat_fdr_${strat}.nii.gz
        if [ ! -f ${out} ]; then
            3dFDR -input ${gdir}/tstat_${strat}.nii.gz \
                  -output ${out} 2>> ${log} \
                && echo "  tstat_fdr_${strat}.nii.gz created (q-values)." >> ${log} \
                || echo "  [ERROR] 3dFDR failed for ${strat}." >> ${log}
        fi

        # Count voxels at FDR q<0.05
        n_fdr=$(3dcalc -a ${out} -expr 'step(0.05-a)' -prefix - 2>/dev/null | 3dBrickStat -count -non-zero - 2>/dev/null)
        echo "  n_sig_fdr_q05 (${strat}) = ${n_fdr}" >> ${log}
        echo "${group} n_sig_fdr_q05 ${strat} ${n_fdr}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 7.9 — Cluster-corrected t-values (using 3dClustSim + 3dClust)
    #            Estimate smoothness and apply cluster threshold to t-values
    #            Allows comparison of cluster-correction on t-stats vs. effect-size maps
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 7.9: Cluster-correction on t-values (3dFWHMx + 3dClustSim) ──" >> ${log}

    # Estimate smoothness (FWHM) from one of the t-value maps
    # Using full sample as reference; residuals would be better but not always available
    fwhm_est=${gdir}/fwhm_estimate_${group}.txt
    if [ ! -f ${fwhm_est} ]; then
        3dFWHMx -input ${gdir}/tstat_full.nii.gz -mask ${mask} \
                -output ${fwhm_est} 2>> ${log} \
            && echo "  FWHM estimated from tstat_full." >> ${log} \
            || echo "  [WARNING] 3dFWHMx failed; using default FWHM=6." >> ${log}
    fi

    # Extract FWHM values (or use defaults)
    if [ -f ${fwhm_est} ]; then
        # 3dFWHMx outputs: FWHMx FWHMy FWHMz
        read fwhmx fwhmy fwhmz < ${fwhm_est}
    else
        fwhmx=6; fwhmy=6; fwhmz=6
        echo "  Using default FWHM = 6 (cerebellar region typical)" >> ${log}
    fi
    echo "  FWHM: x=${fwhmx}, y=${fwhmy}, z=${fwhmz}" >> ${log}

    # Run 3dClustSim for cluster threshold estimation
    clustsim_out=${gdir}/clustsim_${group}.txt
    if [ ! -f ${clustsim_out} ]; then
        3dClustSim -fwhm ${fwhmx} ${fwhmy} ${fwhmz} \
                   -mask ${mask} \
                   -prefix ${gdir}/clustsim \
                   -alpha 0.05 0.01 \
                   > ${clustsim_out} 2>> ${log}
        echo "  3dClustSim completed; results in ${clustsim_out}." >> ${log}
    fi

    # Extract cluster threshold at p<0.05 uncorrected, alpha=0.05 FWE
    # Format: voxels  p=0.050000  p=0.010000
    # We want the cluster size for FWE p<0.05
    if [ -f ${clustsim_out} ]; then
        clust_thresh=$(grep -A 1 "NN=1" ${clustsim_out} | tail -1 | awk '{print $1}')
        if [ -z "${clust_thresh}" ]; then
            clust_thresh=10  # fallback
            echo "  [WARNING] Could not parse cluster threshold from 3dClustSim; using default=10." >> ${log}
        fi
    else
        clust_thresh=10
    fi
    echo "  Cluster threshold (NN=1, p<0.05): ${clust_thresh} voxels" >> ${log}

    # Apply cluster thresholding to t-value maps
    # Note: 3dClust outputs a volume with cluster labels (not -1Dformat text)
    for strat in full match CC AI; do
        out=${gdir}/tstat_clustcorr_${strat}.nii.gz
        out_tmp=${gdir}/tstat_clustcorr_tmp_${strat}
        if [ ! -f ${out} ]; then
            # 3dClust -prefix outputs a PREFIX, not a full filename
            # So we use tmp prefix, then rename to .nii.gz
            3dClust -nosum \
                    -1noneg \
                    -dxyz=1 \
                    -prefix ${out_tmp} \
                    ${clust_thresh} 1 ${gdir}/tstat_${strat}.nii.gz 2>> ${log}
            
            # Rename output (3dClust adds +orig or +tlrc automatically)
            if [ -f "${out_tmp}+orig.HEAD" ]; then
                3dcopy ${out_tmp}+orig ${out} 2>> ${log}
                rm -f ${out_tmp}+orig.* 2>> ${log}
                echo "  tstat_clustcorr_${strat}.nii.gz created (clust_thresh=${clust_thresh})." >> ${log}
            elif [ ! -f ${out} ]; then
                echo "  [WARNING] 3dClust output not found for ${strat}; skipping count." >> ${log}
            fi
        fi

        # Count cluster-corrected voxels
        if [ -f ${out} ]; then
            n_cc=$(3dBrickStat -count -non-zero ${out} 2>/dev/null)
            echo "  n_sig_tstat_clustcorr (${strat}) = ${n_cc}" >> ${log}
            echo "${group} n_sig_tstat_clustcorr ${strat} ${n_cc}" >> ${summary_file}
        fi
    done

    ###########################################################################
    # STEP 8 — Voxelwise CoV / mean / stdev of Cohen's d across strategies
    #          3dTcat concatenates the 4 maps along the t-axis;
    #          3dTstat operates voxelwise across those 4 "time points"
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 8: Voxelwise CoV / mean / stdev of Cohen's d ────────────────" >> ${log}

    stack=${gdir}/effectsize_4strat.nii.gz
    cov=${gdir}/cov_effectsize.nii.gz
    mean_d=${gdir}/mean_effectsize.nii.gz
    stdev_d=${gdir}/stdev_effectsize.nii.gz

    if [ ! -f ${stack} ]; then
        3dTcat -prefix ${stack} \
            ${map_full} ${map_match} ${map_CC} ${map_AI} 2>> ${log} \
            && echo "  effectsize_4strat.nii.gz created." >> ${log}
    fi
    if [ ! -f ${mean_d} ]; then
        3dTstat -mean  -prefix ${mean_d}  ${stack} 2>> ${log}
    fi
    if [ ! -f ${stdev_d} ]; then
        3dTstat -stdev -prefix ${stdev_d} ${stack} 2>> ${log}
    fi
    if [ ! -f ${cov} ]; then
        3dTstat -cvar  -prefix ${cov}     ${stack} 2>> ${log}
    fi

    # Mean CoV within the conjunction mask (low CoV = consistent effect magnitude)
    if [ -f ${conj_all4} ] && [ -f ${cov} ]; then
        mean_cov=$(3dROIstats -mask ${conj_all4} -nzmean ${cov} 2>/dev/null \
            | awk 'NR==2{print $NF}')
        mean_mean_d=$(3dROIstats -mask ${conj_all4} -nzmean ${mean_d} 2>/dev/null \
            | awk 'NR==2{print $NF}')
        echo "  Mean Cohen's d within conjunction mask  = ${mean_mean_d}" >> ${log}
        echo "  Mean CoV    within conjunction mask     = ${mean_cov}" >> ${log}
        echo "${group} mean_cohen_d_conjunction ${mean_mean_d}" >> ${summary_file}
        echo "${group} mean_cov_conjunction ${mean_cov}" >> ${summary_file}
    fi

    # Whole-cerebellum CoV (if SUIT mask available)
    if [ -f ${mask} ] && [ -f ${cov} ]; then
        cov_cerebellum=$(3dROIstats -mask ${mask} -nzmean ${cov} 2>/dev/null \
            | awk 'NR==2{print $NF}')
        echo "  Mean CoV    whole cerebellum (SUIT)     = ${cov_cerebellum}" >> ${log}
        echo "${group} mean_cov_cerebellum ${cov_cerebellum}" >> ${summary_file}
    fi

    ###########################################################################
    # STEP 9 — Sensitivity / Specificity relative to the full-sample analysis
    #          Treats the full-sample as the "reference standard"
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 9: Sensitivity / Specificity vs. full-sample reference ──────" >> ${log}

    n_full=$(3dBrickStat -count -non-zero ${gdir}/mask_full.nii.gz 2>/dev/null)

    for strat in match CC AI; do
        inter=${gdir}/intersect_full_${strat}.nii.gz
        if [ ! -f ${inter} ]; then
            3dcalc -a ${gdir}/mask_full.nii.gz \
                   -b ${gdir}/mask_${strat}.nii.gz \
                   -expr 'a*b' \
                   -prefix ${inter} -overwrite 2>> ${log}
        fi
        n_strat=$(3dBrickStat -count -non-zero ${gdir}/mask_${strat}.nii.gz 2>/dev/null)
        n_inter=$(3dBrickStat -count -non-zero ${inter} 2>/dev/null)

        # Sensitivity = proportion of full-sample sig voxels also sig in strategy
        if [ -n "${n_full}" ] && [ "${n_full}" -gt 0 ] 2>/dev/null; then
            sens=$(echo "scale=6; ${n_inter} / ${n_full}" | bc)
        else
            sens=NA
        fi
        # Positive predictive value = proportion of strategy sig voxels in full
        if [ -n "${n_strat}" ] && [ "${n_strat}" -gt 0 ] 2>/dev/null; then
            ppv=$(echo "scale=6; ${n_inter} / ${n_strat}" | bc)
        else
            ppv=NA
        fi
        echo "  Sensitivity of ${strat} vs full = ${sens}  (${n_inter}/${n_full})" >> ${log}
        echo "  PPV         of ${strat} vs full = ${ppv}  (${n_inter}/${n_strat})" >> ${log}
        echo "${group} sensitivity_vs_full ${strat} ${sens}" >> ${summary_file}
        echo "${group} ppv_vs_full ${strat} ${ppv}" >> ${summary_file}
    done

    ###########################################################################
    # STEP 10 — Visualise conjunction map (montage via @chauffeur_afni)
    ###########################################################################
    echo "" >> ${log}
    echo "── Step 10: Visualisation of conjunction map ─────────────────────────" >> ${log}

    conj_view=${gdir}/conj_view
    mkdir -p ${conj_view}

    if [ -f ${conj_d} ] && [ ! -f ${conj_view}/${group}_conj_all4_000.jpg ]; then
        @chauffeur_afni \
            -ulay   ${mask} \
            -olay   ${conj_d} \
            -cbar   Reds_and_Blues_Inv \
            -ulay_range 0% 100% \
            -func_range 0.5 \
            -set_subbricks 0 0 0 \
            -olay_alpha Yes \
            -olay_boxed Yes \
            -opacity 7 \
            -prefix ${conj_view}/${group}_conj_all4 \
            -set_xhairs OFF \
            -montx 4 -monty 4 \
            -label_mode OFF 2>> ${log} \
            && echo "  Conjunction montage created." >> ${log} \
            || echo "  [WARNING] @chauffeur_afni failed for conjunction map." >> ${log}
    fi

    # Visualise mean effect size map (at conjunction voxels)
    mean_conj=${gdir}/mean_d_at_conjunction.nii.gz
    if [ -f ${mean_d} ] && [ -f ${conj_all4} ] && [ ! -f ${mean_conj} ]; then
        3dcalc -a ${mean_d} -b ${conj_all4} \
            -expr 'a*b' \
            -prefix ${mean_conj} 2>> ${log}
    fi
    if [ -f ${mean_conj} ] && [ ! -f ${conj_view}/${group}_mean_d_000.jpg ]; then
        @chauffeur_afni \
            -ulay   ${mask} \
            -olay   ${mean_conj} \
            -cbar   Reds_and_Blues_Inv \
            -ulay_range 0% 100% \
            -func_range 0.5 \
            -set_subbricks 0 0 0 \
            -olay_alpha Yes \
            -olay_boxed Yes \
            -opacity 7 \
            -prefix ${conj_view}/${group}_mean_d \
            -set_xhairs OFF \
            -montx 4 -monty 4 \
            -label_mode OFF 2>> ${log}
    fi

    echo "" >> ${log}
    echo "Done: ${group}  $(date)" >> ${log}

done  # end group loop

###############################################################################
# Final summary print
###############################################################################
echo ""
echo "================================================================"
echo "  All groups processed."
echo "  Per-group logs : ${outdir}/<GROUP>/similarity_<GROUP>.txt"
echo "  Summary table  : ${outdir}/similarity_summary.txt"
echo "================================================================"
cat ${summary_file}
