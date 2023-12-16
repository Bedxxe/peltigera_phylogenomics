#!/bin/bash

#SBATCH --array=1-130
#SBATCH --mem-per-cpu=16G # The RAM memory that will be asssigned to each threads
#SBATCH -c 16 # The number of threads to be used in this script
#SBATCH --output=logs/taxonomy/bacteriome_peltigerales_contigs/bacteriome_peltigerales_contigs_kraken_contigs_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/taxonomy/bacteriome_peltigerales_contigs/bacteriome_peltigerales_contigs_kraken_contigs_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script
        
        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/peltigerale_v2/tree_nibs.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)

        # CALLING CONDA ENVIRONMENT
        source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
        conda activate metag

        # CREATING OUTPUT DIRECTORIES
        if [ "analyses" = "." ]; 
            then
                # sequences
                mkdir -p taxonomy/kraken/bacteriome_peltigerales_contigs/sequences
                # kraken
                mkdir -p taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/krakens
                mkdir -p taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/reports
                # bracken
                mkdir -p taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/brackens
                mkdir -p taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/reports

                #Defining variables on the directories locations
                # sequences
                sequences=$(echo taxonomy/kraken/bacteriome_peltigerales_contigs/sequences)
                # kraken
                krakens=$(echo taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/krakens)
                k_reports=$(echo taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/reports)
                # bracken
                brackens=$(echo taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/brackens)
                b_reports=$(echo taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/reports)
            else
                # sequences
                mkdir -p analyses/taxonomy/kraken/bacteriome_peltigerales_contigs/sequences
                # kraken
                mkdir -p analyses/taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/krakens
                mkdir -p analyses/taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/reports
                # bracken
                mkdir -p analyses/taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/brackens
                mkdir -p analyses/taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/reports
                
                #Defining variables on the directories locations
                # sequences
                sequences=$(echo "analyses"/taxonomy/kraken/bacteriome_peltigerales_contigs/sequences)
                # kraken
                krakens=$(echo "analyses"/taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/krakens)
                k_reports=$(echo "analyses"/taxonomy/kraken/bacteriome_peltigerales_contigs/kraken/reports)
                # bracken
                brackens=$(echo "analyses"/taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/brackens)
                b_reports=$(echo "analyses"/taxonomy/kraken/bacteriome_peltigerales_contigs/bracken/reports)
        fi

        # KRAKEN
        kraken2 --db /work/dg304/dala/kraken_database/programs/kraken2/11212023_s4_k49 --threads 16 analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${count}_contigs.fasta         --output ${krakens}/${count}.kraken         --report ${k_reports}/${count}.report
        
        # BRACKEN
        bracken -d /work/dg304/dala/kraken_database/programs/kraken2/11212023_s4_k49         -i ${k_reports}/${count}.report         -o ${brackens}/${count}.bracken         -w ${b_reports}/${count}_bracken.report -r 150 -t 5
        
        # CREATING A FILE TO SAVE THE LINEAGE INFORMATION 
        mkdir -p ${sequences}/${count}
        touch ${sequences}/${count}/otus_of_interest.tsv
        echo -e "OTU""\t""tax-id" > ${sequences}/${count}/otus_of_interest.tsv

        # EXTRACTING UNCLASSIFIED READS
        if [ - = "yes" ];
            then
                # Getting the unclassified tax-id
                id_unclassified=$(echo "0")
                # Writting into .tsv file
                echo -e "Unclassified""\t""0" >> ${sequences}/${count}/otus_of_interest.tsv
                echo -e "\n""Extracting unclassified reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${count}_contigs.fasta                 -o ${sequences}/${count}/${count}_unclassified.fasta                 -t 0 --include-children
            else
                echo "The user does not want to extract the unclassified reads"
        fi
        
        # EXTRACTING THE NON_BACTERIAL READS
        if [ - = "yes" ];
            then
                # Getting the non_bacterial tax-id
                id_nonbacterial=$(echo "2")
                # Writting into .tsv file
                echo -e "Non_bacterial""\t""2" >> ${sequences}/${count}/otus_of_interest.tsv
                echo -e "\n""Extracting non bacterial reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${count}_contigs.fasta                 -o ${sequences}/${count}/${count}_non_bacterial.fasta                 -t 2 --include-children --exclude
            else
                echo "The user does not want to extract the non-Bacterial reads"
        fi

        # 1st OTU EXTRACTION 
        if [ "Sphingomonas" = "-" ]; 
            then
                echo "No OTU of interest provided by the user"
            else
                # Getting the tax-id of the first OTU
                id_1_otu=$(grep "$(printf '\t')Sphingomonas$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Sphingomonas"\t"${id_1_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""Sphingomonas"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${count}_contigs.fasta                 -o ${sequences}/${count}/${count}_Sphingomonas.fasta                 -t ${id_1_otu} --include-children
        fi

        # 2nd READ EXTRACTION
        if [ "Methylobacterium" = "-" ]; 
            then
                echo "No second OTU of interest provided by the user"
            else
                # Getting the tax-id of the second OTU
                id_2_otu=$(grep "$(printf '\t')Methylobacterium$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Methylobacterium"\t"${id_2_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""Methylobacterium"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${count}_contigs.fasta                 -o ${sequences}/${count}/${count}_Methylobacterium.fasta                 -t ${id_2_otu} --include-children
        fi

        # 3th READ EXTRACTION
        if [ "Pseudonocardia" = "-" ]; 
            then
                echo "No third OTU of interest provided by the user"
            else
                # Getting the tax-id of the third OTU
                id_3_otu=$(grep "$(printf '\t')Pseudonocardia$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Pseudonocardia"\t"${id_3_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""Pseudonocardia"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s analyses/assemblies/kraken_extracted_reads/peltigerales_microbiome/contigs/${count}_contigs.fasta                 -o ${sequences}/${count}/${count}_Pseudonocardia.fasta                 -t ${id_3_otu} --include-children
        fi
