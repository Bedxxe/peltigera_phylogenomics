#!/bin/bash

# EXTRACTION OF SPECIFIC CONTIGS FROM A FASTA FILE

# DATE OF CREATION: 08/30/2023

# This script will take a fasta file (was initially thinked for using contigs from an assembly) and get specific contigs from that file to create a subset of the sequences that 
# includes only the desired contigs

# Answer to all the decision question with "yes" if that function wants to be used in the program. THE ANSWER IS CASE SENSITIVE!
# Please give all the paths without and ending dash "/" character

# You need to give the script a file with the name of the taxa that you want to extract in the as the first column. The third column must contain the string to catch this taxa in the metaeuk output file. IT IS IMPORTAT THAT STRINGS WITH LESS THAN 6 CHARACTERS CAN RESULT IN FALSE POSITIVES:
#Caulobacter	75	76892;75
#Sphingomonas	13687	41297;13687
#Entirovirga	2026349	2026349
#Mesorhizobium	68287	69277;68287
#Rhizobium	379	227290;379
#Agrobacterium	357	227290;357

# DECLARE USEFUL VARIABLES FOR THE PROCESS:
sign='$'

# DEFINYING THE VARIABLES
pref=${1} # A prefix for the output files that the user want to be present in the outputs
sample=${2} # A file with the list of the samples that you want to process. This can be only one sample
out_dir=${3} # Directory where the user want to generate the output. If you want the output files and folder to be in the actual location, write "."
contigs_path=${4} # Path to the folder where the fasta file to process is stored
contigs_suff=${5} # Suffix of the fasta file taht follows after the sample name (e.g. ".fna" for 3.fna)
metaeuk_path=${6} # The path to the metaeuk output folder. In this path there must be a folder for each of the samples that you want to process. Each of these folders must contain the respective sample "per_contig.tsv" file
info_file=${7} # This needs to be a tsv table with the first column with the name of the name of the taxa to extract and the third one with the string to fetch it from the annotation. As an example:
#Caulobacter	75	76892;75
#Sphingomonas	13687	41297;13687
#Entirovirga	2026349	2026349
#Mesorhizobium	68287	69277;68287
#Rhizobium	379	227290;379
#Agrobacterium	357	227290;357
fasta_to_tbl=${8} # Location of the file to convert fasta to table
tbl_to_fasta=${9} # Location of the file to convert a table to fasta
keep_tables=${10} # Tell the program if you want to keep the tables generated with the fasta_to_table script: yes/no
kraken_trim=${11} # Tell the script if you want to trim the extracted files to use them with kraken: yes/no
slurm=${12} # Indicate the program if you would like to run the output script in a SLURM based cluster: yes/no
if [ ${slurm} = "yes" ];
    then
    	cores=${13} # The numbere of cores to use.
        ram=${14} # Ammount of Gb to use to each thread
        log_files=${15} # The name of both, the output and the error files that SLURM creates
        log_dir=${16} # Directory where to place a folder to put the logs
        script_dir=${17} # Directory where to place the script once it has been created
        par=${18} # The name of the partition where the user wants the job to be run
        w_execute=${19} # Tell the script if you want to execute it on the cluster right after producing the final script
        n_samp=$(cat ${sample} | sort | uniq | wc -l) # The number of iterations in the array of SLURM
        total_ram=$(echo $(("${cores}" * "${ram}")))
    else
        max_jobs=${13} # The maximun number of jobs that the user wants to run in the local computer
fi

# PRINTING THE VARIABLES TO THE USER
echo -e 'These are the variables that you specified to the program: '"\n"
echo -e 'Prefix to be used for the files:'"\t""\t""\t""${pref}"
echo -e 'Location of the table with the fasta files information:'"\t""\t""\t""${sample}"
echo -e 'Directory to create the outputs:'"\t""\t""\t""${out_dir}"
echo -e 'Path to the contig to process:'"\t""\t""\t""${contigs_path}"
echo -e 'Suffix of the contigs files:'"\t""\t""\t""${contigs_suff}"
echo -e 'Path to the folder that contain the metaeuk output:'"\t""\t""\t""${metaeuk_path}"
echo -e 'The file that contains the taxa to extract:'"\t""\t""\t""${info_file}"
echo -e 'Location of the fasta_to_table script'"\t""\t""\t""${fasta_to_tbl}"
echo -e 'Location of the table_to_fasta script'"\t""\t""\t""${tbl_to_fasta}"
echo -e 'The user wants to keep the tables generated from fasta'"\t""\t""\t""${keep_tables}"
echo -e 'The user wants to get the extracted sequences trimmed for use them with kraken:'"\t""\t""\t""${kraken_trim}"
####
if [ ${slurm} = "yes" ]; 
    then
        echo -e "\n"'You chose to run the program in a SLURM-based cluster'
        echo -e 'Threads to use in the process:'"\t""\t""\t""${cores}"
        echo -e 'Gb to use to each thread:'"\t""\t""\t""${ram}"
        echo -e 'Total of RAM to use in each process:'"\t""\t""\t""${total_ram}"
        echo -e 'Name for output files:'"\t""\t""\t""${log_files}"
        echo -e 'Directory to locate the logs:'"\t""\t""\t""${log_dir}"
        echo -e 'Location to put the generated script:'"\t""\t""\t""${script_dir}"
        echo -e 'Partition to use in SLURM:'"\t""\t""\t""${par}"
        echo -e 'The number of samples to process:'"\t""\t""\t""${n_samp}""\n"
    else
        echo -e "\n"'You chose to run the program in a local computer'
        echo -e 'The number of samples to process:'"\t""\t""\t""${n_samp}""\n"
fi

# MAIN BODY
if [ ${slurm} = "yes" ];
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # WITH SLURM
    then 
        # CREATING LOGS DIRECTORIES
        mkdir -p ${log_dir}
        mkdir -p ${script_dir}


       # MAIN SLUMRM SCRIPT
        cat << EOF > ${pref}_extract_contigs_metaeuk_body.sh


        # CREATING OUTPUT DIRECTORIES
		
		if [ "${out_dir}" = "." ]; 
		    then
		        mkdir -p contig_sorting/${pref}/sorted_sequences/${sign}{count}
		        mkdir -p contig_sorting/${pref}/tables/${sign}{count}
		        mkdir -p contig_sorting/${pref}/documents/${sign}{count}
		        
		        # Defining variables on the directories locations
		        sorted=${sign}(echo contig_sorting/"${pref}"/sorted_sequences/${sign}{count})
		        tables=${sign}(echo contig_sorting/"${pref}"/tables/${sign}{count})
		        documents=${sign}(echo contig_sorting/${pref}/documents/${sign}{count})
		    else
		        mkdir -p ${out_dir}/contig_sorting/${pref}/sorted_sequences/${sign}{count}
		        mkdir -p ${out_dir}/contig_sorting/${pref}/tables/${sign}{count}
		        mkdir -p ${out_dir}/contig_sorting/${pref}/documents/${sign}{count}
		        
		        # Defining variables on the directories locations
		        sorted=${sign}(echo "${out_dir}"/contig_sorting/"${pref}"/sorted_sequences/${sign}{count})
		        tables=${sign}(echo "${out_dir}"/contig_sorting/"${pref}"/tables/${sign}{count})
		        documents=${sign}(echo "${out_dir}"/contig_sorting/${pref}/documents/${sign}{count})
		fi

		# CONVERTING THE FASTA FILE INTO A TABLE
		sh ${fasta_to_tbl} ${contigs_path}/${sign}{count}${contigs_suff} > ${sign}{tables}/${sign}{count}.tbl


        # READING THE TAXA THAT ARE GOING TO BE EXTRACTED
        cat ${info_file} | while read line; do
        	# Getting variables with the information from the table
        	taxa=${sign}(echo ${sign}{line} | awk -F ' ' '{print${sign}1}');
        	tid=${sign}(echo ${sign}{line} | awk -F ' ' '{print${sign}2}');
        	decoy=${sign}(echo ${sign}{line} | awk -F ' ' '{print${sign}3}');

        	# GETTING THE NAMES OF THE CONTIGS FOR EACH TAXA
        	grep "${sign}{decoy}" ${metaeuk_path}/${sign}{count}/${sign}{count}_tax_per_contig.tsv | awk -F ' ' '{print${sign}1}' > ${sign}{documents}/${sign}{count}_${sign}{taxa}_contigs.txt

			# GETTING THE DESIRED CONTIGS
			# Creating an empty file to store the information
			touch ${sign}{sorted}/${sign}{count}_${sign}{taxa}.temp
			# Getting the contigs from the list
			cat ${sign}{documents}/${sign}{count}_${sign}{taxa}_contigs.txt | while read line; do
			    contig=${sign}(echo ${sign}{line});
			    grep -m1 ${sign}{contig} ${sign}{tables}/${sign}{count}.tbl >> ${sign}{sorted}/${sign}{count}_${sign}{taxa}.temp
			done

			# TRANSFORMING THE TABLE FILE TO FASTA
			sh ${tbl_to_fasta} ${sign}{sorted}/${sign}{count}_${sign}{taxa}.temp > ${sign}{sorted}/${sign}{count}_${sign}{taxa}.fna
			rm ${sign}{sorted}/${sign}{count}_${sign}{taxa}.temp

			# TRIMMING FOR KRAKEN
			
			if [ "${kraken_trim}" = "yes" ]; then	
				# Making a folder for the trimmed sequences
				
				if [ "${out_dir}" = "." ]; 
			    then
			        mkdir -p contig_sorting/${pref}/sorted_sequences/${sign}{count}/kraken_trimmed_sequences
			        # Defining variables on the directories locations
			        kraken=${sign}(echo contig_sorting/${pref}/sorted_sequences/${sign}{count}/kraken_trimmed_sequences)
			    else
			        mkdir -p ${out_dir}/contig_sorting/${pref}/sorted_sequences/${sign}{count}/kraken_trimmed_sequences
			        #Defining variables on the directories locations
			        kraken=${sign}(echo "${out_dir}"/contig_sorting/${pref}/sorted_sequences/${sign}{count}/kraken_trimmed_sequences)
				fi

				# Creating the new label for the contigs headers
				label=${sign}(echo '>'"${sign}{taxa}""|kraken:taxid|""${sign}{tid}")

				# Copying the original file to modify it later
		        cp ${sign}{sorted}/${sign}{count}_${sign}{taxa}.fna ${sign}{kraken}/${sign}{count}_${sign}{taxa}.fna
		        sed -i "s/>.*/${sign}{label}/g" ${sign}{kraken}/${sign}{count}_${sign}{taxa}.fna
			fi

		done

        # DECITION ON THE TABLES
        if [ ${keep_tables} = "no" ]; then
            rm -r ${sign}{tables}
        fi

EOF

		if [ ${n_samp} -eq 1 ]; then
			# SLURM HEADER FOR A SINGLE SAMPLE
			cat << EOF1 > ${pref}_extract_contigs_metaeuk_header.sh
#!/bin/bash

#SBATCH --mem-per-cpu=${ram}G # The RAM memory that will be asssigned to each threads
#SBATCH -c ${cores} # The number of threads to be used in this script
#SBATCH --output=${log_dir}/${pref}_${log_files}.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=${log_dir}/${pref}_${log_files}.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=${par} # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=${sign}(cat ${sample} | sort | uniq)
EOF1
			else
			# SLURM HEADER WITH ARRAYS
			cat << EOF1 > ${pref}_extract_contigs_metaeuk_header.sh
#!/bin/bash

#SBATCH --array=1-${n_samp}
#SBATCH --mem-per-cpu=${ram}G # The RAM memory that will be asssigned to each threads
#SBATCH -c ${cores} # The number of threads to be used in this script
#SBATCH --output=${log_dir}/${pref}_${log_files}_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=${log_dir}/${pref}_${log_files}_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=${par} # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=${sign}(cat ${sample} | sort | uniq | sed -n ${sign}{SLURM_ARRAY_TASK_ID}p)
EOF1
		fi	
		# CONCATENATING THE SLURM SCRIPT
		cat ${pref}_extract_contigs_metaeuk_header.sh ${pref}_extract_contigs_metaeuk_body.sh > ${pref}_extract_contigs_metaeuk.sh

		# REMOVING THE TEMPLETES AND MOVING THE FINAL SCRIPT TO THE FOLDER
		rm ${pref}_extract_contigs_metaeuk_body.sh ${pref}_extract_contigs_metaeuk_header.sh	
		mv ${pref}_extract_contigs_metaeuk.sh ${script_dir}/${pref}_extract_contigs_metaeuk.sh

        # EXECUTING THE SCRIPT
        if [ ${w_execute} = "yes" ]; then
            sbatch ${script_dir}/${pref}_extract_contigs_metaeuk.sh
        fi
else
        # MAIN SCRIPT
        echo gracias
fi

echo -e "\n"'Thank you for using this script.'"\n"
