# Interpretation Guide: Cross-Strategy VBM Similarity Analysis

## Overview
The similarity analysis quantifies **consistency of cerebellar VBM results across four sample strategies**:
- **Full**: All subjects (primary analysis)
- **Matched**: Propensity-score matched sample (addresses potential confounding)
- **CC** (Complete Cases): Subjects with no missing data (no imputation)
- **AI** (Alternative Imputation): Different imputation approach (sensitivity to imputation method)

**Key Question**: "Do our main findings hold regardless of which analytical choices we make?"

---

## Metrics Explained

### 1a. **n_sig_clustcorr** (Number of Cluster-Corrected Significant Voxels)
**What it is**: Count of voxels where the effect size (Cohen's d) survived cluster-level multiple comparison correction (the primary conservative threshold).

**Interpretation**:
- Tells you the **extent of the effect** using cluster-corrected (most stringent) thresholding
- Larger n_sig_clustcorr = broader cerebellar involvement at stringent threshold
- Smaller n_sig_clustcorr = more focal effect

**What to expect**:
- All four strategies should identify significant voxels; if one is n_sig_clustcorr = 0, that strategy lacked power
- Typical range: 50–500 voxels (depends on effect size and sample size)
- Modest variation (±20–30%) across strategies is normal
- Large divergence (>50% difference) suggests the result is sensitive to sample composition

**Example for collaborators**:
> "The full sample identified 187 significant cerebellar voxels at cluster-corrected threshold (0.4% of cerebellar volume). The matched, CC, and AI samples identified 156, 149, and 168 voxels, respectively — consistent agreement despite methodological differences."

---

### 1b. **n_sig_uncorr_p05** (Number of Voxels at Uncorrected p<0.05)
**What it is**: Count of voxels exceeding a t-value threshold corresponding to p < 0.05 (uncorrected, two-tailed). These are *not* corrected for multiple comparisons.

**Formula**: For a given t-value map and critical t (e.g., t_crit ≈ 1.96 for infinite df), voxels where |t| > t_crit.

**Interpretation**:
- Much more **liberal** threshold than cluster-corrected approach
- Identifies voxels with nominally significant effects but without family-wise error control
- Useful for **flatmap visualization** because it shows broader spatial pattern
- Typically 2–10× larger than cluster-corrected maps

**What to expect**:
- n_sig_uncorr_p05 >> n_sig_clustcorr (expected and normal)
- Typical ratio: cluster-corrected / uncorrected ≈ 0.1–0.3
- Good consistency across strategies: Dice and Jaccard values for uncorrected masks should still be high (> 0.60)

**Why both thresholds?**:
- **Cluster-corrected** (conservative): Use for main manuscript claims; protects against false positives
- **Uncorrected p<0.05** (liberal): Use for detailed flatmaps; shows anatomical specificity and helps readers appreciate effect localization

**Example for collaborators**:
> "At the uncorrected p<0.05 threshold, strategies identified 450–520 cerebellar voxels. The cluster-corrected result (n=187) represents the highly reproducible core, while the broader uncorrected map shows the full spatial extent of group differences for flatmap visualization."

---

### 2. **Pearson r (Correlation of t-statistic maps)**
**What it is**: Spatial correlation of continuous t-statistic maps across all cerebellar voxels (not just significant ones).

**Formula**: Pearson r between full cerebellar map for strategy 1 and strategy 2

**Range**: –1 to +1 (higher = more similar effect direction and magnitude)

**Interpretation**:
- r > 0.90 = **Excellent spatial agreement** (highly consistent)
- r = 0.70–0.90 = **Good agreement** (minor regional differences in effect magnitude)
- r = 0.50–0.70 = **Moderate agreement** (some divergence but general pattern preserved)
- r < 0.50 = **Poor agreement** (substantial differences in where/how strong effects are)

**Why it matters**:
- Captures the **overall spatial pattern** of effects, not just which voxels pass threshold
- More sensitive than binary overlap measures (Dice/Jaccard) because it uses continuous data
- Can reveal whether different strategies identify effects in the same direction, even if magnitudes differ

**Example for collaborators**:
> "Full vs. Matched: r = 0.92 — the propensity-matched sample yields spatially identical effect maps. This suggests our findings are **not driven by confounding variables** that would be balanced by matching."

---

### 3. **Dice Coefficient (Binary Overlap)**
**What it is**: Proportion of overlap between two binary significance masks.

**Formula**: $\text{Dice} = \frac{2|A \cap B|}{|A| + |B|}$

**Range**: 0 to 1 (higher = more overlap)

**Interpretation**:
- Dice ≥ 0.75 = **High agreement** (>75% of significant voxels overlap)
- Dice = 0.50–0.75 = **Moderate agreement** (50–75% overlap)
- Dice < 0.50 = **Poor agreement** (fragmented or discordant results)

**Why it matters**:
- Binary measure: "Do strategies agree on *which voxels* are significant?"
- Asymmetry: If one strategy is much larger than another, Dice can be low even if the smaller set is entirely contained in the larger
- **Interpretation caveat**: Don't compare Dice across pairs if they have very different effect sizes

**Example for collaborators**:
> "Dice(Full vs. CC) = 0.68, but n_sig is very similar (187 vs. 149 voxels). This means CC identified 68% of the same voxels as Full, though with a smaller overall map. This is **expected and acceptable** — missing data naturally reduces power."

---

### 4. **Jaccard Index (Union-based Overlap)**
**What it is**: Proportion of voxels in the intersection relative to the union of two masks.

**Formula**: $\text{Jaccard} = \frac{|A \cap B|}{|A \cup B|}$

**Range**: 0 to 1 (higher = more agreement)

**Interpretation**:
- Jaccard ≥ 0.60 = **Strong agreement**
- Jaccard = 0.40–0.60 = **Moderate agreement**
- Jaccard < 0.40 = **Weak agreement**

**Relationship to Dice**: Jaccard is always ≤ Dice (stricter criterion). Use Jaccard when you want to penalize cases where one strategy finds extra voxels outside the core region.

**Example for collaborators**:
> "Jaccard(Full vs. AI) = 0.55 indicates 55% of the combined voxelwise findings are in both strategies. The alternative imputation identified some additional peripheral voxels, suggesting **slight sensitivity to imputation approach at the edges**, but core effects are preserved."

---

### 5. **η² (Eta-squared; Effect-size Overlap)**
**What it is**: Normalized dot product of Cohen's d maps — captures spatial overlap of *large effect magnitudes* independent of sign.

**Range**: 0 to 1 (higher = more similar effect-size distributions)

**Interpretation**:
- η² ≥ 0.80 = **Highly consistent effect magnitudes**
- η² = 0.60–0.80 = **Good consistency**
- η² < 0.60 = **Magnitude varies substantially**

**Why it matters**:
- More stringent than Pearson r (focuses on high-effect voxels)
- Insensitive to sign flipping (won't penalize if effects reverse)
- **Directly relevant for publication**: If η² is high, effect sizes are reproducible across strategies

**Example for collaborators**:
> "η²(Full vs. Matched) = 0.82 — not only do the matched and full samples identify the same cerebellar regions, but the **magnitude of group differences is nearly identical**. This strongly argues against confounding."

---

### 6. **Conjunction Maps**

#### 6a. **conjunction_all4_clustcorr** (Voxels significant in ALL 4 strategies — cluster-corrected)
**What it is**: Binary mask of voxels passing the cluster-corrected significance threshold in full AND matched AND CC AND AI.

**n_sig conjunction_all4_clustcorr**: Count of these ultra-robust voxels.

**Interpretation**:
- These are the **most conservative, reproducible findings**
- Represent effects that persist across all sensitivity checks AND all statistical corrections
- Often 30–50% of the full-sample result (depending on effect size)
- **Publication strength**: Excellent for claiming "robust" findings; most defensible for claims

**Example for collaborators**:
> "68 cerebellar voxels reached significance in *all four* sample strategies at cluster-corrected threshold (36% of the full-sample result, n=187). These voxels represent **maximum evidence for reproducibility** and should be highlighted in main figures."

##### 6b. **conjunction_all4_p05_uncorr** (Voxels significant in ALL 4 strategies — uncorrected p<0.05)
**What it is**: Binary mask of voxels exceeding the uncorrected p<0.05 t-threshold in all four strategies.

**n_sig conjunction_all4_p05_uncorr**: Count of these voxels.

**Interpretation**:
- Less stringent than cluster-corrected conjunction
- Still represents **high reproducibility** (agreement across all 4 strategies)
- Typically larger than cluster-corrected conjunction by 2–4×
- **Useful for**: Flatmap visualization showing the broader anatomical extent
- **Note**: Individual voxels lack multiple-comparison correction, but *consistency across strategies* strengthens evidence

**Relationship to cluster-corrected conjunction**: 
- If conjunction_all4_p05_uncorr ≈ conjunction_all4_clustcorr: Effects are very focal and robust
- If conjunction_all4_p05_uncorr >> conjunction_all4_clustcorr: Core robust findings with peripheral "suggestive" findings; useful context for flatmaps

**Example for collaborators**:
> "At the uncorrected p<0.05 threshold, 312 voxels showed significance in all four strategies (vs. 68 at cluster-corrected threshold). The expanded map highlights the full spatial extent of cerebellar involvement while the cluster-corrected core (68 voxels) provides the most conservative evidence for publication."

---

### 6c. **tstat_conj_p05** (T-value Maps Restricted to Conjunction Voxels)
**What it is**: The raw t-statistic values from the 3dLMEr model, but only at voxels where all 4 strategies agree at p<0.05 uncorrected.

**Files**: `tstat_conj_p05_<strat>.nii.gz` (per strategy)

**Interpretation**:
- Shows the **actual t-values driving the conjunction**
- Helps identify which regions within the conjunction have the strongest statistical evidence
- Useful for detailed anatomical interpretation: high t-values indicate focal agreement; variable t-values suggest heterogeneous effects

**Why this matters**:
- The conjunction_all4_p05 mask is binary (0 or 1) — you lose magnitude information
- These restricted t-value maps preserve both location AND statistical strength
- Can reveal whether the conjunction is driven by a few very strong voxels or more distributed moderate effects

**Example for collaborators**:
> "Within the 312 conjunctive voxels, t-values ranged from 2.1 to 4.8 (mean=3.2), with the strongest evidence concentrated in the anterior lobe. This indicates a focal, highly significant core with modest effects in surrounding regions."

---

### 6d. **n_sig_fdr_q05** (Voxels Significant at FDR q<0.05 — Voxelwise Control)
**What it is**: Count of voxels where the False Discovery Rate (FDR) adjusted p-value (q-value) is < 0.05.

**Method**: 3dFDR applies Benjamini-Hochberg FDR correction to all t-values.

**Range**: 0 to total number of voxels in brain

**Interpretation**:
- FDR q < 0.05 means: Among all voxels called "significant," no more than 5% are expected to be false positives
- **Voxelwise control**: Different from cluster correction (which controls family-wise error at the cluster level)
- Typically less stringent than cluster correction but more stringent than uncorrected p<0.05
- Expected ordering: **uncorrected p<0.05 > FDR q<0.05 > cluster-corrected**

**Why it matters**:
- Provides an **alternative multiple-comparison correction** based on false discovery rate
- Complementary to cluster-based thresholding; helps validate findings across different statistical approaches
- FDR is more interpretable than cluster correction for many audiences

**Relationship to Cluster Correction**:
| Approach | What it controls | Interpretation | Stringency |
|----------|------------------|-----------------|-----------|
| **Uncorrected p<0.05** | Nothing (one voxel at a time) | ~5% of all voxels are false positives | Most liberal |
| **FDR q<0.05** | False Discovery Rate across all voxels | Among voxels called significant, ≤5% are false positives | Moderate |
| **Cluster-corrected** | Family-wise error at cluster level | Probability of any false positive cluster is <5% | Most conservative |

**Example for collaborators**:
> "At FDR q<0.05, we identified 245 cerebellar voxels (vs. 187 cluster-corrected, 312 uncorrected p<0.05). This FDR-based result sits between the most and least conservative thresholds, validating the core findings through a different correction method."

---

### 6e. **n_sig_tstat_clustcorr** (Voxels in Cluster-Corrected T-Value Maps)
**What it is**: Count of voxels surviving cluster-level correction applied to the t-statistic maps themselves (not the effect-size maps).

**Method**: 
1. Estimate spatial smoothness (FWHM) using 3dFWHMx
2. Determine cluster size threshold via 3dClustSim (for α=0.05 FWE)
3. Apply 3dClust to t-value maps

**Range**: 0 to total number of voxels in brain

**Interpretation**:
- **Different from the primary effect-size cluster correction** in your pipeline
- Provides a consistency check: Do t-values and effect-sizes identify the same regions?
- Often yields similar but not identical results to effect-size-based cluster correction
- Useful for: Understanding whether corrections are threshold-dependent

**Comparison: t-value vs. effect-size cluster correction**:
- If n_sig_tstat_clustcorr ≈ n_sig_clustcorr (effect-size): Methods agree → robust finding
- If n_sig_tstat_clustcorr >> n_sig_clustcorr: T-values suggest larger extent → possible difference in effect-size computation
- If n_sig_tstat_clustcorr << n_sig_clustcorr: Effect-sizes more sensitive → effect-size thresholding is driving results

**Example for collaborators**:
> "Cluster-corrected t-value maps identified 164 voxels (vs. 187 from effect-size maps). The close agreement (87% overlap) confirms our findings are robust across different thresholding approaches."

---
**What it is**: Average Cohen's d across voxels in the all-4 conjunction mask.

**Interpretation**:
- Quantifies effect magnitude at the **most reproducible locations**
- Typical range: 0.3–1.0 (depending on sample size and effect strength)
- Higher values = stronger group differences in robust regions

**Example for collaborators**:
> "At the 68 conjunctive voxels, mean Cohen's d = 0.54 (medium effect). This indicates the cerebellar deficits in this group are **clinically meaningful and reproducible**."

---

### 8. **mean_cov_conjunction** (Coefficient of Variation at Conjunction)
**What it is**: Average variability of Cohen's d *across the four strategies* at conjunctive voxels.

**Formula**: $\text{CoV} = \frac{\text{SD}(\text{Cohen's d across 4 strategies})}{\text{Mean}(\text{Cohen's d})} \times 100\%$

**Range**: 0–100% (lower = more consistent effect sizes)

**Interpretation**:
- CoV < 15% = **Excellent consistency** (effect magnitudes are nearly identical across strategies)
- CoV = 15–30% = **Good consistency** (minor variation in magnitude)
- CoV = 30–50% = **Moderate consistency** (noticeable but acceptable variation)
- CoV > 50% = **Poor consistency** (effect magnitude is strategy-dependent)

**Why it matters**:
- Directly answers: "Are effect sizes reproducible?"
- More informative than binary Dice/Jaccard for understanding magnitude variation

**Example for collaborators**:
> "Within the robust conjunction, CoV = 12% — effect magnitudes are nearly identical across all four sample strategies. This is **extremely reassuring for reproducibility and suggests our effect size estimates are stable**."

---

### 9. **mean_cov_cerebellum** (CoV Across Whole Cerebellum)
**What it is**: Coefficient of variation calculated across the entire cerebellar volume (not just significant voxels).

**Interpretation**:
- Wider context for effect-size consistency
- If whole-cerebellum CoV >> conjunction CoV, variability is concentrated at effect edges (acceptable)
- If whole-cerebellum CoV ≈ conjunction CoV, variability is uniform (less reassuring)

**Example for collaborators**:
> "Whole-cerebellum CoV = 28% (vs. 12% at conjunction voxels). This indicates **variability is concentrated at lower-effect regions**, while core findings remain stable."

---

### 10. **sensitivity_vs_full** (Recall Relative to Full Sample)
**What it is**: Proportion of the full-sample's significant voxels also found significant in an alternate strategy.

**Formula**: $\text{Sensitivity} = \frac{|A_{\text{alt}} \cap A_{\text{full}}|}{|A_{\text{full}}|}$

**Range**: 0–1 (higher = better)

**Interpretation**:
- Sensitivity > 0.90 = **Excellent** (alternative strategy recovers >90% of full-sample result)
- Sensitivity = 0.70–0.90 = **Good** (typical for modest power loss from sample reduction)
- Sensitivity < 0.70 = **Concerning** (substantial findings lost; strategy may be underpowered)

**Why it matters**:
- Power-adjusted comparison: Accounts for different sample sizes
- **Asymmetric by nature**: Full sample is the "gold standard"

**Example for collaborators**:
> "CC sensitivity = 0.88: Complete-case analysis recovers 88% of the full sample's findings despite losing N=45 subjects. This high sensitivity indicates **missing data are not systematically hiding effects**."

---

### 11. **ppv_vs_full** (Positive Predictive Value Relative to Full Sample)
**What it is**: Proportion of an alternate strategy's significant voxels that overlap with the full sample.

**Formula**: $\text{PPV} = \frac{|A_{\text{alt}} \cap A_{\text{full}}|}{|A_{\text{alt}}|}$

**Range**: 0–1 (higher = better)

**Interpretation**:
- PPV > 0.80 = **Excellent** (voxels identified by alternate strategy are mostly validated by full sample)
- PPV = 0.60–0.80 = **Good** (most findings are shared; some strategy-specific voxels)
- PPV < 0.60 = **Concerning** (alternate strategy finds many extra voxels not in full sample)

**Why it matters**:
- Opposite perspective from sensitivity
- Sensitivity: "Did full sample miss anything?" → focuses on full sample's completeness
- PPV: "Are alternate strategy's findings real?" → focuses on false discovery risk

**Interpretation note**: If Sensitivity is high but PPV is low, the alternate strategy identified extra voxels. Investigate whether these are:
- Real but underpowered in full sample (good)
- Noise artifacts from different analysis (concerning)

**Example for collaborators**:
> "AI PPV = 0.91: When alternative imputation identifies a significant voxel, there's a 91% chance the full sample also finds it significant. This **validates the AI strategy** — very few false discoveries."

---

## Comparing Multiple Correction Methods: A Validation Framework

You now have **three independent approaches** to multiple-comparison correction. Comparing them strengthens your evidence:

### The Three Correction Approaches

| Approach | Uses | Corrects For | Output | Stringency |
|----------|------|--------------|--------|-----------|
| **Cluster Correction (Effect-Size)** | Cohen's d effect-size maps | Family-wise error at cluster level | `conjunction_all4_clustcorr`, `n_sig_clustcorr` | Most conservative |
| **FDR Correction (Voxelwise)** | T-statistic maps | False discovery rate at voxel level | `n_sig_fdr_q05` | Moderate |
| **Cluster Correction (T-Value)** | T-statistic maps | Family-wise error at cluster level | `n_sig_tstat_clustcorr` | Conservative |

### Validation Strategy

**Step 1: Check for agreement between methods**
```
Compare: n_sig_clustcorr (effect-size) ≈ n_sig_tstat_clustcorr (t-value)?
- If yes (within 20%): Strong evidence — methods agree on locations
- If divergent: Investigate differences; may reflect effect-size vs. t-statistic sensitivity
```

**Step 2: Check FDR as a bridge**
```
Expected ordering: clustcorr < FDR < uncorrected p<0.05
- n_sig_clustcorr          ≈ 68 voxels (most stringent)
- n_sig_fdr_q05            ≈ 150 voxels (middle ground)
- n_sig_uncorr_p05         ≈ 312 voxels (least stringent)

If actual results deviate from this ordering, investigate why:
  - Too few FDR voxels? Smoothness may be underestimated
  - Too many FDR voxels? Check that t-values are correctly thresholded
  - Inconsistent cluster-corrected numbers? Verify FWHM estimation
```

**Step 3: Interpret the hierarchy of evidence**

**Highest Confidence** (intersection of all methods):
```
Voxels in: conjunction_all4_clustcorr AND n_sig_fdr_q05 AND n_sig_tstat_clustcorr
→ These voxels survived ALL three independent corrections
→ Strongest claim for robustness
```

**High Confidence** (intersection of two methods):
```
Voxels in: conjunction_all4_clustcorr AND n_sig_fdr_q05
→ Survived both cluster-corrected and FDR approaches
→ Strong but not maximum evidence
```

**Moderate Confidence** (single method):
```
Voxels with: n_sig_fdr_q05 only (not cluster-corrected)
→ Pass FDR but lose out in cluster thresholding
→ Possible real effects with lower spatial clustering
→ Worth noting in supplementary findings
```

### Example Interpretation

Suppose your results are:
- **n_sig_clustcorr (effect-size)** = 68 voxels
- **n_sig_fdr_q05** = 145 voxels
- **n_sig_tstat_clustcorr** = 71 voxels

**What this tells you:**
1. Effect-size and t-value cluster corrections agree closely (68 vs. 71) → **Methods are consistent**
2. FDR identifies 145 voxels, about 2× larger → **More liberal; captures some voxels that don't form large clusters**
3. Likely ~55 voxels pass FDR but fail cluster correction → **These may be individually significant but too isolated for cluster thresholding**

**Recommendation for publication:**
> "Our primary finding comprises 68 cerebellar voxels that survived cluster-corrected thresholding of effect-size maps. These voxels were independently validated using two alternative methods: cluster-corrected t-values (n=71, 96% overlap) and FDR voxelwise correction (n=145, including 68 cluster-corrected voxels). The close agreement across methods strengthens confidence in the robustness of these findings."

---

## Practical Workflow: Using All Three Methods

### For your main manuscript:
1. **Primary result**: Use `conjunction_all4_clustcorr` (cluster-corrected effect-size, most conservative)
2. **Validation**: Show that the same voxels pass FDR and t-value cluster correction
3. **Visualization**: Use `tstat_conj_p05_<strat>` to show t-value strength at conjunction voxels

### For supplementary materials:
1. **Secondary findings**: Report voxels passing FDR but not cluster correction
2. **Method comparison**: Create figure showing Venn/UpSet plot of all three approaches
3. **Robustness discussion**: Explain why voxels differ across methods (clustering vs. magnitude vs. FDR)

### For collaborator discussion:
1. "We used three independent approaches to correct for multiple comparisons"
2. "All three methods show strong agreement, indicating robust findings"
3. "Here's where they diverge and why that's expected..."

---

## Summary: What Does "Good Consistency" Look Like?

| Metric | Excellent | Acceptable | Red Flag |
|--------|-----------|------------|----------|
| **n_sig_clustcorr** | Same across strategies | ±20–30% variation | >50% divergence |
| **n_sig_uncorr_p05** | Same across strategies | ±15–25% variation | >40% divergence |
| **n_sig_fdr_q05** | ~2–3× larger than clustcorr | ~1.5–3× clustcorr | <1.2× or >4× clustcorr |
| **n_sig_tstat_clustcorr** | ±10–20% of effect-size clustcorr | ±20–30% variation | >40% divergence |
| **Pearson r** | > 0.90 | 0.70–0.90 | < 0.50 |
| **Dice (clustcorr)** | > 0.75 | 0.50–0.75 | < 0.50 |
| **Dice (uncorr p05)** | > 0.75 | 0.50–0.75 | < 0.50 |
| **Jaccard** | > 0.60 | 0.40–0.60 | < 0.30 |
| **η²** | > 0.80 | 0.60–0.80 | < 0.50 |
| **CoV** | < 15% | 15–30% | > 50% |
| **Sensitivity** | > 0.90 | 0.70–0.90 | < 0.60 |
| **PPV** | > 0.80 | 0.60–0.80 | < 0.50 |
| **Conjunction (% of full, clustcorr)** | > 50% | 30–50% | < 20% |
| **Conjunction (% of full, uncorr)** | > 40% | 25–40% | < 15% |

| Metric | Excellent | Acceptable | Red Flag |
|--------|-----------|------------|----------|
| **n_sig_clustcorr** | Same across strategies | ±20–30% variation | >50% divergence |
| **n_sig_uncorr_p05** | Same across strategies | ±15–25% variation | >40% divergence |
| **Pearson r** | > 0.90 | 0.70–0.90 | < 0.50 |
| **Dice (clustcorr)** | > 0.75 | 0.50–0.75 | < 0.50 |
| **Dice (uncorr p05)** | > 0.75 | 0.50–0.75 | < 0.50 |
| **Jaccard** | > 0.60 | 0.40–0.60 | < 0.30 |
| **η²** | > 0.80 | 0.60–0.80 | < 0.50 |
| **CoV** | < 15% | 15–30% | > 50% |
| **Sensitivity** | > 0.90 | 0.70–0.90 | < 0.60 |
| **PPV** | > 0.80 | 0.60–0.80 | < 0.50 |
| **Conjunction (% of full, clustcorr)** | > 50% | 30–50% | < 20% |
| **Conjunction (% of full, uncorr)** | > 40% | 25–40% | < 15% |

---

## Critical t-Value for p<0.05 Uncorrected Threshold

**Why it matters**: The script thresholds t-statistics at a critical value corresponding to p < 0.05 (two-tailed, uncorrected). This critical value depends on the **degrees of freedom** from your 3dLMEr linear mixed-effects model.

### How to find your degrees of freedom:
1. **Inspect the 3dLMEr output log** (look for "DF" or "degrees_of_freedom")
2. **From the Model_<group>.nii.gz header**: Run `3dinfo -label Model_ALC.nii.gz | grep -i "tstat"` to see contrast labels and associated df

### Critical t-value reference table (two-tailed, α=0.05):
| df | t_crit |
|----|--------|
| 30 | 2.042 |
| 50 | 2.009 |
| 75 | 1.992 |
| 100 | 1.984 |
| 150 | 1.975 |
| 200 | 1.971 |
| ∞ | 1.960 |

### How to compute the exact critical t-value in R:
```R
df <- 100  # Replace with your actual df
t_crit <- qt(0.975, df)  # 0.975 = 1 - 0.05/2 for two-tailed
print(t_crit)
```

### In the script:
Edit this line to match your df:
```bash
t_crit=1.96  # Default for df > 150; change if your df is smaller
```

**Note**: If you don't know the exact df, using t_crit = 1.96 is conservative (slightly stricter than needed for smaller df, slightly lenient for larger df). This is acceptable for sensitivity analysis purposes.

### Scenario: VBM analysis of cerebellar volume in substance use disorder

**Email template:**

> **Subject: Cross-strategy sensitivity analysis — VBM cerebellar findings are robust**
>
> Dear [Collaborator],
>
> We have completed sensitivity analyses to verify the stability of our VBM cerebellar findings across analytical choices. We compared the primary full-sample analysis against three alternative approaches: (1) propensity-matched sample, (2) complete-case analysis, and (3) alternative imputation strategy.
>
> **Key findings:**
>
> 1. **Spatial consistency**: Pearson correlation of whole-brain t-statistic maps was r = 0.91 (full vs. matched), r = 0.87 (full vs. CC), r = 0.89 (full vs. AI). These correlations indicate **near-identical spatial patterns** across all strategies.
>
> 2. **Voxel-level agreement**: The full sample identified 187 significant cerebellar voxels (cluster-corrected, p < 0.05). Binary overlap with matched, CC, and AI samples was 82%, 79%, and 84% (Dice coefficients), indicating **strong consensus on which regions show group differences**.
>
> 3. **Ultra-conservative conjunction**: 68 cerebellar voxels (36% of the primary finding) reached significance in *all four* sample strategies. These voxels represent **maximum evidence for reproducibility** and should be highlighted in publication.
>
> 4. **Effect-size stability**: Within the conjunctive voxels, Cohen's d varied minimally across strategies (CoV = 12%), indicating **our effect-size estimates are not method-dependent**.
>
> 5. **Power considerations**: Complete-case analysis recovered 88% of the full sample's findings despite smaller N. This high sensitivity suggests **missing data did not systematically obscure effects**.
>
> **Conclusion**: Our cerebellar volume findings are robust across a comprehensive range of sensitivity checks. The magnitude and spatial distribution of group differences are consistent regardless of whether we analyze the full sample, use propensity matching, restrict to complete cases, or apply alternative imputation.
>
> Best,
> [Your name]

---

## Common Pitfalls & Troubleshooting

### "One strategy has n_sig = 0, others have significant findings"
- **Cause**: Usually underpowered strategy (smaller sample size after restrictions)
- **Response**: This is concerning; investigate sample size and effect size carefully
- **Action**: Report conjunction_3of4 instead; acknowledge one strategy lacks power

### "n_sig_clustcorr is very different from n_sig_uncorr_p05"
- **Cause**: Normal and expected — cluster correction is much more stringent
- **Response**: This is **not a problem**. Ratio of clustcorr/uncorr ≈ 0.1–0.3 is typical
- **Action**: Use cluster-corrected for main claims; uncorrected for flatmaps showing extent

### "Dice is high for uncorrected but low for cluster-corrected"
- **Cause**: Strategies agree on the broader spatial pattern (high Dice for uncorrected) but diverge on which voxels survive cluster correction
- **Response**: Acceptable; suggests core effects are robust but periphery varies with strategy
- **Action**: Report both; emphasize cluster-corrected conjunction for publication

### "Dice is low (0.40) but strategies identified similar voxels"
- **Cause**: One strategy identified many more voxels; they overlap in the core but diverge peripherally
- **Response**: This is often acceptable; check Jaccard (more conservative) and conjunction
- **Action**: Emphasize conjunction findings; describe the divergence as effect-size gradient differences

### "Pearson r is high (0.92) but Dice is low (0.50)"
- **Cause**: Spatial correlation is high (same *pattern*), but different voxels pass the threshold
- **Response**: Suggests threshold sensitivity, not fundamental disagreement
- **Action**: Compare uncorrected Dice values; report both Pearson r and Dice in paper

### "CoV is high (45%) within the conjunction"
- **Cause**: Effect magnitudes vary substantially across strategies
- **Response**: Concerning for effect-size reproducibility
- **Action**: Investigate which strategy diverges; document in Supplementary Methods; use conjunction findings with caution

### "conjunction_all4_clustcorr is much smaller than conjunction_all4_p05_uncorr"
- **Cause**: Expected — cluster correction is stricter than voxelwise p-threshold
- **Response**: This is **normal**. If uncorrected conj is 2–4× larger, patterns are as expected
- **Action**: Use cluster-corrected for main findings; uncorrected for detailed flatmap context

### "FDR results (n_sig_fdr_q05) are very different from cluster-corrected"
- **Cause**: FDR corrects at voxel level; cluster correction groups voxels. Different spatial structures yield different results
- **Response**: Expected divergence; depends on effect clustering. Compare:
  - If n_sig_fdr_q05 ≈ n_sig_clustcorr: Effects form tight clusters
  - If n_sig_fdr_q05 >> n_sig_clustcorr: Effects are spatially dispersed; FDR more permissive for isolated voxels
  - If n_sig_fdr_q05 << n_sig_clustcorr: Smoothness overestimated or spatial structure unusual
- **Action**: Both results are valid; report both and explain the difference in methods

### "T-value cluster correction (n_sig_tstat_clustcorr) differs from effect-size cluster correction"
- **Cause**: T-values and effect-sizes have different distributions and sensitivities
- **Response**: Expected but should be correlated
- **Action**: 
  - If |tstat_clustcorr - effect_size_clustcorr| / effect_size_clustcorr < 0.2: Good agreement
  - If divergence > 40%: Investigate FWHM estimation or effect-size formula
  - If t-value clustcorr much larger: Effect-sizes may be thresholding more aggressively
  - Report the agreement as evidence of robustness

### "tstat_clustcorr_<strat>.nii.gz files not created"
- **Cause**: Common issue with older script versions using `-1Dformat` flag (outputs text, not volume)
- **Response**: Script has been fixed; -1Dformat removed so 3dClust outputs proper 3D volume
- **Action**:
  1. Verify script has this section in Step 7.9:
     ```bash
     3dClust -nosum -1noneg -dxyz=1 -prefix ${out_tmp} ${clust_thresh} 1 ...
     3dcopy ${out_tmp}+orig ${out}
     ```
  2. Re-run script: `sbatch 11_similarity_across_samples.sh`
  3. Check logs for "tstat_clustcorr_<strat>.nii.gz created" message
  4. Verify files exist: `ls -lh $outdir/<GROUP>/tstat_clustcorr_*.nii.gz`
- **Diagnostics**: If still missing, check:
  - FWHM file: `cat $outdir/<GROUP>/fwhm_estimate_<GROUP>.txt` (should show 3 numbers)
  - ClustSim output: `tail $outdir/<GROUP>/clustsim_<GROUP>.txt` (should show cluster thresholds)
  - Script log: `tail $outdir/<GROUP>/similarity_<GROUP>.txt` (look for error messages)

### "What voxels pass FDR but fail cluster correction?"
- **Interpretation**: Voxels with strong individual t-values but isolated from other significant voxels
- **Options**:
  1. Report in supplementary findings ("secondary voxels of interest")
  2. Create separate flatmap showing FDR-only voxels with different color
  3. Investigate anatomically: Are these biologically meaningful but spatially isolated regions?
- **Recommend**: Mention in methods that some voxels pass FDR but not cluster correction; discuss implications

---

## Figures to Create (For Publication/Presentation)

### Main manuscript figures:
1. **Conjunction map (cluster-corrected)** overlaid on SUIT atlas
   - Input: `conjunction_all4.nii.gz` or `conjunction_all4_cohen_d.nii.gz`
   - Shows the most defensible, reproducible cerebellar regions
   - Use this for main figure in methods/results

### Supplementary figures (flatmaps, detailed spatial extent):
2. **Flatmap comparison across sample strategies**
   - Overlay: `tstat_p05_mask_full.nii.gz`, `tstat_p05_mask_match.nii.gz`, etc.
   - Color-code by strategy (red=full, green=matched, blue=CC, yellow=AI)
   - Shows spatial patterns across strategies; where do they overlap vs. diverge?

3. **Conjunction flatmap (uncorrected p<0.05)**
   - Input: `conjunction_all4_p05.nii.gz`
   - Broader spatial extent than cluster-corrected
   - Useful for: showing full cerebellar involvement and context for the conservative core

4. **Heatmap of Pearson r values** (strategy pairs × groups)
   - Shows spatial correlation; should be uniformly high (> 0.85)

5. **Venn diagram or UpSet plot** showing overlap of significant voxels
   - Use cluster-corrected counts for main voxels
   - Include separate row for uncorrected p<0.05 extent

6. **Bar plot of n_sig_clustcorr and n_sig_uncorr_p05** across strategies
   - Shows that uncorrected >> cluster-corrected (as expected)
   - Demonstrates both are consistent across strategies

7. **Bar plot of Dice/Jaccard** across strategy pairs
   - Separately for cluster-corrected and uncorrected masks
   - Should show high agreement in both cases

8. **Scatterplot**: Dice (clustcorr) vs. Dice (uncorr) — should be positively correlated

9. **Boxplot of CoV distribution** (per group)
   - Shows effect-size consistency

10. **Sensitivity/PPV chart** (bar plot with full sample as reference)

11. **Effect-size distributions** (violin plot of Cohen's d across 4 strategies within conjunction)

---

## References & Context

- **Dice coefficient**: Sørensen (1948), commonly used in imaging for spatial overlap
- **Jaccard index**: Historical citation (1901), generalized for image sets
- **Eta-squared (η²)**: Standardized effect-size measure; 3ddot's -doeta2 implements normalized overlap
- **Coefficient of variation (CoV)**: Ratio of SD to mean; unitless measure of consistency
- **Sensitivity/Specificity**: Diagnostic accuracy terminology; here applied to voxel-level prediction
- **FDR correction**: Benjamini-Hochberg method; implemented in AFNI via 3dFDR
- **Cluster correction**: AFNI 3dClustSim + 3dClust; estimates cluster size thresholds via Monte Carlo
- **FWHM estimation**: AFNI 3dFWHMx; estimates spatial smoothness from data

---

## Complete Output File Guide

### Per-group directory structure: `$outdir/<GROUP>/`

**Effect-Size Maps (from 10_Clusterize scripts)**:
- `effect_size.nii.gz` — Cohen's d at cluster-corrected significant voxels (primary result)
- `Model_${group}.nii.gz` — 3dLMEr output with multiple bricks

**T-Statistic Extractions** (Step 1):
- `tstat_full.nii.gz` — Full sample t-values (brick 5 from 3dLMEr)
- `tstat_match.nii.gz` — Matched sample t-values
- `tstat_CC.nii.gz` — Complete-case t-values
- `tstat_AI.nii.gz` — Alternative imputation t-values

**Binary Masks (Cluster-Corrected)** (Step 2):
- `mask_full.nii.gz` — Cluster-corrected significant voxels (full sample)
- `mask_match.nii.gz` — Cluster-corrected significant voxels (matched)
- `mask_CC.nii.gz` — Cluster-corrected significant voxels (CC)
- `mask_AI.nii.gz` — Cluster-corrected significant voxels (AI)

**Binary Masks (Uncorrected p<0.05)** (Step 2.5):
- `tstat_p05_mask_full.nii.gz` — Uncorrected p<0.05 significant voxels (full sample)
- `tstat_p05_mask_match.nii.gz` — Uncorrected p<0.05 significant voxels (matched)
- `tstat_p05_mask_CC.nii.gz` — Uncorrected p<0.05 significant voxels (CC)
- `tstat_p05_mask_AI.nii.gz` — Uncorrected p<0.05 significant voxels (AI)

**Pairwise Comparisons** (Step 5):
- `intersect_<strat1>_<strat2>.nii.gz` — Overlap of two strategy masks
- `union_<strat1>_<strat2>.nii.gz` — Union of two strategy masks

**Conjunction Maps** (Step 7):
- `conjunction_all4.nii.gz` — Voxels significant in ALL 4 strategies (cluster-corrected)
- `conjunction_3of4.nii.gz` — Voxels significant in ≥3 of 4 strategies (cluster-corrected)
- `conjunction_all4_cohen_d.nii.gz` — Effect-size values at conjunction_all4 voxels (for visualization)

**Conjunction Maps (Uncorrected)** (Step 7.5):
- `conjunction_all4_p05.nii.gz` — Voxels significant in ALL 4 strategies (uncorrected p<0.05)

**Conjunction-Masked T-Values** (Step 7.7):
- `tstat_conj_p05_full.nii.gz` — Full sample t-values at conjunction_all4_p05 voxels
- `tstat_conj_p05_match.nii.gz` — Matched sample t-values at conjunction_all4_p05 voxels
- `tstat_conj_p05_CC.nii.gz` — CC t-values at conjunction_all4_p05 voxels
- `tstat_conj_p05_AI.nii.gz` — AI t-values at conjunction_all4_p05 voxels

**FDR-Corrected T-Values** (Step 7.8):
- `tstat_fdr_full.nii.gz` — Full sample FDR q-values (0–1 scale, lower = more significant)
- `tstat_fdr_match.nii.gz` — Matched sample FDR q-values
- `tstat_fdr_CC.nii.gz` — CC FDR q-values
- `tstat_fdr_AI.nii.gz` — AI FDR q-values

**Cluster-Corrected T-Values** (Step 7.9):
- `tstat_clustcorr_full.nii.gz` — Full sample cluster-corrected t-values
- `tstat_clustcorr_match.nii.gz` — Matched sample cluster-corrected t-values
- `tstat_clustcorr_CC.nii.gz` — CC cluster-corrected t-values
- `tstat_clustcorr_AI.nii.gz` — AI cluster-corrected t-values
- `fwhm_estimate_<group>.txt` — Estimated FWHM (x y z) from 3dFWHMx
- `clustsim_<group>.txt` — 3dClustSim output showing cluster thresholds

**How to inspect cluster-corrected t-value maps**:
```bash
# View the created files (should be .nii.gz format)
ls -lh /path/to/outdir/ALC/tstat_clustcorr_*.nii.gz

# Check voxel count in each
for f in tstat_clustcorr_*.nii.gz; do
  echo "$(basename $f): $(3dBrickStat -count -non-zero $f) voxels"
done

# View in AFNI GUI (after loading SUIT as underlay)
afni -anat SUIT.nii &
# Then File → Open Anatomy, select tstat_clustcorr_full.nii.gz as overlay

# Compare to effect-size based cluster correction (should be similar)
# Cluster-corrected t-values: tstat_clustcorr_<strat>.nii.gz
# Effect-size cluster correction: $ORIGINAL_MODELS/uncorrected_05/<GROUP>_HC/effect_size.nii.gz
```

**Expected relationship**:
- n_sig_tstat_clustcorr should be within ±10–20% of n_sig_clustcorr (effect-size based)
- If very different: suggests FWHM estimation issue or data quality problem
- Check `fwhm_estimate_<group>.txt` and `clustsim_<group>.txt` for diagnostics

**Effect-Size Statistics** (Step 8):
- `effectsize_4strat.nii.gz` — 4-brick concatenated stack (full, match, CC, AI)
- `mean_effectsize.nii.gz` — Mean Cohen's d across strategies (voxelwise)
- `stdev_effectsize.nii.gz` — SD Cohen's d across strategies (voxelwise)
- `cov_effectsize.nii.gz` — Coefficient of variation of Cohen's d (voxelwise)
- `mean_d_at_conjunction.nii.gz` — Mean effect size restricted to conjunction_all4 voxels

**Visualizations** (Step 10):
- `conj_view/` — Directory containing @chauffeur_afni montage JPEGs
  - `<group>_conj_all4_***.jpg` — Cluster-corrected conjunction map montage
  - `<group>_mean_d_***.jpg` — Mean effect-size at conjunction montage

**Logs and summaries**:
- `similarity_<group>.txt` — Per-group detailed log with all metrics and diagnostics
- `../similarity_summary.txt` — Machine-readable summary table (all groups, all metrics)

---

## Quick Reference: Which Files to Use For What

| Task | Primary File | Alternative | Notes |
|------|-------------|-------------|-------|
| Main publication figure | `conjunction_all4_cohen_d.nii.gz` | — | Most conservative; cluster-corrected |
| Flatmap (spatial extent) | `conjunction_all4_p05.nii.gz` | `tstat_p05_mask_*.nii.gz` | Shows broader extent; uncorrected |
| Detailed anatomy | `tstat_conj_p05_full.nii.gz` | — | T-values at conjunction voxels |
| Validation: FDR | `tstat_fdr_*.nii.gz` | — | Alternative correction method |
| Validation: t-value clustering | `tstat_clustcorr_*.nii.gz` | — | Alternative clustering approach |
| Effect-size consistency | `cov_effectsize.nii.gz` | `mean_d_at_conjunction.nii.gz` | Shows variability across strategies |
| Strategy overlap | `mask_*.nii.gz` (all 4) | `conjunction_*.nii.gz` | For Dice/Jaccard calculations |

---

## Using T-Value and Effect-Size Maps for Flatmap Visualization

### Output files for flatmaps:

**From cluster-corrected approach** (conservative, for main claims):
- `conjunction_all4_cohen_d.nii.gz` — Effect-size values at cluster-corrected significant voxels
- `conjunction_all4_p05.nii.gz` — Binary mask of uncorrected p<0.05 conjunction

**From t-value restricted approach** (detailed anatomy):
- `tstat_conj_p05_<strat>.nii.gz` — Per-strategy t-values restricted to conjunction_all4_p05 voxels
- `tstat_p05_mask_<strat>.nii.gz` — Per-strategy uncorrected p<0.05 t-value masks

**From alternative correction approaches** (validation):
- `tstat_fdr_<strat>.nii.gz` — FDR q-values (voxelwise correction)
- `tstat_clustcorr_<strat>.nii.gz` — Cluster-corrected t-value maps (alternative cluster correction)

### Recommended flatmap workflow:

1. **Create main publication flatmap** using `conjunction_all4_cohen_d.nii.gz`
   - Overlays: Cluster-corrected Cohen's d values (from effect-size maps)
   - Underlay: SUIT atlas
   - Caption: "Cerebellar regions showing significant group differences in all four sample strategies (cluster-corrected)"
   - Rationale: Most defensible, highest evidence for reproducibility

2. **Create detailed supplementary flatmap** showing conjunction t-values
   - Overlays: `tstat_conj_p05_full.nii.gz` (or mean of 4 strategies)
   - Underlay: SUIT atlas
   - Caption: "T-statistic values at voxels where all four strategies agree (uncorrected p<0.05). Reflects statistical strength of conjunction findings."
   - Rationale: Shows anatomical detail and individual t-value magnitudes within the robust region

3. **Create strategy comparison flatmap** showing all four strategies
   - Overlays (separate panels or RGB): `tstat_p05_mask_full.nii.gz`, `tstat_p05_mask_match.nii.gz`, `tstat_p05_mask_CC.nii.gz`, `tstat_p05_mask_AI.nii.gz`
   - Use different colors or transparency levels to show agreement
   - Caption: "Cerebellar regions at uncorrected p<0.05 threshold across four analytical strategies. Red=Full, Green=Matched, Blue=CC, Yellow=AI. Overlap indicates reproducibility."
   - Rationale: Illustrates broader extent and strategy-specific patterns; demonstrates robustness

4. **Optional: Create 4-panel validation flatmap** comparing all correction methods
   - Panel A: `conjunction_all4_cohen_d.nii.gz` (cluster-corrected effect-size, primary)
   - Panel B: `conjunction_all4_p05.nii.gz` (uncorrected p<0.05 conjunction, liberal)
   - Panel C: Overlay of voxels passing FDR q<0.05 (alternative voxelwise correction)
   - Panel D: Overlay of voxels in cluster-corrected t-value map (alternative cluster correction)
   - Caption: "Multi-method validation of conjunction findings. Panels show the same anatomical region thresholded using four independent approaches. Close agreement across methods strengthens confidence in localization."
   - Rationale: Demonstrates robustness across different correction methods; addresses reviewer concerns about multiple-comparison control

### Why report both thresholds?

| Threshold | Strength | Weakness | Best for |
|-----------|----------|----------|----------|
| **Cluster-corrected (effect-size)** | Multiple comparison corrected; conservative; defensible for publication | May miss subtle but real effects; smaller extent | Main manuscript claims; highlighting most robust findings |
| **Uncorrected p<0.05 (t-value)** | Shows full spatial extent; better anatomical detail; easier to interpret; consistent across strategies | Not multiple-comparison corrected; individual voxels at risk of false positive | Flatmaps; supplementary materials; showing spatial pattern and context for readers unfamiliar with cluster correction |
| **FDR q<0.05 (voxelwise)** | Alternative to cluster correction; captures isolated significant voxels; easier to interpret for varied audiences | Voxelwise (not spatial cluster control); different from cluster approach | Validation; supplementary methods; showing robustness across correction approaches |
| **Cluster-corrected t-values** | Independent validation using different statistic; tests robustness of FWHM estimation | May diverge from effect-size approach if smoothness differs | Supplementary validation; methods section to show agreement |

**Bottom line**: 
- **Main text**: Use cluster-corrected effect-size results (conjunction_all4_cohen_d)
- **Supplementary flatmaps**: Show uncorrected p<0.05 conjunction + per-strategy t-value maps
- **Validation**: Include brief note that FDR and t-value cluster correction show similar results
- **Methods**: Explain why multiple approaches strengthen claims

---
