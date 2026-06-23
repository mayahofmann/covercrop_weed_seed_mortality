#!/bin/bash 
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --time=3:00:00
#SBATCH --account=open 
#SBATCH --output=qiime.out
#SBATCH --job-name=qiime

############# QIIME2 ################
#########

### STEP 1: Load Qiime2 ###

module load anaconda/2023.09
source activate qiime2-amplicon-2026.1
#########

#########
###  STEP 2: IMPORT DATA ###
    
cd /storage/work/mkh6357/weed_seed/ITS_setfa

export PYTHONWARNINGS=ignore #this will remove the pkg_resources warning

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path manifest_pe_ITS_setfa.txt \
    --output-path paired-end-demux-ITS-setfa.qza \
    --input-format PairedEndFastqManifestPhred33V2
#########

#########
### STEP 3: SUMARIZE DATA ###
qiime demux summarize \
    --i-data paired-end-demux-ITS-setfa.qza \
    --o-visualization paired-end-demux.qzv

#download the qzv file and open it on Qiime2 view

#########
### STEP 3.5: REMOVE PRIMERS

qiime cutadapt trim-paired \
  --i-demultiplexed-sequences paired-end-demux-ITS-setfa.qza \
  --p-front-f CTTGGTCATTTAGAGGAAGTAA \
  --p-front-r GCTGCGTTCTTCATCGATGG \
  --o-trimmed-sequences trimmed-paired-end-demux-ITS-setfa.qza

#########

#########
### STEP 4: FILTER THE SEQUENCES WITH DADA2 ###
    # might need to change trunc-len numbers

qiime dada2 denoise-single \
    --i-demultiplexed-seqs trimmed-paired-end-demux-ITS-setfa.qza \
    --p-trunc-len 260 \
    --p-n-threads 4 \
    --o-representative-sequences ITS-setfa-representative-sequences.qza \
    --o-table ITS-setfa-table.qza \
    --o-denoising-stats ITS-setfa-denoising-stats.qza \
    --o-base-transition-stats base-transition-stats.qza

qiime metadata tabulate \
    --m-input-file ITS-setfa-denoising-stats.qza \
    --o-visualization ITS-setfa-denoising-stats.qzv  

#########
### STEP 5: VIZUALIZE DATA ###
    #explore the resulting data

qiime feature-table summarize \
    --i-table ITS-setfa-table.qza \
    --o-feature-frequencies ITS-setfa-feature-frequencies.qza \
    --o-sample-frequencies ITS-setfa-sample-frequencies.qza \
    --o-summary ITS-setfa-summary.qzv \
    --m-metadata-file metadata.tsv

qiime feature-table tabulate-seqs \
    --i-data ITS-setfa-representative-sequences.qza \
    --o-visualization ITS-setfa-representative-sequences.qzv
    
#download the qzv file and open it on Qiime2 view. what do you think this file is necesary for the next steps?

#########

#########
### STEP 6: PHYLOGENETIC TREE ###

qiime phylogeny align-to-tree-mafft-fasttree \
    --i-sequences ITS-setfa-representative-sequences.qza \
    --o-alignment ITS-setfa-aligned-rep-seqs.qza \
    --o-masked-alignment ITS-setfa-masked-aligned-rep-seqs.qza \
    --o-tree ITS-setfa-unrooted-tree.qza \
    --o-rooted-tree ITS-setfa-rooted-tree.qza

#########

#########
### STEP 6: VISUALIZE ALPHA DIVERSITY ###
#might need to change max depth

qiime diversity alpha-rarefaction \
    --i-table ITS-setfa-table.qza \
    --i-phylogeny ITS-setfa-rooted-tree.qza \
    --p-min-depth 10 \
    --p-max-depth 50000 \
    --o-visualization ITS-setfa-alpha-rarefaction.qzv \
    --m-metadata-file metadata.tsv 
    
qiime diversity core-metrics-phylogenetic \
    --i-phylogeny ITS-setfa-rooted-tree.qza \
    --i-table ITS-setfa-table.qza \
    --p-sampling-depth 10000 \
    --output-dir ITS-setfa-core-metrics-results \
    --m-metadata-file metadata.tsv 

#########

#########
### STEP 8: TAXONOMY COMPOSITION  ###

#greengenes complete 16S RNA:2024.09.backbone.full-length.nb.sklearn-1.4.2.qza
#fungal reads with UNITE:unite_ver2025-02-19_dynamic_s_fungi-Q2-2026.1.qza
#greengenes for V4: 2024.09.backbone.v4.nb.sklearn-1.4.2.qza

qiime feature-classifier classify-sklearn \
    --i-classifier /storage/group/vfr5124/default/PPEM440/students/mkh6357/week6/unite_ver2025-02-19_dynamic_s_fungi-Q2-2026.1.qza \
    --i-reads ITS-setfa-representative-sequences.qza \
    --o-classification ITS-setfa-taxonomy.qza

qiime metadata tabulate \
    --m-input-file ITS-setfa-taxonomy.qza \
    --o-visualization ITS-setfa-taxonomy.qzv

qiime taxa barplot \
    --i-table ITS-setfa-table.qza \
    --i-taxonomy ITS-setfa-taxonomy.qza \
    --o-visualization ITS-setfa-taxa-bar-plots.qzv \
    --m-metadata-file metadata.tsv 
    
########
###  CONVERTING TO TSV ###
    
cd /storage/work/mkh6357/weed_seed/ITS_setfa

qiime tools export \
--input-path ITS-setfa-table.qza \
--output-path exported-table

biom convert \
-i exported-table/feature-table.biom \
-o feature-table.tsv \
--to-tsv

qiime tools export \
--input-path ITS-setfa-taxonomy.qza \
--output-path exported-taxonomy

qiime tools export \
--input-path ITS-setfa-representative-sequences.qza \
--output-path exported-seqs


### FIN/END/ENDE/FIM ###







