#! /usr/bin/perl
use utf8;
use strict;
use warnings;

die "perl $0 <kegg.path> <the first number> \n" unless(@ARGV eq 2);

my(%ra, %qv);
open FA, $ARGV[0] or die $!;
<FA>;
while(<FA>)
{
	chomp;
	my @tmp = split /\t/;
	my $ratio = $tmp[1] / $tmp[2];
	$ra{$tmp[0]} = $ratio;
	$qv{$tmp[0]} = "$tmp[4]\t$tmp[1]";
}
close FA;

my(%hash, $n);
open TMP, "> $ARGV[0].tmp" or die $!;
foreach(sort {$ra{$b} <=> $ra{$a}} keys %ra)
{
	$n ++;
	last if($n > $ARGV[1]);
	print TMP "$_\t$ra{$_}\t$qv{$_}\n";
}
close TMP;

open RCMD, "> $ARGV[0].r" or die $!;
print RCMD "
library(ggplot2)
mat <- read.table(\"$ARGV[0].tmp\", sep = \"\t\", check.names = 0, header = F, quote=\"\")
p <- ggplot(mat, aes(mat\$V2, mat\$V1))
p + geom_point(aes(size = mat\$V4,colour = mat\$V3)) + scale_size(\"GeneNumber\") + scale_colour_continuous(\"QValue\", low=\"red\", high = \"forestgreen\") + labs(title = \"Top 20 of Pathway Enrichment\", x = \"RichFactor\", y = \"Pathway\") + theme_bw()
ggsave(file = \"$ARGV[0].png\", dpi = 300)
";

`Rscript $ARGV[0].r`;
`rm $ARGV[0].tmp $ARGV[0].r Rplots.pdf -rf`;
