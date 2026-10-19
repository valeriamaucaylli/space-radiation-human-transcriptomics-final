#!/usr/bin/env python3
"""Validate frozen aggregate results, with no external data or extra packages."""
import csv
from pathlib import Path
from collections import Counter
base=Path(__file__).resolve().parents[1]/'results'/'summary_tables'
def load(name):
 with (base/name).open(newline='',encoding='utf-8-sig') as f:return list(csv.DictReader(f))
c=load('08A_locked_confirmatory_pathway_results.csv')
e=load('08A_locked_exploratory_fgsea.csv')
m=load('08A_exploratory_method_concordance.csv')
assert len(c)==len(e)==len(m)==60, (len(c),len(e),len(m))
assert sum(float(x['p_holm4'])<.05 for x in c)==0
assert sum(float(x['p_holm4'])<.05 for x in e)==32
assert sum(x['direction_match'].strip().lower() in ('true','1') for x in m)==50
assert len(set((x['analysis'],x['pathway']) for x in c))==60
assert len(set((x['analysis'],x['pathway']) for x in e))==60
assert Counter(x['pathway'] for x in c)==Counter(x['pathway'] for x in e)
print('PASS: frozen 08A aggregate tables — 60/60 rows; confirmatory 0, exploratory 32; direction 50/60.')
