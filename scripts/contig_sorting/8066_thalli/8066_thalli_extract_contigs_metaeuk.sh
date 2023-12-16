#!/bin/bash

#SBATCH --array=3,5,6,8,9,11,12
#SBATCH --mem-per-cpu=8G # The RAM memory that will be asssigned to each threads
#SBATCH -c 1 # The number of threads to be used in this script
#SBATCH --output=logs/contig_sorting/8066_thalli/8066_thalli_contig_extraction_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/contig_sorting/8066_thalli/8066_thalli_contig_extraction_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/taxonomy/metaeuk/opera_contigs/sample_names.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)


        # CREATING OUTPUT DIRECTORIES
		
		if [ "analyses" = "." ]; 
		    then
		        mkdir -p contig_sorting/8066_thalli/sorted_sequences/${count}
		        mkdir -p contig_sorting/8066_thalli/tables/${count}
		        mkdir -p contig_sorting/8066_thalli/documents/${count}
		        
		        # Defining variables on the directories locations
		        sorted=$(echo contig_sorting/"8066_thalli"/sorted_sequences/${count})
		        tables=$(echo contig_sorting/"8066_thalli"/tables/${count})
		        documents=$(echo contig_sorting/8066_thalli/documents/${count})
		    else
		        mkdir -p analyses/contig_sorting/8066_thalli/sorted_sequences/${count}
		        mkdir -p analyses/contig_sorting/8066_thalli/tables/${count}
		        mkdir -p analyses/contig_sorting/8066_thalli/documents/${count}
		        
		        # Defining variables on the directories locations
		        sorted=$(echo "analyses"/contig_sorting/"8066_thalli"/sorted_sequences/${count})
		        tables=$(echo "analyses"/contig_sorting/"8066_thalli"/tables/${count})
		        documents=$(echo "analyses"/contig_sorting/8066_thalli/documents/${count})
		fi

		# CONVERTING THE FASTA FILE INTO A TABLE
		sh scripts/fasta_manipulation/from_fasta_to_tbl.sh sequences/opera_12_discipulos/${count}_contigs.fasta > ${tables}/${count}.tbl


        # READING THE TAXA THAT ARE GOING TO BE EXTRACTED
        cat documents/sequences_from_metaeuk/all_taxa_to+extract.tsv | while read line; do
        	# Getting variables with the information from the table
        	taxa=$(echo ${line} | awk -F ' ' '{print$1}');
        	tid=$(echo ${line} | awk -F ' ' '{print$2}');
        	decoy=$(echo ${line} | awk -F ' ' '{print$3}');

        	# GETTING THE NAMES OF THE CONTIGS FOR EACH TAXA
        	grep "${decoy}" analyses/taxonomy/metaeuk/8066_opera/assignment/${count}/${count}_tax_per_contig.tsv | awk -F ' ' '{print$1}' > ${documents}/${count}_${taxa}_contigs.txt

			# GETTING THE DESIRED CONTIGS
			# Creating an empty file to store the information
			touch ${sorted}/${count}_${taxa}.temp
			# Getting the contigs from the list
			cat ${documents}/${count}_${taxa}_contigs.txt | while read line; do
			    contig=$(echo ${line});
			    grep -m1 ${contig} ${tables}/${count}.tbl >> ${sorted}/${count}_${taxa}.temp
			done

			# TRANSFORMING THE TABLE FILE TO FASTA
			sh scripts/fasta_manipulation/from_tbl_to_fasta.sh ${sorted}/${count}_${taxa}.temp > ${sorted}/${count}_${taxa}.fna

			# TRIMMING FOR KRAKEN
			
			if [ "yes" = "yes" ]; then	
				# Making a folder for the trimmed sequences
				
				if [ "analyses" = "." ]; 
			    then
			        mkdir -p contig_sorting/8066_thalli/sorted_sequences/${count}/kraken_trimmed_sequences
			        # Defining variables on the directories locations
			        kraken=$(echo contig_sorting/8066_thalli/sorted_sequences/${count}/kraken_trimmed_sequences)
			    else
			        mkdir -p analyses/contig_sorting/8066_thalli/sorted_sequences/${count}/kraken_trimmed_sequences
			        #Defining variables on the directories locations
			        kraken=$(echo "analyses"/contig_sorting/8066_thalli/sorted_sequences/${count}/kraken_trimmed_sequences)
				fi

				# Creating the new label for the contigs headers
				label=$(echo '>'"${taxa}""|kraken:taxid|""${tid}")

				# Copying the original file to modify it later
		        cp ${sorted}/${count}_${taxa}.fna ${kraken}/${count}_${taxa}.fna
		        sed -i "s/>.*/${label}/g" ${kraken}/${count}_${taxa}.fna
			fi

		done

        # DECITION ON THE TABLES
        if [ no = "no" ]; then
            rm -r ${tables}
        fi

