#! /usr/bin/perl -w

use utf8;
use strict;

die
"
	Calculate exon(according your filtered file) union set for each gene in the file
	Usage: perl $0 <gtf_file>

"if(@ARGV != 1);

open IN , '<' , $ARGV[0] or die $!;
open OUT , '>' , "$ARGV[0].Union";

my @dat;
my @desc;
my @post;
my $key;
my $tag;
my $exon;
my %hash;
my %hash_search;

while (<IN>){
	my $text = $_;
	my $gene_id;
	@dat = split /\t/, $text;
	@desc = split /;/, $dat[8];
	if($desc[0] =~ /"(\w+)"$/){
		$gene_id = $1;
		$desc[1] =~ s/"(\w+)"$/"$gene_id"/;
	}
	$key = "$dat[0]\t$dat[1]\t$dat[2]\t$dat[5]\t$dat[6]\t$dat[7]\t$desc[0]\; $desc[1]";
	if ($dat[3]<=$dat[4]){
		$hash{$key}.="$dat[3]\t$dat[4]\t";
	}
	else{
		$hash{$key}.="$dat[4]\t$dat[3]\t"
	}
}

foreach $key (sort keys %hash){
	@post = split(/\t/, $hash{$key});
	$hash_search{$post[0]} = $post[1];
	my $i= 2;
	while($i<= $#post-1){
		print "error\n" if $post[$i] > $post[$i+1];
		foreach $tag (sort keys %hash_search){
			if($post[$i]<$tag){
				if($post[$i+1]<$tag){}
				elsif($post[$i+1]>=$tag && $post[$i+1]<=$hash_search{$tag}){
					$post[$i+1] = $hash_search{$tag};
					delete $hash_search{$tag};
				}
				elsif($post[$i+1]>$hash_search{$tag}){
					delete $hash_search{$tag};
				}
			}
			elsif($post[$i]>=$tag && $post[$i]<=$hash_search{$tag}){
				if($post[$i+1]<=$hash_search{$tag}){
					$post[$i] = $tag;
					$post[$i+1] = $hash_search{$tag};
					delete $hash_search{$tag};
				}
				elsif($post[$i+1]>$hash_search{$tag}){
					$post[$i] = $tag;
					delete $hash_search{$tag};
				}
			}
			elsif($post[$i]>$hash_search{$tag}){}
		}
		$hash_search{$post[$i]} = $post[$i+1];
		$i+= 2;
	}
	foreach $exon (sort keys %hash_search){
		my @item = split(/\t/, $key);
		print OUT "$item[0]\t$item[1]\t$item[2]\t$exon\t$hash_search{$exon}\t$item[3]\t$item[4]\t$item[5]\t$item[6]\n";
		delete $hash_search{$exon};
	}
}
