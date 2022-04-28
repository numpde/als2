#!/usr/bin/env bash

out_dir="output/b"
mkdir -p "${out_dir}"

kallisto="/bio/tools/kallisto/src/build/src/kallisto"

tx_cdna_file="output/a/transcripts_cdna.fa"
tx_cdna_index="${out_dir}/$(basename "${tx_cdna_file}").kallisto.idx"

echo "Creating the Kallisto index for ${tx_cdna_file}"

${kallisto} \
  index \
  --index="${tx_cdna_index}" \
  "${tx_cdna_file}"
