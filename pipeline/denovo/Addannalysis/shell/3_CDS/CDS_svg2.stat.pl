#!usr/bin/perl-w
use strict;
my ($r20,$r50,$r80,$r81);
open IN,shift;
while(<IN>)
{
	chomp;
	next if($_=~/^#/);
	my @a=split(/\t/);
	my $cov=($a[2]/$a[1]);
	$r20++ if($cov<=0.2);
	$r50++ if (0.2<$cov && $cov<=0.5);
	$r80++ if (0.5<$cov && $cov<=0.8);
	$r81++ if (0.8<$cov);
}
close IN;
print "Cover percentage of Unigene/Ortholog\tcount\n";
print "coverage <= 20%\t$r20\n";
print "20% < coverage <= 50%\t$r50\n";
print "50% < coverage <= 80%\t$r80\n";
print "coverage > 80%\t$r81\n";
