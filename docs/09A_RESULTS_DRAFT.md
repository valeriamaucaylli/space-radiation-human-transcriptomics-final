# 09A — Manuscript Results draft (post-lock)

## Canonical validation and primary inference
Canonical re-analysis in R/Bioconductor reproduced the principal direction and heterogeneity findings across the astronaut and controlled-model datasets. No pre-specified pathway-level test using the biological participant or experimental replicate as the unit of inference remained significant after Holm correction. This lack of confirmatory significance was expected given the small cohort sizes and was not replaced by gene-level pseudoreplication.

## Human spaceflight responses differed across mission context and sampling phase
In Inspiration4 whole blood, the immediate postflight contrast (R+1 versus the subject-specific mean of three preflight samples) showed negative mean pathway-score changes for reactive oxygen species, DNA repair and oxidative phosphorylation and a positive inflammatory change. None was significant after Holm correction. In a secondary gene-ranked analysis, inflammation showed the strongest positive enrichment, whereas the other three pathways were negatively ranked.

Ax-1 whole blood showed a different pattern at R+24 h: ROS and OXPHOS pathway scores increased, DNA repair decreased slightly, and inflammation was near zero with discordant subject-level directions. Gene-ranked analysis strongly enriched ROS and OXPHOS. Thus, the two commercial missions did not support a single uniform postflight four-pathway signature.

The aggregate JAXA cfRNA layer, retained as directional evidence only, further indicated phase dependence: all four pathways were modestly positive inflight but negative postflight relative to preflight. Because the public JAXA export is group-level, no participant-level inferential statistics were assigned to this layer.

## Human microgravity models reproduced several astronaut-associated pathway directions
In GSE218935, an independent DESeq2 rerun was highly concordant with the deposited DESeq2 statistic (Spearman ρ=0.971). Gene-ranked enrichment indicated positive ROS and DNA-repair responses and negative inflammatory enrichment under simulated microgravity, while OXPHOS was not enriched. Biological-replicate pathway-score tests did not survive multiplicity correction.

The paired OSD-129 factorial experiment independently separated radiation, modeled microgravity and their interaction. At the gene-rank level, radiation at 1G enriched DNA repair and OXPHOS, whereas modeled microgravity without irradiation enriched DNA repair and inflammation while depleting OXPHOS. The radiation×microgravity interaction was strongest for inflammation and was negative, demonstrating that the combined response was not a simple additive superposition of the individual stressors.

## Controlled radiation responses were context- and radiation-quality-dependent
In OSD-577, 0.5 Gy simplified GCRsim produced distinct transcriptomic responses in the 24-h Mature and 6-day Angiogenesis models. Neither model yielded a Holm-significant pathway-score result at the biological-replicate level. Nevertheless, exploratory gene-ranked analysis identified strong DNA-repair depletion and inflammatory enrichment in the 24-h model, while the 6-day model showed positive ROS, OXPHOS and inflammatory enrichment together with negative DNA-repair enrichment. These temporal/model differences argue against a single invariant GCRsim transcriptomic signature.

OSD-993 further demonstrated radiation-quality heterogeneity. Proton, Si-28 and Fe-56 exposures each showed positive inflammatory pathway scores, while the Cs-137 pattern was weaker and partially discordant. Gene-ranked analyses suggested stronger inflammatory enrichment for charged-particle exposures and OXPHOS enrichment for Si-28 and Fe-56, but none of the replicate-level pathway tests survived Holm correction.

## Cross-context overlap limited radiation specificity
The controlled models demonstrated that ROS, DNA-repair, OXPHOS and inflammatory perturbations are not unique to radiation. Several pathway directions observed in astronaut samples were also reproduced under simulated microgravity, while controlled radiation signatures varied with dose context, radiation quality, tissue/model state and sampling time. Consequently, transcriptomic similarity to a controlled radiation model was insufficient for causal attribution to radiation.

Together, these results support a model of **context-dependent and non-specific pathway convergence** rather than a universal human space-radiation transcriptomic signature.
