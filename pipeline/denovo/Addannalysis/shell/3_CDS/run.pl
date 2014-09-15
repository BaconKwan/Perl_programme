#!usr/bin/perl -w
use strict;

print "Have you linked ohter three Proximal species?(yes/no)\n";
#if (<STDIN> ne "yes\n")
#{
#	print "Your are still too young\n";
#	print "please have a look at '/parastor/users/luoda/bio/Database/Species'  '/parastor/users/luoda/gaochuan/database/genome'\n";
#	die;
#}

die "perl $0 <Proximal species> <denovo name> <sample name>\n" if @ARGV != 3;

my $latin = shift;
my $denovo = shift;
my $sample = shift;

`mkdir -p $latin`;
chdir($latin);
#system("cd $latin");

`perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/3_CDS/generate_Ref-vs-denovo_shell.pl $latin $denovo $sample`;
