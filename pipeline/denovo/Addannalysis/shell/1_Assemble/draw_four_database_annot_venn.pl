#!usr/bin/perl -w
use strict;
use SVG;
use Math::Combinatorics;

## read file
my $dir=shift;
my @list=` ls $dir/*_id.xls`;
my %hash;
my @database;
foreach my $out (@list)
{
	chomp $out;    my $db;
	if($out=~/([^\/]+)_id\.xls/)
	{
		$db=$1;   push @database,$db;
	}
	open(IN,$out)||die"cannot open:$!";
	while(<IN>)
	{
		chomp;  my @a=split(/\s+/,$_);
		if($.==1 && $a[0] eq "geneID")
		{
			next;
		}
		else
		{
			if(!exists $hash{$a[0]})
			{
				push @{$hash{$a[0]}},$db;
			}
			else
			{
				my $mark=-1;
				foreach my $in(@{$hash{$a[0]}})
				{
					if($in eq $db)
					{
						$mark=1;
						last;
					}
					else
					{
						$mark=0;
					}
				}
				if($mark==0)
				{
					push @{$hash{$a[0]}},$db;
				}
			}
		}
	}
	close IN;
}


### draw
my %count;
foreach my $out(keys %hash)
{
	my $tmp=join",",@{$hash{$out}};
	$count{$tmp}++;
}
close IN;

my $svg = SVG->new('width',1500,'height',1000);
my $x=500;   my $y=300;   my $rx=200;   my $ry=100;
my $rotate_x=400;   my $rotate_y=340;    my $shift_x=32;   my $shift_y=80;
#{
my $rotate=0;
$rotate=-45;
$svg->ellipse('cx',$x-$shift_x,'cy',$y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'green','transform',"rotate($rotate,$rotate_x,$rotate_y)");
$svg->ellipse('cx',$x,'cy',$y+$shift_y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'red','transform',"rotate($rotate,$rotate_x,$rotate_y)");
$rotate=-135;
$svg->ellipse('cx',$x,'cy',$y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'blue','transform',"rotate($rotate,$rotate_x,$rotate_y)");
$svg->ellipse('cx',$x-$shift_x,'cy',$y+$shift_y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'chocolate','transform',"rotate($rotate,$rotate_x,$rotate_y)");

$rotate=-45;
$svg->ellipse('cx',$x-$shift_x,'cy',$y,'rx',$rx,'ry',$ry,'stroke'=>'black','stroke-width'=>'4','fill'=>'none','transform',"rotate($rotate,$rotate_x,$rotate_y)");
$svg->ellipse('cx',$x,'cy',$y+$shift_y,'rx',$rx,'ry',$ry,'stroke'=>'black','stroke-width'=>'4','fill'=>'none','transform',"rotate($rotate,$rotate_x,$rotate_y)");
$rotate=-135;
$svg->ellipse('cx',$x,'cy',$y,'rx',$rx,'ry',$ry,'stroke'=>'black','stroke-width'=>'4','fill'=>'none','transform',"rotate($rotate,$rotate_x,$rotate_y)");
$svg->ellipse('cx',$x-$shift_x,'cy',$y+$shift_y,'rx',$rx,'ry',$ry,'stroke'=>'black','stroke-width'=>'4','fill'=>'none','transform',"rotate($rotate,$rotate_x,$rotate_y)");

@database=sort @database;
my $text_r=$x-$rotate_x+$rx;    my $pi=3.1415926;   my $bias_1=40;   my $bias_2=60;
$svg->text('x',$rotate_x-(cos($bias_1/180*$pi)*$text_r+50),'y',$rotate_y-sin($bias_1/180*$pi)*$text_r,'-cdata',$database[0],'text-anchor','middle','fill','blue','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_2/180*$pi)*$text_r,'y',$rotate_y-sin($bias_2/180*$pi)*$text_r,'-cdata',$database[1],'text-anchor','middle','fill','chocolate','font-weight','bold');
$svg->text('x',$rotate_x+(cos($bias_1/180*$pi)*$text_r+50),'y',$rotate_y-sin($bias_1/180*$pi)*$text_r,'-cdata',$database[3],'text-anchor','middle','fill','red','font-weight','bold');
$svg->text('x',$rotate_x+cos($bias_2/180*$pi)*$text_r,'y',$rotate_y-sin($bias_2/180*$pi)*$text_r,'-cdata',$database[2],'text-anchor','middle','fill','green','font-weight','bold');

my %output;  my @db_combinations=();
foreach my $out(1 .. 4)
{
	#$tmp++;
	my @name=map {join",",sort (@$_)} combine($out,@database);    #### combine return a list of array,so here use @$_
	foreach my $in(@name)
	{
		push @db_combinations,$in;
	}
}
my $tmp=0;
foreach my $out(sort @db_combinations)
{
	$tmp++;
	if(exists $count{$out})
	{
		$output{$tmp}=$count{$out};
	}
	else
	{
		$output{$tmp}=0;
	}
}

$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-20),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-150),'-cdata',$output{"1"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-130),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-100),'-cdata',$output{"2"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-220),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-200),'-cdata',$output{"3"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-300),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-310),'-cdata',$output{"4"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-350),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-400),'-cdata',$output{"5"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-170),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-350),'-cdata',$output{"6"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-250),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-400),'-cdata',$output{"7"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-300),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-450),'-cdata',$output{"8"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_2/180*$pi)*($text_r-120),'y',$rotate_y-sin($bias_2/180*$pi)*($text_r-75),'-cdata',$output{"9"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-300),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-100),'-cdata',$output{"10"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-380),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-200),'-cdata',$output{"11"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-430),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-350),'-cdata',$output{"12"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_2/180*$pi)*($text_r-480),'y',$rotate_y-sin($bias_2/180*$pi)*($text_r-75),'-cdata',$output{"13"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-470),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-100),'-cdata',$output{"14"},'text-anchor','middle','font-weight','bold');
$svg->text('x',$rotate_x-cos($bias_1/180*$pi)*($text_r-580),'y',$rotate_y-sin($bias_1/180*$pi)*($text_r-150),'-cdata',$output{"15"},'text-anchor','middle','font-weight','bold');
print $svg->xmlify();
