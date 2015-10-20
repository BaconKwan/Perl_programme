#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "perl $0 <desc_file> <header:1/0> <xls1> ... [xlsn] \n" unless(@ARGV >= 3);

my $file = shift @ARGV;
my $header = shift @ARGV;
my %hash_xls;
my $head_line;
my $desc_col;

open XLS, "< $file" || die $!;
if ($header > 0){
	$head_line = <XLS>;
	chomp $head_line;
	my @tmp = split /\t/, $head_line;
	shift @tmp;
	$head_line = join "\t", @tmp;
}
while(<XLS>){
	chomp;
	my @line = split /\t/;
	my $id = shift @line;
	$hash_xls{$id} = join "\t", @line;
	$desc_col = scalar(@line);
}
close XLS;

foreach(@ARGV){
	open IN, "< $_" || die $!;
	my $out = $_;
	open OUT, "> $out.annot.xls" ||die $!;
	my $out_line;
	if ($header > 0){
		$out_line = <IN>;
		chomp $out_line;
		print OUT "$out_line\t$head_line\n";
	}
	while(<IN>){
		chomp;
		my @line = split /\t/;
		if(exists $hash_xls{$line[0]}){
			print OUT "$_\t$hash_xls{$line[0]}\n";
		}
		else{
			print OUT "$_" . "\t-" x $desc_col . "\n";
		}
	}
	close OUT;
	close IN;

	`mv $out.annot.xls $out -f`;
}
