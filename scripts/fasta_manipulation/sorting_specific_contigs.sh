#!/usr/bin/bash

# EXTRACTION OF SPECIFIC CONTIGS FROM A FASTA FILE

# DATE OF CREATION: 06/06/2023

# This script will take a fasta file (was initially thinked for using contigs from an assembly) and get specific contigs from that file to create a subset of the sequences that 
# includes only the desired contigs

# You need to give the script a file with the name of the contigs that you want to extract arranged in a list:
# S1C3CNODE_1816_length_7395_cov_3.996027
# S1C3CNODE_17250_length_2273_cov_4.740588
# S1C3CNODE_5389_length_4576_cov_4.153760
# S1C3CNODE_4685_length_4907_cov_5.024730
# S1C3CNODE_15466_length_2462_cov_2.992818

# DECLARE USEFUL VARIABLES FOR THE PROCESS:
sign='$'

# DEFINYING THE VARIABLES
pref=${1} # A prefix for the output files that the user want to be present in the outputs
sample=${2} # The name of the sample that you are going to process. All your files must begin with this string for the script to work:
# 3.fna contigs_file
# 3_lecanoromycetes_contigs.txt contigs_information_file
out_dir=${3} # Directory where the user want to generate the output. If you want the output files and folder to be in the actual location, write "."
contigs_path=${4} # Path to the folder where the fasta file to process is stored
contigs_suff=${5} # Suffix of the fasta file taht follows after the sample name (e.g. ".fna" for 3.fna)
info_path=${6} # Path to the folder where the text file with the names of the contigs to keep
info_suff=${7} # Suffix of the text file that follows after the sample name (e.g. "_lecanoromycetes_contigs.txt" for 3_lecanoromycetes_contigs.txt)
fasta_to_tbl=${8} # Path to the script to transform from fasta to table format. scripts/utilites/from_fasta_to_tbl.sh
tbl_to_fasta=${9} # Path to the script to transform from table to fasta format. scripts/utilites/from_tbl_to_fasta.sh

# CREATING OUTPUT DIRECTORIES
if [ "${out_dir}" = "." ]; 
    then
        # sequences
        mkdir -p contig_sorting/${pref}/sorted_sequences
        mkdir -p contig_sorting/${pref}/tables
        #Defining variables on the directories locations
        # sequences
        sorted=$(echo contig_sorting/"${pref}"/sorted_sequences)
        tables=$(echo contig_sorting/"${pref}"/tables)
    else
        # sequences
        mkdir -p ${out_dir}/contig_sorting/${pref}/sorted_sequences
        mkdir -p ${out_dir}/contig_sorting/${pref}/tables
        #Defining variables on the directories locations
        # sequences
        sorted=$(echo "${out_dir}"/contig_sorting/"${pref}"/sorted_sequences)
        tables=$(echo "${out_dir}"/contig_sorting/"${pref}"/tables)
fi

# TRANSFORMING THE FASTA FILE TO TABLE
sh ${fasta_to_tbl} ${contigs_path}/${sample}${contigs_suff} > ${tables}/${sample}.tbl 

# GETTING THE DESIRED CONTIGS
# Creating an empty file to store the information
touch ${sorted}/${sample}.temp
# Getting the contigs from the list
cat ${info_path}/${sample}${info_suff} | while read line; do
    contig=$(echo ${line});
    grep -m1 ${contig} ${tables}/${sample}.tbl >> ${sorted}/${sample}.temp
done

# TRANSFORMING THE TABLE FILE TO FASTA
sh ${tbl_to_fasta} ${sorted}/${sample}.temp > ${sorted}/${sample}.fna
# Removing the temporal file
rm ${sorted}/${sample}.temp