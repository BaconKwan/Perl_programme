#! /usr/bin/perl -w
use utf8;
use strict;

die"
	get diff gene union from rpkm_all.xls by loading glist_files as index
	perl $0 <rpkm_all.xls> <group_amount> <rpkm_col>(eg, 4,7,10,13,16,19) <glist_files>
"if(4 > @ARGV);

my %hash;

for(my $i = 3; $i <= $#ARGV; $i++){
	open IN, '<', $ARGV[$i] || die $!;
	while(<IN>){
		chomp;
		my @line = split;
		$hash{$line[0]} = 0;
	}
	close IN;
}

my @rpkm_col = split /,/, $ARGV[2];
my $re = ($#rpkm_col + 1)/ $ARGV[1];
print "GeneID";
for(my $i = 1; $i <= $ARGV[1]; $i++){
	for(my $j = 1; $j <= $re; $j++){
		print "\tgroup${i}_${j}";
	}
}
print "\n";
open ALL, '<', $ARGV[0] || die $!;
<ALL>;
while(<ALL>){
	chomp;
	my @line = split;
	if(exists $hash{$line[0]}){
		print "$line[0]";
		for(my $i = 0; $i <= $#rpkm_col; $i++){
			print "\t$line[$rpkm_col[$i]]";
		}
		print "\n";
	}
}
close ALL;
