ls documents/lichen_microbiome_taxa_extracted_metaeuk/| while read line; do group=$(echo ${line} | cut -d_ -f1); cat documents/lichen_microbiome_taxa_extracted_metaeuk/${line} | while read line; do lin=$(echo ${line}); ls analyses/contig_sorting/8066_env/sorted_sequences/ | while read line; do samp=$(echo ${line}); cp analyses/contig_sorting/8066_env/sorted_sequences/${samp}/kraken_trimmed_sequences/*${lin}*.fna /hpc/group/bio1/diego/sequences/${group}/kraken_trimmed_sequences/ ; cp analyses/contig_sorting/8066_env/sorted_sequences/${samp}/*${lin}*.fna /hpc/group/bio1/diego/sequences/${group}/;done;done;done