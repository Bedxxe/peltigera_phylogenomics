#!/bin/bash

#SBATCH --array=1-19
#SBATCH --mem-per-cpu=24G # The RAM memory that will be asssigned to each threads
#SBATCH -c 12 # The number of threads to be used in this script
#SBATCH --output=logs/taxonomy/peltigerales_reads/metagenomes_with_nostoc_kraken_taxonomy_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/taxonomy/peltigerales_reads/metagenomes_with_nostoc_kraken_taxonomy_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script
        
        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/nostoc_phylogeny/metagenomes_with_nostoc_genome.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)

        # CALLING CONDA ENVIRONMENT
        source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
        conda activate metag

        # CREATING OUTPUT DIRECTORIES
        if [ "analyses" = "." ]; 
            then
                # sequences
                mkdir -p taxonomy/kraken/peltigerales_reads/sequences
                # kraken
                mkdir -p taxonomy/kraken/peltigerales_reads/kraken/krakens
                mkdir -p taxonomy/kraken/peltigerales_reads/kraken/reports
                # bracken
                mkdir -p taxonomy/kraken/peltigerales_reads/bracken/brackens
                mkdir -p taxonomy/kraken/peltigerales_reads/bracken/reports

                #Defining variables on the directories locations
                # sequences
                sequences=$(echo taxonomy/kraken/"peltigerales_reads"/sequences)
                # kraken
                krakens=$(echo taxonomy/kraken/"peltigerales_reads"/kraken/krakens)
                k_reports=$(echo taxonomy/kraken/"peltigerales_reads"/kraken/reports)
                # bracken
                brackens=$(echo taxonomy/kraken/"peltigerales_reads"/bracken/brackens)
                b_reports=$(echo taxonomy/kraken/"peltigerales_reads"/bracken/reports)
            else
                # sequences
                mkdir -p analyses/taxonomy/kraken/metagenomes_with_nostoc/sequences
                # kraken
                mkdir -p analyses/taxonomy/kraken/metagenomes_with_nostoc/kraken/krakens
                mkdir -p analyses/taxonomy/kraken/metagenomes_with_nostoc/kraken/reports
                # bracken
                mkdir -p analyses/taxonomy/kraken/metagenomes_with_nostoc/bracken/brackens
                mkdir -p analyses/taxonomy/kraken/metagenomes_with_nostoc/bracken/reports
                
                #Defining variables on the directories locations
                # sequences
                sequences=$(echo "analyses"/taxonomy/kraken/"metagenomes_with_nostoc"/sequences)
                # kraken
                krakens=$(echo "analyses"/taxonomy/kraken/"metagenomes_with_nostoc"/kraken/krakens)
                k_reports=$(echo "analyses"/taxonomy/kraken/"metagenomes_with_nostoc"/kraken/reports)
                # bracken
                brackens=$(echo "analyses"/taxonomy/kraken/"metagenomes_with_nostoc"/bracken/brackens)
                b_reports=$(echo "analyses"/taxonomy/kraken/"metagenomes_with_nostoc"/bracken/reports)
        fi

        # KRAKEN
        kraken2 --db /work/dg304/dala/kraken_database/programs/kraken2/10122023_s4_k49 --threads 12 --paired /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_all.fastq*         /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_all.fastq*         --output ${krakens}/${count}.kraken         --report ${k_reports}/${count}.report
        
        # BRACKEN
        bracken -d /work/dg304/dala/kraken_database/programs/kraken2/10122023_s4_k49         -i ${k_reports}/${count}.report         -o ${brackens}/${count}.bracken         -w ${b_reports}/${count}_bracken.report -r 150 -t 50
        
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
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_all.fastq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_all.fastq*                 -o ${sequences}/${count}/${count}_unclassified_1.fq                 -o2 ${sequences}/${count}/${count}_unclassified_2.fq -t 0                 --fastq-output --include-children
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
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_all.fastq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_all.fastq*                 -o ${sequences}/${count}/${count}_non_bacterial_1.fq                 -o2 ${sequences}/${count}/${count}_non_bacterial_2.fq -t 2                 --fastq-output --include-children --exclude
            else
                echo "The user does not want to extract the non-Bacterial reads"
        fi

        # 1st OTU EXTRACTION 
        if [ "Lecanoromycetes" = "Lecanoromycetes" ]; 
            then
                echo "No OTU of interest provided by the user"
            else
                # Getting the tax-id of the first OTU
                id_1_otu=$(grep "$(printf '\t')Lecanoromycetes$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Lecanoromycetes"\t"${id_1_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""Lecanoromycetes"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_all.fastq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_all.fastq*                 -o ${sequences}/${count}/${count}_w_Lecanoromycetes_1.fq                 -o2 ${sequences}/${count}/${count}_w_Lecanoromycetes_2.fq -t ${id_1_otu}   --exclude              --fastq-output --include-children
        fi

        # 2nd READ EXTRACTION
        if [ "Nostoc" = "Nostoc" ]; 
            then
                echo "No second OTU of interest provided by the user"
            else
                # Getting the tax-id of the second OTU
                id_2_otu=$(grep "$(printf '\t')Nostoc$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e Nostoc"\t"${id_2_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""Nostoc"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_all.fastq*                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_all.fastq*                 -o ${sequences}/${count}/${count}_w_Nostoc_1.fq                 -o2 ${sequences}/${count}/${count}_w_Nostoc_2.fq -t ${id_1_otu} ${id_2_otu}               --exclude  --fastq-output --include-children
        fi

        # 3th READ EXTRACTION
        if [ "-" = "-" ]; 
            then
                echo "No third OTU of interest provided by the user"
            else
                # Getting the tax-id of the third OTU
                id_3_otu=$(grep "$(printf '\t')-$(printf '\t')" /hpc/group/bio1/cyanolichen_holobiome/documents/names.dmp | grep -o '[0-9]*')
                # Writting into .tsv file
                echo -e -"\t"${id_3_otu} >> ${sequences}/${count}/otus_of_interest.tsv 
                echo -e "\n""Extracting ""-"" reads in fastq from sample: ""${count}"
                extract_kraken_reads.py -k ${krakens}/${count}.kraken                 -r ${k_reports}/${count}.report                 -s1 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R1_all.fastq                 -s2 /hpc/group/bio1/diego/lmicrobiome/lmicrob-library/${count}/${count}_R2_all.fastq                 -o ${sequences}/${count}/${count}_-_1.fq                 -o2 ${sequences}/${count}/${count}_-_2.fq -t ${id_3_otu}                 --fastq-output --include-children
        fi
