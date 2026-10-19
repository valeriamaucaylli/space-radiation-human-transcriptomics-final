# 08A RESULTS LOCK — EXTREME HEALTH 01
**Lock date:** 17 October 2026  
**Decision:** **PASS — RESULTS LOCKED**

## Canonical environment
The final canonical validation was executed independently in RStudio on Windows 11:
- R 4.5.2
- DESeq2 1.50.2
- limma 3.66.0
- fgsea 1.36.2
- jsonlite 2.0.0

Uploaded `R_results.zip` SHA-256:
`462d3c52cd3f4f88d151560d1db26bb16af22e5d707dd925167701a43fbf9fdc`

## Lock decision
**PASS.** The pre-specified primary inference is unchanged after canonical R/Bioconductor validation.

Across the biological-replicate/subject-level four-pathway tests, **0/60 pathway tests survive Holm correction**. Therefore the locked primary result is not a claim of pathway-level statistical significance in the small astronaut or controlled cohorts.

The defensible primary conclusion is:

> Human spaceflight transcriptomic responses across ROS, DNA repair, OXPHOS and inflammatory pathways are heterogeneous across missions and sampling phases. Controlled human radiation models reproduce several of these directions, but independent simulated-microgravity models reproduce overlapping directions as well. Consequently, the astronaut transcriptomic patterns are not specific enough to support causal attribution to radiation alone.

## Human astronaut arm
### Inspiration4 — R+1 vs mean preflight
Canonical subject-level pathway scores:
- ROS: DOWN, Holm=1.00
- DNA repair: DOWN, Holm=1.00
- OXPHOS: DOWN, Holm=1.00
- Inflammation: UP, Holm=1.00

Canonical fgsea/Wald ranking keeps the same four directions and identifies inflammation as the strongest exploratory signal (NES ≈ 1.69; Holm ≈ 5.8×10⁻4). This is **exploratory**, because pathway-gene ranking is not a substitute for n=4 subject-level inference.

### Ax-1 — R+24h vs L-2wk
Canonical subject-level scores:
- ROS: UP
- DNA repair: DOWN
- OXPHOS: UP
- Inflammation: essentially null/mixed (+0.008 mean; subject directions disagree)
- all Holm=1.00.

Canonical fgsea strongly enriches ROS and OXPHOS. Ax-1 inflammation changed sign between ranking/normalization approaches and is therefore locked as **indeterminate**, not DOWN or UP.

## Simulated microgravity
### GSE218935
The independent DESeq2 rerun agrees closely with the deposited DESeq2 Wald statistic: Spearman ρ = **0.971**.

Canonical fgsea:
- ROS UP (Holm ≈ 0.040)
- DNA repair UP (Holm ≈ 0.0069)
- OXPHOS not enriched
- inflammation DOWN (Holm ≈ 0.0069).

The biological-replicate pathway-score layer remains non-significant after Holm.

### OSD-129 factorial human PBL model
Canonical limma confirms the major checkpoint patterns:
- radiation at 1G: DNA repair UP and OXPHOS UP at gene-rank level;
- modeled microgravity without radiation: DNA repair UP, OXPHOS DOWN, inflammation UP;
- radiation×microgravity interaction: strongest for inflammation, with a negative interaction term.

The donor-level exact pathway tests remain non-significant after Holm. Several weak ROS/inflammation directions change with ranking method and are not locked as robust biological findings.

## Controlled radiation
### OSD-577 — 0.5 Gy simplified GCRsim
The 24-h Mature and 6-day Angiogenesis contexts remain separate.

**Mature / 24 h:** replicate-level pathway scores show ROS UP, DNA repair DOWN, OXPHOS near-zero/slightly DOWN in the canonical score table, inflammation UP; none survives Holm. Gene-rank analysis strongly supports DNA-repair depletion and inflammatory enrichment, but these remain exploratory.

**Angiogenesis / 6 d:** replicate-level scores are ROS UP, DNA repair DOWN, OXPHOS UP, inflammation UP; none survives Holm. Canonical gene-rank enrichment gives the same directions. The inflammation rank direction differed in one earlier non-canonical ranking method despite a positive mean pathway score, so its enrichment magnitude is treated as method-sensitive.

### OSD-993 — 4 Gy radiation qualities
Replicate-level exact pathway scores remain non-significant after Holm for proton, Si-28, Fe-56 and Cs-137.

Canonical gene-rank enrichment shows radiation-quality-specific patterns, including strong inflammatory enrichment after proton, Si-28 and Fe-56, plus OXPHOS enrichment for Si-28/Fe-56. These are **exploratory**, not confirmatory.

## Method-stability audit
Across 60 matched context×pathway exploratory comparisons, checkpoint and canonical R ranking agree in direction for **50/60 (83.3%)**.

The 10 sign disagreements are concentrated in weak/method-sensitive effects. They are retained in `08A_exploratory_method_concordance.csv` and must not be promoted to robust findings.

## What is locked
### CONFIRMATORY
1. No four-pathway biological-replicate test survives Holm in the small astronaut/controlled cohorts.
2. The astronaut pathway response is heterogeneous across mission and sampling phase.
3. Overlap with simulated-microgravity pathways prevents radiation-specific attribution from transcriptomics alone.
4. GCRsim/radiation responses themselves vary with model state, radiation quality and sampling time.

### EXPLORATORY
- DESeq2/limma-ranked fgsea effects and leading edges.
- Radiation-quality differences.
- Directional similarity of astronaut and controlled-model signatures.

### HYPOTHESIS-GENERATING
- Any statement that Ax-1, I4 or JAXA is specifically “radiation-like”.
- Four-pathway cosine/directional similarity metrics.
- Antagomir rescue interpretation.

## Results-lock rule
No pathway, contrast, gene set, normalization method, endpoint or exclusion rule may now be changed based on significance. Any subsequent analysis must be explicitly labeled **post-lock exploratory** or **sensitivity analysis**.

## 09A implication
The manuscript should be framed around **specificity failure / contextual heterogeneity**, not discovery of a universal radiation signature.
