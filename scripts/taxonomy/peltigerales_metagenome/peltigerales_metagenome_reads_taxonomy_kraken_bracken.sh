#!/bin/bash

#SBATCH --array=44-130
#SBATCH --mem-per-cpu=16G # The RAM memory that will be asssigned to each threads
#SBATCH -c 12 # The number of threads to be used in this script
#SBATCH --output=logs/taxonomy/peltigerales_metagenome_reads/peltigerales_metagenome_reads_kraken_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/taxonomy/peltigerales_metagenome_reads/peltigerales_metagenome_reads_kraken_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
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
                mkdir -p taxonomy/kraken/peltigerales_metagenome_reads/sequences
                # kraken
                mkdir -p taxonomy/kraken/peltigerales_metagenome_reads/kraken/krakens
                mkdir -p taxonomy/kraken/peltigerales_metagenome_reads/kraken/reports
                # bracken
                mkdir -p taxonomy/kraken/peltigerales_metagenome_reads/bracken/brackens
                mkdir -p taxonomy/kraken/peltigerales_metagenome_reads/bracken/reports

                #Defining variables on the directories locations
                # sequences
                sequences=$(echo taxonomy/kraken/"peltigerales_metagenome_reads"/sequences)
                # kraken
                krakens=$(echo taxonomy/kraken/"peltigerales_metagenome_reads"/kraken/krakens)
                k_reports=$(echo taxonomy/kraken/"peltigerales_metagenome_reads"/kraken/reports)
                # bracken
                brackens=$(echo taxonomy/kraken/"peltigerales_metagenome_reads"/bracken/brackens)
                b_reports=$(echo taxonomy/kraken/"peltigerales_metagenome_reads"/bracken/reports)
            else
                # sequences
                mkdir -p analyses/taxonomy/kraken/peltigerales_metagenome_reads/sequences
                # kraken
                mkdir -p analyses/taxonomy/kraken/peltigerales_metagenome_reads/kraken/krakens
                mkdir -p analyses/taxonomy/kraken/peltigerales_metagenome_reads/kraken/reports
                # bracken
                mkdir -p analyses/taxonomy/kraken/peltigerales_metagenome_reads/bracken/brackens
                mkdir -p analyses/taxonomy/kraken/peltigerales_metagenome_reads/bracken/reports
                
                #Defining variables on the directories locations
                # sequences
                sequences=$(echo "analyses"/taxonomy/kraken/"peltigerales_metagenome_reads"/sequences)
                # kraken
                krakens=$(echo "analyses"/taxonomy/kraken/"peltigerales_metagenome_reads"/kraken/krakens)
                k_reports=$(echo "analyses"/taxonomy/kraken/"peltigerales_metagenome_reads"/kraken/reports)
                # bracken
                brackens=$(echo "analyses"/taxonomy/kraken/"peltigerales_metagenome_reads"/bracken/brackens)
                b_reports=$(echo "analyses"/taxonomy/kraken/"peltigerales_metagenome_reads"/bracken/reports)
        fi

        # KRAKEN
        kraken2 --db /work/dg304/dala/kraken_database/programs/kraken2/12122023_s4_k49 --threads 24 --paired /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_paired.fq*         /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_paired.fq*         --output ${krakens}/${count}.kraken         --report ${k_reports}/${count}.report
        
        # BRACKEN
        bracken -d /work/dg304/dala/kraken_database/programs/kraken2/12122023_s4_k49         -i ${k_reports}/${count}.report         -o ${brackens}/${count}_genus.bracken       -l 'G'  -w ${b_reports}/${count}_genus_bracken.report -r 150 -t 50
        bracken -d /work/dg304/dala/kraken_database/programs/kraken2/12122023_s4_k49         -i ${k_reports}/${count}.report         -o ${brackens}/${count}_species.bracken      -l 'S'   -w ${b_reports}/${count}_species_bracken.report -r 150 -t 50
        
        # CREATING A FILE TO SAVE THE LINEAGE INFORMATION 
        mkdir -p ${sequences}/${count}
        touch ${sequences}/${count}/otus_of_interest.tsv
        echo -e "OTU""\t""tax-id" > ${sequences}/${count}/otus_of_interest.tsv

        # EXTRACTING UNCLASSIFIED READS
        if [ no = "yes" ];
            then
                # Getting the unclassified tax-id
                id_unclassified=$(echo "0")
                # Writting into .tsv file
                echo -e "Unclassified""\t""0" >> ${sequences}/${count}/otus_of_interest.tsv
                echo -e "\n""Extracting unclassified reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_paired.fq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_paired.fq*                 -o ${sequences}/${count}/${count}_unclassified_1.fq                 -o2 ${sequences}/${count}/${count}_unclassified_2.fq -t 0                 --fastq-output --include-children
            else
                echo "The user does not want to extract the unclassified reads"
        fi
        
        # EXTRACTING THE NON_BACTERIAL READS
        if [ no = "yes" ];
            then
                # Getting the non_bacterial tax-id
                id_unclassified=$(echo "2")
                # Writting into .tsv file
                echo -e "Non_bacterial""\t""2" >> ${sequences}/${count}/otus_of_interest.tsv
                echo -e "\n""Extracting non bacterial reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_paired.fq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_paired.fq*                 -o ${sequences}/${count}/${count}_non_bacterial_1.fq                 -o2 ${sequences}/${count}/${count}_non_bacterial_2.fq -t 2                 --fastq-output --include-children --exclude
            else
                echo "The user does not want to extract the non-Bacterial reads"
        fi

        # 1st OTU EXTRACTION 
        if [ "Nostoc" = "-" ]; 
            then
                echo "No OTU of interest provided by the user"
            else
                # Getting the tax-id of the first OTU
                id_1_otu=$(grep -m1 "$(printf '\t')Nostoc$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Nostoc"\t"${id_1_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                #echo -e "\n""Extracting ""Nostoc"" reads in fastq from sample: ""${count}"
                #extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_paired.fq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_paired.fq*                 -o ${sequences}/${count}/${count}_Nostoc_1.fq                 -o2 ${sequences}/${count}/${count}_Nostoc_2.fq -t ${id_1_otu}                 --fastq-output --include-children
        fi

        # 2nd READ EXTRACTION
        if [ "Viridiplantae" = "-" ]; 
            then
                echo "No second OTU of interest provided by the user"
            else
                # Getting the tax-id of the second OTU
                id_2_otu=$(grep -m1 "$(printf '\t')Viridiplantae$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Viridiplantae"\t"${id_2_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                #echo -e "\n""Extracting ""Viridiplantae"" reads in fastq from sample: ""${count}"
                #extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_paired.fq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_paired.fq*                 -o ${sequences}/${count}/${count}_Viridiplantae_1.fq                 -o2 ${sequences}/${count}/${count}_Viridiplantae_2.fq -t ${id_2_otu}                 --fastq-output --include-children
        fi

        # 3th READ EXTRACTION
        if [ "Fungi" = "-" ]; 
            then
                echo "No third OTU of interest provided by the user"
            else
                # Getting the tax-id of the third OTU
                id_3_otu=$(grep -m1 "$(printf '\t')Fungi$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Fungi"\t"${id_3_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""Fungi"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_paired.fq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_paired.fq*                 -o ${sequences}/${count}/${count}_bacterial_1.fq                 -o2 ${sequences}/${count}/${count}_bacterial_2.fq -t ${id_1_otu} ${id_2_otu} ${id_3_otu}            --exclude     --fastq-output --include-children
        fi
