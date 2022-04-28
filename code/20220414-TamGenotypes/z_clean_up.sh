rm -v output/d_3_kallisto_map_sample/*/pseudoalignments.bam
rm -v output/d_3_kallisto_map_sample/*/pseudoalignments.bam.bai
rm -v output/d_3_kallisto_map_sample/*/pseudoalignments.bam.mapped_only.bam
rm -v output/d_3_kallisto_map_sample/*/pseudoalignments.bam.mapped_only.bam.bai

# Downloaded read files (very large)
rm -v ../../data/*-Tam-2019/samples_original/*/*.fastq.gz

# Subsampled read files (large)
rm -v ../../data/*-Tam-2019/samples_preprocessed/*/*sub_1.fq.gz
rm -v ../../data/*-Tam-2019/samples_preprocessed/*/*sub_2.fq.gz

# There shouldn't be any of these temporary files
rm -v ../../data/*-Tam-2019/samples_preprocessed/*/*trimmed.fq.gz

# "Validated" reads: keep
#ls ../../data/*-Tam-2019/samples_preprocessed/*/*_val_1.fq.gz
#ls ../../data/*-Tam-2019/samples_preprocessed/*/*_val_2.fq.gz
