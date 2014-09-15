#!usr/bin/perl -w
use strict;

die "Usage:perl $0 <annotation.xls> <e_row>\n" unless @ARGV == 2;
open A, $ARGV[0] || die $!;
<A>;
my %hash = ();
while(<A>)
{
	chomp;
	my @a = split(/\t/, $_);
	next if $a[$ARGV[1] -1] =~ /^--$/;
	if(!($a[$ARGV[1] -1] =~ /e/i))
	{
		$hash{'evalue = 0'} ++;
	}
	else
	{
		my ($e) = $a[$ARGV[1] -1] =~ /-(\d+)/;
		if($e >= 5 && $e < 20)
		{
			$hash{'1E-20 < evalue <= 1E-5'}++;
		}
		if($e >= 20 && $e < 50)
		{
			$hash{'1E-50 < evalue <= 1E-20'}++;
		}
		if($e >= 50 && $e < 100)
		{
			$hash{'1E-100 < evalue <= 1E-50'}++;
		}
		if($e >= 100 && $e < 150)
		{
			$hash{'1E-150 < evalue <= 1E-100'}++;
		}
		if($e >= 150)
		{
			$hash{'0 < evalue <= 1E-150'}++;
		}
	}
}
close A;

print "E-value range\tNumber of Unigenes\n";	#Head added 2013-01-16
#foreach(sort keys %hash)
#{
#	print "$_\t$hash{$_}\n";
#}
#print "x > 1E-5\t$hash{'x > 1E-5'}\n";
print "1E-20 < evalue <= 1E-5\t$hash{'1E-20 < evalue <= 1E-5'}\n";
print "1E-50 < evalue <= 1E-20\t$hash{'1E-50 < evalue <= 1E-20'}\n";
print "1E-100 < evalue <= 1E-50\t$hash{'1E-100 < evalue <= 1E-50'}\n";
print "1E-150 < x <= 1E-100\t$hash{'1E-150 < evalue <= 1E-100'}\n";
print "0 < evalue <= 1E-150\t$hash{'0 < evalue <= 1E-150'}\n";
print "evalue = 0\t$hash{'evalue = 0'}\n";
