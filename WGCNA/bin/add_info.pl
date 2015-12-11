#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die "perl $0 <rpkm> <glist> ... <glist>\n" unless(@ARGV >= 2);

my %hash;
my $exp_file = shift(@ARGV);

open EXP, "$exp_file" || die $!;
my $exp_head = <EXP>;
chomp $exp_head;
my @exp_head = split /\t/, $exp_head;
shift(@exp_head);
$exp_head = join "\t", @exp_head;
while(<EXP>){
	chomp;
	my @tmp = split /\t/;
	my $id = shift(@tmp);
	$hash{$id}{exp} = join "\t", @tmp;
}
close EXP;

open ALL, "> all.glist" || die $!;
print ALL "GeneID\tModule\tConnectivity\t$exp_head\n";
while (my $in_file = shift(@ARGV)){
	my ($name) = $in_file =~ /(\S+).glist/;
#next if($name eq "all");

	open IN, "10.${name}ModuleConnectivity.xls" || die $!;
	while(<IN>){
		chomp;
		my @tmp = split;
		$hash{$tmp[0]}{Connectivity} = $tmp[1];
	}
	close IN;
	
	open GLIST, "$in_file" || die $!;
	open OUT, "> ${name}.tmp" || die $!;
	<GLIST>;
	print OUT "GeneID\tModule\tConnectivity\t$exp_head\n";
	while(<GLIST>){
		chomp;
		my @tmp = split;
		print OUT "$tmp[0]\t$name\t$hash{$tmp[0]}{Connectivity}\t$hash{$tmp[0]}{exp}\n";
		print ALL "$tmp[0]\t$name\t$hash{$tmp[0]}{Connectivity}\t$hash{$tmp[0]}{exp}\n";
	}
	close GLIST;
	close OUT;

	`mv ${name}.tmp $in_file -f`;
}
close ALL;
