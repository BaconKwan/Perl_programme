#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Getopt::Long;

die "
	Usage: perl $0 <fasta> <color> <motif> [options]
	Options:
		-o          output prefix, default: motif
		-x          image width, default: 800px
		-y          image height, default: 600px
		-lpost      legend position: top[default], topleft, topright, bottom, bottomleft, bottomright
		-mode       the model of karyo figure: normal[default] or vertical
" if(@ARGV < 3);

my (%fa, %color, %opts);
my ($label, $fill);
GetOptions(\%opts, "o=s", "x=i", "y=i", "lpost=s", "mode=s");

$opts{o} = (defined $opts{o}) ? $opts{o} : "motif";
$opts{x} = (defined $opts{x}) ? $opts{x} : 800;
$opts{y} = (defined $opts{y}) ? $opts{y} : 600;
if(defined $opts{lpost}){
	die "wrong mode: $opts{lpost}!" unless($opts{lpost} eq "topleft" || $opts{lpost} eq "top" || $opts{lpost} eq "topright" || $opts{lpost} eq "bottomleft" || $opts{lpost} eq "bottom" || $opts{lpost} eq "bottomright");
}
else{
	$opts{lpost} = "top";
}
if(defined $opts{mode}){
	die "wrong mode: $opts{mode}!" unless($opts{mode} eq "normal" || $opts{mode} eq "vertical");
}
else{
	$opts{mode} = "normal";
}

open FA, "< $ARGV[0]" || die $!;
open OUT1, "> fasta.len" || die $!;
$/ = "\n>";
while(<FA>){
	s/>//g;
	if(/\S+/){
		my $t = $&;
		my @parts = split /\n/;
		my $seq = join "\n", @parts[1..$#parts];
		$seq =~ s/\s+//g;
		my $len = length($seq);
		print OUT1 "$t\t$t\t1\t$len\tchr1\n";

		$fa{$t} = "";
	}
}
$/ = "\n";
close OUT1;
close FA;

open COLOR, "< $ARGV[1]" || die $!;
while(<COLOR>){
	chomp;
	my @line = split;
	$color{$line[0]} = $line[1];
	$label .= " $line[0]";
	$fill .= " $line[1]";
}
close COLOR;

open OUT2, "> motif.range" || die $!;
open MOTIF, "< $ARGV[2]" || die $!;
while(<MOTIF>){
	chomp;
	if(/BL\s+MOTIF/){
		my @parts = split;
		my $flag = "motif" . $parts[2];
		my $l = $1 if($parts[3] =~ /width=(\d+)/);
		while(<MOTIF>){
			chomp;
			last if(/\/\//);
			my @line = split;
			$line[2] =~ s/\)//;
			my $e = ($line[2] + $l) - 1;
			print OUT2 "$line[0]\t$line[2]\t$e\tfill=$color{$flag}\n";
		}
	}
}
close MOTIF;
close OUT2;

open CONF, "> legend.conf" || die $!;
print CONF
"<legend>
#------------------------------------
# the position of legend
# (x,y) or keywords like:
# outright, top, left ,right ,bottom 
#------------------------------------
pos = $opts{lpost}
margin = -30

#---------------------------------------------
# define the title of legend
# 1. title: the title value
# 2. title_pos: the position of title in legend
# top, right, bottom, left [default is top]
# 3. title_theme: the text theme
#---------------------------------------------
#title = color
title_pos = topleft
title_theme = size:14;family:arial;weight:bold;
title_hjust = 0
title_vjust = 0

#---------------------------------------------------
# define the labels of legend
# 1. lable: the values of label
# 2. label_pos: the position of lable around symbol
# top, right, bottom, left [default is right]
# 3. label_theme: the text theme
#---------------------------------------------------
label =$label
label_show = TRUE
label_pos = right
label_theme = size:12;font:arial;face:normal;
label_hjust = 0
lable_vjust = 0

#hspace = 5
#vspace = 5

#--------------------------------------------------------------------
# the column/row symbol number 
# can't be defined at once
# the ncol is privileged
# byrow: logical. [default is false]
# reverse: logical. If TRUE the order of legends is reversed. [FALSE]
#--------------------------------------------------------------------
#ncol = 1
nrow = 1
byrow = FALSE
reverse = FALSE

#---------------------------------------------------
# define the symbol style
# shape: the symbol shape
# color: the symbol stroke color
# fill: the symbol fill color
# width: the width of symbol 
# height: the height of symbol
#---------------------------------------------------
#shape = 0
#color = none
fill =$fill
width = 20
height = 20

hspace = 5
vspace = 5
</legend>
";
close CONF;

open CONF, "> karyo.conf" || die $!;
print CONF
"# set the conf for karyo figure
dir  = .
file = $opts{o}.svg

width = $opts{x}
height = $opts{y}
margin = 40 20 40 20
#background = ccc

<karyo>
# the file defined the karyotype 
file = fasta.len

# the model of karyo figure:
# normal , vertical, circular
model = $opts{mode}
start = 0.5r

# ideogram
<ideogram>
show = yes
thickness = 20

show_chromosomes_default = yes
#chromosomes = chr1;chr2;-chr3;chr4
#chromosomes_order = chr4;chr3;chr2;chr1
#chromosomes_breaks = 
#chromosomes_reverse = chr2;chr1
chromosomes_color = no
chromosomes_rounded_ends = no

show_label = yes
label_with_tag = no
label_parallel = yes
</ideogram>


# highlights
<highlights>
stroke_width = 0
<highlight>
file = motif.range
ideogram = yes
loc0 = -20
loc1 = -40
shape = 0
fill = fc0
color = 000
</highlight>
</highlights>


<<include legend.conf>>
</karyo>
<<include etc/colors.conf>>
<<include etc/styles/styles.karyo.conf>>
";
close CONF;

`ln -sf /home/guanpeikun/tools/SBV/bin/sbv.pl ./`;
#print "RUNNING: perl sbv.pl karyo -conf karyo.conf\n";
#`perl sbv.pl karyo -conf karyo.conf`;
#print "RUNNING: convert $opts{o}.svg $opts{o}.png\n";
#`convert $opts{o}.svg $opts{o}.png`;

print
"
please run:
	draw motif SVG : perl sbv.pl karyo -conf karyo.conf
	SVG 2 PNG format : convert $opts{o}.svg $opts{o}.png
";
