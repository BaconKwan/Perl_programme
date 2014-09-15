#! /usr/bin/perl -w
use utf8;
use strict;

die 
"
	This programme is searching optimizing display for a snp overview table, which is working by search each separate file.
	Usage: perl $0 <SNP matrix> <snp site list> ...

"if(@ARGV < 2);

my %REF_matrix;
my %RES_matrix;
my %RB;
my %column;
my @col;
my $title;
my $key;
my $out = "";

for(my $i = 0; $i<=$#ARGV; $i++){
	if (0 == $i){
		open IN , '<' , $ARGV[$i] or die $!;
		print "loading old SNP matrix...\n";
		my @text;
		my $c1c2;
		while (<IN>){
			@text = split (/\t/,$_);
			if($text[0] eq "chr"){
				$title = $_;
			}
			else{
				$c1c2 = shift(@text);
				$c1c2 = $c1c2 . "\t" . shift(@text);
				$REF_matrix{$c1c2} = join "\t",@text;
				$RES_matrix{$c1c2} = "";
			}
		}
		print "finished\n";
		print "creating column index from the 1st line...\n";
		@col = split(/\t/,$title);
		for(my $c = 0; $c <= $#col; $c++){
			$column{$col[$c]} = $c;
		}
		$title = "";
		print "finished\n";
	}
	else{
		open IN , "gzip -dc $ARGV[$i] |" or die $!;
		my @record;
		my @title;
		my %matrix;
		my $col_num;
		my $id;
		my $filename = $ARGV[$i];
		$filename =~ s/.*(LV\w+).*/$1/;
		$out .= "_$filename";
		foreach (keys %column){
			if (/^($filename)_fir$/){
				$col_num = $column{$_}-2;
				$title .= "$col[$col_num+2]\t$col[$col_num+3]\t$col[$col_num+4]\t$col[$col_num+5]\t";
				print "column located: $filename -- $_ on $col_num\n";
			}
		}
		print "importing nucleotide site information...\n";
		while (<IN>){
			@record= split (/\t/,$_);
			$id = "$record[0]\t$record[1]";
			#print "$id\n";
			if(exists $REF_matrix{$id}){
				$matrix{$id} = 0;
			}
		}
		print "index generation finished\n";
		print "modifying SNP records...\n";
		foreach $id (sort keys %REF_matrix){
			@record = split(/\t/,$REF_matrix{$id});
			if(exists $matrix{$id}){
				if($record[$col_num] eq "-"){
					$record[$col_num] = "yes";
					$record[$col_num + 1] = "yes";
					$record[$col_num + 2] = "yes";
					$record[$col_num + 3] = "yes";
				}
			}
			else{
				$record[$col_num] = "no";
				$record[$col_num + 1] = "no";
				$record[$col_num + 2] = "no";
				$record[$col_num + 3] = "no";
			}
			$RES_matrix{$id} .= join "\t", $record[$col_num],$record[$col_num + 1],$record[$col_num + 2],$record[$col_num + 3] . "\t";
			$RB{$id} = $record[0];
		}
		%matrix=();
		print "finished\n";
	}
	close IN;
}
open OUT , '>' , "$ARGV[0]$out" or die $!;
open OUTT, '>' , "$ARGV[0]$out.CSR" or die $!;
print "generating new SNP matrix...\n";
$title =~ s/\t*$//;
print OUT "$title\n";
print OUTT "$col[0]\t$col[1]\t$col[2]\n";
foreach $key (sort keys %RES_matrix){
	$RES_matrix{$key} =~ s/\t*$//;
	print OUTT "$key\t$RB{$key}\n";
	print OUT "$RES_matrix{$key}\n";
}
print "finished\n";
close OUTT;
close OUT;
