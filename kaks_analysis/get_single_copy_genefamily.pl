#!usr/bin/perl -w
use strict;
my $orthomcl_result_file=shift;  ### all_orthomcl.out
my $all_tax_num=shift;
open(IN,$orthomcl_result_file)||die"cannot open:$!";
while(<IN>)
{
	chomp;   my @a=split(/\s+/,$_);
	my $gene_num=0;
	my $family_id;
	my $tax_num=0;
	if($a[0]=~/(ORTHOMCL\d+)\((\d+)/)
	{
		$gene_num=$2;
		$family_id=$1;
	}
	if($a[1]=~/genes,(\d+)/)
	{
		$tax_num=$1;
	}
	if($gene_num == $tax_num && $tax_num == $all_tax_num)
	{
		my @array;
		foreach my $out(3 .. $#a)
		{
			$a[$out]=~s/\(\S+\)//;
			push @array,$a[$out];
		}
		print "$family_id\t",(join",",@array),"\n";
	}
}
close IN;
