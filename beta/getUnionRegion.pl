#! /usr/bin/perl -w
use utf8;
use strict;

die
"
	calculate region union for venn prepare files
	Usage: perl $0 <region_file>

"if(@ARGV < 1);

open IN, '<', $ARGV[0];

my $end = <IN>;
chomp $end;
my ($chr, $fs, $fe) = split / /, $end;
my %region;

while( my $line = <IN>){
	chomp $line;
	my @tag = split / /, $line;
	if( $tag[0] eq $chr ){
		if($tag[1] > $fe)
		{
			print "$chr $fs $fe\n";
			push(@{$region{$chr}}, "$fs $fe");
			($fs, $fe) = @tag[1,2];
		}else{
			$fe = $tag[2];
		}
	}else{
		print "$chr $fs $fe\n";
		push(@{$region{$chr}}, "$fs $fe");
		($chr, $fs, $fe) = @tag;
	}
#if(eof)
#{
#push();
#}
}
print "$chr $fs $fe\n";
push(@{$region{$chr}}, "$fs $fe");

open SOURCE, $ARGV[1];
open OUT, '>', "$ARGV[1].Region";

<SOURCE>;
while(<SOURCE>){
	chomp;
	my @t = split;
	my $target = $t[6];
	my ($c, $s, $e) = split /-|:/, $t[6];
	if(exists $region{$c})
	{
		foreach my $o (@{$region{$c}}){
			my @l = split / /, $o;
			if(($s>=$l[0] && $s<=$l[1]) || ($e>=$l[0] && $e<=$l[1])){
				print OUT "$c $o\n";
			}
		}
	}
}
