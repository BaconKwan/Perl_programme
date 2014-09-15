#!usr/bin/perl -w
use strict;
use Excel::Writer::XLSX;
use File::Basename qw /basename/;

my $abs_path = shift;
chomp($abs_path);
my $file = basename $abs_path;

my $workbook = Excel::Writer::XLSX->new("$abs_path.xlsx");
my $worksheet = $workbook->add_worksheet();

open IN,$abs_path||die "cannot open $!";

while (<IN>)
{
	chomp;
	my @arr = split (/\t/,$_);
	foreach my $item (0 .. $#arr)
	{
		$worksheet->write($.-1,$item,$arr[$item]);
	}
}
close IN;

`rm $abs_path`;
