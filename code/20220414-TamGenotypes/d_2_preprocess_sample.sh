#!/usr/bin/env bash

sample="${1:-SRR8375359}"

src="/bio/als/data/20220414-Tam-2019/samples_original/${sample}"

out_dir_info="output/$(basename -s ".sh" "$0")/${sample}"
mkdir -p "${out_dir_info}" || exit 1

out_dir="/bio/als/data/20220414-Tam-2019/samples_preprocessed/${sample}"
mkdir -p "${out_dir}" || exit 1

echo "${out_dir}" >"${out_dir_info}/readme.txt"
echo "Created $(date -Is) by: $0" >"${out_dir}/source.txt"

#

echo -e "[$(date -Is)] Subsampling ${sample} ..."

seed=47

if [[ ! -e "${out_dir}/${sample}_sub_1.fq.gz" ]]; then
  zcat "${src}"/*_1.fast* | seqtk sample -s${seed} - 0.1 | gzip -9 >"${out_dir}/${sample}_sub_1.fq.gz"
fi

if [[ ! -e "${out_dir}/${sample}_sub_2.fq.gz" ]]; then
  zcat "${src}"/*_2.fast* | seqtk sample -s${seed} - 0.1 | gzip -9 >"${out_dir}/${sample}_sub_2.fq.gz"
fi

#

echo -e "[$(date -Is)] Filtering and trimming ${sample} ..."

trim_galore \
  --cores 6 \
  --trim-n \
  --fastqc \
  --gzip \
  --paired \
  "${out_dir}"/*_sub_1.fq* \
  "${out_dir}"/*_sub_2.fq* \
  -o "${out_dir}" ||
  exit 1
