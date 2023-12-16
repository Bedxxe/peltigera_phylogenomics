#!/bin/bash

#SBATCH --array=1-12
#SBATCH --mem-per-cpu=16G # The RAM memory that will be asssigned to each threads
#SBATCH -c 24 # The number of threads to be used in this script
#SBATCH --output=logs/assembly/peltigera_hybrid/peltigera_hybrid_spades_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/assembly/peltigera_hybrid/peltigera_hybrid_spades_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/taxonomy/metaeuk/opera_contigs/sample_names.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)
        # CALLING CONDA ENVIRONMENT
        if [ yes = "yes" ]; then
            source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
            conda activate metag       
        elif [ yes = "no" ]; then
            # No conda environment
            echo 'No conda environment'
        else
            source yes
            conda activate metag
        fi

        # LOADING MODULES
        module load SPAdes/3.15.4-rhel8
        
    		# CREATING OUTPUT DIRECTORIES
             if [ "analyses" = "." ]; 
                then
                    # Directories
                    # fastp
                    #mkdir -p trimming/fastp/${count}/spades/unpaired
                    #mkdir -p trimming/fastp/${count}/spades/paired
                    
                    # spades
                    mkdir -p assemblies/spades/peltigera_hybrid/${count}
                    mkdir -p assemblies/spades/peltigera_hybrid/contigs
                    mkdir -p assemblies/spades/peltigera_hybrid/scaffolds
                    if [ no = "yes" ];
                        then
                            mkdir -p assemblies/spades/peltigera_hybrid/${count}/plasmids
                    fi
                    
                    # Defining variables on the directories locations
                    # fastp
                    #trimming=$(echo trimming/fastp/"${count}"/spades)
                    #paired=$(echo trimming/fastp/"${count}"/spades/paired)
                    #unpaired=$(echo trimming/fastp/"${count}"/spades/unpaired)

                    # spades
                    assembly=$(echo assemblies/spades/"peltigera_hybrid"/"${count}")
                    contigs=$(echo assemblies/spades/"peltigera_hybrid"/contigs)
                    scaffolds=$(echo assemblies/spades/"peltigera_hybrid"/scaffolds)
                    if [ no = "yes" ];
                        then
                            plasmids=$(echo assemblies/spades/"peltigera_hybrid"/"${count}"/plasmids)
                    fi
    			else				
                    # Directories
                    # fastp
                    #mkdir -p analyses/trimming/fastp/${count}/spades/unpaired
                    #mkdir -p analyses/trimming/fastp/${count}/spades/paired

                    # spades
                    mkdir -p analyses/assemblies/spades/peltigera_hybrid/${count}
                    mkdir -p analyses/assemblies/spades/peltigera_hybrid/contigs
                    mkdir -p analyses/assemblies/spades/peltigera_hybrid/scaffolds
                    if [ no = "yes" ];
                        then
                            mkdir -p analyses/assemblies/spades/peltigera_hybrid/${count}/plasmids
                    fi                
                    
                    # Defining variables on the directories locations
                    # fastp
                    #trimming=$(echo "analyses"/trimming/fastp/"${count}"/spades)
                    #paired=$(echo "analyses"/trimming/fastp/"${count}"/spades/paired)
                    #unpaired=$(echo "analyses"/trimming/fastp/"${count}"/spades/unpaired)

                    # spades
                    assembly=$(echo "analyses"/assemblies/spades/"peltigera_hybrid"/"${count}")
                    contigs=$(echo "analyses"/assemblies/spades/"peltigera_hybrid"/contigs)
                    scaffolds=$(echo "analyses"/assemblies/spades/"peltigera_hybrid"/scaffolds)
                    if [ no = "yes" ];
                        then
                            plasmids=$(echo "analyses"/assemblies/spades/"peltigera_hybrid"/${count}/plasmids)
                    fi                
    		fi

            # EXECUTING SPADES GENERAL
            spades.py -1 sequences/lecanoromycetes_12_discipulos/illumina/${count}/${count}_Lecanoromycetes_1.fq             -2 sequences/lecanoromycetes_12_discipulos/illumina/${count}/${count}_Lecanoromycetes_2.fq            -o ${assembly} -t 24             -k 21,29,39,49,59,79,97,105,117 -m 384              --careful  --nanopore sequences/lecanoromycetes_12_discipulos/long_reads/${count}_Lecanoromycetes.fasta
            cp ${assembly}/scaffolds.fasta ${scaffolds}/${count}_scaffolds.fasta
            cp ${assembly}/contigs.fasta ${contigs}/${count}_contigs.fasta

            if [ yes = "no" ];
                then
                    rm -r ${assembly}/tmp
                    rm -r ${assembly}/K*
            fi


            # FOR PLASMIDS
            if [ no = "yes" ];
                then
                    spades.py -1 sequences/lecanoromycetes_12_discipulos/illumina/${count}/${count}_Lecanoromycetes_1.fq                     -2 sequences/lecanoromycetes_12_discipulos/illumina/${count}_Lecanoromycetes_2.fq                     -o ${plasmids} -t 24                     -k 21,29,39,49,59,79,97,105,117  -m 384 --meta --plasmid
                else
                    echo 'User choose not to obtain plasmid assembly'
            fi         

            if [ yes = "no" ];
                then
                    rm -r ${plasmids}/tmp
                    rm -r ${plasmids}/K*
            fi   
