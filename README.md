# covercrop_weed_seed_mortality
Relevant data files, metadata, and R code for weed seed mortality in CCC (2022-2023, 2023-2024) + COMPFUNC (2024-2025). 

ccc_seed_mortality_22_23.csv: data file for year 1 of experiment 1 (2022-2023)

ccc_seed_mortality_23_24.csv: data file for year 2 of experiment 1 (2023-2024)

compfunc_winter_y2_plot.csv: data file for experiment 2 (2024-2025)

metadata_csvfiles.xlsx: has column name and description for the following files - ccc_seed_mortality_22_23.csv, ccc_seed_mortality_23_24.csv, compfunc_winter_y2_plot.csv

metadata.tsv: metadata used in QIIME scripts (found in 16s and its folders)

weedseedmortALLCODE.Rmd: R markdown file with entire R script used to perform all statistical analyses and create figures 

WITHIN THE 16s and ITS folders:
- a taxonomy.tsv, feature-table.tsv, rep-seqs.fasta, and sample_metadata.txt used to create the phyloseq object in the R code, which is also included in the folder (phyloseq.rds). These files were generated using the QIIME script also found in each respective folder, which uses the manifest.txt file found in each folder to access the raw sequencing data. Raw sequencing data is in the process of being uploaded to NCBI. 

