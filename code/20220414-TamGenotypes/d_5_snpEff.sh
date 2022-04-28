#!/usr/bin/env bash

set -e

#

sample="${1:-SRR8375426}"

#

snpEff="/bio/tools/snpEff/snpEff/snpEff.jar"
genome="GRCh38.105"

#

out_dir="output/$(basename -s ".sh" "$0")/${sample}"
mkdir -p "${out_dir}" || exit 1

echo "Created $(date -Is) by: $0" >"${out_dir}/source.txt"

#

tx_enst_file="$(realpath -s "output/"a*/*_enst.txt)"
tx_enst_no_v="${out_dir}/../transcripts.txt"

if [[ ! -e "${tx_enst_no_v}" ]]; then
  cat "${tx_enst_file}" | cut -f 1 -d '.' >"${tx_enst_no_v}"
fi

#

vcf_input="$(realpath -s "${out_dir}"/../../d_4_*/"${sample}/${sample}.mpileup.vcf")"
vcf_output="$(realpath -s "${out_dir}/${sample}.mpileup.vcf.snpEff.vcf")"

#

if [[ ! -f "${vcf_output}" ]]; then
  echo "Running snpEff."

  java \
    -Xmx8g \
    -jar "${snpEff}" \
    -stats "${out_dir}/${sample}.snpEff.html" \
    -onlyTr "${tx_enst_no_v}" \
    -no-downstream \
    -no-upstream \
    -no-intron \
    -no-intergenic \
    "${genome}" \
    "${vcf_input}" \
    >"${vcf_output}"
fi
