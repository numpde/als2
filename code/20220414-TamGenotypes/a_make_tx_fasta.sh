#!/usr/bin/env bash

out_dir="output/a"
mkdir -p "${out_dir}"

ref_cdna="/bio/ref/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"

tx_enst_file="${out_dir}/transcripts_enst.txt"
tx_cdna_file="${out_dir}/transcripts_cdna.fa"

#

echo "Looking for transcript versioned ENSTs."

zcat "${ref_cdna}" |
  grep -i ":MT:" |
  while read -r line; do
    echo "$(echo "$line" | cut -f 2 -d '>' | cut -f 1 -d ' ')"
  done \
    >"${tx_enst_file}"

#

echo "Retrieving transcript sequences (cDNA)."

seqtk subseq "${ref_cdna}" "${tx_enst_file}" >"${tx_cdna_file}"
