#!/usr/bin/env bash

# Project URLs:
# https://www.ncbi.nlm.nih.gov/sra?term=SRP174614
# https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR8375401

# Download from European Nucleotide Archive
# https://www.ebi.ac.uk/ena/browser/view/PRJNA512012

samples_table="output/$(basename -s ".sh" "$0")/manifest.tsv"

mkdir -p "$(dirname "${samples_table}")" || exit 1

wget \
  -nc \
  -O "${samples_table}" \
  "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA512012&result=read_run&fields=study_accession,sample_accession,experiment_accession,run_accession,tax_id,scientific_name,fastq_ftp,submitted_ftp,sra_ftp&format=tsv&download=true&limit=0"
