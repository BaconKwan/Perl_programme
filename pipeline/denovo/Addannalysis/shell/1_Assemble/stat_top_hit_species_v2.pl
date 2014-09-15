#!usr/bin/perl -w
use strict;

die "Usage:perl $0 <annotation.xls> <desc_row[1-bais]>\n" unless @ARGV == 2;
open A, $ARGV[0] || die $!;
#open B,">debug_nr-species/debug.xls";
my $desc = $ARGV[1] - 1;
<A>;
my %hash = ();
while(<A>)
{
	chomp;
	my @a = split(/\t/, $_);
	next if ($a[$desc] eq "--");
#	$hash{$1}++ if($a[$desc] =~ /\[([^\]]+)\]$/);	#$ added 2012-12-31 for better match on species | removed 2013-10-11 luoyue
#	if ($a[$desc] =~ /\[([^\]]+)\]$/)
#	if ($a[$desc] =~ /\[(.+)\]$/)
#	{
#		$hash{$1}++;
#	}

#	else
#	{
#		print B "$_\n";
#	}
	my @b=split(//,$a[$desc]);	##added 2013-10-11 luoyue
	my $tag=0;my $pos=0;
	my %flag1;my %flag2;
	foreach(@b)
	{
		$pos++;
		if($_ eq "[")
		{
			$tag++;
			$flag1{$tag}=$pos;
		}
		elsif($_ eq "]")
		{
			$flag2{$tag}=$pos;
			$tag--;
		}
	}
	my $species=substr($a[$desc],$flag1{1},$flag2{1}-$flag1{1}-1);
	$hash{$species}++;
}

# foreach(sort keys %hash)	## old output way, it is not easy for us to find the nearest species
foreach(sort {$hash{$b} <=> $hash{$a}} keys %hash)	# add by zhangxuan 2013-07-17 
{
	print "$_\t$hash{$_}\n";
}
