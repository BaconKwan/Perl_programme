#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my $file = shift @ARGV;
my $desc_col = shift @ARGV;
my %hash_xls;

open XLS, "< $file" || die $!;
my $head_line = <XLS>;
chomp $head_line;
my @tmp = split /\t/, $head_line;
$head_line = $tmp[-($desc_col)];
foreach my $index ( -($desc_col - 1) .. -1){
	$head_line = join "\t", $head_line, $tmp[$index];
}
while(<XLS>){
	chomp;
	my @line = split /\t/;
	my $id = shift @line;
	$hash_xls{$id} = $line[-($desc_col)];
	foreach my $index ( -($desc_col - 1) .. -1){
		$hash_xls{$id} = join "\t", $hash_xls{$id}, $line[$index];
	}
}
close XLS;

foreach(@ARGV){
	open IN, "< $_" || die $!;
	open OUT, "> $_.xls" ||die $!;
	my $out_line = <IN>;
	chomp $out_line;
	print OUT "$out_line\t$head_line\n";
	while(<IN>){
		chomp;
		my @line = split /\t/;
		print OUT "$_\t$hash_xls{$line[0]}\n";
	}
	close OUT;
	close IN;
}
