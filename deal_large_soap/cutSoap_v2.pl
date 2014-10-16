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
	This programme is use for cutting large soap files into several parts.
	Usage: perl $0 <SoapAlign.gz> <SoapSingle.gz> <cuts_amount>
"
if(@ARGV ne 3);

my ($cut_cnt, $A_pfx, $S_pfx) = (1, $ARGV[0], $ARGV[1]);
my %hash;
$A_pfx =~ s/.gz//;
$S_pfx =~ s/.gz//;

open SOAP, "gzip -cd $ARGV[0] |" || die $!;
LINE:while(<SOAP>){
		chomp;
		my @line = split /\t/;
		for(my $i = 1; $i <= $ARGV[2]; $i++){
			if(exists $hash{$i}{$line[7]}){
				open OUT, ">>:gzip", "$A_pfx.cut.$i.gz" || die $!;
				print OUT "$_\n";
				close OUT;
				next LINE;
				}
			}
		open OUT, ">>:gzip", "$A_pfx.cut.$cut_cnt.gz" || die $!;
		$hash{$cut_cnt}{$line[7]} = 0;
		print OUT "$_\n";
		close OUT;
		$cut_cnt++;
		$cut_cnt = 1 if($cut_cnt > $ARGV[2]);
		&showTime("==== reading SoapAlign file $. line ====") if($. % 10000000 == 0);
	 }
close SOAP;

open SOAP, "gzip -cd $ARGV[1] |" || die $!;
while(my $line = <SOAP>){
	chomp $line;
	my @line = split /\t/, $line;
	foreach(sort { $a <=> $b } keys %hash){
		if(exists $hash{$_}{$line[7]}){
			open OUT, ">>:gzip", "$S_pfx.cut.$_.gz" || die $!;
			print OUT "$line\n";
			close OUT;
			}
		}
	&showTime("==== reading SoapSingle file $. line ====") if($. % 10000000 == 0);
}
close SOAP;

sub showTime{
	my ($text) = @_;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}

