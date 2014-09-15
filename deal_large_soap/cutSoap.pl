#! /usr/bin/perl -w

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	June 25, 2014
#	Usage:	cut large soap result file into several parts

use utf8;
use strict;

die
"	This programme is use for cutting large soap files into several parts.
	Usage: perl $0 <soap_file> <cuts_amount>
"
if(@ARGV ne 2);

my $cut_cnt = 1;
my %hash;
my $prefix = $ARGV[0];
$prefix =~ s/.gz//;

open SOAP, "gzip -cd $ARGV[0] |" || die $!;
LINE:while(<SOAP>){
	chomp;
	my @line = split /\t/;
	for(my $i = 1; $i <= $ARGV[1]; $i++){
		if(exists $hash{$i}{$line[7]}){
			open OUT, ">>", "$prefix.cut.$i" || die $!;
			print OUT "$_\n";
			close OUT;
			next LINE;
		}
	}
	open OUT, ">>", "$prefix.cut.$cut_cnt" || die $!;
	open LIST, ">>", "$prefix.list.$cut_cnt" ||die $!;
	$hash{$cut_cnt}{$line[7]} = 0;
	print OUT "$_\n";
	print LIST "$line[7]\n";
	close LIST;
	close OUT;
	$cut_cnt++;
	$cut_cnt = 1 if($cut_cnt > $ARGV[1]);
	&showTime("==== reading $. line ====") if($. % 10000000 == 0);
}
close SOAP;

sub showTime{
	my ($text) = @_;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}
