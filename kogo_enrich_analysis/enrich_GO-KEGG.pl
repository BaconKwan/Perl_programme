#!/usr/bin/env perl
use warnings;
use strict;

die "perl $0 <dir> <gokegg.sh>\n" if(@ARGV ne 2);

#`sed 's/LISTS/\$\(ls $ARGV[0]\/\*\.glist\)/' $ARGV[1] > $ARGV[2].sh`;
open SH, "> $ARGV[0]/glist.sh" or die $!;
print SH "for i in `ls $ARGV[0]/*.txt`; do a=`basename \$i .DEfilter.txt`; sed 1d \$i > $ARGV[0]/\$a.tmp; done \n";
print SH "for i in `ls $ARGV[0]/*.tmp`; do a=`basename \$i .tmp`; perl -lane 'if(/^XLOC/){}else{print \"\$F[0]\\t\$F[9]\"}' \$i > $ARGV[0]/\$a.glist; done \n";

`sh $ARGV[0]/glist.sh`;
`rm $ARGV[0]/*.tmp $ARGV[0]/glist.sh -rf`;

open GK, $ARGV[1] or die $!;
open OUT, "> $ARGV[0]/enrich.sh" or die $!;
while(<GK>)
{
	if(/LISTS/){
		$_ =~ s#LISTS#\$\(ls $ARGV[0]/\*\.glist\)#;
	}elsif(/OUTK/){
		$_ =~ s#OUTK#$ARGV[0]/Pathway#g;
	}elsif(/OUTG/){
		$_ =~ s#OUTG#$ARGV[0]/GO#g;
	}elsif(/GOUP/){
		$_ =~ s#GOUP#$ARGV[0]#g;
	}
	print OUT;
}
mkdir "$ARGV[0]/Pathway";
mkdir "$ARGV[0]/GO";
chdir $ARGV[0];
`sh $ARGV[0]/enrich.sh`;
`rm $ARGV[0]/enrich.sh -rf`;
