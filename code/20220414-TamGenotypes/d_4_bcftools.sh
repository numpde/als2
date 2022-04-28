#!/usr/bin/env bash

set -e # fail sooner than later

#

sample="${1:-SRR8375359}"

#

assembly="GRCh38"

ref_gtf="/bio/ref/gtf/Homo_sapiens.${assembly}.105.gtf.gz"
ref_gen="/bio/ref/dna/homo_sapiens/${assembly}/MT.fa.gz"

#

bam3_sorted="$(find output/d_3_*/"${sample}"/*.sorted.bam)"

#

out_dir="output/$(basename -s ".sh" "$0")/${sample}"
mkdir -p "${out_dir}" || exit 1

echo "Created $(date -Is) by: $0" >"${out_dir}/source.txt"

#

ref_gen_mt="${out_dir}/../mt.dna.fa"
ref_gtf_mt="${out_dir}/../mt.gtf"

vcf_1_pileup="${out_dir}/${sample}.mpileup.vcf"
vcf_2_call="${out_dir}/${sample}.mpileup.vcf.call.vcf"

regions="MT"

#

if [[ ! -f "${ref_gen_mt}" ]]; then
  gzip -dkc "${ref_gen}" >"${ref_gen_mt}"
fi

#

if [[ ! -f "${ref_gtf_mt}" ]]; then
  zcat "${ref_gtf}" | grep "\"MT-" >"${ref_gtf_mt}"
fi

#

# INFO/AD  .. Total allelic depth (Number=R,Type=Integer)
# FORMAT/QS  .. Allele phred-score quality sum for use with `call -mG` and +trio-dnm (Number=R,Type=Integer)
# https://github.com/samtools/bcftools/blob/69733a90a3d8800d2783cd67e694949b7f230187/mpileup.c#L1077

if [[ ! -f "${vcf_1_pileup}" ]]; then
  echo "Running bcftools mpileup & call."

  bcftools mpileup \
    --min-BQ 10 \
    --min-MQ 30 \
    --annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD \
    --no-BAQ \
    --fasta-ref "${ref_gen_mt}" \
    --max-depth 10000000 \
    --regions "${regions}" \
    --output "${vcf_1_pileup}" \
    "${bam3_sorted}"
fi

#

if [[ ! -f "${vcf_2_call}" ]]; then
  bcftools call \
    -c \
    --keep-alts \
    --ploidy ${assembly} \
    --output "${vcf_2_call}" \
    "${vcf_1_pileup}"
fi
