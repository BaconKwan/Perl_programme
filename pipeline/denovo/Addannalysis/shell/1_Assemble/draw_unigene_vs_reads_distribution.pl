#!usr/bin/perl -w
use strict;
use SVG;
	# Draws svg for uniquely mapped read-count distribution for unigenes
	# Usage: perl draw_unigene_vs_reads_distribution.pl "Infile" > "Outfile(svg)"
my $unigene_cover_file=shift;
open(IN,$unigene_cover_file)||die"cannot open:$!";
my %reads;    my %name;
while(<IN>)
{
	chomp;    my @a=split(/\s+/,$_);
	if($.==1 && $a[0]!~/Unigene/)
	{
		next;
	}
	else
	{
		&classify($a[-1]);
	}
}
close IN;
sub classify
{
	my $i=shift;
	if($i>=1 && $i<=10)
	{
		$reads{"1"}++;
		$name{"1"}="1-10";
	}
	elsif($i>=11 && $i<=100)
	{
		$reads{"2"}++;
		$name{"2"}="11-100";
	}
	elsif($i>=101 && $i<=200)
	{
		$reads{"3"}++;
		$name{"3"}="101-200";
	}
	elsif($i>=201 && $i<=300)
	{
		$reads{"4"}++;
		$name{"4"}="201-300";
	}
	elsif($i>=301 && $i<=400)
	{
		$reads{"5"}++;
		$name{"5"}="301-400";
	}
	elsif($i>=401 && $i<=500)
	{
		$reads{"6"}++;
		$name{"6"}="401-500";
	}
	elsif($i>=501 && $i<=600)
	{
		$reads{"7"}++;
		$name{"7"}="501-600";
	}
	elsif($i>=601 && $i<=700)
	{
		$reads{"8"}++;
		$name{"8"}="601-700";
	}
	elsif($i>=701 && $i<=800)
	{
		$reads{"9"}++;
		$name{"9"}="701-800";
	}
	elsif($i>=801 && $i<=900)
	{
		$reads{"10"}++;
		$name{"10"}="801-900";
	}
	elsif($i>=901 && $i<=1000)
	{
		$reads{"11"}++;
		$name{"11"}="901-1000";
	}
	elsif($i>=1001 && $i<=2000)
	{
		$reads{"12"}++;
		$name{"12"}="1001-2000";
	}
	elsif($i>=2001 && $i<=4000)
	{
		$reads{"13"}++;
		$name{"13"}="2001-4000";
	}
	elsif($i>=4001 && $i<=6000)
	{
		$reads{"14"}++;
		$name{"14"}="4001-6000";
	}
	elsif($i>=6001 && $i<=8000)
	{
		$reads{"15"}++;
		$name{"15"}="6001-8000";
	}
	elsif($i>=8001 && $i<=10000)
	{
		$reads{"16"}++;
		$name{"16"}="8001-10000";
	}
	elsif($i>10000)
	{
		$reads{"17"}++;
		$name{"17"}=">10000";
	}
	else
	{
		print STDERR "reads counts error: $i\n";
	}
}


###draw
my $svg = SVG->new('width',900,'height',700);
my $x_margin=150;     my $y_margin=500;
my $width=700;   my $height=400;
$svg->line('x1',$x_margin,'x2',$x_margin+$width,'y1',$y_margin,'y2',$y_margin,'stroke','black','stroke-width','1');
$svg->line('x1',$x_margin,'x2',$x_margin,'y1',$y_margin,'y2',$y_margin-$height,'stroke','black','stroke-width','1');
$svg->text('x',$x_margin+$width/2,'y',$y_margin+110,'-cdata','Number of reads','text-anchor','middle');
my $title_x=$x_margin-100;
my $title_y=$y_margin-$height/2;
$svg->text('x',$title_x,'y',$title_y,'-cdata','Number of Unigenes','text-anchor','middle','transform',"rotate(-90,$title_x,$title_y)");
my $y_conut=6;
my $y_gap=$height/$y_conut;
my $resolution=5000/$y_gap;
foreach my $out(1 .. $y_conut+1)
{
	$svg->line('x1',$x_margin,'x2',$x_margin-3,'y1',$y_margin-$y_gap*($out-1),'y2',$y_margin-$y_gap*($out-1),'stroke','black','stroke-width','1');
	$svg->text('x',$x_margin-10,'y',$y_margin-$y_gap*($out-1)+5,'-cdata',($out-1)*5000,'text-anchor','end');
}
my @tmp=sort {$a<=>$b} keys %name;
my $x_conut=$tmp[-1];
my $x_gap=$width/$x_conut;
foreach my $out(1 .. $x_conut)
{
	$svg->line('x1',$x_margin+$x_gap*$out,'x2',$x_margin+$x_gap*$out,'y1',$y_margin,'y2',$y_margin-3,'stroke','black','stroke-width','1');
	$svg->rect('x',$x_margin+$x_gap*($out-1)+9,'y',$y_margin-$reads{$out}/$resolution,'width',$x_gap-18,'height',$reads{$out}/$resolution,'fill','black');
	my $text_x=$x_margin+$x_gap*$out-$x_gap/2+5;;
	my $text_y=$y_margin-$reads{$out}/$resolution-10;
	$svg->text('x',$text_x,'y',$text_y,'-cdata',$reads{$out},'text-anchor','start','transform',"rotate(-90,$text_x,$text_y)");
	$text_y=$y_margin+15;
	$svg->text('x',$text_x,'y',$text_y,'-cdata',$name{$out},'text-anchor','end','transform',"rotate(-90,$text_x,$text_y)");
}
print $svg->xmlify();
