#! /usr/bin/perl -w
use utf8;
use strict;

open INGENE , '<' , $ARGV[0];
open INK , '<' , $ARGV[1];
open KO , '>' , "kofile";

my %genelist;
my $id;
my $text;

while ($id = (<INGENE>)){
	chomp($id);
	$genelist{$id} = "";
}
while ($text = (<INK>)){
	chomp($text);
	my @line = split /\t/, $text;
	if (exists $genelist{$line[0]}){
		$genelist{$line[0]} = $line[12];
	}
}
foreach my $key (sort keys %genelist){
	print KO "$key\t$genelist{$key}\n";
}
