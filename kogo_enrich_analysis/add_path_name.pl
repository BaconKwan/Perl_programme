#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my (%map, %title);

open MAP, "/Bio/Database/Database/kegg/data/map_class/animal_ko_map.tab" || die $!;
while(<MAP>){
	chomp;
	my @line = split;
	my $id = shift(@line);
	@{$map{$id}} = @line;
}
close MAP;

open TITLE, "/Bio/Database/Database/kegg/pub/kegg/pathway/map_title.tab" || die $!;
while(<TITLE>){
	chomp;
	my @line = split /\t/;
	$title{$line[0]} = $line[1];
}
close TITLE;

open KO, "$ARGV[0]" || die $!;
<KO>;
while(<KO>){
	chomp;
	my $id = (split /\t/)[1];
	print "$_";
	foreach my $i (@{$map{$id}}){
		print "\t$title{$i}" if(exists $title{$i});
	}
	print "\n";
}
close KO;
