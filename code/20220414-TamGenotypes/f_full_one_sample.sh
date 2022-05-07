#!/usr/bin/env bash

set -e

sample="${1:-SRR8375406}" # other_neuro (ALS-Glia)	72.0	Female	Unknown
sample="${1:-SRR8375426}" # ALS (ALS-Glia)	63.0	Female	Limb
sample="${1:-SRR8375409}" # ALS (ALS-Ox)	76.0	Female	Unknown
sample="${1:-SRR8375359}" # ALS (ALS-Ox)	69.0	Female	Bulbar
sample="${1:-SRR8375274}" # ALS (ALS-Ox)	60.0	Female	Limb
sample="${1:-SRR8375398}" # non-neuro
sample="${1:-SRR8375295}" # non-neuro
sample="${1:-SRR8375405}" # ALS (ALS-Ox)	65.0	Female	Limb
sample="${1:-SRR8375403}" # ALS (Discordant)	60.0	Male	Limb
sample="${1:-SRR8375401}" # ALS (ALS-Ox)	67.0	Female	Bulbar
sample="${1:-SRR8375402}" # ALS (Discordant)	74.0	Male	Limb

echo "${sample}" &&
  bash d_1_download_sample.sh "${sample}" &&
  bash d_2_preprocess_sample.sh "${sample}" &&
  bash d_3_kallisto_map_sample.sh "${sample}" &&
  bash d_4_bcftools.sh "${sample}" &&
  bash d_5_snpEff.sh "${sample}"
