# Human spaceflight transcriptomics: radiation vs simulated microgravity

**EXTREME HEALTH 01 — archived Results Lock 08A (17 October 2026)**

This repository contains the source R scripts, a v3 execution wrapper, aggregate locked pathway results, validation programs, and static manuscript figures associated with a secondary bioinformatics analysis of human spaceflight and controlled human radiation/microgravity models.

## Scientific scope and interpretation

Four prespecified pathways: **HALLMARK_REACTIVE_OXYGEN_SPECIES_PATHWAY**, **REACTOME_DNA_REPAIR**, **HALLMARK_OXIDATIVE_PHOSPHORYLATION**, and **HALLMARK_INFLAMMATORY_RESPONSE** (MSigDB 2026.1.Hs).

The locked biological-unit-level analysis contains 60 context–pathway tests: **0/60** significant after within-context Holm correction. Gene-ranked exploratory `fgsea` has **32/60** pathways below the reported within-context Holm threshold. The preliminary-to-canonical method-direction audit shows **50/60** matching directions. Gene-ranked significance is not biological-replicate-level significance. Effects vary by mission, timepoint, tissue and exposure model. These contrasts do **not** identify a radiation-specific signature or establish causal radiation effects in astronauts.

## Verified output identity (18 October 2026 review)

The user-supplied `R results.zip` contains 40 output files whose **uncompressed bytes match all 40 corresponding files** within the original 17 October 2026 Results Lock. A local SHA-256 manifest and a verifier are in `validation/`. This confirms exact output identity, **not independent proof that the most recent interrupted RStudio session recomputed every file from scratch**.

## Directory guide

- `scripts/analysis_08A_canonical_R.R` — original source script (historical; contains known JSON/fgsea vector issues).
- `scripts/RUN_08A_SOURCE_ME_v3.R` — v3 wrapper used to patch the source script for RStudio.
- `scripts/analysis_08A_canonical_R_v3_patched.R` — audited v3-patched derivative, convenient for command-line use.
- `scripts/history/` — previous wrappers retained for history, **do not run**.
- `scripts/reconstruct_OSD129_manifest.py` — reconstructs 20-sample factorial manifest from original OSD-129 ISA source.
- `results/summary_tables/` — three locked, aggregated 60-row CSVs.
- `validation/` and `tests/` — result-integrity and aggregate-table tests.
- `figures/` — static 09A graphics; original plot-generation scripts were not supplied and **are not** represented as programmatically reproduced here.
- `data/` — study/source dataset registry.
- `docs/` — provenance, limitations, environment and audit notes.

## Reproduction with authorized source inputs

1. Consult `docs/REPRODUCTION_INPUT_CONTRACT.md` and `data/DATASET_REGISTRY.md`.
2. Obtain study matrices **directly from authorized NASA OSDR/GeneLab or NCBI GEO sources**. The prepared Inspiration4/Ax-1 13,009 × 22 matrix and subject metadata, and exact frozen Ensembl gene-set mapping, were in the local input bundle used for historical validation and **are intentionally not redistributed**.
3. Assemble a local `R_bundle/inputs` directory using the ten exact file names listed in the input contract; generate the OSD-129 manifest with the script after downloading the NASA ISA metadata. The MSigDB-mapped file requires a rights-compliant local copy of the frozen membership mapping.
4. Open `RUN_08A_SOURCE_ME_v3.R` in RStudio with the expected `R_bundle/scripts/` structure, or run `Rscript scripts/analysis_08A_canonical_R_v3_patched.R R_bundle R_bundle/R_results` from the repository root after providing the input files. Install compatible R/Bioconductor packages if necessary.
5. Run `python tests/validate_release.py` for the aggregate summaries. To compare your outputs against archival checksums, run `python validation/verify_local_results.py PATH_TO_R_results`.

**Reference software environment:** R 4.5.2; DESeq2 1.50.2; limma 3.66.0; fgsea 1.36.2; jsonlite 2.0.0. An original `sessionInfo.txt` is in `docs/`.

## Governance and availability

No original human sample-level molecular matrices, individual participant deltas, raw reads, ISA ZIPs, or full gene-level DE results are included. Published source data do not necessarily carry blanket re-licensing rights. The authors have confirmed release authorization for their original figures and aggregate tables; third-party components and source data remain governed by their original terms. Review figure provenance before any public release. This archive does not contain the 00A raw bibliographic exports. See `docs/SEARCH_AUDIT_TRANSPARENCY.md` for coverage caveats.

**Literature novelty audit:** Investigators applied no publication-date restrictions; Web of Science institutional coverage from 2016 reflects access coverage, not a screening date filter. LeapSpace was not searched.

**Registration integrity:** The OSF registration proposed for this completed analysis is retrospective, **not** a prospective preregistration.

## Citation and licensing

Please cite the relevant original NASA OSDR/GeneLab/GEO dataset records and associated publications, in addition to any GitHub/Zenodo DOI generated later. Confirmed author order, affiliations, correspondence and ORCID identifiers are listed in `AUTHORS.md`. Original scripts use MIT and author-owned scholarly materials use CC BY 4.0; see `LICENSE` and `LICENSING_AND_THIRD_PARTY.md` for scope and third-party exclusions. No DOI has been generated or assigned by this repository.

## Authors and conflicts of interest

Valeria Luz Maucaylli Campos (corresponding author), Claudia Andrea Maucaylli Campos, and José Santos Herrada-Torres. All three authors report no conflicts of interest. For full affiliations and ORCIDs, see [`AUTHORS.md`](AUTHORS.md).
