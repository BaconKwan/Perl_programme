#!usr/bin/perl -w
use strict;

my %hash = ();
open IN,$ARGV[0]||die "cannot open $!";
while (<IN>)
{
	chomp;
	my @arr = split (/\s+/,$_);
	$hash{$arr[0]}++;
}
close IN;

open IN,$ARGV[1]||die "cannot open $!";

while (<IN>)
{
	chomp;
	my @arr = split (/\s+/,$_);
	if (exists $hash{$arr[0]})
	{
		print "$_\n";
	}
}
close IN;
