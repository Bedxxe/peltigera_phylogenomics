#!/usr/bin/bash

#SBATCH --array=1-12
#SBATCH --mem-per-cpu=1G  # adjust as needed
#SBATCH -c 1 # number of threads per process
#SBATCH --output=logs/contig_sorting/8066_hybrid/extraction_%A_%a.out
#SBATCH --error=logs/contig_sorting/8066_hybrid/extraction_%A_%a.err
#SBATCH --partition=scavenger

# This script is for extracting the bacterial identified contigs in the sequences from the hybrid assemblies from the 12 discipulos

# CREATING THE ARRAY VARIABLE
sample=$(cat documents/taxonomy/metaeuk/opera_contigs/sample_names.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)

# CREATING THE OUTPUT FOLDER
mkdir -p analyses/contig_sorting/8066_hybrid/sorted_sequences/${sample}
mkdir -p analyses/contig_sorting/8066_hybrid/documents
mkdir -p analyses/contig_sorting/8066_hybrid/temp


# GETTING THE NAMES OF THE CONTIGS THAT WE WANT TO GET (JUST LECANOROMYCETES)
grep -v ';2;' | awk -F ' ' '{print$1}' analyses/taxonomy/metaeuk/8066_hybrid/assignment/${sample}/${sample}_tax_per_contig.tsv > analyses/contig_sorting/8066_hybrid/documents/${sample}_lecanoromycetes_contigs.txt

# CREATING THE DESTINATION FILE
touch analyses/contig_sorting/8066_hybrid/sorted_sequences/${sample}/${sample}_Lecanoromycetes_contigs.fna

# We will read the names of the contigs and use this to make a while loop
cat analyses/contig_sorting/8066_hybrid/documents/${sample}_lecanoromycetes_contigs.txt | while read line; do
	contig=$(echo ${line});
	/hpc/group/bio1/diego/programs/faSomeRecords/faSomeRecords.py -f analyses/assemblies/spades/peltigera_hybrid/contigs/${sample}_contigs.fasta -r "${contig}" -o analyses/contig_sorting/8066_hybrid/temp/${sample}_contig.fasta;
	cat analyses/contig_sorting/8066_hybrid/temp/${sample}_contig.fasta >> analyses/contig_sorting/8066_hybrid/sorted_sequences/${sample}/${sample}_Lecanoromycetes_contigs.fna;
	rm analyses/contig_sorting/8066_hybrid/temp/${sample}_contig.fasta;
done

