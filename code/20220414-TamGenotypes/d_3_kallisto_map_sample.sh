#!/usr/bin/env bash

sample="${1:-SRR8375359}"

assembly="GRCh38"

ref_gtf="/bio/ref/gtf/Homo_sapiens.${assembly}.105.gtf.gz"
ref_gen="/bio/ref/dna/homo_sapiens/${assembly}/MT.fa.gz"

#

kallisto="/bio/tools/kallisto/src/build/src/kallisto"

#

src="/bio/als/data/20220414-Tam-2019/samples_preprocessed/${sample}"

tx_cdna_file="$(find output/a*/*cdna.fa)"
tx_cdna_index="$(find output/b*/*.kallisto.idx)"

#

out_dir="output/$(basename -s ".sh" "$0")/${sample}"
mkdir -p "${out_dir}" || exit 1

echo "Created $(date -Is) by: $0" >"${out_dir}/source.txt"

#

# Expected Kallisto output file
bam1_full="${out_dir}/pseudoalignments.bam"
bam2_mapped_only="${bam1_full}.mapped_only.bam"
bam3_sorted="${bam2_mapped_only}.sorted.bam"

#

if [ ! -e "${bam1_full}" ]; then
  echo "Mapping to ${bam1_full} ..."

  # Map reads to transcripts
  # https://cyverse-leptin-rna-seq-lesson-dev.readthedocs-hosted.com/en/latest/section-8.html

  "${kallisto}" \
    quant \
    --index="${tx_cdna_index}" \
    --output-dir "$(dirname "${bam1_full}")" \
    --genomebam \
    --gtf="${ref_gtf}" \
    --threads=7 \
    "${src}"/*val_1.fq.gz \
    "${src}"/*val_2.fq.gz
fi

#

if [[ ! -f "${bam2_mapped_only}" ]]; then
  ## https://www.biostars.org/p/56246/
  echo "Filtering for mapped reads only..."
  samtools view -T "${tx_cdna_file}" -F 0x08 -b "${bam1_full}" >"${bam2_mapped_only}"
fi

#

if [[ ! -f "${bam3_sorted}" ]]; then
  echo "Sorting the smaller BAM file..."
  samtools sort --reference "${ref_gen}" -o "${bam3_sorted}" "${bam2_mapped_only}"
fi

#

out="${bam3_sorted}.bai"

if [[ ! -f "${out}" ]]; then
  echo "Indexing the smaller BAM file..."
  samtools index "${bam3_sorted}" "${out}"
fi
