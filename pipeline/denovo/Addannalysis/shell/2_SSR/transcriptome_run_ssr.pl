#!usr/bin/perl -w
use strict;
my $file=shift;   ## input cut_id fasta file
### step1
`perl /parastor/users/luoda/gaochuan/program/transcriptome_SSR/misa.pl $file`;
`perl /parastor/users/luoda/gaochuan/program/transcriptome_SSR/misa_result_ssr_statistic.pl $file.statistics`;
`perl /parastor/users/luoda/gaochuan/program/transcriptome_SSR/draw_zhifang_svg.pl $file.statistics.drawSVG.txt > $file.statistics.distribution_of_ssr.svg`;
`/usr/java/latest/bin/java -jar /parastor/users/luoda/bio/bin/RNA/common/batik-1.7/batik-rasterizer.jar -m image/png $file.statistics.distribution_of_ssr.svg`;
#`date ; echo "step1 was done"`;
### step2
`perl /parastor/users/luoda/gaochuan/program/transcriptome_SSR/p3_in.pl $file.misa > $file.p3_primer3.log`;
`/parastor/users/luoda/gaochuan/program/primer/src/primer3_core < $file.p3in > $file.p3out`;
`perl /parastor/users/luoda/gaochuan/program/transcriptome_SSR/p3_out.pl $file.p3out $file.misa >>$file.p3_primer3.log`;
#`date ; echo "step2 was done"`;
