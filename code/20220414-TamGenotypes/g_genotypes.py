import re

from collections import OrderedDict
from pathlib import Path

import pandas as pd
import numpy as np

from pysam import VariantFile
from pysam.libcbcf import VariantMetadata

from plox import Plox, rcParam

from tcga.utils import mkdir, first

out_dir = mkdir(Path(__file__).parent / f"output/{Path(__file__).stem}/tmp")

vcf_files = OrderedDict((
    (re.search(r"SRR[0-9]+", str(vcf_file)).group(), vcf_file)
    for vcf_file in sorted(Path(__file__).parent.glob("output/*_bcftools/*/*.mpileup.vcf"))
))

df_meta: pd.DataFrame
df_meta = pd.read_table(first(f for p in Path('.').resolve().parents for f in p.glob('**/*Tam-2019/meta_merged.tsv')))
df_meta = df_meta.set_index('run_accession').loc[list(vcf_files)]

from_field = 'QS'  # 'AD' or 'QS'

df_meta[f"hist_{from_field}"] = None

for (sample, vcf_file) in vcf_files.items():
    print(sample, vcf_file)

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

    style = {
        rcParam.Hatch.linewidth: 1,
        rcParam.Figure.figsize: (8, 3),
    }

    with Plox(style) as px:
        a1 = px.a

        bins = np.linspace(0, 1, 77)

        a1.hist(freq1, hatch='//', bins=bins, color='C1', alpha=0.6, label="1st", edgecolor='C1')
        a1.hist(freq2, hatch='//', bins=bins, color='C2', alpha=0.6, label="2nd", edgecolor='C2')
        a1.hist(ref, hatch='\\\\', bins=bins, color='C0', alpha=0.6, label="ref", edgecolor='C0')

        a1.grid(True, zorder=-100, linewidth=0.5, alpha=0.6)
        a1.legend(loc="upper center")

        for a in [a1, ]:
            a.set_yscale('log')

            a.set_xlim(0, 1)
            a.set_xticks(list(np.linspace(0, 1, 11)))
            a.set_xticklabels([f"{x * 100:.0f}%" for x in a.get_xticks()])

            a.set_ylim(0.5, 20_000)

        filename = mkdir(out_dir / f"hist_{from_field}") / f"{sample}.png"
        px.f.savefig(filename)

        df_meta.loc[sample, f"hist_{from_field}"] = f"<img height='200px' src='{filename}' />"

df_meta.to_csv(out_dir / "meta.tsv", sep='\t')
df_meta.to_html(out_dir / "meta.html", escape=False, border=1, sparsify=True)
