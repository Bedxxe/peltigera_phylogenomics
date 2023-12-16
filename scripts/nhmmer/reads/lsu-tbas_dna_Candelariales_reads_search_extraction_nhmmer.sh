#!/bin/bash

#SBATCH --array=1-212
#SBATCH --mem-per-cpu=4G # The RAM memory that will be asssigned to each threads
#SBATCH -c 1 # The number of threads to be used in this script
#SBATCH --output=logs/nhmmer/reads/Candelariales_reads_nhmmer_Candelariales_reads_lsu_%A_%a.out # Indicate a path where a file with the output information will be created. That directory must already exist
#SBATCH --error=logs/nhmmer/reads/Candelariales_reads_nhmmer_Candelariales_reads_lsu_%A_%a.err # Indicate a path where a file with the error information will be created. That directory must already exist
#SBATCH --partition=scavenger # Partition to be used to run the script

        # BUILDING THE VARIABLE FOR THE ARRAY COUNTER
        count=$(cat documents/metadata/complete_sample_names.txt | sort | uniq | sed -n ${SLURM_ARRAY_TASK_ID}p)
        # CALLING CONDA ENVIRONMENT
        if [ yes = "yes" ]; then
            source /hpc/group/bio1/diego/miniconda3/etc/profile.d/conda.sh
            conda activate metag       
        elif [ +- = "no" ]; then
            # No conda environment
            echo 'No conda environment'
        else
            source yes
            conda activate metag
        fi

		# CREATING OUTPUT DIRECTORIES
        if [ "analyses" = "." ]; 
            then
            	if [ "no" = "yes" ];
            		then
            			# Creating directories
		            	# mafft
						mkdir -p nhmmer/Candelariales_reads/${count}/alignment 
		                # nhmmer
		                # REMOVING FORMER OUTPUTS 
						rm -r nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas
						mkdir -p nhmmer/Candelariales_reads/${count}/nhmmer/lsu-tbas/dna
						mkdir -p nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna
						mkdir -p nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna/single_hits

						#Defining variables on the directories locations
						# mafft
						alignment=$(echo nhmmer/"Candelariales_reads"/"${count}"/alignment)
						# nhmmer
						nhmmer=$(echo nhmmer/"Candelariales_reads"/"${count}"/nhmmer/"lsu-tbas"/"dna")
						sequences=$(echo nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna")
						single_hits=$(echo nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna"/single_hits)
					else
						# nhmmer
		                # REMOVING FORMER OUTPUTS 
						rm -r nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas
						mkdir -p nhmmer/Candelariales_reads/${count}/nhmmer/lsu-tbas/dna
						mkdir -p nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna
						mkdir -p nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna/single_hits

						#Defining variables on the directories locations
						# mafft
						alignment=$(echo "-")
						# nhmmer
						nhmmer=$(echo nhmmer/"Candelariales_reads"/"${count}"/nhmmer/"lsu-tbas"/"dna")
						sequences=$(echo nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna")
						single_hits=$(echo nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna"/single_hits)
				fi
			else
				if [ "no" = "yes" ];
            		then
            			# Creating directories
		            	# mafft
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/alignment 
		                # nhmmer
		                # REMOVING FORMER OUTPUTS 
						rm -r analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/nhmmer/lsu-tbas/dna
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna/single_hits

						#Defining variables on the directories locations
						# mafft
						alignment=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/alignment)
						# nhmmer
						nhmmer=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/nhmmer/"lsu-tbas"/"dna")
						sequences=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna")
						single_hits=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna"/single_hits)
					else
						# nhmmer
		                # REMOVING FORMER OUTPUTS 
						rm -r analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas					
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/nhmmer/lsu-tbas/dna
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna/single_hits

						#Defining variables on the directories locations
						# mafft
						alignment=$(echo "-")
						# nhmmer
						nhmmer=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/nhmmer/"lsu-tbas"/"dna")
						sequences=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna")
						single_hits=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna"/single_hits)
				fi
		fi

		# MAKING DECITIONS
		if [ hmmer_profiles/tbas/profile_lsu_tbas.hmm = "no" ];
		    then
				if [ "no" = "yes" ]; 
					then
						# MAKING THE ALINGMENT WITH MAFFT
						mafft --auto --thread 1 - > $alignment/lsu-tbas_dna_aln.fasta
						# Definying the new location of the alignemnt
						profile_aln=$(echo $alignment/"lsu-tbas"_"dna"_aln.fasta)
						echo -e '\n'"The alingment has been done with mafft"'\n'
					else
						# Definying the new location of the alignemnt
						profile_aln=$(echo "-")
						echo -e '\n'"The program will proceed with the alignment located in -"'\n'
				fi

				# CREATING THE PROFILE WITH THE ALIGNMENT
				hmmbuild --cpu 1 --dna $nhmmer/${count}_lsu-tbas.hmm $profile_aln
				# Definying the new location of the profile	
				nhmmer_profile=$(echo "${nhmmer}"/"${count}"_"lsu-tbas".hmm)
			else
			# Definying the new location of the profile	
			nhmmer_profile=$(echo hmmer_profiles/tbas/profile_lsu_tbas.hmm)
			# Removing unused folders
			rm -r $alignment
		fi
		
		# SEARCHING THE PROFILE IN THE QUERY SEQUENCE(S)
		if [ "" = "+" ]; 
			then
				nhmmer --dna --cpu 1 --watson --incE 1.0e-10 				--tblout $nhmmer/${count}_lsu-tbas.tbl 				-A $nhmmer/${count}_lsu-tbas.multialignment 				-o $nhmmer/${count}_lsu-tbas_nhmmer.output 				${nhmmer_profile} problematic_otus/reads/Candelariales//${count}_Candelariales_2.fq
		elif [ "+-" = "-" ];
			then
				nhmmer --dna --cpu 1 --crick --incE 1.0e-10 				--tblout $nhmmer/${count}_lsu-tbas.tbl 				-A $nhmmer/${count}_lsu-tbas.multialignment 				-o $nhmmer/${count}_lsu-tbas_nhmmer.output 				${nhmmer_profile} problematic_otus/reads/Candelariales//${count}_Candelariales_2.fq
			else
				nhmmer --dna --cpu 1 --incE 1.0e-10 				--tblout $nhmmer/${count}_lsu-tbas.tbl 				-A $nhmmer/${count}_lsu-tbas.multialignment 				-o $nhmmer/${count}_lsu-tbas_nhmmer.output 				${nhmmer_profile} problematic_otus/reads/Candelariales//${count}_Candelariales_2.fq
		fi

		# READING THE OUTPUT FROM HMMER
		if [ "2" -eq 1 ]; then 
		# USING SEQKIT
			number_hits=$(cat $nhmmer/${count}_lsu-tbas.multialignment | wc -l )

			# DECITION BASED ON THE PRESENCE OF HITS
			if [ "${number_hits}" -eq 0 ]; then
				echo -e '\n''No hits obstained with nhmmer'
			else 
				# EXTRACTION OF THE NEEDED INFORMATION FROM THE .tbl OUTPUT FILE. This information is the name of the contigs where there was a significant match with the profile and the position
				#Creating a file where to held the information
				touch $single_hits/${count}_lsu-tbas_hits_information.tsv 
				echo -e "#Contig_name"'\t'"#From"'\t'"#To"'\t'"#Strand"'\t'"#E-value"'\t'"#Lenght"'\t'"#Original_start"'\t'"#Original_ending"'\t'"#Threshold"'\t'"#Notes" > $single_hits/${count}_lsu-tbas_hits_information.tsv

				# Reading information to the created file
				thr=$(echo 1.0e-10 )
				alignment_query=$(cat $nhmmer/${count}_lsu-tbas.tbl | sed -n 3p | awk -F ' ' '{print$3}')
				cat $nhmmer/${count}_lsu-tbas.tbl | grep "${alignment_query}" | grep -v 'Query file' | grep -v 'Option settings'| while read line;
				do hedr=$(echo $line | cut -d' ' -f1);
				seq_beg=$(echo $line | cut -d' ' -f7); 
				seq_end=$(echo $line | cut -d' ' -f8); 
				orientation_strand=$(echo $line | cut -d' ' -f12);
				evl=$(echo $line | cut -d' ' -f13 );
				x1=$(echo $evl $thr | awk '{if ($1 <= $2) print "1"; else print "0"}');


				if [ "$seq_end" -gt "$seq_beg" ] # We will rearrenge the output
					then
						contig_edge_beg=$(echo $(("$seq_beg" - "0")))
						if [ "$contig_edge_beg" -gt "0" ]; then				
							adj_seq_beg=$(echo $(("$seq_beg" - "0")))
						else
							adj_seq_beg=$(echo "0")
							note=$(echo "beggining_on_contig_edge")
						fi

						contig_edge_end=$(echo $(("$seq_end" + "0")))
						if [ "$contig_edge_end" -gt "0" ]; then	
							adj_seq_end=$(echo $(("$seq_end" + "0")))
						else
							adj_seq_end=$(echo "0")
							note=$(echo "end_on_contig_edge")
						fi
						seq_lenght=$(echo $(("$adj_seq_end" - "$adj_seq_beg")))
						if [ "$x1" -eq 1 ]; then
							echo -e $hedr'\t'$adj_seq_beg'\t'$adj_seq_end'\t'$orientation_strand'\t'$evl'\t'$seq_lenght'\t'$seq_beg'\t'$seq_end'\t'"$thr"'\t'"$note" >> $single_hits/${count}_lsu-tbas_hits_information.tsv
						fi
					else
						contig_edge_beg=$(echo $(("$seq_beg" + "0")))
						if [ "$contig_edge_beg" -gt "0" ]; then				
							adj_seq_beg=$(echo $(("$seq_beg" + "0")))
						else
							adj_seq_beg=$(echo "0")
							note=$(echo "beggining_on_contig_edge")
						fi

						contig_edge_end=$(echo $(("$seq_end" - "0")))
						if [ "$contig_edge_end" -gt "0" ]; then	
							adj_seq_end=$(echo $(("$seq_end" - "0")))
						else
							adj_seq_end=$(echo "0")
							note=$(echo end_on_contig_edge)
						fi
						seq_lenght=$(echo $(("$adj_seq_beg" - "$adj_seq_end")))
						if [ "$x1" -eq 1 ]; then
							echo -e $hedr'\t'$adj_seq_end'\t'$adj_seq_beg'\t'$orientation_strand'\t'$evl'\t'$seq_lenght'\t'$seq_end'\t'$seq_beg'\t'"$thr"'\t'"$note" >> $single_hits/${count}_lsu-tbas_hits_information.tsv
						fi
				fi;
				done

				#EXTRACTING THE INFORMATION FROM ALL THE HITS FOUND WITH HMMER USING SEQKIT
				touch $single_hits/${count}_lsu-tbas_all_concatenated.fasta
				cat $single_hits/${count}_lsu-tbas_hits_information.tsv | sed -n '1!p' | while read line;
				do 
					hedr=$(echo $line | cut -d' ' -f1);
					node=$(echo $hedr | cut -d'_' -f1,2);
					beg=$(echo $line | cut -d' ' -f2);
					endo=$(echo $line | cut -d' ' -f3);
					seq_lenght=$(echo $line | cut -d' ' -f6);
					seqkit subseq problematic_otus/reads/Candelariales//${count}_Candelariales_2.fq -r $beg:$endo --chr "$hedr" -o ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta;
					old_label=$(grep '>' ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta | cut -d' ' -f1);
					new_label=$(echo '>'"${count}"_"lsu-tbas"_"$node"_"${seq_lenght}");
		        	sed -i "s/${old_label} .*/${new_label}/g" ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta;
					# Concatenating the sequences
					cat ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta >> ${single_hits}/${count}_lsu-tbas_all_concatenated.fasta;
					echo "done with sequence" $node;
				done
			fi

				##---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				# EXTRACTING THE BEST HITS IF THE USER SO DESIRE TO
				if [ "0" -gt 0 ]; then
					# CREATING OUTPUT DIRECTORIES
		        	if [ "analyses" = "." ]; then
		        		# Creating directories
						mkdir -p nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna/best_hits
						#Defining variables on the directories locations
						best_hits=$(echo nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna"/best_hits)
					else
		        		# Creating directories
						mkdir -p analyses/nhmmer/Candelariales_reads/${count}/sequences/lsu-tbas/dna/best_hits
						#Defining variables on the directories locations
						best_hits=$(echo "analyses"/nhmmer/"Candelariales_reads"/"${count}"/sequences/"lsu-tbas"/"dna"/best_hits)
					fi
					
					# Extraction of the information from the .tbl file
					touch $best_hits/${count}_lsu-tbas_best_hits_information.tsv
					echo -e "#Contig_name"'\t'"#From"'\t'"#To"'\t'"#Strand"'\t'"#E-value"'\t'"#T_test"'\t'"#Lenght"'\t'"#Original_start"'\t'"#Original_ending"'\t'"#Threshold"'\t'"#Notes" > $best_hits/${count}_lsu-tbas_best_hits_information.tsv 

					# Reading information to the created file
					thr=$(echo 1.0e-10 )
					for (( i=1 ; i<="0" ; i++ )); do
						sequence_line=$( echo $(( "2" + ${i} )) );
						info=$(cat $nhmmer/${count}_lsu-tbas.tbl | sed -n "${sequence_line}"p);
						hedr=$(echo $info | cut -d' ' -f1);
						seq_beg=$(echo $info | cut -d' ' -f7); 
						seq_end=$(echo $info | cut -d' ' -f8); 
						orientation_strand=$(echo $info | cut -d' ' -f12);
						evl=$(echo $info | cut -d' ' -f13 );
						x1=$(echo $evl $thr | awk '{if ($1 < $2) print "1"; else print "0"}');

						# Evaluate if there is more results
		                if [ "${hedr}" = "#" ];
		                        then
		                                echo "No more results to report"
		                        else
									if [ "$seq_end" -gt "$seq_beg" ] # We will rearrenge the output
										then
											contig_edge_beg=$(echo $(("$seq_beg" - "0")))
											if [ "$contig_edge_beg" -gt "0" ]; then				
												adj_seq_beg=$(echo $(("$seq_beg" - "0")))
											else
												adj_seq_beg=$(echo "0")
												note=$(echo "beggining_on_contig_edge")
											fi

											contig_edge_end=$(echo $(("$seq_end" + "0")))
											if [ "$contig_edge_end" -gt "0" ]; then	
												adj_seq_end=$(echo $(("$seq_end" + "0")))
											else
												adj_seq_end=$(echo "0")
												note=$(echo "end_on_contig_edge")
											fi
											
											seq_lenght=$(echo $(("$adj_seq_end" - "$adj_seq_beg")))
											
											if [ "$x1" -eq 1 ]; then
												t_output=$( echo "Yes" )
											else
												t_output=$( echo "No" )
											fi

											echo -e $hedr'\t'$adj_seq_beg'\t'$adj_seq_end'\t'$orientation_strand'\t'$evl'\t'$t_output'\t'$seq_lenght'\t'$seq_beg'\t'$seq_end'\t'"$thr"'\t'"$note" >> $best_hits/${count}_lsu-tbas_best_hits_information.tsv
										else
											contig_edge_beg=$(echo $(("$seq_beg" + "0")))
											if [ "$contig_edge_beg" -gt "0" ]; then				
												adj_seq_beg=$(echo $(("$seq_beg" + "0")))
											else
												adj_seq_beg=$(echo "0")
												note=$(echo "beggining_on_contig_edge")
											fi

											contig_edge_end=$(echo $(("$seq_end" - "0")))
											if [ "$contig_edge_end" -gt "0" ]; then	
												adj_seq_end=$(echo $(("$seq_end" - "0")))
											else
												adj_seq_end=$(echo "0")
												note=$(echo end_on_contig_edge)
											fi
											seq_lenght=$(echo $(("$adj_seq_beg" - "$adj_seq_end")))
											
											if [ "$x1" -eq 1 ]; then
												t_output=$( echo "Yes" )
											else
												t_output=$( echo "No" )
											fi

											echo -e $hedr'\t'$adj_seq_end'\t'$adj_seq_beg'\t'$orientation_strand'\t'$evl'\t'$t_output'\t'$seq_lenght'\t'$seq_end'\t'$seq_beg'\t'"$thr"'\t'"$note" >> $best_hits/${count}_lsu-tbas_best_hits_information.tsv
									fi;
						fi;
					done

					#EXTRACTING THE INFORMATION FROM ALL THE HITS FOUND WITH HMMER
					touch ${best_hits}/${count}_lsu-tbas_all_best_hits_concatenated.fasta
					cat ${best_hits}/${count}_lsu-tbas_best_hits_information.tsv | sed -n '1!p' | while read line;
					do 
						hedr=$(echo $line | cut -d' ' -f1);
						node=$(echo $hedr | cut -d'_' -f1,2);
						beg=$(echo $line | cut -d' ' -f2);
						endo=$(echo $line | cut -d' ' -f3);
						seq_lenght=$(echo $line | cut -d' ' -f7);
						seqkit subseq problematic_otus/reads/Candelariales//${count}_Candelariales_2.fq -r $beg:$endo --chr "$hedr" -o ${best_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta;
			        	old_label=$(grep '>' ${best_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta | cut -d' ' -f1);
						new_label=$(echo '>'"${count}"_"lsu-tbas"_"$node");
		        		sed -i "s/${old_label} .*/${new_label}/g" ${best_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta;
						# Concatenating the sequences
						cat $best_hits/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta >> $best_hits/${count}_lsu-tbas_all_best_hits_concatenated.fasta;
					done
				else
					echo "The user do not want the extraction of a specific number of best_hits"
				fi
		else
		#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			# USING faSomeRecords
			number_hits=$(cat $nhmmer/${count}_lsu-tbas.multialignment | wc -l )

			# DECITION BASED ON THE PRESENCE OF HITS
			if [ "${number_hits}" -eq 0 ]; then
				echo -e '\n''No hits obstained with nhmmer'
			else 
				# EXTRACTION OF THE NEEDED INFORMATION FROM THE .tbl OUTPUT FILE. This information is the name of the contigs where there was a significant match with the profile and the position
				#Creating a file where to held the information
				touch $single_hits/${count}_lsu-tbas_hits_information.tsv 
				echo -e "#Contig_name"'\t'"#Strand"'\t'"#E-value"'\t'"#Lenght"'\t'"#Threshold" > $single_hits/${count}_lsu-tbas_hits_information.tsv

				# Reading information to the created file
				thr=$(echo 1.0e-10 )
				alignment_query=$(cat $nhmmer/${count}_lsu-tbas.tbl | sed -n 3p | awk -F ' ' '{print$3}')
				cat $nhmmer/${count}_lsu-tbas.tbl | grep "${alignment_query}" | grep -v 'Query file' | grep -v 'Option settings'| while read line; do 
					hedr=$(echo $line | cut -d' ' -f1);
					orientation_strand=$(echo $line | cut -d' ' -f12);
					seq_lenght=$(echo $line | cut -d' ' -f11);
					evl=$(echo $line | cut -d' ' -f13 );
					x1=$(echo $evl $thr | awk '{if ($1 <= $2) print "1"; else print "0"}');

					if [ "$x1" -eq 1 ]; then
						echo -e $hedr'\t'$orientation_strand'\t'$evl'\t'$seq_lenght'\t'"$thr"'\t' >> $single_hits/${count}_lsu-tbas_hits_information.tsv
					fi
				done		
				#EXTRACTING THE INFORMATION FROM ALL THE HITS FOUND WITH HMMER USING faSomeRecords
				touch $single_hits/${count}_lsu-tbas_all_concatenated.fasta
				cat $single_hits/${count}_lsu-tbas_hits_information.tsv | sed -n '1!p' | while read line;
				do 
					hedr=$(echo $line | cut -d' ' -f1);
					node=$(echo $hedr | cut -d'_' -f1,2);
					seq_lenght=$(echo $line | cut -d' ' -f4);
					/hpc/group/bio1/diego/programs/faSomeRecords/faSomeRecords.py -f problematic_otus/reads/Candelariales//${count}_Candelariales_2.fq -r "${hedr}" -o ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta;
					old_label=$(grep '>' ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta | cut -d' ' -f1);
					new_label=$(echo '>'"${count}"_"lsu-tbas"_"$node"_"${seq_lenght}");
		        	sed -i "s/${old_label} .*/${new_label}/g" ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta;
					# Concatenating the sequences
					cat ${single_hits}/"${count}"_"lsu-tbas"_"$node"_length_"$seq_lenght".fasta >> ${single_hits}/${count}_lsu-tbas_all_concatenated.fasta;
					echo "done with sequence" $node;
				done
			fi
		fi	
