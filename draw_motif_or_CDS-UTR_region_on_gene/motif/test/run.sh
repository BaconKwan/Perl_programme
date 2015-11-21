## first step --> get files: fasta.len & motif.range
perl fetch_info_from_fa_v2.pl -x 1000 -y 2000 seq.need.fa color meme.txt
## second step --> get svg file
perl sbv.pl karyo -conf karyo.conf
