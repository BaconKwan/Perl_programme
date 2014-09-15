#! /usr/bin/perl -w

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	June 25, 2014
#	Usage:	cut large SEsoap; use with cutSoap.pl

use utf8;
use strict;

die
"	This programme is use for cutting SE_file by a list fetch from PE_file
	Usage: perl $0 <SE_soap_file> <PElist_file_prefix>
"
if(@ARGV ne 2);

my %hash;
my @files = `ls $ARGV[1]*`;
my @cnt;
my $prefix = $ARGV[0];
$prefix =~ s/.gz//;

foreach my $list (@files){
	open LIST, "$list" || die $!;
	my $i = $1 if($list =~ /([0-9]+)$/);
	push(@cnt, $i);
	while(<LIST>){
		chomp;
		$hash{$i}{$_} = 0;
	}
	close LIST;
}

open SOAP, "gzip -cd $ARGV[0] |" || die $!;
while(<SOAP>){
	chomp;
	my @line = split /\t/;
	foreach my $n (@cnt){
		if(exists $hash{$n}{$line[7]}){
			open OUT, ">> $prefix.cut.$n" || die $!;
			print OUT "$_\n";
			close OUT;
		}
	}
	&showTime("==== reading $. line ====") if($. % 10000000 == 0);
}
close SOAP;

sub showTime{
	my ($text) = @_;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}

