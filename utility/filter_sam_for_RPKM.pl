#! /usr/bin/perl -w
use utf8;
use strict;

die 
"
	filter reads by calculate mismatch site / (mismatchs + matchs) from a samfile for input and 5 columns including Qname, Rname, length, match & mismatch
	Usage：perl $0 <samfile>

"if(@ARGV != 1);

my %length_hash;
my %reads_hash;

open IN , '<' , $ARGV[0];
while (<IN>){
	if (/^@/){
		my @length = split /\t/, $_;
		if ($length[1] =~ /^SN:(\w+)/){
			$length_hash{$1} = $length[2];
			chomp($length_hash{$1});
			$length_hash{$1} =~ s/^LN://;
		}
	}
	else{
		my @text = split /\t/, $_;
		my $Svalue = 0;
		my $Mvalue = 0;
		my $value = 0;

		next if $text[5] eq "*";

		my $Stext = $text[5];
		my $Mtext = $text[5];

		while ($Mtext =~ s/(\d+)M//){
			$Mvalue += $1;
		}
		while ($Stext =~ s/(\d+)S//){
			$Svalue += $1;
		}

		$value = $Svalue/($Svalue + $Mvalue);

		if (exists $reads_hash{$text[0]} && $value <= 0.1){
				my @tmp = split /\t/, $reads_hash{$text[0]};
				$reads_hash{$text[0]} = join "\t", $text[2], $length_hash{$text[2]}, $Mvalue, $Svalue if($tmp[2]<$Mvalue || ($tmp[2]=$Mvalue && $tmp[3]>$Svalue));
		}
		else{
			if ($value <= 0.1){
				$reads_hash{$text[0]} = join "\t", $text[2], $length_hash{$text[2]}, $Mvalue, $Svalue;
			}
		}
	}
}
close IN;
open OUT , '>' , "RPKM_List.xls"; 
foreach my $key (sort keys %reads_hash){
	print OUT "$key\t$reads_hash{$key}\n"; 
}
