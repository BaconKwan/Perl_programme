#!usr/bin/perl -w
use strict;
#use lib "/parastor/users/luoda/bio/bin/mybin/lib";

### This program change -33 quality to -64 quality ## and change  reads ID like "xx 1" to "xx/1".
die "Usage:perl $0 <*fq.gz> <out>\n" unless @ARGV == 2;

die "Infile is the same as OUT file\n" if $ARGV[0] eq $ARGV[1];
open A, "<:gzip", "$ARGV[0]" || die $!;
#open A,  "$ARGV[0]" || die $!;
open OUT, ">:gzip", "$ARGV[1]" || die $!;
while(<A>)
{
	if(/^(\@\S+)\s?(\d):\w+:\d+:(\w+)$/)	#record INDEX
{
	print OUT "$1#$3/$2\n";	#print INDEX
#	print OUT "$_";
	for(0..1)
	{
		my $tmp = <A>;
		print OUT $tmp;
	}
	my $qual33 = <A>; ### +33
	my $qual = "";
	chomp $qual33;
	my @a = split(//, $qual33);
	foreach my $char (@a)
	{
		my $int = ord($char) + 31;
		$char = chr($int);
		$qual .= $char;
	}
	print OUT "$qual\n";
}
else
{
	die "$_";
}
}
close A;
close OUT;

