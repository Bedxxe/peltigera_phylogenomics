#!/bin/bash

#SBATCH --mem-per-cpu=16G # The RAM memory that will be asssigned to each threads
#SBATCH -c 16 # The number of threads to be used in this script
#SBATCH --output=logs/metabolism/dram/peltigerales/all_samples/distill_all_samples.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/metabolism/dram/peltigerales/all_samples/distill_all_samples.err # Indicate a path where a file with the error information will be created. That directory mustalready exist
#SBATCH --partition=scavenger # Partition to be used to run the script

# This script is to get the distill of the metabolism of all the microbiome from the Peltigerales project

# CALLING CONDA ENVIRONMENT
source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
conda activate dram

DRAM.py distill -i analyses/metabolism/dram/bacteriome_peltigerales/all_samples/annotations.tsv -o analyses/metabolism/dram/bacteriome_peltigerales/all_samples/genome_summaries
