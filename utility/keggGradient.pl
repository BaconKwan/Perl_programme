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
	my $ratio = $tmp[3] / $tmp[4];
	$ra{$tmp[2]} = $ratio;
	$qv{$tmp[2]} = "$tmp[6]\t$tmp[3]";
}
close FA;

my(%hash, $n);
open TMP, "> $ARGV[0].tmp" or die $!;
foreach(sort {$ra{$b} <=> $ra{$a}} keys %ra)
{
	$n ++;
	last if($n > $ARGV[1]);
	my $path = $_;
	$path =~ s/'/\'/g;
	$path =~ s/"/\"/g;
	print TMP "$path\t$ra{$_}\t$qv{$_}\n";
}
close TMP;

open RCMD, "> $ARGV[0].r" or die $!;
print RCMD "
library(ggplot2)
mat <- read.table(\"$ARGV[0].tmp\", sep = \"\t\", check.names = 0, header = F, quote=\"\")
matmp = as.matrix(mat)
matmpx = arrayInd(order(matmp,decreasing=TRUE)[1:1],dim(matmp))
matx = mat[matmpx[1,1],matmpx[1,2]]
matmpi = arrayInd(order(matmp,decreasing=FALSE)[1:1],dim(matmp))
mati = mat[matmpi[1,1],matmpi[1,2]]
if (matx == mati)
{
	p <- ggplot(mat, aes(mat\$V2, mat\$V1))
	p + geom_point(aes(size = mat\$V4,colour = mat\$V3)) + scale_size(\"GeneNumber\") + scale_colour_continuous(\"QValue\", low=\"red\", high = \"forestgreen\") + labs(title = \"Top $ARGV[1] of  Pathway Enrichment\", x = \"RichFactor\", y = \"Pathway\") + theme_bw()
	ggsave(file = \"$ARGV[0].png\", dpi = 300)
}else{
	p <- ggplot(mat, aes(mat\$V2, mat\$V1))
	p + geom_point(aes(size = mat\$V4,colour = \"red\")) + scale_size(\"GeneNumber\") + labs(title = \"Top $ARGV[1] of Pathway Enrichment\", x = \"RichFactor\", y = \"Pathway\") + theme_bw()
	ggsave(file = \"$ARGV[0].png\", dpi = 300)
}
";

`Rscript $ARGV[0].r`;
`rm $ARGV[0].tmp $ARGV[0].r Rplots.pdf -rf`;
