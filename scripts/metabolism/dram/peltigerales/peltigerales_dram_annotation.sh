#!/bin/bash

#SBATCH --array=85
#SBATCH --mem-per-cpu=16G # The RAM memory that will be asssigned to each threads
#SBATCH -c 24 # The number of threads to be used in this script
#SBATCH --output=logs/metabolism/dram/primary_annotation_peltigerales_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/metabolism/dram/primary_annotation_peltigerales_%A_%a.err # Indicate a path where a file with the error information will be created. That directory mustalready exist
#SBATCH --partition=common # Partition to be used to run the script

# CREATING A VARIABLE TO CHOOSE THE SEQUENCE TO USE IN THE ARRAY
seq=$(cat documents/peltigerale_v2/tree_nibs.txt | sed -n ${SLURM_ARRAY_TASK_ID}p)

# CALLING CONDA ENVIRONMENT
source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
conda activate dram

rm -r analyses/metabolism/dram/bacteriome_peltigerales/${seq}

DRAM.py annotate -i analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${seq}_contigs.fasta \
-o analyses/metabolism/dram/bacteriome_peltigerales/${seq} --min_contig_size 1000

#if [ -f analyses/dram/set_2/"${seq}"/rrnas.tsv ]; 
#    then
#    	if [ -f analyses/dram/set_2/"${seq}"/trnas.tsv ]; 
#    		then
#				DRAM.py distill -i analyses/dram/set_2/${seq}/annotations.tsv -o analyses/dram/set_2/${seq}/genome_summaries --trna_path analyses/dram/set_2/${seq}/trnas.tsv --rrna_path analyses/dram/set_2/${seq}/rrnas.tsv
#			else
#				DRAM.py distill -i analyses/dram/set_2/${seq}/annotations.tsv -o analyses/dram/set_2/${seq}/genome_summaries --rrna_path analyses/dram/set_2/${seq}/rrnas.tsv
#			fi
#	else
#		DRAM.py distill -i analyses/dram/set_2/${seq}/annotations.tsv -o analyses/dram/set_2/${seq}/genome_summaries
#fi
