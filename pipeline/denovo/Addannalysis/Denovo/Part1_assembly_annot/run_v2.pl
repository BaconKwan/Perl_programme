#!usr/bin/perl -w
use strict;
use File::Basename;
#die "input denovo name and sample name\n" unless @ARGV==2;
my $denovo = shift;
#$denovo="Litopenaeus_vannamei";
#my $sample = shift;

# 1 n50
`mkdir -p n50`;
my @a=`ls ../../pipe/$denovo/assembly/1.Contig/*fa ../../pipe/$denovo/assembly/2.Unigene/*Unigene.fa ../../pipe/$denovo/assembly/2.Unigene/*Unigene.5-3.fa`;
foreach(@a)
{
	chomp;
	my $in =$_;
	my $out=basename($in);
	$out=~s/fa/n50/;
#	print "perl /parastor/users/luoda/zhangxuan/bin/Seq_N.pl $in > n50/$out\n";
	`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/Seq_N.pl $in > n50/$out`;
}
#die;	#For debug;


`ln -s ../../pipe/$denovo/annotation/annotation.xls`;
open(A,"annotation.xls");
my ($nr_id,$nr_ev,$nr_an) = (0,0,0);
my ($sp_id,$sp_ev) = (0,0);
my ($cog_id,$cog_ev) = (0,0);
my ($ko_id,$ko_ev) = (0,0);
$_=<A>;
chomp;
my @tmp=split(/\t/);
my $col;
foreach(@tmp)
{
        $nr_id=($col+1) if ($_=~/Nr-ID/);       $nr_ev=($col+1) if ($_=~/Nr-Evalue/);   $nr_an=($col+1) if ($_=~/Nr-annotation/);
                $sp_id=($col+1) if ($_=~/Swissprot-ID/);        $sp_ev=($col+1) if ($_=~/Swissprot-Evalue/);
                        $cog_id=($col+1) if ($_=~/COG-ID/);     $cog_ev=($col+1) if ($_=~/COG-Evalue/);
                                $ko_id=($col+1) if ($_=~/KO_id/);       $ko_ev=($col+1) if ($_=~/KEGG-Evalue/);
                                        $col++;
}


# 2 Nr_species
`mkdir -p Nr_species`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/stat_top_hit_species_v2.pl annotation.xls $nr_an > Nr_species/Nr.species.stat.xls`;

# 3 evalue
`mkdir -p evalue`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/stat_evalue.pl annotation.xls $nr_ev > evalue/Nr.stat.xls`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/stat_evalue.pl annotation.xls $sp_ev > evalue/Swissprot.stat.xls`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/stat_evalue.pl annotation.xls $cog_ev > evalue/COG.stat.xls`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/stat_evalue.pl annotation.xls $ko_ev > evalue/KEGG.stat.xls`;


# 4 database
`mkdir -p 4_database`;
`cut -f 1,$nr_id,$sp_id,$cog_id,$ko_id annotation.xls > annot.short.xls`;
`perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/4_database.pl annot.short.xls`;
system("perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/draw_four_database_annot_venn.pl 4_database > 4_database/venn.svg");
system("/usr/bin/java -jar /Bio/Bin/Linux-src-files/batik-1.7/batik-1.7/batik-rasterizer.jar -m image/png 4_database/venn.svg");
