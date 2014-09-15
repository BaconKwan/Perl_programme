#!/usr/bin/perl
use strict;
#use Thread 'async';
use threads;
open IN,"<Add.lib";
my $fa;
while (<IN>)
{
	chomp;
	my @inf=split /=/,$_;
	$fa=$inf[1] if $inf[0]=~/fa/;
}
my $base=`basename $fa`;
chomp $base;
`mkdir n50`;
`mkdir Nr_species`;
`mkdir evalue`;
`mkdir 4_database`;
######n50#########
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/Seq_N.pl $fa >n50/$base.n50`;
######Nrspe#######
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/stat_top_hit_species.pl annot/database/$base/gene-annotation/$base.blast.Nr.xls 16 > Nr_species/Nr.species.stat.xls`;

#######Evalue#####
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/stat_evalue.pl annot/database/$base/gene-annotation/$base.blast.Nr.xls 14 > evalue/Nr.stat.xls`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/stat_evalue.pl annot/database/$base/gene-annotation/$base.blast.Swissprot.xls 11 > evalue/Swissprot.stat.xls`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/stat_evalue.pl annot/database/$base/gene-annotation/$base.blast.cog.xls 11 > evalue/COG.stat.xls`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/stat_evalue.pl annot/database/$base/gene-annotation/$base.blast.kegg.xls 11 > evalue/KEGG.stat.xls`;
##################

`cut -f1,4 annot/database/$base/gene-annotation/$base.blast.Nr.xls > 4_database/Nr_id.xls`;
`cut -f1,2 annot/database/$base/gene-annotation/$base.blast.Swissprot.xls > 4_database/Swissprot_id.xls`;
`cut -f1,2 annot/database/$base/gene-annotation/$base.blast.cog.xls > 4_database/Cog_id.xls`;
`cut -f1,2 annot/database/$base/gene-annotation/$base.blast.kegg.xls > 4_database/KEGG_id.xls`;
`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/draw_four_database_annot_venn.pl 4_database > 4_database/venn.svg`;
`/usr/java/latest/bin/java -jar /parastor/users/luoda/bio/bin/RNA/common/batik-1.7/batik-rasterizer.jar -m image/png 4_database/venn.svg`;
