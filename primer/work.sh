dos2unix original.fa
/home/guanpeikun/bin/fastx_toolkit/bin/fasta_formatter -i original.fa -o primer.fa -w 60
perl p3in.pl primer.fa > primer.p3in
/home/miaoxin/Pipeline/RNA_denovo/Denovo_Programs/primer3_core < primer.p3in > primer.p3out
perl p3out.pl primer.p3out
