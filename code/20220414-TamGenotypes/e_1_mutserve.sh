#!/usr/bin/env bash

sample="${1:-SRR8375274}"

#

mutserve="/bio/tools/mutserve/v2.0.0-rc13/mutserve"

#

# Homo sapiens mitochondrion, complete genome (NCBI Reference Sequence: NC_012920.1)
# https://mitomap.org/foswiki/bin/view/MITOMAP/MitoSeqs
# https://www.ncbi.nlm.nih.gov/nuccore/251831106?report=fasta&log$=seqview
#ref_url="https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?tool=portal&save=file&log$=seqview&db=nuccore&report=fasta_cds_na&id=251831106&conwithfeat=on&withparts=on&hide-cdd=on"
ref_url="https://github.com/seppinho/mutserve/blob/master/files/rCRS.fasta "

#

#ref_gtf="/bio/ref/gtf/Homo_sapiens.${assembly}.105.gtf.gz"
#ref_gen="/bio/ref/dna/homo_sapiens/${assembly}/MT.fa.gz"

#

bam="$(realpath -s output/d_3_*/"${sample}"/*.sorted.bam)"

#

out_dir="output/$(basename -s ".sh" "$0")/${sample}"
mkdir -p "${out_dir}" || exit 1

echo "Created $(date -Is) by: $0" >"${out_dir}/source.txt"

#

ref_gen_mt="$(realpath -s "${out_dir}/../rCRS.fasta")"

vcf_output="$(realpath -s "${out_dir}/${sample}_mutserve_call.vcf")"

#

wget -nc "${ref_url}" -O "${ref_gen_mt}"

#

if [[ ! -f "${vcf_output}" ]]; then
  echo "Running mutserve."

  "${mutserve}" call \
    --contig-name MT \
    --alignQ=30 \
    --baseQ=20 \
    --mapQ=20 \
    --level=0.01 \
    --deletions=false \
    --mode=mtdna \
    --threads=1 \
    --reference="${ref_gen_mt}" \
    --output="${vcf_output}" \
    "${bam}"
fi
