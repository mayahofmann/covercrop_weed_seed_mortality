#!/bin/bash 
#SBATCH --nodes=1 --ntasks-per-node=10
#SBATCH --time=20:00:00
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

cd /storage/work/mkh6357/weed_seed/16S_setfa

export PYTHONWARNINGS=ignore #this will remove the pkg_resources warning

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path manifest_pe_16s_setfa.txt \
    --output-path paired-end-demux-16s-setfa.qza \
    --input-format PairedEndFastqManifestPhred33V2
    
#########

#########
### STEP 3: SUMMARIZE DATA ###

qiime demux summarize \
    --i-data paired-end-demux-16s-setfa.qza \
    --o-visualization paired-end-demux.qzv

#download the qzv file and open it on Qiime2 view. 

#########
### STEP 3.5: REMOVE PRIMERS

qiime cutadapt trim-paired \
  --i-demultiplexed-sequences paired-end-demux-16s-setfa.qza \
  --p-front-f GTGYCAGCMGCCGCGGTAA \
  --p-front-r GGACTACNVGGGTWTCTAAT \
  --o-trimmed-sequences trimmed-paired-end-demux-16s-setfa.qza

#########

#########
### STEP 4: FILTER THE SEQUENCES WITH DADA2 ###
    # You can also use deblur, but for this class we will use dada2
    # might need to change trunc-len number

qiime dada2 denoise-paired \
    --i-demultiplexed-seqs trimmed-paired-end-demux-16s-setfa.qza \
    --p-trim-left-f 0 \
    --p-trim-left-r 0 \
    --p-trunc-len-f 240 \
    --p-trunc-len-r 200 \
    --p-n-threads 4 \
    --o-representative-sequences 16s-setfa-representative-sequences.qza \
    --o-table 16s-setfa-table.qza \
    --o-denoising-stats 16s-setfa-denoising-stats.qza \
    --o-base-transition-stats base-transition-stats.qza

qiime metadata tabulate \
    --m-input-file 16s-setfa-denoising-stats.qza \
    --o-visualization 16s-setfa-denoising-stats.qzv  

#download the qzv file and open it on Qiime2 view. 

#########
### STEP 5: VIZUALIZE DATA ###
    #explore the resulting data

qiime feature-table summarize \
    --i-table 16s-setfa-table.qza \
    --o-feature-frequencies 16s-setfa-feature-frequencies.qza \
    --o-sample-frequencies 16s-setfa-sample-frequencies.qza \
    --o-summary 16s-setfa-summary.qzv \
    --m-metadata-file metadata.tsv

qiime feature-table tabulate-seqs \
    --i-data 16s-setfa-representative-sequences.qza \
    --o-visualization 16s-setfa-representative-sequences.qzv

#########

#########
### STEP 6: PHYLOGENETIC TREE ###
    # The tree provides an inherent structure to the data, allowing us to consider an evolutionary relationship between organisms.

qiime phylogeny align-to-tree-mafft-fasttree \
    --i-sequences 16s-setfa-representative-sequences.qza \
    --o-alignment 16s-setfa-aligned-rep-seqs.qza \
    --o-masked-alignment 16s-setfa-masked-aligned-rep-seqs.qza \
    --o-tree 16s-setfa-unrooted-tree.qza \
    --o-rooted-tree 16s-setfa-rooted-tree.qza

#########

#########
### STEP 7: VISUALIZE ALPHA DIVERSITY ###
    #change max depth for a number that fits your data

qiime diversity alpha-rarefaction \
    --i-table 16s-setfa-table.qza \
    --i-phylogeny 16s-setfa-rooted-tree.qza \
    --p-min-depth 10 \
    --p-max-depth 50000 \
    --m-metadata-file metadata.tsv \
    --o-visualization 16s-setfa-alpha-rarefaction.qzv

qiime diversity core-metrics-phylogenetic \
    --i-phylogeny 16s-setfa-rooted-tree.qza \
    --i-table 16s-setfa-table.qza \
    --p-sampling-depth 10000 \
    --m-metadata-file metadata.tsv \
    --output-dir 16s-setfa-core-metrics-results

#download the qzv files and open them on Qiime2 view

#########

#########
### STEP 8: TAXONOMY COMPOSITION  ###
    #[!]change classifier.qza and YOU to any of the options provided:

#greengenes complete 16S RNA:2024.09.backbone.full-length.nb.sklearn-1.4.2.qza
#fungal reads with UNITE:unite_ver2025-02-19_dynamic_s_fungi-Q2-2026.1.qza
#greengenes for V4: 2024.09.backbone.v4.nb.sklearn-1.4.2.qza

qiime feature-classifier classify-sklearn \
    --i-classifier /storage/group/vfr5124/default/PPEM440/students/mkh6357/week6/2024.09.backbone.v4.nb.sklearn-1.4.2.qza \
    --i-reads 16s-setfa-representative-sequences.qza \
    --o-classification 16s-setfa-taxonomy.qza

qiime metadata tabulate \
    --m-input-file 16s-setfa-taxonomy.qza \
    --o-visualization 16s-setfa-taxonomy.qzv

qiime taxa barplot \
    --i-table 16s-setfa-table.qza \
    --i-taxonomy 16s-setfa-taxonomy.qza \
    --m-metadata-file metadata.tsv \
    --o-visualization 16s-setfa-taxa-bar-plots.qzv


#CONVERTING TO TSV

#########
###  STEP 2: IMPORT DATA ###
    
cd /storage/work/mkh6357/weed_seed/16S_setfa

qiime tools export \
--input-path 16s-setfa-table.qza \
--output-path exported-table

biom convert \
  -i /storage/work/mkh6357/weed_seed/16S_setfa/exported-table/feature-table.biom \
  -o feature-table.tsv \
  --to-tsv

qiime tools export \
--input-path 16s-setfa-taxonomy.qza \
--output-path exported-taxonomy

qiime tools export \
--input-path 16s-setfa-representative-sequences.qza \
--output-path exported-seqs

### FIN/END/ENDE/FIM ###





