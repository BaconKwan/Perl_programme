#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;

die"
	Usage: perl $0 <bed_file> <output_prefix>

"if(@ARGV ne 2);

my @exonLen;
my @exonSite;
my @line;
my($length, $_5UTR, $_3UTR, $_5post, $_3post);

open BED, "< $ARGV[0]" || die $!;
open LEN, "> $ARGV[1].len" || die $!;
open INFO, "> $ARGV[1].info" || die $!;
while(<BED>){
	chomp;
	@line = split /\t/;

	# write length file
	$length = $line[2] - $line[1] + 1;
	print LEN "$line[3]\t$line[3]\t1\t$length\tchr1\n";

	# write info file
	@exonLen = split /,/, $line[10];
	@exonSite = split /,/, $line[11];
	$_5UTR = $line[6] - $line[1];
	$_3UTR = $line[2] - $line[7];
	$_5post = -1;
	$_3post = $#exonSite + 1;

	foreach my $i (0..$#exonSite){
		$_5post = $i if($_5UTR > $exonSite[$i] && $_5UTR <= ($exonSite[$i] + $exonLen[$i]));
		$_3post = $i if(($length - $_3UTR) > $exonSite[$i] && ($length - $_3UTR) <= ($exonSite[$i] + $exonLen[$i]));
	}

	if((-1 == $_5post) && ($_3post < $#exonSite)){
		&step3;
		&step4;
		&step5;
	}
	elsif((-1 == $_5post) && ($#exonSite == $_3post)){
		&step3;
		&step4;
	}
	elsif((-1 == $_5post) && (($#exonSite + 1) == $_3post)){
		&step3;
	}
	elsif((0 == $_5post) && ($_3post < $#exonSite)){
		if($_5post == $_3post){
			&stepX;
			&step5;
		}
		else{
			&step2;
			&step3;
			&step4;
			&step5;
		}
	}
	elsif((0 == $_5post) && ($#exonSite == $_3post)){
		if($_5post == $_3post){
			&stepX;
		}
		else{
			&step2;
			&step3;
			&step4;
		}
	}
	elsif((0 == $_5post) && (($#exonSite + 1) == $_3post)){
		&step2;
		&step3;
	}
	elsif((0 < $_5post) && ($_3post < $#exonSite)){
		if($_5post == $_3post){
			&step1;
			&stepX;
			&step5;
		}
		else{
			&step1;
			&step2;
			&step3;
			&step4;
			&step5;
		}
	}
	elsif((0 < $_5post) && ($#exonSite == $_3post)){
		if($_5post == $_3post){
			&step1;
			&stepX;
		}
		else{
			&step1;
			&step2;
			&step3;
			&step4;
		}
	}
	elsif((0 < $_5post) && (($#exonSite + 1) == $_3post)){
		&step1;
		&step2;
		&step3;
	}
}
close INFO;
close LEN;
close BED;

sub step1{
	for(my $i = 0; $i <= $_5post-1; $i++){
		my $s = $exonSite[$i] + 1;
		my $e = $s + $exonLen[$i];
		print INFO "$line[3]\t$s\t$e\tfill=#000000\n";
	}
}

sub step2{
	my $_5us = $exonSite[$_5post] + 1;
	my $_5ue = $_5UTR + 1;
	my $_5cs = $_5ue + 1;
	my $_5ce = $_5us + $exonLen[$_5post];
	print INFO "$line[3]\t$_5us\t$_5ue\tfill=#000000\n";
	print INFO "$line[3]\t$_5cs\t$_5ce\tfill=#0000FF\n";
}

sub step3{
	for(my $i = $_5post + 1; $i <= $_3post-1; $i++){
		my $s = $exonSite[$i] + 1;
		my $e = $s + $exonLen[$i];
		print INFO "$line[3]\t$s\t$e\tfill=#0000FF\n";
	}
}

sub step4{
	my $_3cs = $exonSite[$_3post] + 1;
	my $_3ce = $length - $_3UTR - 1;
	my $_3us = $_3ce + 1;
	my $_3ue = $_3cs + $exonLen[$_3post];
	print INFO "$line[3]\t$_3cs\t$_3ce\tfill=#0000FF\n";
	print INFO "$line[3]\t$_3us\t$_3ue\tfill=#000000\n";
}

sub step5{
	for(my $i = $_3post + 1; $i <= $#exonSite; $i++){
		my $s = $exonSite[$i] + 1;
		my $e = $s + $exonLen[$i];
		print INFO "$line[3]\t$s\t$e\tfill=#000000\n";
	}
}

sub stepX{
	my $_5us = $exonSite[$_5post] + 1;
	my $_5ue = $_5UTR + 1;
	my $cs = $_5ue + 1;
	my $ce = $length - $_3UTR - 1;
	my $_3us = $ce + 1;
	my $_3ue = $_5us + $exonLen[$_5post];
	print INFO "$line[3]\t$_5us\t$_5ue\tfill=#000000\n";
	print INFO "$line[3]\t$cs\t$ce\tfill=#0000FF\n";
	print INFO "$line[3]\t$_3us\t$_3ue\tfill=#000000\n";
}
