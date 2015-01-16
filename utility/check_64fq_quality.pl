#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	check 64 quality fastq file
	Usage: perl $0 <fastq_file>

"if(@ARGV != 1);

open IN, ($ARGV[0] =~ /\.gz$/) ? "gzip -cd $ARGV[0] |" : "$ARGV[0]" || die $!;

my %char;

while (<IN>){
	<IN>;<IN>; 
	my $p = <IN>;
	chomp($p);
#print "$p\n";
	my @chars = split //, $p;
	foreach my $char (@chars){
		if ($char lt "B"){
			$char{$char}++;
		}
	}
}
foreach my $out (sort keys %char){
		print "$out\t$char{$out}\n";
}
=cut
print "\n";
my $a = "`";
my $b = "'";

$a = ord($a);
$b = ord($b);
print "$a\t$b\n";
=cut
