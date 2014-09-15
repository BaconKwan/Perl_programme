#!/usr/bin/perl
use strict;
use Data::Dumper;

my $file=shift;
open IN,$file or die "$!";
my %gg;
while(<IN>){
	chomp;
	if($_=~/^>(\S+)/){
		my $gene_id=$1;
		my $specie_id=$1 if($gene_id=~/\S+\_(\S+)$/);
		push @{$gg{$specie_id}},$gene_id;
	}
}
foreach my $gg(keys %gg){
	my @gene=@{$gg{$gg}};
	my $list=join(" ",@gene);
	print "$gg: $list\n";
}
