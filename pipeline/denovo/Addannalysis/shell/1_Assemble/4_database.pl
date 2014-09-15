#!usr/bin/perl-w
use strict;

die "Usage: perl $0 <infile>" unless @ARGV == 1;
open A, $ARGV[0] || die $!;
my $header=<A>;
chomp($header);
my @head=split(/\t/,$header);
my %hash = ();
open(NR,">4_database/Nr_id.xls");
open(SP,">4_database/Swissprot_id.xls");
open(COG,">4_database/COG_id.xls");
open(KE,">4_database/KEGG_id.xls");

print NR "$head[0]\t$head[1]";
print SP "$head[0]\t$head[2]";
print COG "$head[0]\t$head[3]";
print KE "$head[0]\t$head[4]";

my $num = 0;

while(<A>){
	chomp;
	my @a=split(/\t/,$_);
	if ($a[1] ne "--")
	{
		print NR "\n$a[0]\t$a[1]";
		$hash{"nr"}++;
		$hash{"gene"}{$a[0]}++;
	}
	if ($a[2] ne "--")
	{
		print SP "\n$a[0]\t$a[2]";
		$hash{"sp"}++;
		$hash{"gene"}{$a[0]}++;
	}
	if ($a[3] ne "--")
	{
		print COG "\n$a[0]\t$a[3]";
		$hash{"cog"}++;
		$hash{"gene"}{$a[0]}++;
	}
	if ($a[4] ne "--")
	{
		print KE "\n$a[0]\t$a[4]";
		$hash{"ke"}++;
		$hash{"gene"}{$a[0]}++;
	}
	$num++;
}
close A;

my $b = scalar(keys %{$hash{"gene"}});
open OUT,">4_database/4_database_anno.stat"||die "cannot open $!";
my $total=`cut -f 1  annotation.xls | grep -c 'Unigene'`;
print OUT "Total Unigenes\t$total";
print OUT "Nr\t",$hash{"nr"},"\n";
print OUT "Swissport\t",$hash{"sp"},"\n";
print OUT "COG\t",$hash{"cog"},"\n";
print OUT "Kegg\t",$hash{"ke"},"\n";
print OUT "annotation gene: ",$b,"\n";
print OUT "without annotation gene number: ",$num - $b,"\n";
close OUT;
