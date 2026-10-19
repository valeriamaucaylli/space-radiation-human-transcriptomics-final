# Independent artifact comparison audit

Two distinct user-supplied archives were inspected:

- Historical `EXTREME_HEALTH_01_08A_RESULTS_LOCK_2026-10-17.zip`, subfolder `canonical_R/`, containing 40 canonical R output files.
- `R results.zip`, subsequently returned from a Windows RStudio workflow, containing 40 corresponding files.

All forty uncompressed files matched **byte-for-byte** (40/40). `validation/40_CANONICAL_OUTPUT_SHA256.csv` stores the SHA-256 of every uncompressed canonical output for independent checking. This is a file-identity and archival-reproducibility check; it does not independently certify the user reran the analysis without cached/intermediate files, because the outputs themselves carry no verifiable generation provenance. The execution script and v3-patched variant are preserved without altering the locked statistical results.

Three locked aggregate CSV checks passed structural assertions: 60 confirmatory tests with 0 Holm < 0.05; 60 exploratory gene-ranked tests with 32 Holm < 0.05; 60 method direction comparison entries with 50 matches. These tests check archived results rather than retesting original study hypotheses.

Source processed data and original per-participant results are withheld from this public candidate. No direct estimate of mission astronaut radiation dose was inferred from transcriptomics.
