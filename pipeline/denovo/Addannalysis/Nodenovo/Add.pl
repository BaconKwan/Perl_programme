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
`mkdir SH`;
`perl /parastor/users/luoda/bio/bin/RNA/new/denovo_2.0/annotation/search-database.pl  -nr an  -cog -kegg an  -swissprot -cpu 20 -queue all.q -tophit 20 -topmatch 1  -input $fa   -outdir  annot/  -path1 /parastor/users/luoda/bio/bin/RNA/new/denovo_2.0 -path2 /parastor/users/luoda/bio/bin/RNA/common/ -shdir SH  && echo finish blast at time date +%y-%m-%d.%H:%M:%S`;
$fa=`basename $fa`;
my $cog = async {
	my $step1=1;
	$step1=system ("perl /parastor/users/luoda/bio/bin/RNA/new/denovo_2.0/trinityrnaseq_r20131110/util/cmd_process_forker.pl --CPU 2 -c  SH/$fa.blast.cog.sh ");
	my $step3=1;
	$step3=system("sh SH/cat_blast.cog.$fa.sh") if ($step1 eq 0);
	if($step3 eq 0){return 0}else{return 1}
};
my $kegg = async {
	my $step1=1;
	$step1=system ("perl /parastor/users/luoda/bio/bin/RNA/new/denovo_2.0/trinityrnaseq_r20131110/util/cmd_process_forker.pl --CPU 2 -c  SH/$fa.blast.kegg.sh ");
	my $step3=1;
	$step3=system("sh SH/cat_blast.kegg.$fa.sh") if ($step1 eq 0);
	if($step3 eq 0){return 0}else{return 1}
};
my $swissprot = async {
	my $step1=1;
	$step1=system ("perl /parastor/users/luoda/bio/bin/RNA/new/denovo_2.0/trinityrnaseq_r20131110/util/cmd_process_forker.pl  --CPU 2 -c  SH/$fa.blast.swissprot.sh ");
	my $step3=1;
	$step3=system("sh SH/cat_blast.swiss.$fa.sh") if ($step1 eq 0);
	if($step3 eq 0){return 0}else{return 1}
};
my $nr = async {
	my $step1=1;
	$step1=system ("perl /parastor/users/luoda/bio/bin/RNA/new/denovo_2.0/trinityrnaseq_r20131110/util/cmd_process_forker.pl --CPU 2 -c  SH/$fa.blast.nr.sh ");
	my $step3=1;
	$step3=system("sh SH/cat_blast.nr.$fa.sh") if ($step1 eq 0);
	if($step3 eq 0){return 0}else{return 1}
};
if ($cog->join() == 0 && $kegg->join() == 0 && $swissprot->join() == 0 && $nr->join() == 0 ) {
	print "Finish : blast nr cog kegg swissprot nt!";
	exit 0;
}else{
	print "Warn : blast in one of nr cog kegg swissprot nt went wrong!";
	exit 1;
}
