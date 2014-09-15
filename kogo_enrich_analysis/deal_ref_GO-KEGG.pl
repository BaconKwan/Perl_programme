#!/usr/bin/env perl
use warnings;
use strict;
use File::Spec::Functions qw(rel2abs);

die "perl $0 <go file> <kegg file> <outprefix> <species[animal|plant]> 
go file 4 cols from biomart: Ensembl Gene ID \\t Associated Gene Name \\t GOSlim GOA Accession(s) \\t Description
" unless @ARGV == 4;

my $s;
if($ARGV[3] eq "animal")
{
	$s = "/Bio/Database/Database/kegg/data/map_class/animal_ko_map.tab";
}elsif($ARGV[3] eq "plant"){
	$s = "/Bio/Database/Database/kegg/data/map_class/plant_ko_map.tab";
}else{
	die "species: animal or plant!";
}

my (%hash, %ts);
open GO, (($ARGV[0] =~ /.*\.gz/) ? "gzip -dc $ARGV[0] |" : $ARGV[0]) or die $!;
<GO>;
my $ourdir = "$ARGV[2]\_annot";
system "mkdir $ourdir";
open GT, "> $ourdir/$ARGV[2].annot" or die $!;
open GS, "> $ourdir/$ARGV[2].gen2sym" or die $!;
my %g2s;
while(<GO>)
{
	chomp;
	my @tmp = split /\t/;
	if(defined $tmp[1])
	{
		$g2s{$tmp[0]}{$tmp[1]} = 0;
	}else{
		$g2s{$tmp[0]}{'-'} = 0;
	}
	print GT "$tmp[0]\t$tmp[2]\n" if(defined $tmp[2] and $tmp[2] =~ /^GO:/);
	if(defined $tmp[2] and $tmp[2] =~ /^GO:/ and defined $tmp[3])
	{
		$ts{"$tmp[0]\t$tmp[3]"} = 0;
	}elsif(defined $tmp[2] and $tmp[2] =~ /^GO:/ and !defined $tmp[3]){
		
	}elsif(defined $tmp[2] and $tmp[2] !~ /^GO:/){
		$ts{"$tmp[0]\t$tmp[2]"} = 0;
	}else{
		
	}
	if(exists $hash{$tmp[1]})
	{
		push @{$hash{$tmp[1]}}, $tmp[0];
	}else{
		@{$hash{$tmp[1]}} = ();
	}
}
close GO;
close GT;
foreach(keys %g2s)
{
	foreach my $i(keys %{$g2s{$_}})
	{
		print GS "$_\t$i\n";
	}
}

open DESC, "> $ourdir/$ARGV[2].desc" or die $!;
foreach my $t(keys %ts)
{
	print DESC "$t\n";
}

chdir "$ourdir";
system "perl /Bio/Bin/pipe/RNA/denovo_2.0/annot2goa.pl $ARGV[2].annot $ARGV[2]";
system "perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/annot2wego.pl $ARGV[2].annot > $ARGV[2].wego";
chdir "..";

open KEGG, ($ARGV[1] =~ /.*\.gz/) ? "gzip -dc $ARGV[1] |" : $ARGV[1] or die $!;
open KT, "> $ourdir/$ARGV[2].ko" or die $!;
my %ko;
while(<KEGG>)
{
	chomp;
	if(/^D/)
	{
		my @tmp = split /\t/;
		next if(@tmp < 2);
		if($tmp[0] =~ /(\S+);/ or $tmp[0] =~ /(\S+) gene product/)
		{
			if(exists $hash{$1})
			{
				my @k = split /\s+/, $tmp[1];
				foreach my $t(@{$hash{$1}})
				{
					$ko{$t}{$k[0]} = 0;
				}
			}
		}
	}
}
foreach(keys %ko)
{
	foreach my $i(keys %{$ko{$_}})
	{
		print KT "$_\t$i\n";
	}
}

chdir "$ourdir";
system "perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/pathfind.pl -fg $ARGV[2].ko -komap $s -out $ARGV[2].path";
system "perl /home/sunyong/bin/genDesc.pl -gene2tr $ARGV[2].gen2sym -desc $ARGV[2].desc -pathway $ARGV[2].path -go $ARGV[2] -output $ARGV[2]Annot.txt";
chdir "..";

my $out = rel2abs($ourdir);
`sed 's#^wego=\$#wego=$out/$ARGV[2]\.wego#' /home/sunyong/bin/gokegg.sh > $out/gokegg.sh`;
`sed -i 's#^ko=#ko=$out/$ARGV[2]\.ko#' $out/gokegg.sh`;
`sed -i 's#^go=#go=$out/#' $out/gokegg.sh`;
`sed -i 's#^go_species=#go_species=$ARGV[2]#' $out/gokegg.sh`;
`sed -i 's#^mapko=\$#mapko=$s#' $out/gokegg.sh`;
