#!usr/bin/perl -w
use strict;

die `perl $0 <Latin Name> <Denovo Name> <Sample Name>` unless @ARGV==3;
my $latin = shift;
my $denovo = shift;
my $sample = shift;
my @ln = split (/\_/,$latin);

#`ln -s ../../../pipe/$denovo/CDS/$sample-Unigene.ESTscan.protein.fa $latin/`;
#`ln -s ../../../pipe/$denovo/CDS/$sample-Unigene.blast.protein.fa $latin`;
#unless (-e $denovo.cds.fa)
#{
#	`cat $denovo-Unigene.blast.cds.fa $denovo-Unigene.ESTscan.cds.fa > $denovo.cds.fa`;
#}
#unless (-e $denovo.cds.fa.cut)
#{
#	`perl ~/gaochuan/program/cut_id.pl $denovo.cds.fa > $denovo.cds.fa.cut`;
#	`/opt/bio/ncbi/bin/formatdb -i $denovo.cds.fa.cut -p F`;
#}
#`cd $latin`;

`/opt/bio/ncbi/bin/blastall -p blastn -d ../$sample.cds.fa.cut -i ../$latin*.cds.cut -o $latin-vs-$denovo.blast -F F -e 1e-5 -a 10; echo DONE`;

`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step0_blast2solar_v2.pl $latin-vs-$denovo.blast > $latin-vs-$denovo.blast.step0`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step1_symbol_v1.pl $latin-vs-$denovo.blast.step0 > $latin-vs-$denovo.blast.step1`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step2_resort.pl $latin-vs-$denovo.blast.step1 > $latin-vs-$denovo.blast.step2`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step3_deleteoverlap.pl $latin-vs-$denovo.blast.step2 > $latin-vs-$denovo.blast.step3`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step4_deletecrossmatch.pl $latin-vs-$denovo.blast.step3 > $latin-vs-$denovo.blast.step4`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step5_1_resortbac.pl $latin-vs-$denovo.blast.step4 > $latin-vs-$denovo.blast.step51`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step5_2_deleteoverlapbac.pl $latin-vs-$denovo.blast.step51 > $latin-vs-$denovo.blast.step52`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step5_3_deletecrossbac.pl $latin-vs-$denovo.blast.step52 > $latin-vs-$denovo.blast.step53`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step2_resort.pl $latin-vs-$denovo.blast.step53 > $latin-vs-$denovo.blast.step5f`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step6_deletegap.pl $latin-vs-$denovo.blast.step5f > $latin-vs-$denovo.blast.step6`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/solar_step7_getmaxorder_v3.pl $latin-vs-$denovo.blast.step6 > $latin-vs-$denovo.blast.step7`;
`perl /parastor/users/luoda/gaochuan/program/solar_simulation/generate_solar.pl $latin-vs-$denovo.blast.step7 > $latin-vs-$denovo.blast.step7.solar`;
`perl /parastor/users/luoda/gaochuan/program/sort_gff.pl $latin-vs-$denovo.blast.step7.solar -k1 6 -k2 8 > $latin-vs-$denovo.blast.step7.solar.sort`;
`perl /parastor/users/luoda/gaochuan/program/delete_overlap_2.0_ves.pl $latin-vs-$denovo.blast.step7.solar.sort > $latin-vs-$denovo.blast.step7.solar.sort.del1`;
`perl /parastor/users/luoda/gaochuan/program/delete_overlap_2.0_ves.pl $latin-vs-$denovo.blast.step7.solar.sort.del1 > $latin-vs-$denovo.blast.step7.solar.sort.del2`;
`perl /parastor/users/luoda/gaochuan/program/delete_overlap_2.0_ves.pl $latin-vs-$denovo.blast.step7.solar.sort.del2 > $latin-vs-$denovo.blast.step7.solar.sort.del3`;
`perl /parastor/users/luoda/gaochuan/program/delete_overlap_2.0_ves.pl $latin-vs-$denovo.blast.step7.solar.sort.del3 > $latin-vs-$denovo.blast.step7.solar.sort.del4`;
`ln -s ../../../pipe/$denovo/assembly/2.Unigene/$sample-Unigene.$sample.Coverage.xls $denovo\_unigene_coverage.xls`;
#`ln -s ../../pipe/$denovo/assembly/2.Unigene/$sample-Unigene.$sample.Coverage.xls`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/draw_unigene_vs_reads_distribution.pl $denovo\_unigene_coverage.xls > ../../Part1_assembly_annot/n50/$sample-Unigene.reads_distribution.svg`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/3_CDS/stat_unigene_vs_reads_distribution.pl $denovo\_unigene_coverage.xls > ../../Part1_assembly_annot/n50/$sample-Unigene.reads_distribution.xls`;
`/usr/java/latest/bin/java -jar /parastor/users/luoda/bio/bin/RNA/common/batik-1.7/batik-rasterizer.jar -m image/png ../../Part1_assembly_annot/n50/$sample-Unigene.reads_distribution.svg`;
#`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/get_match_subject_best.pl $latin-vs-$denovo.blast.step7.solar.sort.del4 |awk '\$11/\$7>=0.5' > $latin-vs-$denovo.blast.step7.solar.sort.del4.${denovo}bestmatch`;
`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/get_match_subject_best.pl $latin-vs-$denovo.blast.step7.solar.sort.del4 > $latin-vs-$denovo.blast.step7.solar.sort.del4.${denovo}bestmatch`;
`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/prepare_data_to_draw.pl $denovo\_unigene_coverage.xls $latin-vs-$denovo.blast.step7.solar.sort.del4.${denovo}bestmatch > data_to_draw.raw.txt`;
`awk '!/nodepth/' data_to_draw.raw.txt > data_to_draw.filter.txt`;
`awk '\$3<=1000' data_to_draw.filter.txt > $latin-vs-$denovo.1.svg.xls`;
`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/draw_distribute_svg.pl $ln[0] $ln[1] $latin-vs-$denovo.1.svg.xls > $latin-vs-$denovo.1.svg`;

`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/get_query_gene_cover.pl $latin-vs-$denovo.blast.step7.solar.sort.del4.${denovo}bestmatch > $latin\_gene_cover.out`;
`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/query_gene_cover.filter.pl $latin\_gene_cover.out > $latin-vs-$denovo.2.svg.xls`;
`perl /parastor/users/luoda/gaochuan/program/Homologous_cds_evaluate_assembly/draw_query_gene_cover_by_subject_svg.pl $ln[0] $ln[1] $latin-vs-$denovo.2.svg.xls > $latin-vs-$denovo.2.svg`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/3_CDS/CDS_svg1.stat.pl $latin-vs-$denovo.1.svg.xls > $latin-vs-$denovo.1.svg.stat.xls`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/3_CDS/CDS_svg2.stat.pl $latin-vs-$denovo.2.svg.xls > $latin-vs-$denovo.2.svg.stat.xls`;
`/usr/java/latest/bin/java -jar /parastor/users/luoda/bio/bin/RNA/common/batik-1.7/batik-rasterizer.jar -m image/png $latin-vs-$denovo.1.svg`;
`/usr/java/latest/bin/java -jar /parastor/users/luoda/bio/bin/RNA/common/batik-1.7/batik-rasterizer.jar -m image/png $latin-vs-$denovo.2.svg`;
`rm *blast*`;
