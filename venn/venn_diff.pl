#!/usr/bin/perl -w
=head1 name

	 venn_diff.pl

=head1 descripyion

	-outdir outdir
	-l Filelist (Ps:list name must be like Samplename.xls or SampleA.txt or SampleA.xxxxx)
	-h heaher..T or F..The default is F.

=head1 example

	perl venn_diff.pl -outdir xxx -l xx,xx,xx,xx

=cut

use strict;
use Getopt::Long;
use File::Basename;
use Math::Combinatorics;
use SVG;

my ($number,$list,$outdir,$head);
GetOptions(
	"l=s"=>\$list,
	"outdir=s"=>\$outdir,
	"h=s"=>\$head,
);

die ` pod2text $0` unless ($list);
$head="F" unless ($head);
$head="T" if $head =~ /t/i;
$outdir="." unless ($outdir);
`mkdir $outdir` unless (-e $outdir);

my @list=split /,/,$list;
$number=@list;
my @database;
my %hash;
foreach my $out (@list)
{
	chomp $out; my $db;
	my $a=basename $out;
	if ($a=~ /(\S+?)\./)
	{
		$db=$1; push @database,$db;
	}
	open (IN,$out) || die"cannot open:$!";
	<IN> if $head eq "T";
	while (<IN>)
	{
		chomp;
		my @inf=split;
		my $b;
		if (defined$inf[0])
		{
			$b=$inf[0];
		}
		else
		{
			$b=$_;
		}
		if ($.==1 && $_ =~/geneID/i)
		{
			next;
		}
		else
		{
			if (!exists $hash{$b})
			{
				push @{$hash{$b}},$db;
			}
			else
			{
				my $mark=-1;
				for my $in(@{$hash{$b}})
				{
					if ($in eq $db)
					{
						$mark=1;
						last;
					}
					else
					{
						$mark=0;
					}
				}
				if ($mark==0)
				{
					push @{$hash{$b}},$db;
				}
			}
		}
	}
	close IN;
}

my %count;
for my $out(keys %hash)
{
	my @a=sort @{$hash{$out}};
	my $tmp=join"_",@a;
	$count{$tmp}++;
	open OUT,">$outdir/$tmp.veen.xls" ;
	close OUT;
}

for my $out(keys %hash)
{
	my @a=sort @{$hash{$out}};
	my $tmp=join"_",@a;
	open OUT,">>$outdir/$tmp.veen.xls";
	print OUT "$out\n";
}
@database=sort @database;
my %output;my @db_combinations=();
foreach my $out(1..$number)
{
	my @name=map{join"_",sort(@$_)} combine($out,@database);
	for my $in(@name)
	{
		push @db_combinations,$in;
	}
}
my $tmp=0;
foreach my $out(sort @db_combinations)
{
	$tmp++;
	if (exists $count{$out})
	{
		$output{$tmp}=$count{$out};
	}
	else
	{
		$output{$tmp}=0;
	}
}
open OUT,">$outdir/Venn.svg" ||die"cannot open:$!";
if ($number == 2)
{
	my $svg=SVG ->new ('width',1000,'height',800);
	$svg->circle('cx',400,'cy',400,'r',180,'fill','red','stroke','black','stroke-width','1','fill-opacity',0.3);
	$svg->circle('cx',630,'cy',400,'r',180,'fill','green','stroke','black','stroke-width','1','fill-opacity',0.3);
	$svg->text('x',365,'y',210,'-cdata',$database[0],'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',655,'y',210,'-cdata',$database[1],'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',360,'y',403,'-cdata',$output{"1"},'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',515,'y',403,'-cdata',$output{"2"},'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',670,'y',403,'-cdata',$output{"3"},'text-anchor','middle','font-size',24,'style','fill: black');
	my $print=$svg->xmlify();
	print OUT $print;
}
elsif($number==3)
{
	my $svg=SVG ->new ('width',900,'height',800);
	$svg->circle('cx',370,'cy',480,'r',180,'fill','red','stroke','red','stroke-width','1','fill-opacity',0.3);
	$svg->circle('cx',560,'cy',480,'r',180,'fill','blue','stroke','blue','stroke-width','1','fill-opacity',0.3);
	$svg->circle('cx',465,'cy',290,'r',180,'fill','green','stroke','green','stroke-width','1','fill-opacity',0.3);
	$svg->text('x',600,'y',100,'-cdata',$database[0],'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',160,'y',675,'-cdata',$database[1],'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',740,'y',675,'-cdata',$database[2],'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',465,'y',270,'-cdata',$output{"1"},'text-anchor','middle','font-size',20,'style','fill: black');
	$svg->text('x',370,'y',380,'-cdata',$output{"2"},'text-anchor','middle','font-size',20,'style','fill: black');
	$svg->text('x',465,'y',420,'-cdata',$output{"3"},'text-anchor','middle','font-size',20,'style','fill: black');
	$svg->text('x',560,'y',380,'-cdata',$output{"4"},'text-anchor','middle','font-size',20,'style','fill: black');
	$svg->text('x',335,'y',510,'-cdata',$output{"5"},'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',465,'y',510,'-cdata',$output{"6"},'text-anchor','middle','font-size',24,'style','fill: black');
	$svg->text('x',595,'y',510,'-cdata',$output{"7"},'text-anchor','middle','font-size',20,'style','fill: black');

	my $print=$svg->xmlify();
	print OUT $print;
}
elsif ($number==4)
{
	my $svg = SVG->new('width',800,'height',540);
	my $x=500;   my $y=300;   my $rx=200;   my $ry=100;
	my $rotate_x=400;   my $rotate_y=340;    my $shift_x=32;   my $shift_y=80;
	my $rotate=0;
	$rotate=-45;
	$svg->ellipse('cx',$x-$shift_x,'cy',$y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'green','stroke'=>'black','stroke-width'=>'4','transform',"rotate($rotate,$rotate_x,$rotate_y)");
	$svg->ellipse('cx',$x,'cy',$y+$shift_y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'red','stroke'=>'black','stroke-width'=>'4','transform',"rotate($rotate,$rotate_x,$rotate_y)");
	$rotate=-135;
	$svg->ellipse('cx',$x,'cy',$y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'blue','stroke'=>'black','stroke-width'=>'4','transform',"rotate($rotate,$rotate_x,$rotate_y)");
	$svg->ellipse('cx',$x-$shift_x,'cy',$y+$shift_y,'rx',$rx,'ry',$ry,'fill-opacity'=>'0.5','fill'=>'chocolate','stroke'=>'black','stroke-width'=>'4','transform',"rotate($rotate,$rotate_x,$rotate_y)");
######################text#######################
	my $text_r=$x-$rotate_x+$rx;    my $pi=3.1415926;   my $bias_1=40;   my $bias_2=60;
	$svg->text('x',$rotate_x-(cos($bias_1/180*$pi)*$text_r+50),'y',$rotate_y-sin($bias_1/180*$pi)*$text_r,'-cdata',$database[0],'text-anchor','middle','fill','blue','font-weight','bold');
	$svg->text('x',$rotate_x-cos($bias_2/180*$pi)*$text_r,'y',$rotate_y-sin($bias_2/180*$pi)*$text_r,'-cdata',$database[1],'text-anchor','middle','fill','chocolate','font-weight','bold');
	$svg->text('x',$rotate_x+(cos($bias_1/180*$pi)*$text_r+50),'y',$rotate_y-sin($bias_1/180*$pi)*$text_r,'-cdata',$database[3],'text-anchor','middle','fill','red','font-weight','bold');
	$svg->text('x',$rotate_x+cos($bias_2/180*$pi)*$text_r,'y',$rotate_y-sin($bias_2/180*$pi)*$text_r,'-cdata',$database[2],'text-anchor','middle','fill','green','font-weight','bold');
#######################################################################i
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

	my $print=$svg->xmlify();
	print OUT $print;
}
elsif ($number==5)
{
	my $center_x=350;  my $center_y=350;  my $radius_d=110; my $radius_c=160; my $radius_b=140;  my $radius_a=75;  my $pi=atan2(1,1)*4;
	my $start_x=$center_x-$radius_d;   my $line_x=430;
	my $svg=SVG->new('width',1000,'height',900);
	my $sin=$center_x-sin(5/180*$pi)*$radius_a;    my $cos=$center_y-cos(5/170*$pi)*$radius_a;   my $cos1=$center_y+cos(5/170*$pi)*$radius_a;
	$svg->path('d',"M$start_x $center_y A$radius_d $radius_a 0 0 1 $sin $cos L$line_x 260 A$radius_c $radius_b 0 1 1 $line_x 440 L$sin $cos1 A$radius_d $radius_a 0 0 1 $start_x $center_y",'stroke','red','stroke-width',1,'fill',"red",'fill-opacity','0.3','stroke-opacity','1');
	$svg->path('d',"M$start_x $center_y A$radius_d $radius_a 0 0 1 $sin $cos L$line_x 260 A$radius_c $radius_b 0 1 1 $line_x 440 L$sin $cos1 A$radius_d $radius_a 0 0 1 $start_x $center_y",'stroke','blue','stroke-width',1,'fill',"blue",'fill-opacity','0.3','stroke-opacity','1','transform',"rotate(72,420,320)");
	$svg->path('d',"M$start_x $center_y A$radius_d $radius_a 0 0 1 $sin $cos L$line_x 260 A$radius_c $radius_b 0 1 1 $line_x 440 L$sin $cos1 A$radius_d $radius_a 0 0 1 $start_x $center_y",'stroke','green','stroke-width',1,'fill',"green",'fill-opacity','0.3','stroke-opacity','1','transform',"rotate(144,420,320)");
	$svg->path('d',"M$start_x $center_y A$radius_d $radius_a 0 0 1 $sin $cos L$line_x 260 A$radius_c $radius_b 0 1 1 $line_x 440 L$sin $cos1 A$radius_d $radius_a 0 0 1 $start_x $center_y",'stroke','yellow','stroke-width',1,'fill',"yellow",'fill-opacity','0.3','stroke-opacity','1','transform',"rotate(216,420,320)");
	$svg->path('d',"M$start_x $center_y A$radius_d $radius_a 0 0 1 $sin $cos L$line_x 260 A$radius_c $radius_b 0 1 1 $line_x 440 L$sin $cos1 A$radius_d $radius_a 0 0 1 $start_x $center_y",'stroke','brown','stroke-width',1,'fill',"brown",'fill-opacity','0.3','stroke-opacity','1','transform',"rotate(288,420,320)");

	$svg->text('x',620,'y',70,'stroke',"black",'stroke-width',0.7,'-cdata',$database[0],'text-anchor','middle','font-style','italic','font-size',15);
	$svg->text('x',753,'y',350,'stroke',"black",'stroke-width',0.7,'-cdata',$database[1],'text-anchor','middle','font-style','italic','font-size',15);
	$svg->text('x',500,'y',630,'stroke',"black",'stroke-width',0.7,'-cdata',$database[2],'text-anchor','middle','font-style','italic','font-size',15);
	$svg->text('x',115,'y',515,'stroke',"black",'stroke-width',0.7,'-cdata',$database[3],'text-anchor','middle','font-style','italic','font-size',15);
	$svg->text('x',170,'y',90,'stroke',"black",'stroke-width',0.7,'-cdata',$database[4],'text-anchor','middle','font-style','italic','font-size',15);

	$svg->text('x',520,'y',100,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{1}",'text-anchor','middle');
	$svg->text('x',640,'y',350,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{17}",'text-anchor','middle');
	$svg->text('x',450,'y',540,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{25}",'text-anchor','middle');
	$svg->text('x',220,'y',410,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{29}",'text-anchor','middle');
	$svg->text('x',260,'y',170,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{31}",'text-anchor','middle');

	$svg->text('x',425,'y',320,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{5}",'text-anchor','middle');

	$svg->text('x',493,'y',270,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{8}",'text-anchor','middle');
	$svg->text('x',485,'y',373,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{6}",'text-anchor','middle');
	$svg->text('x',395,'y',398,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{4}",'text-anchor','middle');
	$svg->text('x',330,'y',315,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{20}",'text-anchor','middle');
	$svg->text('x',393,'y',227,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{12}",'text-anchor','middle');

	$svg->text('x',513,'y',193,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{14}",'text-anchor','middle');
	$svg->text('x',573,'y',250,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{2}",'text-anchor','middle');
	$svg->text('x',569,'y',360,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{24}",'text-anchor','middle');
	$svg->text('x',533,'y',453,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{18}",'text-anchor','middle');
	$svg->text('x',433,'y',470,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{10}",'text-anchor','middle');
	$svg->text('x',325,'y',460,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{26}",'text-anchor','middle');
	$svg->text('x',277,'y',373,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{22}",'text-anchor','middle');
	$svg->text('x',255,'y',268,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{30}",'text-anchor','middle');
	$svg->text('x',325,'y',195,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{28}",'text-anchor','middle');
	$svg->text('x',405,'y',145,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{16}",'text-anchor','middle');

	$svg->text('x',531,'y',235,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{7}",'text-anchor','middle');
	$svg->text('x',538,'y',308,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{9}",'text-anchor','middle');
	$svg->text('x',534,'y',393,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{21}",'text-anchor','middle');
	$svg->text('x',462,'y',428,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{3}",'text-anchor','middle');
	$svg->text('x',382,'y',450,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{11}",'text-anchor','middle');
	$svg->text('x',328,'y',393,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{19}",'text-anchor','middle');
	$svg->text('x',282,'y',317,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{23}",'text-anchor','middle');
	$svg->text('x',320,'y',252,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{27}",'text-anchor','middle');
	$svg->text('x',375,'y',187,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{13}",'text-anchor','middle');
	$svg->text('x',455,'y',200,'stroke',"black",'stroke-width',0.7,'-cdata',"$output{15}",'text-anchor','middle');
	print OUT $svg->xmlify;
}
`/usr/bin/java -jar /Bio/Bin/Linux-src-files/batik-1.7/batik-1.7/batik-rasterizer.jar -m image/png $outdir/Venn.svg`;
