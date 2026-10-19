#!/usr/bin/env python3
"""Rebuild OSD129_design_manifest.csv from OSD-129 NASA ISA ZIP.
Usage: python scripts/reconstruct_OSD129_manifest.py path/to/OSD-129_metadata_OSD-129-ISA.zip path/to/GLDS-129_array_SampleTable_GLmicroarray.csv output.csv
No dataset is downloaded or bundled by this script.
"""
import csv, io, re, sys, zipfile
from collections import Counter
if len(sys.argv)!=4: raise SystemExit(__doc__)
with zipfile.ZipFile(sys.argv[1]) as z:
    lines=io.StringIO(z.read('s_OSD-129.txt').decode('utf-8-sig'))
    table=list(csv.DictReader(lines,delimiter='\t'))
with open(sys.argv[2],newline='') as f: sm={r['sample']:r['group'] for r in csv.DictReader(f)}
rows=[]
for r in table:
    match=re.search(r'[-_]([ACGHP])$',r['Source Name'])
    if not match: raise ValueError('Unrecognized donor pattern')
    grav={'1G on Earth':'1G','uG by RWV':'uG'}[r['Factor Value[Microgravity Simulation]']]
    rad={'non-irradiated':'NoIR','cesium-137 gamma radiation':'IR'}[r['Factor Value[Ionizing Radiation]']]
    sample=r['Sample Name']
    if sample not in sm:raise ValueError('Missing sample')
    assert ('uG by RWV' in sm[sample]) == (grav=='uG')
    assert ('non-irradiated' in sm[sample]) == (rad=='NoIR')
    rows.append(dict(sample=sample,donor=match.group(1),gravity=grav,radiation=rad))
assert len(rows)==20 and Counter((x['gravity'],x['radiation']) for x in rows)=={('1G','NoIR'):5,('1G','IR'):5,('uG','NoIR'):5,('uG','IR'):5}
with open(sys.argv[3],'w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=['sample','donor','gravity','radiation']);w.writeheader();w.writerows(rows)
print('Derived and validated 20 rows; 5 paired donors; balanced 2x2 design')
