import re
from pathlib import Path

import pandas as pd
import numpy as np

from pysam import VariantFile
from pysam.libcbcf import VariantMetadata

from plox import Plox
from tcga.utils import mkdir

out_dir = mkdir(Path(__file__).parent / f"output/{Path(__file__).stem}/tmp")

vcf_files = sorted(Path(__file__).parent.glob("output/*_bcftools/*/*.mpileup.vcf"))

for vcf_file in vcf_files:
    sample = re.search(r"SRR[0-9]+", str(vcf_file)).group()
    print(sample)

    vcf_file = set(f for f in vcf_files if (sample in str(f))).pop()

    from_field = 'QS'  # 'AD' or 'QS'

    try:
        df = pd.DataFrame(
            data=[
                {
                    'chrom': record.chrom,
                    'pos': record.pos,
                    'ref': record.ref,
                    'depth': record.info['DP'],
                    **dict(zip(record.alleles, record.info[from_field]))
                }
                for record in VariantFile(vcf_file)
            ],
        )
    except KeyError as ex:
        print(ex)
        continue
    else:
        print("Data frame OK.")

    # df = df.sample(n=100)

    if from_field == 'AD':
        pass
        # print(f"Deviations from 'depth':")
        # print(pd.Series(df.depth - df[['A', 'C', 'T', 'G']].sum(axis=1)).describe())

    if from_field == 'QS':
        if not all(np.isclose(1, df[['A', 'C', 'T', 'G']].sum(axis=1))):
            print("W: ACTG do not sum to 1.")

    genotypes = ['A', 'C', 'T', 'G']

    freq1 = df[genotypes].apply(lambda s: min(s.nlargest(1)) / sum(s), axis=1)
    freq2 = df[genotypes].apply(lambda s: min(s.nlargest(2)) / sum(s), axis=1)
    ref = df[genotypes].apply(lambda s: s[df.ref[s.name]] / sum(s), axis=1)

    with Plox() as px:
        a1 = px.a

        bins = np.linspace(0, 1, 77)

        a1.hist(freq1, bins=bins, color='C1', alpha=0.8, label="1st")
        a1.hist(freq2, bins=bins, color='C2', alpha=0.8, label="2nd")
        a1.hist(ref, bins=bins, color='C0', alpha=0.6, label="ref")

        a1.legend(loc="upper center")

        for a in [a1, ]:
            a.set_yscale('log')

            a.set_xlim(0, 1)
            a.set_xticks(list(np.linspace(0, 1, 11)))
            a.set_xticklabels([f"{x * 100:.0f}%" for x in a.get_xticks()])

            a.set_ylim(0.5, 20_000)

        px.f.savefig(mkdir(out_dir / f"hist_{from_field}") / f"{sample}.png")
