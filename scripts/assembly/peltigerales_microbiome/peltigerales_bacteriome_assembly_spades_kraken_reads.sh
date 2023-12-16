#!/bin/bash

#SBATCH --array=1-130 
#SBATCH --mem-per-cpu=12G # The RAM memory that will be asssigned to each threads
#SBATCH -c 12 # The number of threads to be used in this script
#SBATCH --output=logs/assembly/peltigerales_bacteriome/peltigerales_bacteriome_spades_kraken_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/assembly/peltigerales_bacteriome/peltigerales_bacteriome_spades_kraken_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/peltigerale_v2/tree_nibs.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)

        # OUTPUT DIRECTORIES
        if [ "analyses" = "." ]; 
            then
                # Directories
                # fastp
                mkdir -p trimming/fastp/${count}/kraken_extracted_reads/unpaired
                mkdir -p trimming/fastp/${count}/kraken_extracted_reads/paired
                
                # spades
                mkdir -p assemblies/kraken_extracted_reads/peltigerales_bacteriome/${count}
                mkdir -p assemblies/kraken_extracted_reads/peltigerales_bacteriome/contigs
                mkdir -p assemblies/kraken_extracted_reads/peltigerales_bacteriome/scaffolds
                if [ yes = "yes" ];
                    then
                        mkdir -p assemblies/kraken_extracted_reads/peltigerales_bacteriome/${count}/plasmids
                fi
                
                # Defining variables on the directories locations
                # fastp
                trimming=$(echo trimming/fastp/"${count}"/kraken_extracted_reads)
                paired=$(echo trimming/fastp/"${count}"/kraken_extracted_reads/paired)
                unpaired=$(echo trimming/fastp/"${count}"/kraken_extracted_reads/unpaired)

                # spades
                assembly=$(echo assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/"${count}")
                contigs=$(echo assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/contigs)
                scaffolds=$(echo assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/scaffolds)
                if [ yes = "yes" ];
                    then
                        plasmids=$(echo assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/"${count}"/plasmids)
                fi

            else
                # Directories
                # fastp
                mkdir -p analyses/trimming/fastp/${count}/kraken_extracted_reads/unpaired
                mkdir -p analyses/trimming/fastp/${count}/kraken_extracted_reads/paired

                # spades
                mkdir -p analyses/assemblies/kraken_extracted_reads/peltigerales_bacteriome/${count}
                mkdir -p analyses/assemblies/kraken_extracted_reads/peltigerales_bacteriome/contigs
                mkdir -p analyses/assemblies/kraken_extracted_reads/peltigerales_bacteriome/scaffolds
                if [ yes = "yes" ];
                    then
                        mkdir -p analyses/assemblies/kraken_extracted_reads/peltigerales_bacteriome/${count}/plasmids
                fi                
                
                # Defining variables on the directories locations
                # fastp
                trimming=$(echo "analyses"/trimming/fastp/"${count}"/kraken_extracted_reads)
                paired=$(echo "analyses"/trimming/fastp/"${count}"/kraken_extracted_reads/paired)
                unpaired=$(echo "analyses"/trimming/fastp/"${count}"/kraken_extracted_reads/unpaired)

                # spades
                assembly=$(echo "analyses"/assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/"${count}")
                contigs=$(echo "analyses"/assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/contigs)
                scaffolds=$(echo "analyses"/assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/scaffolds)
                if [ yes = "yes" ];
                    then
                        plasmids=$(echo "analyses"/assemblies/kraken_extracted_reads/"peltigerales_bacteriome"/${count}/plasmids)
                fi                

        fi  

        # CALLING CONDA ENVIRONMENT
        source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
        conda activate metag

        # LOADING NEEDED MODULES
        module load SPAdes/3.14.1

        # EXECUTING FASTP
        fastp -i analyses/taxonomy/kraken/peltigerales_metagenome_reads/sequences/${count}/${count}_bacterial_1.fq         -I analyses/taxonomy/kraken/peltigerales_metagenome_reads/sequences/${count}/${count}_bacterial_2.fq         -o ${paired}/${count}_paired_bacterial_1.fq         -O ${paired}/${count}_paired_bacterial_2.fq         --unpaired1 ${unpaired}/${count}_unpaired_bacterial_1.fq         --unpaired2 ${unpaired}/${count}_unpaired_bacterial_2.fq        --html ${trimming}/${count}_peltigerales_bacteriome_fastp.html --json ${trimming}/${count}_peltigerales_bacteriome_fastp.json --thread 12


        # EXECUTING SPADES GENERAL
        spades.py -1 ${paired}/${count}_paired_bacterial_1.fq         -2 ${paired}/${count}_paired_bacterial_2.fq        -o ${assembly} -t 12         -k 21,29,39,49,59,79,97,105,117 -m 144         --meta   
        cp ${assembly}/scaffolds.fasta ${scaffolds}/${count}_scaffolds.fasta
        cp ${assembly}/contigs.fasta ${contigs}/${count}_contigs.fasta

        if [ no = "no" ];
            then
                rm -r ${assembly}/tmp
                rm -r ${assembly}/K*
        fi
 

         # FOR PLASMIDS
            if [ yes = "yes" ];
                then
                    spades.py -1 ${paired}/${count}_paired_bacterial_1.fq                     -2 ${paired}/${count}_paired_bacterial_2.fq                     -o ${plasmids} -t 12                     -k 21,29,39,49,59,79,97,105,117 -m 144 --meta --plasmid
                else
                    echo 'User choose not to obtain plasmid assembly'
            fi         

        if [ no = "no" ];
            then
                rm -r ${plasmids}/tmp
                rm -r ${plasmids}/K*
        fi   

#!/bin/bash

#SBATCH --array=1-130
#SBATCH --mem-per-cpu=12G # The RAM memory that will be asssigned to each threads
#SBATCH -c 12 # The number of threads to be used in this script
#SBATCH --output=logs/assembly/peltigerales_bacteriome/peltigerales_bacteriome_spades_kraken_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/assembly/peltigerales_bacteriome/peltigerales_bacteriome_spades_kraken_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/peltigerale_v2/tree_nibs.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)
