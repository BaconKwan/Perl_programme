#!usr/bin/perl -w 
use strict;

#my $file="tmp.cds";

die "perl $0 <cds> <control_id> <case_id> \n" if(@ARGV ne 3);

my ($i, $j) = @ARGV[1..2];

$/="\n>";
open IN,$ARGV[0] or die $!;
while (<IN>)
{
	chomp;
	my @a=split /\n/,$_;
	$a[0] =~ s/>//g;
	my (@b,@f);
	foreach my $i (1 .. $#a)
	{
		my @c=split /\s+/,$a[$i];
		push @b,$c[0];
		push @f,$c[1];
	}
	my ($ATH,$X,$gene);
	foreach my $k (0 .. $#b)
	{
		if ($b[$k]=~ /_$i$/)
		{
			$b[$k] =~ s/_$i$//g;
			$ATH=$f[$k];
			$gene=$b[$k];
		}
		elsif( $b[$k] =~/_$j/)
		{
			$X=$f[$k];
		}
	}
	print "$gene\n$ATH\n$X\n\n";
}

