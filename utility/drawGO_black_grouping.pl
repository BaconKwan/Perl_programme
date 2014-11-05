#!/usr/bin/perl -w
use Data::Dumper;
=pod
description: draw GO
author: Zhang Fangxian, zhangfx@genomics.cn
created date: 20091020
modified date: 20100318, 20010204, 20100123, 20091208, 20091021
=cut

use Getopt::Long;
use File::Basename qw(dirname);
use Cwd 'abs_path';

my ($gglist, $goClass, $output, $help);
GetOptions("gglist:s" => \$gglist, "go:s" => \$goClass, "output:s" => \$output, "help|?" => \$help);
$output ||= "./go";

my $db="/Bio/Database/Database/go/20111231/";
$db=abs_path($db);
$goClass0 = "$db/go.class";
#$goClass0 = "/panfs/RD/dengchaojin/bin/support_pg_nr2go/database/go.class";
$goClass ||= $goClass0;

sub usage {
	print STDERR << "USAGE";
description: draw GO
usage: perl $0 [options]
options:
	-gglist: gene-go list files, separated by comma ","
	-go: go.class file, default is "$goClass0"
	-output: outdir with prefix of ouput file, default is "./go"
	-help|?: help information
e.g.:
	perl $0 -gglist 1,2,3 -output 123
USAGE
}

if (!defined $gglist || defined $help) {
	&usage();
	exit 1;
}

# check input files
@inputs = split /,/, $gglist;
$exit = 0;
for (@inputs) {
	if (!-f $_) {
		print STDERR "file $_ not exists\n";
		$exit = 1;
	}
}

exit 1 if ($exit == 1);

# mkdir
$outdir = dirname($output);
system("mkdir -p $outdir") if (!-d $outdir);

# main
@items = ();
%stats = ();
my $mark_len=30;### 图例的长度 add by nixiaoming 
for $input (@inputs) {
	$input = abs_path($input);
	$item_len = &getItemName($input);
	my ($item,$len)=split /\t/,$item_len;###  add by nixiaoming 
	if ($len>$mark_len) {
		$mark_len=$len;
	}
	push @items, $item;
	%had = ();
	open IN, "< $input" || die $!;
	while (<IN>) {
		chomp;
		next if (/^\s*$/);
		@tabs = split /[\t;]/, $_;
		$gene = shift @tabs;
		$stats{"total"}{$item}++;
		for $go (@tabs) {
			next if ($go eq "-");
			next if ($go =~ /^\s*$/);
			next if ($go !~ /^GO:/);
			$go = (split /\//, $go)[0];
			next if (exists $had{$go}{$gene});
			push @{$gos{$go}{$item}}, $gene;
			$had{$go}{$gene} = 1;
		}
	}
	close IN;
}

open CLASS, "< $goClass" || die $!;
while (<CLASS>) {
	chomp;
	next if (/^$/);
	@tabs = split /\t/, $_;
	if (exists $gos{$tabs[2]}) {
		for $item (@items) {
			next if (!exists $gos{$tabs[2]}{$item});
			for $g (@{$gos{$tabs[2]}{$item}}) {
				if (!exists $classes{$tabs[0]}{$tabs[1]}{$item}) {
					push @{$classes{$tabs[0]}{$tabs[1]}{$item}}, $g;
				} else {
					push @{$classes{$tabs[0]}{$tabs[1]}{$item}}, $g if (index("," . (join ",", @{$classes{$tabs[0]}{$tabs[1]}{$item}}) . ",", ",$g,") == -1);
				}
			}
		}
	}
}
close CLASS;

$data = ["", ["GO Class", "Percent of genes", "Number of genes"], [], []]; # [图名, [x 轴名称, y 轴名称], [[图例, 颜色], ...],[[x 坐标名称, 数据], ...]]

@colors = ("#7FFF00", "#DC143C", "#00FFFF", "#00008B", "#008B8B", "#B8860B", "#A9A9A9", "#006400", "#BDB76B", "#8B008B", "#556B2F", "#FF8C00", "#8B0000", "#E9967A");
for $i (0 .. $#items) {
	push @{$data->[2]}, [$items[$i], $colors[$i]];
}
open OUT, "> $output.xls" || die $!;
print OUT "Ontology\tClass";

for $item (@items) {
	print OUT "\tnumber_of_$item";
}
for $item (@items) {
	print OUT "\tgenes_of_$item";
}
print OUT "\n";

my %go_class;
for $class (sort keys %classes) {
#	print "\n$class\t";
	for $class2 (sort keys %{$classes{$class}}) {
		print OUT "$class\t$class2";
		$goStat{$class}++;
		$goStat{"total"}++;
#		print "$class2\t";
		push @{$data2}, $class2;
		my ($out_count,$out_genes);
		for (@items) {
			$count = (exists $classes{$class}{$class2}{$_})? @{$classes{$class}{$class2}{$_}} : 0;
		#	$go_class{$class}{$_}{$class2} = (exists $classes{$class}{$class2}{$_})? @{$classes{$class}{$class2}{$_}} : 0;
#			print "$class2\t$count\n";
			$out_count.="\t$count";
			if ($count == 0) {
				#print OUT "\t-";
				$out_genes.="\t-";
			} else {
				$out_genes.="\t".(join ";", @{$classes{$class}{$class2}{$_}});
				#print OUT "\t" . (join ";", @{$classes{$class}{$class2}{$_}});
			}
			push @{$data2}, $count;
			if (!exists $stats{"max"}{$_} || $stats{"max"}{$_} < $count) {
				$stats{"max"}{$_} = $count;
			}
		}
		print OUT $out_count.$out_genes."\n";
		push @{$data->[3]}, $data2;
		undef($data2);
	}
}

close OUT;
for $class (sort keys %classes)
{
	for $class2 (sort keys %{$classes{$class}}) 
	{
		for my $k ( 0 .. $#items)
		{
			$go_class{$k}{$class}{$class2} = (exists $classes{$class}{$class2}{$items[$k]})? @{$classes{$class}{$class2}{$items[$k]}} : 0;
		}
	}
}

#print Dumper (\%go_class);
my %class_num;
my %class_name;
my %class_first_name;
my $number=0;
foreach my $class (sort keys %{$go_class{"0"}} )
{
	
	foreach my $class2 (sort {$go_class{"0"}{$class}{$b}<=>$go_class{"0"}{$class}{$a} }  keys %{$go_class{"0"}{$class}})
	{
		$class_num{$number}{"1"}=$go_class{"0"}{$class}{$class2};
#		print "\t$number\t$class2\t$go_class{'0'}{$class}{$class2}\n";
		$class_name{$number}=$class2;
		$class_first_name{$number}=$class;
		$number++;
	}
	#	print "$class_nanme{$number}\n";
}
foreach my $n ( 1 .. $#items)
{
	foreach  my $m (sort {$a<=>$b} keys %class_name)
	{
		my $class=$class_first_name{$m};
		my $class2=$class_name{$m};
		$class_num{$m}{$n+1}=$go_class{$n}{$class}{$class2};
	}
}
#print Dumper (\%class_num);
#print Dumper (\%class_name);

$width = 1200+8*($mark_len-10);
$height = 600+4*($mark_len-10);

%margins = ("t" => 60, "r" => 100+8*($mark_len-10), "b" => 300, "l" => 100);

$code = '<?xml version="1.0" encoding="utf-8" ?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><svg width="' . $width . '" height="' . $height . '" version="1.1" xmlns="http://www.w3.org/2000/svg">';

# 边框
#$code .= '<rect x="0" y="0" width="' . $width . '" height="' . $height . '" style="fill: none; stroke: #000; stroke-width: 2;" />';

# x-y 坐标轴
$code .= '<line x1="' . $margins{"l"} . '" y1="' . ($height - $margins{"b"}) . '" x2="' . ($width - $margins{"r"}) . '" y2="' . ($height - $margins{"b"}) . '" style="stroke: #000; stroke-width: 2;" />';

$code .= '<line x1="' . $margins{"l"} . '" y1="' . ($height - $margins{"b"}) . '" x2="' . $margins{"l"} . '" y2="' . $margins{"t"} . '" style="stroke: #000; stroke-width: 2;" />';
$code .= '<line x1="' . ($width - $margins{"r"}) . '" y1="' . ($height - $margins{"b"}) . '" x2="' . ($width - $margins{"r"}) . '" y2="' . $margins{"t"} . '" style="stroke: #000; stroke-width: 2;" />';

# y 轴名称
$code .= '<text x="' . ($margins{"l"} - 50) . '" y="' . (($height - $margins{"b"} + $margins{"t"}) / 2) . '" style="fill: black; text-anchor: middle;" transform="rotate(-90, ' . ($margins{"l"} - 50) . ', ' . (($height - $margins{"b"} + $margins{"t"}) / 2) . ')">' . $data->[1]->[1] . '</text>';
$code .= '<text x="' . ($width - $margins{"r"} +10+50*scalar(@items)) . '" y="' . (($height - $margins{"b"} + $margins{"t"}) / 2) . '" style="fill: black; text-anchor: middle;" transform="rotate(-90, ' . ($width - $margins{"r"} + 10+50*scalar(@items)) . ', ' . (($height - $margins{"b"} + $margins{"t"}) / 2) . ')">' . $data->[1]->[2] . '</text>';
@colour =qw(black red green darkviolet lawngreen midnightblue saddlebrown);
# y 轴坐标线
for ($i = 0; $i < 4; $i++) {
	$code .= '<line x1="' . ($margins{"l"} - 4) . '" y1="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (3 - $i) / 3) . '" x2="' . ($width - $margins{"r"}) . '" y2="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (3 - $i) / 3) . '" style="stroke: #000; stroke-width: 2;" />';
	$code .= '<text x="' . ($margins{"l"} - 8) . '" y="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (3 - $i) / 3) . '" style="text-anchor: end; dominant-baseline: central;">' . 0.1 * 10 ** $i . '</text>';

	$code .= '<line x1="' . ($width - $margins{"r"}) . '" y1="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (3 - $i) / 3) . '" x2="' . ($width - $margins{"r"} + 4) . '" y2="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (3 - $i) / 3) . '" style="stroke: #000; stroke-width: 2;" />';
	@text = ();
	for $j (0 .. $#items) {
		if ($i == 0) {
			push @text, '<tspan style="fill:'.$colour[$j]. ';">0</tspan>';
		} else {
			push @text, '<tspan style="fill:'.$colour[$j]. ';">' . int($stats{"total"}{$items[$j]} / 10 ** (3 - $i)) . '</tspan>';
		}
	}
	$text = join "<tspan>,</tspan>", @text;
	$code .= '<text x="' . (($width - $margins{"r"}) + 8) . '" y="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (3 - $i) / 3) . '" style="text-anchor: start; dominant-baseline: central; ">' . $text . '</text>';
}

$itemWidth = ($width - $margins{"l"} - $margins{"r"}) / ($#{$data->[3]} + 1);
$angel = 70;

# x 轴分类
$left = $margins{"l"};
for $class (sort keys %classes) {
	$x1 = $left;
	$y1 = $height - $margins{"b"};
	$x2 = $x1 - 250 * cos($angel * 3.14159 / 180) / sin($angel * 3.14159 / 180);
	$y2 = $y1 + 250;
	$x3 = $x2 + ($goStat{$class} - 0) * $itemWidth;
	$y3 = $y2;
	$x4 = $x1 + ($goStat{$class} - 0) * $itemWidth;
	$y4 = $y1;
	$code .= "<path d=\"M$x1 $y1 L$x2 $y2 L$x3 $y3 L$x4 $y4\" style=\"stroke: #000; stroke-width: 1; fill-opacity: 0;\" />";
	$code .= "<text x='" . ($x2 + $x3) / 2 . "' y='" . ($y2 + 20) . "' style='text-anchor: middle;'>" . $class . "</text>";
	$left = $x4;
}
#print "$#items\n";
# 数据
$text = "";
#@colour =qw(red green darkviolet lawngreen midnightblue saddlebrown);
foreach my $i (sort {$a<=>$b} keys %class_num ){
#	print "i=$i\t$data->[3]->[$i]->[0]\n";
	#print "$#{$data->[3]->[$i]}\t";
	foreach my $j (sort {$a<=>$b} keys %{$class_num{$i}}) {
#		print "j=$j\t$data->[3]->[$i]->[$j]\n";
		$class_num{$i}{$j} = 0.001 if ($class_num{$i}{$j} eq "0");
#		print "i=$i\tj=$j\t$class_num{$i}{$j}\t$stats{'total'}{$items[$j - 1]}ui\n";
		$myHeight = ($height - $margins{"t"} - $margins{"b"}) * (3 + log($class_num{$i}{$j} / $stats{"total"}{$items[$j - 1]}) / log(10)) / 3;
		$myHeight = 0 if ($myHeight < 0);
		
		$code .= '<rect x="' . ($margins{"l"} + $itemWidth * ($i + ($j + 0.0) / ($#items + 3))) . '" y="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) * (-(log($class_num{$i}{$j} / $stats{"total"}{$items[$j - 1]}) / log(10)) / 3)) . '" width="' . $itemWidth / ($#items +3 ) . '" height="' . $myHeight . '" style="fill:'.$colour[$j-1].';" />';
	}
	$code .= '<text x="' . ($margins{"l"} + $itemWidth * ($i + 0.5)) . '" y="' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) + 10) . '" style="fill: black; text-anchor: end;" transform="rotate(' . -$angel . ', ' . ($margins{"l"} + $itemWidth * ($i + 0.5)) . ', ' . ($margins{"t"} + ($height - $margins{"t"} - $margins{"b"}) + 10) . ')">' . $class_name{$i} . '</text>';
}

$code .= $text;

# 图例
for ($i = 0; $i <= $#{$data->[2]}; $i++) {
	$code .= '<rect width="10" height="10" x="' . ($width - $margins{"r"}) . '" y="' . ($margins{"t"} + $height / 2 + 20 * $i) . '" style="fill: '.$colour[$i].';" /><text x="' . ($width - $margins{"r"} + 15) . '" y="' . ($margins{"t"} + $height / 2 + 10 + 20 * $i) . '" style="fill:'.$colour[$i].'; text-anchor: start;">' . $data->[2]->[$i]->[0] . '</text>';
}

# 图名
$code .= '<text x="' . $width / 2 . '" y="' . ($height - 20) . '" style="fill: black; text-anchor: middle;">' . $data->[0] . '</text>';

$code .= '</svg>';

# 输出
open SVG, "> $output.svg" || die $!;
print SVG $code;
close SVG;

exit 0;

sub getItemName {
	my ($str) = @_;
	$str = (split /[\/\\]/, $str)[-1];
	$str = (split /\./, $str)[0];
	my $len=length($str);### 获取图例长度 add by nixiaoming 
	$str.="\t".$len;### 获取图例长度
	return $str;
tem_len}
