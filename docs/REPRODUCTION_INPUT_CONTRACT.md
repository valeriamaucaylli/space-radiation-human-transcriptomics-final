# Reproduction input contract — updated 18 October 2026

All ten expected local inputs have now been located or, for the OSD-129 design manifest, reconstructed from source ISA metadata and validated against the matching sample table. This is **input completeness**, not independent computational reproduction.

- `pathway_sets_2026_1_Hs.json`: frozen MSigDB 2026.1.Hs pathways; check MSigDB redistribution license before publishing.
- `counts_13009_filtered.csv.gz`: 13,009 rows × 22 samples, no duplicate gene IDs; 22/22 sample headers agree with the local metadata. **Human sample-level; LOCAL ONLY.**
- `metadata_22samples.csv`: 22 sample records from Inspiration4/Axiom-1; **LOCAL ONLY.**
- `OSD129_design_manifest.csv`: 20 records × donor/gravity/radiation factors, **derived** directly from original OSD-129 ISA ZIP (not a byte-for-byte recovered previous manifest). Use `scripts/reconstruct_OSD129_manifest.py` to recreate.
- `GSE218935_BulkRNAseq_counts_DEG.txt.gz`: downloaded experimental dataset (LOCAL ONLY).
- `GLDS-805_rna_seq_STAR_Unnormalized_Counts_GLbulkRNAseq.csv` and `GLDS-805_rna_seq_SampleTable_GLbulkRNAseq.csv`: OSD-993 (LOCAL ONLY).
- `GLDS-571_rna_seq_STAR_Unnormalized_Counts_GLbulkRNAseq.csv` and `GLDS-571_rna_seq_SampleTable_GLbulkRNAseq.csv`: OSD-577 (LOCAL ONLY).
- `GLDS-129_array_raw_intensities_GLmicroarray.csv`: OSD-129 (LOCAL ONLY).

Human matrices and frozen gene-set memberships are deliberately NOT distributed in the public repo package. Acquire from the original authorized sources.

The exact four frozen sets are HALLMARK_REACTIVE_OXYGEN_SPECIES_PATHWAY, REACTOME_DNA_REPAIR, HALLMARK_OXIDATIVE_PHOSPHORYLATION, HALLMARK_INFLAMMATORY_RESPONSE.

The historical software baseline is R 4.5.2; DESeq2 1.50.2; limma 3.66.0; fgsea 1.36.2; jsonlite 2.0.0. The original canonical script requires the v3-patched variant for reliable execution. On 18 October 2026, the uploaded `R results.zip` was compared byte-for-byte with 40 archived canonical R output files: 40/40 matched. This verifies output identity but does not independently prove generation timestamps or full raw-source preprocessing reproducibility.
