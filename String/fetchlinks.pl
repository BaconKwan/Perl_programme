#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

my %glist;
my (%edge, %node);
my %gene;

die "perl $0 <glist> <links>\n" unless(@ARGV eq 2);

open GLIST, "$ARGV[0]" || die $!;
while(<GLIST>){
	chomp;
	my @line = split /\t/;
	$glist{$line[0]} = $line[1];
}
close GLIST;

open LINKS, "$ARGV[1]" || die $!;
while(<LINKS>){
	chomp;
	my @line = split /\t/;
	if(exists $glist{$line[0]} && exists $glist{$line[3]}){
		unless($line[2] =~ /^\s*$/){
			$gene{$line[2]} = $line[2] unless(exists $gene{$line[2]});
			if($gene{$line[2]} eq "T" || $gene{$line[2]} eq $line[2]){
				next;
			}
			else{
				$gene{$line[2]} = "T";
			}
		}
	}
}
close LINKS;

open LINKS, "$ARGV[1]" || die $!;
while(<LINKS>){
	chomp;
	my @line = split /\t/;
	if(exists $glist{$line[0]} && exists $glist{$line[3]}){
		$line[2] = $line[0] if($line[2] =~ /^\s*$/ || $gene{$line[2]} eq "T");
		$line[5] = $line[3] if($line[5] =~ /^\s*$/ || $gene{$line[5]} eq "T");
		my @tmp = split /\s+/, $line[-1];
		my $t = join "-", $line[2], $line[5];
		unless(exists $edge{"$line[5]-$line[2]"}){
			$edge{$t} = $tmp[-1];
			print "$line[2]\t$line[5]\t$tmp[-1]\n";
		}
		$node{$line[2]} = $glist{$line[0]};
		$node{$line[5]} = $glist{$line[3]};
#print "$line[2]\t$line[5]\t$tmp[-1]\n";
	}
}
close LINKS;

foreach my $i (sort keys %node){
	print STDERR "$i\t$node{$i}\n";
}
