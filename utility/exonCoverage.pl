#! /usr/bin/perl -w

use utf8;
use strict;
use File::Basename qw(basename);

#die "perl $0 <12bed> <outprefix> <bam>\n" if(@ARGV ne 3);

open BED, "< $ARGV[0]" || die $!;
open OUT, "> $ARGV[1].4bed" || die $!;
while(<BED>){
	chomp;
	my @line = split /\t/;
	my @start_site = split /,/, $line[11];
	my @range = split /,/, $line[10];
	my %exons_range;
	my $cnt = 1;
	for(my $i = 0; $i <= $#start_site; $i++){
		my $s = $line[1] + $start_site[$i];
		my $e = $s + $range[$i];
		foreach my $ss (sort keys %exons_range){
			if($s < $ss){
				if($e < $ss){}
				elsif($e >= $ss && $e <= $exons_range{$ss}){
					$e = $exons_range{$ss};
					delete $exons_range{$ss};
				}
				elsif($e > $exons_range{$ss}){
					delete $exons_range{$ss};
				}
			}
			elsif($s >= $ss && $s <= $exons_range{$ss}){
				if($e <= $exons_range{$ss}){
					$s = $ss;
					$e = $exons_range{$ss};
					delete $exons_range{$ss};
				}
				elsif($e > $exons_range{$ss}){
					$s = $ss;
					delete $exons_range{$ss};
				}
			}
			elsif($s > $exons_range{$ss}){}
		}
		$exons_range{$s} = $e;
	}
	foreach my $tag (sort keys %exons_range){
print OUT "$line[0]\t$tag\t$exons_range{$tag}\t$line[3]\n";
#		print OUT "$line[0]\t$tag\t$exons_range{$tag}\t$line[3].",$cnt++,"\n";
		delete $exons_range{$tag};
	}
}
close OUT;
close BED;
=cut
`/usr/bin/bedtools coverage -abam $ARGV[2] -b $ARGV[1].4bed > $ARGV[1].4bedstat`;
`rm $ARGV[1].4bed -rf`;

my %hash;
open STAT, "$ARGV[1].4bedstat" or die $!;
while(<STAT>)
{
	chomp;
	my @tmp = split;
	$hash{$tmp[3]}{sum} += $tmp[6];
	$hash{$tmp[3]}{cov} += $tmp[5];
}
close STAT;
`rm $ARGV[1].4bedstat -rf`;

open OP, "> $ARGV[1].coverage" or die $!;
my %stat;
foreach(keys %hash)
{
	next if($hash{$_}{cov} == 0);
	my $ratio = $hash{$_}{cov}/$hash{$_}{sum};
	if($ratio >= 0.9)
	{
		$stat{"90-100%"} ++;
	}elsif($ratio >= 0.8 && $ratio < 0.9){
		$stat{"80-90%"} ++;
	}elsif($ratio >= 0.7 && $ratio < 0.8){
		$stat{"70-80%"} ++;
	}elsif($ratio >= 0.6 && $ratio < 0.7){
		$stat{"60-70%"} ++;
	}elsif($ratio >= 0.5 && $ratio < 0.6){
		$stat{"50-60%"} ++;
	}elsif($ratio >= 0.4 && $ratio < 0.5){
		$stat{"40-50%"} ++;
	}elsif($ratio >= 0.3 && $ratio < 0.4){
		$stat{"30-40%"} ++;
	}elsif($ratio >= 0.2 && $ratio < 0.3){
		$stat{"20-30%"} ++;
	}elsif($ratio >= 0.1 && $ratio < 0.2){
		$stat{"10-20%"} ++;
	}elsif($ratio >= 0.0 && $ratio < 0.1){
		$stat{"00-10%"} ++;
	}
}
foreach(sort {$a cmp $b} keys %stat)
{
	print OP "$_\t$stat{$_}\n";
}

my $name = basename($ARGV[1]);
open CMD, "> $ARGV[1].coverage.r" or die $!;
print CMD "
dat <- read.table(\"$ARGV[1].coverage\", header = F, row.names = 1, sep=\"\\t\")
png(\"$ARGV[1].coverage.png\",width=800,height=600)
label <- sprintf(\"%s: %d\",row.names(dat), dat[,1])
percent <- sprintf(\"%2.2f%s\",100*dat[,1]/sum(dat[,1]),\"%\")
pie(as.numeric(100*dat[,1]), main=\"Distribution of Genes\' Coverage($name)\", col=rainbow(14),border=\"white\", clockwise=\"T\", labels=percent, font=1,cex=1,cex.main=2)
legend(\"topright\",legend=label, bty=\"n\",pch=15, pt.cex=2.2, col=rainbow(14))
dev.off()
";

`Rscript $ARGV[1].coverage.r`;
