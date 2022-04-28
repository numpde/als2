#!/usr/bin/env bash

sample="${1:-SRR8375401}"

samples_table=$(find output/c_*/manifest.tsv)

out_dir_info="output/$(basename -s ".sh" "$0")/${sample}"
mkdir -p "${out_dir_info}" || exit 1

out_dir="/bio/als/data/20220414-Tam-2019/samples_original/${sample}"
mkdir -p "${out_dir}" || exit 1

echo "${out_dir}" >"${out_dir_info}/readme.txt"
echo "Created $(date -Is) by: $0" >"${out_dir}/source.txt"

urls="$(cat "${samples_table}" | grep "${sample}" | cut -f 7)"
url1="$(echo "${urls}" | cut -f 1 -d ';')"
url2="$(echo "${urls}" | cut -f 2 -d ';')"

wget -nc -P "${out_dir}" "ftp://${url1}"
wget -nc -P "${out_dir}" "ftp://${url2}"
