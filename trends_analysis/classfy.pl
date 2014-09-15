#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	this programme is especially using in GOKO analysis after Trend analysis
	Usage: perl $0 <stem_file> <target_file prefix> <gokegg.sh>

"if(@ARGV ne 3);

open STEM, '<', $ARGV[0] || die $!;

my %folder;

print "Classifying genes in stem_file...\n";
<STEM>;<STEM>;
while(<STEM>){
	chomp;
	my @line = split;
	push(@{$folder{$line[2]}}, $line[0]);
}
close STEM;

print "Creating glist_files...\n";
system("mkdir $ARGV[1]");
system("cp $ARGV[2] $ARGV[1]/$ARGV[2]");
foreach my $i (sort keys %folder){
	open OUT, '>', "$ARGV[1]/$ARGV[1]_$i.glist" || die $!;
	foreach(@{$folder{$i}}){
		print OUT "$_\n"; 
	}
	close OUT;
}
print "All done!\n";
print "Please run $ARGV[1]/$ARGV[2]\n";
