#!/usr/bin/perl -w
=head1

	perl path_sta.pl -i indir -o output.xls


=cut



use strict;
use Getopt::Long;
my ($input,$output);
GetOptions(
        "i=s"=>\$input,
	"o=s"=>\$output,
);

die ` pod2text $0` unless ($input);
die ` pod2text $0` unless ($output);
my %hash;
my %ko;
my %pvalue;
my %qvalue;
my %hash1;
my %ko1;
my %pvalue1;
my %qvalue1;
my %koinf;
my @path=`ls $input/*.path.xls`;
for (@path)
{
	chomp;
	my $base=`basename $_`;
	$base=~s/\.path\.xls//;
	chomp $base;
	next if($base eq "all");
	open IN,"<$_";
	my @a=split /\s/,<IN>;
	$a[4]=~s/\(//;
	$a[4]=~s/\)//;
	$hash{$base}{sta}=$a[4];
	while (<IN>)
	{
		chomp;
		my @inf=split /\t/,$_;
		$hash{$base}{$inf[2]}=$inf[3];
		$ko{$base}{$inf[2]}=$inf[7];
		$pvalue{$base}{$inf[2]}=$inf[5];
		$qvalue{$base}{$inf[2]}=$inf[6];
	}
	close IN;
}
########all###############
my $in="$input/all.path.xls";
my $base=`basename $in`;
$base=~s/\.path\.xls//;
chomp $base;
open IN,"<$in";
my @a=split /\s/,<IN>;
$a[4]=~s/\(//;
$a[4]=~s/\)//;
$hash1{$base}{sta}=$a[4];
while (<IN>)
{
		chomp;
		my @inf=split /\t/,$_;
		$koinf{$inf[2]}="$inf[0]\t$inf[1]";
		$hash1{$base}{$inf[2]}=$inf[3];
		$ko1{$base}{$inf[2]}=$inf[7];
		$pvalue1{$base}{$inf[2]}=$inf[5];
		$qvalue1{$base}{$inf[2]}=$inf[6];
}
close IN;
##########################
my $title="KEGG_A_class\tKEGG_B_class\tPathway\tPathway_ID\tall($hash1{all}{sta})";
for (sort{$a cmp $b} keys %hash)
{
	$title.="\t$_($hash{$_}{sta})" unless $_=~/all/;
}

open OUT,">$output";
print OUT "$title\n";
my $xun=$hash1{all};
for (sort{${$xun}{$b} cmp ${$xun}{$a}}  keys %{$xun})
{
	my $out;
	my $lll=$_;
	unless ($_=~/sta/)
	{
		my $cal=$hash1{all}{$_}*100/$hash1{all}{sta};
		$cal=sprintf "%.2f",$cal;
		my $pv = $pvalue1{all}{$_};
		my $qv = $qvalue1{all}{$_};
		$out="$koinf{$_}\t$_\t$ko1{all}{$_}\t$hash1{all}{$_}($cal\%,$pv,$qv)";
		for (sort{$a cmp $b} keys %hash) 	
		{
			unless ($_=~/all/)
			{
				$hash{$_}{$lll} = 0 unless defined$hash{$_}{$lll};
				$cal=$hash{$_}{$lll}*100/$hash{$_}{sta};
				$cal=sprintf "%.2f",$cal;
				$pv = $pvalue{$_}{$lll} if defined$pvalue{$_}{$lll};
				$qv = $qvalue{$_}{$lll} if defined$qvalue{$_}{$lll};
				$pv = "NA" unless defined$pvalue{$_}{$lll};
				$qv = "NA" unless defined$qvalue{$_}{$lll};
				$out.="\t$hash{$_}{$lll}($cal\%,$pv,$qv)";
			}
		}	
	print OUT "$out\n";
	}
}
