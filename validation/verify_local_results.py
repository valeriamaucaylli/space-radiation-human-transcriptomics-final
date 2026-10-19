#!/usr/bin/env python3
"""Verify uncompressed files from a local R_results directory or R results.zip.
Usage: python validation/verify_local_results.py /path/to/R_results
       python validation/verify_local_results.py '/path/to/R results.zip'
"""
from pathlib import Path
import csv,hashlib,sys,zipfile
manifest=Path(__file__).with_name('40_CANONICAL_OUTPUT_SHA256.csv')
rows=list(csv.DictReader(manifest.open(encoding='utf-8')))
assert len(rows)==40
if len(sys.argv)!=2:
 print(__doc__);sys.exit(2)
path=Path(sys.argv[1]);bad=[]
if path.is_file():
 with zipfile.ZipFile(path) as z:
  for row in rows:
   matches=[n for n in z.namelist() if Path(n).name==row['filename']]
   if len(matches)!=1:
    bad.append((row['filename'],'missing/ambiguous'));continue
   data=z.read(matches[0])
   if hashlib.sha256(data).hexdigest()!=row['sha256']: bad.append((row['filename'],'hash differs'))
elif path.is_dir():
 for row in rows:
  match=list(path.rglob(row['filename']))
  if len(match)!=1:
   bad.append((row['filename'],'missing/ambiguous'));continue
  if hashlib.sha256(match[0].read_bytes()).hexdigest()!=row['sha256']:bad.append((row['filename'],'hash differs'))
else:raise FileNotFoundError(path)
if bad:
 for file,err in bad:print('FAIL',file,err)
 sys.exit(1)
print('PASS: 40/40 files match the locked archive (SHA-256, uncompressed bytes).')
