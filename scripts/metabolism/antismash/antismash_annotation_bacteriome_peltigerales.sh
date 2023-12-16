#!/bin/bash

#SBATCH --array=1-130
#SBATCH --mem-per-cpu=16G # The RAM memory that will be asssigned to each threads
#SBATCH -c 2 # The number of threads to be used in this script
#SBATCH --output=logs/metabolism/antismash/antismash_annotation_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/metabolism/antismash/antismash_annotation_%A_%a.err # Indicate a path where a file with the error information will be created. That directory mustalready exist
#SBATCH --partition=scavenger # Partition to be used to run the script

# CREATING A VARIABLE TO CHOOSE THE SEQUENCE TO USE IN THE ARRAY
seq=$(cat documents/peltigerale_v2/tree_nibs.txt | sed -n ${SLURM_ARRAY_TASK_ID}p)

# CALLING CONDA ENVIRONMENT
source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
conda activate gmining

# RUNNING THE ANNOTATION WITH ANTISMASH
antismash --clusterhmmer --asf --cc-mibig --cb-general --pfam2go --taxon bacteria \
analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${seq}_contigs.fasta \
--output-dir analyses/metabolism/antismash/${seq} --genefinding-tool prodigal --html-start-compact
