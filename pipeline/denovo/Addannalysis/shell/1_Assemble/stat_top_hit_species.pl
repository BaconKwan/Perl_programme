#!usr/bin/perl -w
use strict;

die "Usage:perl $0 <annotation.xls> <desc_row[1-bais]>\n" unless @ARGV == 2;
open A, $ARGV[0] || die $!;
my $desc = $ARGV[1] - 1;
<A>;
my %hash = ();
while(<A>)
{
	chomp;
	my @a = split(/\t/, $_);
	$hash{$1}++ if($a[$desc] =~ /\[([^\]]+)\]$/);	#$ added 2012-12-31 for better match on species
}

# foreach(sort keys %hash)	## old output way, it is not easy for us to find the nearest species
foreach(sort {$hash{$b} <=> $hash{$a}} keys %hash)	# add by zhangxuan 2013-07-17 
{
	print "$_\t$hash{$_}\n";
}
