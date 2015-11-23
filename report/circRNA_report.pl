#!/usr/bin/env perl

=head1 Programe

	circRNA_report.pl

=head1 Description

	This Programme is used to generate HTML report of circRNA analysis pipeline.

=head1 Usage

	perl circRNA_pipeline.pl <config> <outdir>

=head1 Announcements

	Do not copy this script or links it to current path, you must use the full path.

=head1 Author

	Development Group of Genedenovo

=cut

use strict;
use warnings;
use Getopt::Long;
use File::Basename qw/basename dirname/;
use File::Spec::Functions qw/rel2abs/;

##### Initial #####

unless(@ARGV eq 2){
	system("pod2text $0");
	exit 0;
}

my ($config_file, $outdir) = @ARGV;
my (%opts, %samples, %groups, @sample_lab, @group_lab, %sample_diff, %group_diff, @multi_diff);

my $bin_file = rel2abs($0);
my $base_dir = dirname($bin_file);

$config_file = rel2abs($config_file);
$outdir = rel2abs($outdir);

&info("Loading configure ... ");
&readConfig($config_file, \%opts);
&info("Reformatting configure ... ");
&reformConfig(\%opts, \%samples, \%groups, \@sample_lab, \@group_lab, \%sample_diff, \%group_diff, \@multi_diff);

##### Start #####

opendir DIR, "$outdir" || die $!;
my %folders;
my @folders = readdir(DIR);
foreach my $f (@folders){
	if($f =~ /^\d+\.(\S+)/){
		$folders{$1} = $f;
	}
}
closedir DIR;

mkdir "$outdir/Page_Config";
mkdir "$outdir/Page_Config/image"; system("cp $base_dir/Page_Config_All/image_circRNA/* $outdir/Page_Config/image/ -rf");
mkdir "$outdir/Page_Config/doc"; system("cp $base_dir/Page_Config_All/doc_circRNA/* $outdir/Page_Config/doc/ -rf");
mkdir "$outdir/Page_Config/js"; system("cp $base_dir/Page_Config_All/js/*-min.js $outdir/Page_Config/js/ -rf");
mkdir "$outdir/Page_Config/css"; system("cp $base_dir/Page_Config_All/css/* $outdir/Page_Config/css/ -rf");

##### Content #####

my $resp_tabs_cnt = 0;

open HTML, "> $outdir/Page_Config/content.html" || die $!;
print HTML <<HTML_cont;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<!-- 基本信息 -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>基迪奥生物 环状RNA分析 结题报告</title>
		
		<!-- CSS文档 -->
		<link rel="stylesheet" type="text/css" href="css/report.css" />
		<link rel="stylesheet" type="text/css" href="css/jumpto.css" />
		<link rel="stylesheet" type="text/css" href="css/easy-responsive-tabs.css" />
		
		<!-- JS脚本 -->
		<script src="js/jquery-1.9.1-min.js"></script>
		<script src="js/modernizr-min.js"></script>
		<script src="js/jquery.jumpto-min.js"></script>
		<script src="js/jquery.nicescroll-min.js"></script>
		<script src="js/easyResponsiveTabs-min.js"></script>
		<script src="js/show_help-min.js"></script>
		
	</head>
	<body>
		<div id="report_body">
		
			<!-- 项目概述 -->
			<section id="project_info" class="normal_cont">
				<h3>项目概述</h3>
HTML_cont

my $project_info_sample_lab;
my $project_info_sample_lab_unit = 10;
if(scalar @sample_lab > $project_info_sample_lab_unit){
	my $times = int(@sample_lab / $project_info_sample_lab_unit);
	for my $i (1 .. $times){
		my $first = ($i - 1) * $project_info_sample_lab_unit;
		my $last = $first + $project_info_sample_lab_unit - 1;
		$project_info_sample_lab .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @sample_lab[$first .. $last]) . "<br />";
	}
	$project_info_sample_lab .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @sample_lab[$times*$project_info_sample_lab_unit .. $#sample_lab]);
}
else{
	$project_info_sample_lab = join ("<span class=\"project_info_separator\">&brvbar;</span>", @sample_lab);
}

my $project_info_sample_diff;
my $project_info_sample_diff_unit = 5;
if(exists $opts{Sde} && $opts{Sde} ne "none"){
	my @sample_diff_pair = split /\,/, $opts{Sde};
	foreach (@sample_diff_pair){
		$_ =~ s/\&/<span class=\"project_info_diff\">\&harr;<\/span>/;
	}
	if(scalar @sample_diff_pair > $project_info_sample_diff_unit){
		my $times = int(@sample_diff_pair / $project_info_sample_diff_unit);
		for my $i (1 .. $times){
			my $first = ($i - 1) * $project_info_sample_diff_unit;
			my $last = $first + $project_info_sample_diff_unit - 1;
			$project_info_sample_diff .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @sample_diff_pair[$first .. $last]) . "<br />";
		}
		$project_info_sample_diff .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @sample_diff_pair[$times*$project_info_sample_diff_unit .. $#sample_diff_pair]);
	}
	else{
		$project_info_sample_diff = join ("<span class=\"project_info_separator\">&brvbar;</span>", @sample_diff_pair);
	}
}

my $project_info_group_lab;
my $project_info_group_lab_unit = 3;
if(scalar @group_lab > 0){
	my @group = @group_lab;
	foreach (@group){
		my $members = join ("<span class=\"project_info_and\">\&</span>", @{$groups{$_}});
		$_ = "<span class=\"project_info_group_lab\">$_ :</span>$members";
	}
	if(scalar @group_lab > $project_info_group_lab_unit){
		my $times = int(@group_lab / $project_info_group_lab_unit);
		for my $i (1 .. $times){
			my $first = ($i - 1) * $project_info_group_lab_unit;
			my $last = $first + $project_info_group_lab_unit - 1;
			$project_info_group_lab .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @group[$first..$last]) . "<br />";
		}
		$project_info_group_lab .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @group[$times*$project_info_group_lab_unit .. $#group_lab]);
	}
	else{
		$project_info_group_lab = join ("<span class=\"project_info_separator\">&brvbar;</span>", @group);
	}
}

my $project_info_group_diff;
my $project_info_group_diff_unit = 5;
if(exists $opts{Gde} && $opts{Gde} ne "none"){
	my @group_diff_pair = split /\,/, $opts{Gde};
	foreach (@group_diff_pair){
		$_ =~ s/\&/<span class=\"project_info_diff\">\&harr;<\/span>/;
	}
	if(scalar @group_diff_pair > $project_info_group_diff_unit){
		my $times = int(@group_diff_pair / $project_info_group_diff_unit);
		for my $i (1 .. $times){
			my $first = ($i - 1) * 5;
			my $last = $first + $project_info_group_diff_unit - 1;
			$project_info_group_diff .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @group_diff_pair[$first .. $last]) . "<br />";
		}
		$project_info_group_diff .= join ("<span class=\"project_info_separator\">&brvbar;</span>", @group_diff_pair[$times*$project_info_group_diff_unit .. $#group_diff_pair]);
	}
	else{
		$project_info_group_diff = join ("<span class=\"project_info_separator\">&brvbar;</span>", @group_diff_pair);
	}
}
print HTML <<HTML_cont;
				<table>
					<tr><td>项目编号</td><td>$opts{project}</td></tr>
					<tr><td>项目名称</td><td>$opts{content}</td></tr>
					<tr><td>参考基因组</td><td>$opts{reference}</td></tr>
					<tr><td>样品名称</td><td>$project_info_sample_lab</td></tr>
HTML_cont

if(exists $opts{Sde} && $opts{Sde} ne "none"){
	print HTML <<HTML_cont;
					<tr><td>样品间差异方案</td><td>$project_info_sample_diff</td></tr>
HTML_cont
}

if(scalar @group_lab > 0){
	print HTML <<HTML_cont;
					<tr><td>分组方案</td><td>$project_info_group_lab</td></tr>
HTML_cont
}

if(exists $opts{Gde} && $opts{Gde} ne "none"){
	print HTML <<HTML_cont;
					<tr><td>分组间差异方案</td><td>$project_info_group_diff</td></tr>
HTML_cont
}

print HTML <<HTML_cont;
				</table>
			</section>
			
			<!-- <br /><hr /><br /> -->
			
			<!-- 概述 -->
			<section id="introduction" class="normal_cont">
				<h3>技术简介</h3>
				<h5>实验简介</h5>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="image/flow_001.png" target="_blank"><img src="image/flow_001.png" /></td>
						<td class="pic_table_desc" style="width: 50%"><p>样品提取总RNA后，去除核糖体RNA，然后用Rnase R酶降解线性RNA。得到的环状RNA中加入fragmentation buffer使其片断成为短片段，再以片断后的环状RNA为模板，用六碱基随机引物（random hexamers）合成cDNA第一链，并加入缓冲液、dNTPs、RNase H和DNA polymerase I合成cDNA第二链，经过QiaQuick PCR试剂盒纯化并加EB缓冲液洗脱经末端修复、加碱基A，加测序接头，再经琼脂糖凝胶电泳回收目的大小片段，并进行PCR扩增，从而完成整个文库制备工作，构建好的文库用Illumina HiSeq<sup>TM</sup> 2500进行测序。</p></td>
					</tr>
					<tr>
						<td>实验流程图</td>
						<td></td>
					</tr>
				</table>
				<h5>信息分析简介</h5>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="image/flow_002.png" target="_blank"><img src="image/flow_002.png" /></td>
						<td class="pic_table_desc" style="width: 50%"><p>得到下机数据后，首先将会对其进行过滤，得到HQ Clean Reads。每个样品的 HQ Clean Reads 与 参考基因组 分别进行分别 TopHat 比对，得到每个样品的比对结果。从比对结果中提取Unmapped Reads，然后截取每一条Unmapped Reads的两端（默认20bp），得到Anchors Reads。用Anchors Reads再一次比对到基因组上，将得到的比对结果提交给find_circ软件鉴定出环状RNA。得到鉴定的环状RNA后，主要分三部分进行分析。1）环状RNA统计，包括统计Reads类型，环状RNA类型，环状RNA分布等；2）表达量计算与差异分析，包括表达量计算和样品比较组或分组比较组差异表达分析；3）数据库注释与靶向预测，包括对环状RNA进行circBase数据库注释，对被注释的环状RNA定义为已存在环状RNA，未被注释的环状RNA定义为新预测环状RNA，然后对已存在环状RNA进行starBase小RNA靶向关系注释，对数据库中已有靶向关系定义为已存在靶向关系，然后对全体环状RNA进行小RNA靶向预测，得到新预测靶向关系。获得靶向关系后，我们可从mirTarBase中找到已存在的小RNA与mRNA靶向关系，利用以上信息可构建网络图。<p></td>
					</tr>
					<tr>
						<td>信息分析流程图</td>
						<td></td>
					</tr>
				</table>
			</section>
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	if($opts{isFilter} eq "yes"){
		print HTML <<HTML_cont;
	
			<!-- <br /><hr /><br /> -->
			
			<!-- 测序评估 -->
			<section id="seq_stat" class="normal_cont">
				<h3>测序评估<a href="doc/seq_stat.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<h5>测序质量评估<a href="doc/seq_stat.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

		my $seq_stat_sample_list;
		my $seq_stat_qa_img;
		my $seq_stat_bp_img;
		foreach (@sample_lab){
			$seq_stat_sample_list .= <<TEMP;
						<li>$_</li>
TEMP
			$seq_stat_qa_img .= <<TEMP;
						<div>
							<a href="../$folders{ReadsStat}/${_}.pie.png" target="_blank"><img src="../$folders{ReadsStat}/${_}.pie.png" /></a>
						</div>
TEMP
			$seq_stat_bp_img .= <<TEMP;
						<div>
							<table class="pic_table">
								<tr>
									<td>
										<a href="../$folders{ReadsStat}/${_}.old.png" target="_blank"><img src="../$folders{ReadsStat}/${_}.old.png" /></a>
										<p>样品 <span class="sample_lab_strong">${_}</span> <span class="pic_table_strong">过滤前</span> 碱基组成分布图</p>
									</td>
									<td>
										<a href="../$folders{ReadsStat}/${_}.new.png" target="_blank"><img src="../$folders{ReadsStat}/${_}.new.png" /></a>
										<p>样品 <span class="sample_lab_strong">${_}</span> <span class="pic_table_strong">过滤后</span> 碱基组成分布图</p>
									</td>
								</tr>
							</table>
						</div>
TEMP
		}
		$resp_tabs_cnt++;
		print HTML <<HTML_cont;
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$seq_stat_sample_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$seq_stat_qa_img
					</div>
				</div>
				<h5>碱基组成与质量分析<a href="doc/seq_stat.html#sub_3" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

		$resp_tabs_cnt++;
		print HTML <<HTML_cont;
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$seq_stat_sample_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$seq_stat_bp_img
					</div>
				</div>
				<h5>过滤信息统计</h5>
HTML_cont

		my $reads_stat_line1;
		my $reads_stat_line2;
		foreach (@sample_lab){
			my $flag = 0;
			my %useful;
			open IN, "$outdir/$folders{ReadsStat}/${_}.stat" || die $!;
			while (my $line = <IN>){
				chomp $line;
				$flag = 1 if ($line =~ /^before\ filter/);
				my @data = split /\s+/,$line;
				if ($flag){
					if ($line =~ /^total\s+reads\s+nt/){
						$useful{b_r_n} = $data[3];
					}
					if ($line =~ /^total\s+reads\s+\d+/){
						$useful{b_r} = $data[3]+$data[4];
					}
					if ($line =~ /^reads\s+len/){
						$useful{len} = $data[2];
					}
					if ($line =~ /^Q20\s+number/){
						$useful{b_q20_n} = $data[2];
					}
					if ($line =~ /^Q20\s+percentage/){
						$useful{b_q20_p} = $data[2];
					}
					if ($line =~ /^Q30\s+number/){
						$useful{b_q30_n} = $data[2];
					}
					if ($line =~ /^Q30\s+percentage/){
						$useful{b_q30_p} = $data[2];
					}
					if ($line =~ /^N\s+number/){
						$useful{b_N_n} = $data[2];
					}
					if ($line =~ /^N\s+percentage/){
						$useful{b_N_p} = $data[2];
					}
					if ($line =~ /^GC\s+number/){
						$useful{b_GC_n} = $data[2];
					}
					if ($line =~ /^GC\s+percentage/){
						$useful{b_GC_p} = $data[2];
					}
					if ($line =~ /^clean\s+reads/){
						$useful{c_r_p} = $data[-1];
					}
					if ($line =~ /filter\s+adapter/){
						$useful{adp_n} = $data[-2]+$data[-4];
						$data[-1] =~ s/\%$//;
						$data[-3] =~ s/\%$//;
						$useful{adp_p} = $data[-1]+$data[-3];
						$useful{adp_p} .= "%";
						$useful{adp_p} = "(".$useful{adp_p}.")";
					}
					if ($line =~ /low\s+quality/){
						$useful{lq_n} = $data[-2];
						$useful{lq_p} = "($data[-1])";
					}
					if ($line =~ /poly\s+A/){
						if($line =~ /\<y\/n\>\ \:\ y/){
							$useful{pla_n} = $data[-2];
							$useful{pla_p} = "($data[-1])";
						}else{
							$useful{pla_n} = "0";
							$useful{pla_p} = "(0%)";
						}
					}
					if ($line =~ /filter\s+N/){
						$useful{fN_n} = $data[-2];
						$useful{fN_p} = $data[-1];
					}
				}else{
					if ($line =~ /^total\s+reads\s+nt/){
						$useful{a_r_n} = $data[3];
					}
					if ($line =~ /^total\s+reads\s+\d+/){
						$useful{a_r} = $data[3]+$data[4];
					}
					if ($line =~ /^Q20\s+number/){
						$useful{a_q20_n} = $data[2];
					}
					if ($line =~ /^Q20\s+percentage/){
						$useful{a_q20_p} = $data[2];
					}
					if ($line =~ /^Q30\s+number/){
						$useful{a_q30_n} = $data[2];
					}
					if ($line =~ /^Q30\s+percentage/){
						$useful{a_q30_p} = $data[2];
					}
					if ($line =~ /^N\s+number/){
						$useful{a_N_n} = $data[2];
					}
					if ($line =~ /^N\s+percentage/){
						$useful{a_N_p} = $data[2];
					}
					if ($line =~ /^GC\s+number/){
						$useful{a_GC_n} = $data[2];
					}
					if ($line =~ /^GC\s+percentage/){
						$useful{a_GC_p} = $data[2];
					}
				}
			}
			if($opts{read_type} =~ /^se$/i){
				$useful{b_r_n} = $useful{b_r_n} / 2;
				$useful{b_q20_n} = $useful{b_q20_n} / 2;
				$useful{b_q30_n} = $useful{b_q30_n} / 2;
				$useful{b_N_n} = $useful{b_N_n} / 2;
				$useful{b_GC_n} = $useful{b_GC_n} / 2;
				$useful{a_r_n} = $useful{a_r_n} / 2;
				$useful{a_q20_n} = $useful{a_q20_n} / 2;
				$useful{a_q30_n} = $useful{a_q30_n} / 2;
				$useful{a_N_n} = $useful{a_N_n} / 2;
				$useful{a_GC_n} = $useful{a_GC_n} / 2;
				
				$useful{b_r} = $useful{b_r} / 2;
				$useful{a_r} = $useful{a_r} / 2;
				$useful{len} = (split /\+/, $useful{len})[0];	
			}
			$useful{b_r_p} = "100.00%";
			$useful{a_r_p} = ($useful{a_r_n} / $useful{b_r_n}) * 100;
			$useful{a_r_p} = sprintf("%.2f%%", $useful{a_r_p});
			
			$reads_stat_line1 .= <<TEMP;
					<tr><td>${_}</td><td> $useful{b_r_n} ($useful{b_r_p}) </td><td> $useful{b_q20_n} ($useful{b_q20_p}) </td><td> $useful{b_q30_n} ($useful{b_q30_p}) </td><td> $useful{b_N_n} ($useful{b_N_p}) </td><td> $useful{b_GC_n} ($useful{b_GC_p}) </td><td> $useful{a_r_n} ($useful{a_r_p}) </td><td> $useful{a_q20_n} ($useful{a_q20_p}) </td><td> $useful{a_q30_n} ($useful{a_q30_p}) </td><td> $useful{a_N_n} ($useful{a_N_p}) </td><td> $useful{a_GC_n} ($useful{a_GC_p}) </td></tr>
TEMP
			$reads_stat_line2 .= <<TEMP;
					<tr><td>${_}</td><td> $useful{b_r} </td><td> $useful{a_r} ($useful{c_r_p}) </td><td> $useful{len} </td><td> $useful{adp_n} $useful{adp_p} </td><td> $useful{lq_n} $useful{lq_p} </td><td> $useful{pla_n} $useful{pla_p} </td><td> $useful{fN_n} ($useful{fN_p}) </td></tr>
TEMP
			close IN;
		}
		print HTML <<HTML_cont;
				<table>
					<caption>过滤前后碱基信息统计表<a href="doc/seq_stat.html#sub_4_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th rowspan=2>Sample</th><th colspan=5>Before Filter</th><th colspan=5>After Filter</th></tr>
					<tr><th>Clean Data(bp)</th><th>Q20(%)</th><th>Q30(%)</th><th>N(%)</th><th>GC(%)</th><th>HQ Clean Data(bp)</th><th>Q20(%)</th><th>Q30(%)</th><th>N(%)</th><th>GC(%)</th></tr>
$reads_stat_line1
				</table>
				
				<p><br /></p>
				
				<table>
					<caption>Reads 过滤信息统计表<a href="doc/seq_stat.html#sub_4_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Sample</th><th>Clean Reads Num</th><th>HQ Clean Reads Num(%)</th><th>Read Length</th><th>Adapter(%)</th><th>Low Quality(%)</th><th>Poly A(%)</th><th>N(%)</th></tr>
$reads_stat_line2
				</table>
			</section>
HTML_cont
	}
}

print HTML <<HTML_cont;

			<!-- <br /><hr /><br /> -->
			
			<!-- 比对统计 -->
			<section id="align_stat" class="normal_cont">
				<h3>比对统计</h3>
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	if($opts{isRrRNA} eq "yes"){
		print HTML <<HTML_cont;
				<h5>比对核糖体<a href="doc/align_stat.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

		my $align_stat_rRNA;
		foreach (@sample_lab){
			my ($all_read,$mapped,$unmapped,$rate_map,$rate_unmap)=(0,0,0,0,0);
			open IN,"$outdir/$folders{ReadsStat}/$_.rRNA.log" || die $!;
			if($opts{read_type} eq "pe"){
				while (my $line = <IN>){
					chomp $line;
					$line =~ s/^\s+//;
					my @data = split/\s+/,$line;
					if ($line =~ /aligned\ concordantly\ exactly\ 1\ time/){
						$mapped += $data[0]*2;
					}
					if ($line =~ /aligned\ concordantly\ \>1\ times/){
						$mapped += $data[0]*2;
					}
#					if ($line =~ /aligned\ discordantly\ 1\ time/){
#						$mapped += $data[0]*2;
#					}
#					if ($line =~ /aligned\ exactly\ 1\ time/){
#						$mapped += $data[0];
#					}
#					if ($line =~ /aligned\ \>1\ times/){
#						$mapped += $data[0];
#					}
					if ($line =~ /reads\;\ of\ these\:/){
						$all_read = $data[0]*2;
					}
				}
			}
			else{
				while (my $line = <IN>){
					chomp $line;
					$line =~ s/^\s+//;
					my @data = split/\s+/,$line;
					if ($line =~ /aligned exactly 1 time/){
						$mapped += $data[0];
					}
					if ($line =~ /aligned >1 times/){
						$mapped += $data[0];
					}
					if ($line =~ /reads\;\ of\ these\:/){
						$all_read = $data[0];
					}
				}
			}
			close IN;
			$unmapped = $all_read-$mapped;
			$rate_map = sprintf("%.2f%%",$mapped/$all_read*100);
			$rate_unmap = sprintf("%.2f%%",$unmapped/$all_read*100);
			$align_stat_rRNA .= <<TEMP;
					<tr><td>${_}</td><td> $all_read </td><td> $mapped ( $rate_map ) </td><td>  $unmapped ( $rate_unmap ) </td></tr>
TEMP
		}
		print HTML <<HTML_cont;
				<table>
					<caption>HQ clean data 与 rRNA 的比对统计表</caption>
					<tr><th>Sample</th><th>All Reads Num</th><th>Mapped Reads</th><th>Unmapped Reads</th></tr>
$align_stat_rRNA
				</table>
HTML_cont
	}
}

print HTML <<HTML_cont;
				<h5>比对基因组<a href="doc/align_stat.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	my $align_stat_reads_align;
	foreach (@sample_lab){
		open IN,"<$outdir/$folders{AlignmentStat}/$_.align.stat" || die $!;
		if($opts{read_type} eq "pe"){
			my ($all_left,$unmap_left,$uniq_map_left,$mult_map_left,$all_right,$unmap_right,$uniq_map_right,$mult_map_right,$all,$unmap,$uniq_map,$mult_map) = (0,0,0,0,0,0,0,0,0,0,0,0);
			my $if_right=0;
			while (my $line = <IN>){
				chomp $line;
				$line =~ s/^\s+//;
				my @data = split/\s+/,$line;
				if ($line =~ /Right\ reads\:/){
					$if_right=1;
				}
				if ($line =~ /overall\ read\ mapping\ rate\./){
					$all = $all_left + $all_right;
					$unmap = $unmap_left + $unmap_right;
					$uniq_map = $uniq_map_left + $uniq_map_right;
					$mult_map = $mult_map_left + $mult_map_right;
					last;
				}
				if (!$if_right){
					if ($line =~ /Input/){
						$all_left = $data[2];
					}
					if ($line =~ /Mapped/){
						$unmap_left = $all_left-$data[2];
					}
					if ($line =~ /have\ multiple\ alignments/){
						$mult_map_left = $data[2];
						$uniq_map_left = $all_left-$unmap_left-$mult_map_left;
					}
				}
				else{
					if ($line =~ /Input/){
						$all_right = $data[2];
					}
					if ($line =~ /Mapped/){
						$unmap_right = $all_right-$data[2];
					}
					if ($line =~ /have\ multiple\ alignments/){
						$mult_map_right = $data[2];
						$uniq_map_right = $all_right-$unmap_right-$mult_map_right;
					}
				}
			}
			my $rate_unmap = sprintf("%.2f%%",$unmap/$all*100);
			my $rate_uniq_map = sprintf("%.2f%%",$uniq_map/$all*100);
			my $rate_mult_map = sprintf("%.2f%%",$mult_map/$all*100);
			my $map_ratio = sprintf("%.2f%%",($all-$unmap)/$all*100);
			$align_stat_reads_align .= <<TEMP;
					<tr><td>$_</td><td> $all </td><td> $unmap ($rate_unmap) </td><td> $uniq_map ($rate_uniq_map) </td><td> $mult_map ($rate_mult_map) </td><td> $map_ratio </td></tr>
TEMP
		}
		else{
			my ($all,$unmap,$uniq_map,$mult_map) = (0,0,0,0,0,0,0,0,0,0,0,0);
			open IN,"<$outdir/$folders{AlignmentStat}/$_.align.stat" or die;
			while (my $line = <IN>){
				chomp $line;
				$line =~ s/^\s+//;
				my @data = split/\s+/,$line;
				if ($line =~ /Input/){
					$all = $data[2];
				}
				if ($line =~ /Mapped/){
					$uniq_map = $data[2];
				}
			}
			$unmap = $all - $uniq_map;
			my $rate_unmap = sprintf("%.2f%%",$unmap/$all*100);
			my $rate_uniq_map = sprintf("%.2f%%",$uniq_map/$all*100);
			$align_stat_reads_align .= <<TEMP;
					<tr><td>$_</td><td> $all </td><td> $unmap ($rate_unmap) </td><td> $uniq_map ($rate_uniq_map) </td><td> 0 (0%) </td><td> $rate_uniq_map </td></tr>
TEMP
		}
		close IN;
	}
	print HTML <<HTML_cont;
				<table>
					<caption>比对核糖体后得到的 Unmapped Reads 与 参考基因组 的比对统计表</caption>
					<tr><th>Sample</th><th>Total Reads</th><th>Unmapped Reads</th><th>Unique Mapped Reads</th><th>Multiple Mapped reads</th><th>Mapping Ratio</th></tr>
$align_stat_reads_align
				</table>
				
				<p><br /></p>
				
HTML_cont
}

my $align_stat_anchors_align;
foreach (@sample_lab){
	open IN, "$outdir/$folders{AlignmentStat}/${_}_anchors.align.stat" || die $!;
	my ($reads, $mapped_reads, $mapped_ratio) = (0, 0, 0);
	while(my $line = <IN>){
		$reads = $1 if($line =~ /(\d+) reads;/);
		$mapped_reads += $1 if($line =~ /(\d+) \S+ aligned exactly 1 time/);
		$mapped_reads += $1 if($line =~ /(\d+) \S+ aligned >1 times/);
		$mapped_ratio = $1 if($line =~ /(\S+) overall alignment rate/);
	}
	close IN;
	$reads = $reads / 2;
	$mapped_reads = $mapped_reads / 2;
	$align_stat_anchors_align .= <<TEMP;
					<tr><td>${_}</td><td>$reads</td><td>$mapped_reads</td><td>$mapped_ratio</td></tr>
TEMP
}
print HTML <<HTML_cont;
				<table>
					<caption>Anchors Reads 与 参考基因组 比对统计表</caption>
					<tr><th>Sample</th><th>Reads Num</th><th>Mapped Reads</th><th>Mapping Ratio</th></tr>
$align_stat_anchors_align
				</table>
			</section>
			
			<!-- <br /><hr /><br /> -->
			
			<!-- 环状RNA鉴定 -->
			<section id="circRNA_identify" class="normal_cont">
				<h3>环状RNA鉴定<a href="doc/circRNA_identify.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<h5>环状RNA信息统计</h5>
HTML_cont

#my $circRNA_identify_site_log;
#{
#	open IN, "$outdir/$folders{CircRNA}/sites.log" || die $!;
#	my $line = <IN>;
#	my @t = split /,/, $line;
#	shift @t;
#	foreach (@t){
#		if(/'(\w+)': (\d+)/){
#			$circRNA_identify_site_log .= <<TEMP;
#					<tr><td>$1</td><td>$2</td></tr>
#TEMP
#		}
#	}
#	close IN;
#}

my $circRNA_identify_cntline = 0;
my $circRNA_identify_info;
{
	open IN, "$outdir/$folders{CircRNA}/circ_candidates.bed" || die $!;
	<IN>;
	while($circRNA_identify_cntline < 10){
		my $line = <IN>;
		chomp $line;
		my @t = split /\t/, $line;
		@t = (@t[0..6], "...", @t[11..15]);
		$line = join "", map{"<td>" . $_ . "</td>"} @t;
		$circRNA_identify_cntline++;
		$circRNA_identify_info .= <<TEMP;
					<tr>$line</tr>
TEMP
	}
	close IN;
}

my $circRNA_gene_count = `wc -l $outdir/$folders{CircRNA}/circ_candidates.info.xls`;
chomp $circRNA_gene_count;
$circRNA_gene_count--;

print HTML <<HTML_cont;
				<!--
				<table>
					<caption>环状RNA Reads类型统计表<a href="doc/circRNA_identify.html#sub_1_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Type</th><th>Reads Num</th></tr>
\$circRNA_identify_site_log
				</table>
				<p><br /></p>
				-->
				<table>
					<caption>环状RNA信息统计表<a href="doc/circRNA_identify.html#sub_1_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Chr</th><th>Start</th><th>End</th><th>GeneID</th><th>Reads Num</th><th>Strand</th><th>Uniq Reads Num</th><th>...</th><th>Samples</th><th>Samples Counts</th><th>Edits</th><th>Anchor Overlap</th><th>Breakpoints</th></tr>
$circRNA_identify_info
				</table>
				<p>
					<ul>
						<li>环状RNA数目：<span class="pic_table_strong">$circRNA_gene_count</span></li>
						<li>环状RNA信息统计表：<a href="../$folders{CircRNA}/circ_candidates.bed" target="_blank"> circ_candidates.bed </a></li>
					</ul>
				</p>
				<h5>环状RNA类型统计<a href="doc/circRNA_identify.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

my $circ_candidates_cntline = 0;
my $circ_candidates_info;

open IN, "$outdir/$folders{CircRNA}/circ_candidates.info.xls" || die $!;
<IN>;
while($circ_candidates_cntline < 10){
	my $line = <IN>;
	chomp $line;
	my @t = split /\t/, $line;
	$line = join "", map{"<td>" . $_ . "</td>"} @t;
	$circ_candidates_cntline++;
	$circ_candidates_info .= <<TEMP;
					<tr>$line</tr>
TEMP
}
close IN;


print HTML <<HTML_cont;
				<table>
					<caption>环状RNA类型统计表<a href="doc/circRNA_identify.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Gene ID</th><th>Source Gene</th><th>Chr</th><th>Strand</th><th>Start</th><th>End</th><th>Length</th><th>Type</th></tr>
$circ_candidates_info
				</table>
				<p>
					<ul>
						<li>环状RNA类型统计表：<a href="../$folders{CircRNA}/circ_candidates.info.xls" target="_blank"> circ_candidates.info.xls </a></li>
						<li>环状RNA序列文件：<a href="../$folders{CircRNA}/circ_candidates.fa" target="_blank"> circ_candidates.fa </a></li>
						<li>环状RNA转录组注释 GTF 文件：<a href="../$folders{CircRNA}/circ_candidates.gtf" target="_blank"> circ_candidates.gtf </a></li>
					</ul>
				</p>
				<p>环状RNA统计图</p>
HTML_cont
$resp_tabs_cnt++;
print HTML <<HTML_cont;
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
						<li>环状RNA染色体分布</li>
						<li>环状RNA长度分布</li>
						<li>环状RNA类型分布</li>
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
						<div>
							<a href="../$folders{Statistics}/circ.chr.png" target="_blank"><img src="../$folders{Statistics}/circ.chr.png" /></a>
						</div>
						<div>
							<a href="../$folders{Statistics}/circ.len.png" target="_blank"><img src="../$folders{Statistics}/circ.len.png" /></a>
						</div>
						<div>
							<a href="../$folders{Statistics}/circ.type.png" target="_blank"><img src="../$folders{Statistics}/circ.type.png" /></a>
						</div>
					</div>
				</div>
			</section>
HTML_cont

if($opts{isEnrich} eq "yes"){
	print HTML <<HTML_cont;
	
			<!-- <br /><hr /><br /> -->
			
			<!-- 来源基因富集分析 -->
			<section id="source_gene_enrichment" class="normal_cont">
				<h3>来源基因富集分析</h3>
				<p>
					<ul>
						<li>来源基因列表：<a href="../$folders{SourceGeneEnrichment}/source_gene.glist.xls" target="_blank">source_gene.glist.xls</a></li>
					</ul>
				</p>
				<h5>Pathway富集分析<a href="doc/source_gene_enrichment.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

	unless( -s "$outdir/$folders{SourceGeneEnrichment}/KO"){
		print HTML <<HTML_cont;
				<p>由于缺少KO注释，因此无法进行Pathway富集分析。</p>
HTML_cont
	}
	else{
		print HTML <<HTML_cont;
				<p>
					<ul>
						<li>Pathway富集分析结果：<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.htm" target="_blank">source_gene.htm</a></li>
						<li>Pathway Map目录：<a href="../$folders{SourceGeneEnrichment}/KO/source_gene_map" target="_blank">source_gene_map</a></li>
						<li>Pathway注释表：<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.path.xls" target="_blank">source_gene.path.xls</a></li>
						<li>基因ID与K号对照表：<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.ko.xls" target="_blank">source_gene.ko.xls</a></li>
					</ul>
				</p>
				<table class="pic_table">
					<tr><td>
						<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.path.png" target="_blank"><img src="../$folders{SourceGeneEnrichment}/KO/source_gene.path.png" /></a>
					</td><tr>
					<tr><td>Pathway富集分析气泡图</td></tr>
				</table>
HTML_cont
	}
	
	print HTML <<HTML_cont;
				<h5>功能富集分析<a href="doc/source_gene_enrichment.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

	unless( -s "$outdir/$folders{SourceGeneEnrichment}/GO"){
		print HTML <<HTML_cont;
				<p>由于缺少GO注释，因此无法进行功能富集分析。</p>
HTML_cont
	}
	else{
		print HTML <<HTML_cont;
				<p>
					<ul>
						<li>功能富集分析结果：<a href="../$folders{SourceGeneEnrichment}/GO/GOView.html" target="_blank">GOView.html</a></li>
						<li>细胞组分富集分析结果：<a href="../$folders{SourceGeneEnrichment}/GO/source_gene_C.xls" target="_blank">source_gene_C.xls</a></li>
						<li>分子功能富集分析结果： <a href="../$folders{SourceGeneEnrichment}/GO/source_gene_F.xls" target="_blank">source_gene_F.xls</a></li>
						<li>生物学过程富集分析结果： <a href="../$folders{SourceGeneEnrichment}/GO/source_gene_P.xls" target="_blank">source_gene_P.xls</a></li>
						<li>功能富集分析分类表：<a href="../$folders{SourceGeneEnrichment}/GO/source_gene.go.class.xls" target="_blank">source_gene.go.class.xls</a></li>
					</ul>
				</p>
				<table class="pic_table">
					<tr><td>
						<a href="../$folders{SourceGeneEnrichment}/GO/source_gene.go.class.png" target="_blank"><img src="../$folders{SourceGeneEnrichment}/GO/source_gene.go.class.png" /></a>
					</td><tr>
					<tr><td>功能富集分析分类柱状图</td></tr>
				</table>
HTML_cont
	}
	
	print HTML <<HTML_cont;
			</section>
HTML_cont
}
print HTML <<HTML_cont;

			<!-- <br /><hr /><br /> -->
			
			<!-- 表达与差异分析 -->
			<section id="exp_diff" class="normal_cont">
				<h3>表达与差异分析<a href="doc/exp_diff.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<h5>表达量统计<a href="doc/exp_diff.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
				<table class="pic_table">
					<tr><td>
						<a href="../$folders{ExpressionStat}/circ.rpkm.distribution.png" target="_blank"><img src="../$folders{ExpressionStat}/circ.rpkm.distribution.png" /></a>
					</td><tr>
					<tr><td>表达量丰度分布图<a href="doc/exp_diff.html#sub_1_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></td></tr>
				</table>
HTML_cont

my $exp_diff_sample_exp;
{
	my $skip = scalar @sample_lab;
	open IN, "$outdir/$folders{ExpressionStat}/circ.expression.annot.xls" || die $!;
	my $head = <IN>;
	chomp $head;
	my @head = split /\t/, $head;
	$head[1] =~ s/_rpkm/ RPKM/;
	$head[$skip + 1] =~ s/_count/ Count/;
	@head = ("Gene ID", $head[1], "...", $head[$skip + 1], "...", "Source Gene", "...", "Type");
	$head = join "", map {"<th>" . $_ . "</th>"} @head;
	$exp_diff_sample_exp .= <<TEMP;
					<tr>$head</tr>
TEMP
	my $cntline = 0;
	while($cntline < 10){
		my $line = <IN>;
		chomp $line;
		my @t = split /\t/, $line;
		$t[1] = sprintf("%.2f", $t[1]);
		$t[$skip + 1] = sprintf("%.1f", $t[$skip + 1]);
		@t = (@t[0 .. 1], "...", $t[$skip + 1], "...", $t[$skip * 2 + 1], "...", $t[$#t]);
		$line = join "", map {"<td>" . $_ . "</td>"} @t;
		$cntline++;
		$exp_diff_sample_exp .= <<TEMP;
					<tr>$line</tr>
TEMP
	}
	close IN;
}
	
print HTML <<HTML_cont;
				<p><br /></p>
				<table>
					<caption>样品表达量统计表<a href="doc/exp_diff.html#sub_1_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
$exp_diff_sample_exp
				</table>
				<p>
					<ul>
						<li>样品表达量统计表：<a href="../$folders{ExpressionStat}/circ.expression.annot.xls" target="_blank"> circ.expression.annot.xls </a></li>
					</ul>
				</p>
HTML_cont

if(scalar(@group_lab) >= 1){
	my $exp_diff_group_exp;
	{
		my $skip = scalar @group_lab;
		open IN, "$outdir/$folders{ExpressionStat}/circ.group.expression.annot.xls" || die $!;
		my $head = <IN>;
		chomp $head;
		my @head = split /\t/, $head;
		$head[1] =~ s/_rpkm/ RPKM/;
		$head[$skip + 1] =~ s/_count/ Count/;
		@head = ("Gene ID", $head[1], "...", $head[$skip + 1], "...", "Source Gene", "...", "Type");
		$head = join "", map {"<th>" . $_ . "</th>"} @head;
		$exp_diff_group_exp .= <<TEMP;
					<tr>$head</tr>
TEMP
		my $exp_diff_group_cntline = 0;
		while($exp_diff_group_cntline < 10){
			my $line = <IN>;
			chomp $line;
			my @t = split /\t/, $line;
			$t[1] = sprintf("%.2f", $t[1]);
			$t[$skip + 1] = sprintf("%.1f", $t[$skip + 1]);
			@t = (@t[0 .. 1], "...", $t[$skip + 1], "...", $t[$skip * 2 + 1], "...", $t[$#t]);
			$line = join "", map {"<td>" . $_ . "</td>"} @t;
			$exp_diff_group_cntline++;
			$exp_diff_group_exp .= <<TEMP;
					<tr>$line</tr>
TEMP
		}
		close IN;
	}
	
	print HTML <<HTML_cont;
				<p><br /></p>
				<table>
					<caption>分组表达量统计表<a href="doc/exp_diff.html#sub_1_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
$exp_diff_group_exp
				</table>
				<p>
					<ul>
						<li>分组表达量统计表：<a href="../$folders{ExpressionStat}/circ.group.expression.annot.xls" target="_blank"> circ.group.expression.annot.xls </a></li>
					</ul>
				</p>
HTML_cont
}

if($opts{Sde} ne "none" && scalar(@sample_lab) >= 2){
	print HTML <<HTML_cont;
				<h5>样品间差异表达分析<a href="doc/exp_diff.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont
	my $sample_diff_pair_list;
	my $sample_diff_table;
	my $sample_diff_pic_scatter_plot;
	my $sample_diff_pic_volcano_plot;
	open IN, "$outdir/$folders{SamplesDifferentialExpression}/geneDE.stat" || die $!;
	<IN>;
	while(my $line = <IN>){
		chomp $line;
		my @t = split /\t/, $line;
		push(@t, $t[1] + $t[2]);
		my $sample_diff_pair = shift(@t);
		$line = join "", map {"<td>" . $_ . "</td>"} @t;
		$sample_diff_table .= <<TEMP;
					<tr><td>$sample_diff_pair</td>$line<td><a href="../$folders{SamplesDifferentialExpression}/$sample_diff_pair.genes.annot.xls" target="_blank">$sample_diff_pair.genes.annot.xls</td><td><a href="../$folders{SamplesDifferentialExpression}/$sample_diff_pair.genes.filter.annot.xls" target="_blank">$sample_diff_pair.genes.filter.annot.xls</td></tr>
TEMP
		$sample_diff_pair_list .= <<TEMP;
						<li>$sample_diff_pair</li>
TEMP
		$sample_diff_pic_scatter_plot .= <<TEMP;
						<div>
							<a href="../$folders{SamplesDifferentialExpression}/$sample_diff_pair.DE.scatter.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/$sample_diff_pair.DE.scatter.png" /></a>
						</div>
TEMP
		$sample_diff_pic_volcano_plot .= <<TEMP;
						<div>
							<a href="../$folders{SamplesDifferentialExpression}/$sample_diff_pair.DE.volcano.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/$sample_diff_pair.DE.volcano.png" /></a>
						</div>
TEMP
	}
	close IN;
	
	print HTML <<HTML_cont;
				<table>
					<caption>样品间差异基因统计表</caption>
					<tr><th>差异比较组</th><th>显著上调差异基因</th><th>显著下调差异基因</th><th>显著差异基因总数</th><th>差异基因注释表<a href="doc/exp_diff.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></th><th>显著差异基因注释表</th></tr>
$sample_diff_table
				</table>
				<p><br /></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{SamplesDifferentialExpression}/geneDE.h.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/geneDE.h.png" /></a></td>
						<td style="width: 50%"><a href="../$folders{SamplesDifferentialExpression}/geneDE.v.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/geneDE.v.png" /></a></td>
					</tr>
					<tr>
						<td><span class="pic_table_strong">样品间</span> 差异基因统计柱状图（横向）</td>
						<td><span class="pic_table_strong">样品间</span> 差异基因统计柱状图（纵向）</td>
					</tr>
				</table>
				<p>样品间差异基因散点图<a href="doc/exp_diff.html#sub_2_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
HTML_cont
	$resp_tabs_cnt++;
	print HTML <<HTML_cont;
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$sample_diff_pair_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$sample_diff_pic_scatter_plot
					</div>
				</div>
HTML_cont
	$resp_tabs_cnt++;
	print HTML <<HTML_cont;
				<p>样品间差异基因火山图<a href="doc/exp_diff.html#sub_2_3" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$sample_diff_pair_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$sample_diff_pic_volcano_plot
					</div>
				</div>
				<p>样品间差异表达模式聚类分析<a href="doc/exp_diff.html#sub_2_4" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{SamplesDifferentialExpression}/allsamples.heatmap.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/allsamples.heatmap.png" /></a></td>
					</tr>
					<tr>
						<td>样品间差异基因热图</td>
					</tr>
				</table>
HTML_cont
}

if($opts{Gde} ne "none" && scalar(@group_lab) >= 2){
	print HTML <<HTML_cont;
				<h5>分组间差异表达分析</h5>
HTML_cont
	my $group_diff_pair_list;
	my $group_diff_table;
	my $group_diff_pic_volcano_plot;
	open IN, "$outdir/$folders{GroupsDifferentialExpression}/geneDE.stat" || die $!;
	<IN>;
	while(my $line = <IN>){
		chomp $line;
		my @t = split /\t/, $line;
		push(@t, $t[1] + $t[2]);
		my $group_diff_pair = shift(@t);
		$line = join "", map {"<td>" . $_ . "</td>"} @t;
		$group_diff_table .= <<TEMP;
					<tr><td>$group_diff_pair</td>$line<td><a href="../$folders{GroupsDifferentialExpression}/$group_diff_pair.genes.annot.xls" target="_blank">$group_diff_pair.genes.annot.xls</td><td><a href="../$folders{GroupsDifferentialExpression}/$group_diff_pair.genes.filter.annot.xls" target="_blank">$group_diff_pair.genes.filter.annot.xls</td></tr>
TEMP
		$group_diff_pair_list .= <<TEMP;
						<li>$group_diff_pair</li>
TEMP
		$group_diff_pic_volcano_plot .= <<TEMP;
						<div>
							<a href="../$folders{GroupsDifferentialExpression}/$group_diff_pair.DE.volcano.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/$group_diff_pair.DE.volcano.png" /></a>
						</div>
TEMP
	}
	close IN;
	
	print HTML <<HTML_cont;
				<table>
					<caption>分组间差异基因统计表</caption>
					<tr><th>差异比较组</th><th>显著上调差异基因</th><th>显著下调差异基因</th><th>显著差异基因总数</th><th>差异基因注释表<a href="doc/exp_diff.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></th><th>显著差异基因注释表</th></tr>
$group_diff_table
				</table>
				<p><br /></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{GroupsDifferentialExpression}/geneDE.h.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/geneDE.h.png" /></a></td>
						<td style="width: 50%"><a href="../$folders{GroupsDifferentialExpression}/geneDE.v.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/geneDE.v.png" /></a></td>
					</tr>
					<tr>
						<td><span class="pic_table_strong">分组间</span> 差异基因统计柱状图（横向）</td>
						<td><span class="pic_table_strong">分组间</span> 差异基因统计柱状图（纵向）</td>
					</tr>
				</table>
HTML_cont
	$resp_tabs_cnt++;
	print HTML <<HTML_cont;
				<p>分组间差异基因火山图<a href="doc/exp_diff.html#sub_2_3" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$group_diff_pair_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$group_diff_pic_volcano_plot
					</div>
				</div>
				<p>分组间差异表达模式聚类分析<a href="doc/exp_diff.html#sub_2_4" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{GroupsDifferentialExpression}/allgroups.heatmap.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/allgroups.heatmap.png" /></a></td>
					</tr>
					<tr>
						<td>分组间差异基因热图</td>
					</tr>
				</table>
HTML_cont
}

print HTML <<HTML_cont;
			</section>
HTML_cont

if($opts{isAnnot} eq "yes" || $opts{isPredict} eq "yes"){
	print HTML <<HTML_cont;

			<!-- <br /><hr /><br /> -->
			
			<!-- 数据库注释与靶向预测 -->
			<section id="database_annot_and_predition" class="normal_cont">
				<h3>数据库注释与靶向预测</h3>
				<p>
					<ul>
						<li>网络关系（可用于Cytoscape作图<a href="doc/cytoscape.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>）：<a href="../$folders{Cytoscape}/" target="_blank"> Cytoscape输入文件目录 </a></li>
					</ul>
				</p>
HTML_cont

	if($opts{isAnnot} eq "yes"){
		print HTML <<HTML_cont;
				<h5>数据库注释<a href="doc/database_annot_and_predition.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

		my $circRNA_exist_count = `wc -l $outdir/$folders{CircBaseAnnotation}/exist.circ.info.annot.xls`;
		my $circRNA_novel_count = `wc -l $outdir/$folders{CircBaseAnnotation}/novel.circ.info.annot.xls`;
		chomp $circRNA_exist_count;
		chomp $circRNA_novel_count;
		$circRNA_exist_count--;
		$circRNA_novel_count--;
		
		my $database_annot_cntline = 0;
		my $database_annot_info;
		open IN, "$outdir/$folders{CircBaseAnnotation}/circBase_annotation.xls" || die $!;
		<IN>;
		while($database_annot_cntline < 10){
			my $line = <IN>;
			chomp $line;
			my @t = split /\t/, $line;
			$t[1] =~ s/(.{30}).*/$1 ... /;
			$line = join "", map{"<td>" . $_ . "</td>"} @t;
			$database_annot_cntline++;
			$database_annot_info .= <<TEMP;
					<tr>$line</tr>
TEMP
		}
		close IN;
	
		my $database_annot_exist_target;
		open IN, "$outdir/$folders{CircBaseAnnotation}/exist.target.stat" || die $!;
		<IN>;
		{
			my $line = <IN>;
			chomp $line;
			my @t = split /\t/, $line;
			$line = join "", map{"<td>" . $_ . "</td>"} @t;
			$database_annot_exist_target .= <<TEMP;
					<tr>$line</tr>
TEMP
		}
		close IN;

		print HTML <<HTML_cont;
				<table>
					<caption>环状RNA注释情况统计</caption>
					<tr><th>环状RNA总数</th><th>已存在环状RNA数</th><th>新预测环状RNA数</th></tr>
					<tr><td>$circRNA_gene_count</td><td>$circRNA_exist_count</td><td>$circRNA_novel_count</td></tr>
				</table>
				<p><br /></p>
				<table>
					<caption>环状RNA注释信息表<a href="doc/database_annot_and_predition.html#sub_1_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Gene ID</th><th>Annotation</th><th>Best Transcript</th><th>Gene Symbol</th><th>Study</th></tr>
$database_annot_info
				</table>
				<p>
					<ul>
						<li>环状RNA注释信息表：<a href="../$folders{CircBaseAnnotation}/circBase_annotation.xls" target="_blank"> circBase_annotation.xls </a></li>
						<li>环状RNA类型统计表（带注释信息）：
							<ul>
								<li><a href="../$folders{CircBaseAnnotation}/circ_candidates.info.annot.xls" target="_blank"> 全体环状RNA类型统计表 </a></li>
								<li><a href="../$folders{CircBaseAnnotation}/exist.circ.info.annot.xls" target="_blank"> 已存在环状RNA类型统计表 </a></li>
								<li><a href="../$folders{CircBaseAnnotation}/novel.circ.info.annot.xls" target="_blank"> 新预测环状RNA类型统计表 </a></li>
							</ul>
						</li>
					</ul>
				</p>
HTML_cont
		$resp_tabs_cnt++;
		print HTML <<HTML_cont;
				<p>已存在和新预测环状RNA统计图</p>
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
						<li>已存在环状RNA染色体分布</li>
						<li>新预测环状RNA染色体分布</li>
						<li>已存在环状RNA长度分布</li>
						<li>新预测环状RNA长度分布</li>
						<li>已存在环状RNA类型分布</li>
						<li>新预测环状RNA类型分布</li>
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
						<div>
							<a href="../$folders{CircBaseAnnotation}/exist.chr.png" target="_blank"><img src="../$folders{CircBaseAnnotation}/exist.chr.png" /></a>
						</div>
						<div>
							<a href="../$folders{CircBaseAnnotation}/novel.chr.png" target="_blank"><img src="../$folders{CircBaseAnnotation}/novel.chr.png" /></a>
						</div>
						<div>
							<a href="../$folders{CircBaseAnnotation}/exist.len.png" target="_blank"><img src="../$folders{CircBaseAnnotation}/exist.len.png" /></a>
						</div>
						<div>
							<a href="../$folders{CircBaseAnnotation}/novel.len.png" target="_blank"><img src="../$folders{CircBaseAnnotation}/novel.len.png" /></a>
						</div>
						<div>
							<a href="../$folders{CircBaseAnnotation}/exist.type.png" target="_blank"><img src="../$folders{CircBaseAnnotation}/exist.type.png" /></a>
						</div>
						<div>
							<a href="../$folders{CircBaseAnnotation}/novel.type.png" target="_blank"><img src="../$folders{CircBaseAnnotation}/novel.type.png" /></a>
						</div>
					</div>
				</div>
				<h5>靶向关系预测<a href="doc/database_annot_and_predition.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
				<table>
					<caption>环状RNA已存在靶向关系统计表</caption>
					<tr><th>小RNA数目</th><th>靶基因数目（环状RNA）</th><th>靶向关系数目</th></tr>
$database_annot_exist_target
				</table>
				<p>
					<ul>
						<li>环状RNA已存在靶向关系信息表<a href="doc/database_annot_and_predition.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>：
							<ul>
								<li><a href="../$folders{CircBaseAnnotation}/exist.target.aln.annot.xls" target="_blank"> exist.target.aln.annot.xls </a></li>
								<li><a href="../$folders{CircBaseAnnotation}/exist.target.aln.annot_index_mir.xls" target="_blank"> exist.target.aln.annot_index_mir.xls </a></li>
							</ul>
						</li>
					</ul>
				</p>
HTML_cont
	}

	if($opts{isPredict} eq "yes"){
		my $database_annot_novel_target;
		open IN, "$outdir/$folders{TargetPrediction}/novel.target.stat" || die $!;
		<IN>;
		{
			my $line = <IN>;
			chomp $line;
			my @t = split /\t/, $line;
			$line = join "", map{"<td>" . $_ . "</td>"} @t;
			$database_annot_novel_target .= <<TEMP;
				<tr>$line</tr>
TEMP
		}
		close IN;
		
		print HTML <<HTML_cont;
				<table>
					<caption>环状RNA新预测靶向关系统计表</caption>
					<tr><th>小RNA数目</th><th>靶基因数目（环状RNA）</th><th>靶向关系数目</th></tr>
$database_annot_novel_target
				</table>
				<p>
					<ul>
						<li>环状RNA新预测靶向关系信息表<a href="doc/database_annot_and_predition.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>：
							<ul>
								<li><a href="../$folders{TargetPrediction}/novel.target.aln.annot.xls" target="_blank"> novel.target.aln.annot.xls </a></li>
								<li><a href="../$folders{TargetPrediction}/novel.target.aln.annot_index_mir.xls" target="_blank"> novel.target.aln.annot_index_mir.xls </a></li>
							</ul>
						</li>
					</ul>
				</p>
			</section>
HTML_cont
	}
	else{
		print HTML <<HTML_cont;
			</section>
HTML_cont
	}

	if($opts{isMirTar} eq "yes"){
		print HTML <<HTML_cont;
	
			<!-- <br /><hr /><br /> -->
			
			<!-- mRNA关联分析 -->
			<section id="mirTar_analysis" class="normal_cont">
				<h3>mRNA关联分析<a href="doc/mirTar_analysis.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
HTML_cont

		my $exist_mirTar_novel_target;
		open IN, "$outdir/$folders{MirTarget}/exist_mirTar.target.stat" || die $!;
		<IN>;
		{
			my $line = <IN>;
			chomp $line;
			my @t = split /\t/, $line;
			$line = join "", map{"<td>" . $_ . "</td>"} @t;
			$exist_mirTar_novel_target .= <<TEMP;
				<tr>$line</tr>
TEMP
		}
		close IN;
		
		print HTML <<HTML_cont;
				<table>
					<caption>miTarBase靶向关系统计表</caption>
					<tr><th>小RNA数目</th><th>靶基因数目（mRNA）</th><th>靶向关系数目</th></tr>
$exist_mirTar_novel_target
				</table>
				<p>
					<ul>
						<li>miTarBase靶向关系信息表<a href="doc/mirTar_analysis.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>：
							<ul>
								<li><a href="../$folders{MirTarget}/exist_mirTar.target.aln.annot.xls" target="_blank"> exist_mirTar.target.aln.annot.xls </a></li>
								<li><a href="../$folders{MirTarget}/exist_mirTar.target.aln.annot_index_mir.xls" target="_blank"> exist_mirTar.target.aln.annot_index_mir.xls </a></li>
							</ul>
						</li>
					</ul>
				</p>
			</section>
HTML_cont
	}
}

print HTML <<HTML_cont;
			
			<!-- <br /><hr /><br /> -->

			<!-- 结题报告目录结构 -->
			<section id="catalog" class="normal_cont">
				<h3>目录结构</h3>
				<pre>
upload                                                报告总目录
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	if($opts{isFilter} eq "yes" || $opts{isRrRNA} eq "yes"){
		print HTML <<HTML_cont;
├── $folders{ReadsStat}                                        测序评估结果目录
HTML_cont
	}
	if($opts{isFilter} eq "yes"){
		if($opts{isRrRNA} eq "yes"){
			print HTML <<HTML_cont;
│   ├── *.stat                                            各样品数据过滤详细情况
│   ├── *.pie.png                                         各样品测序质量饼图
│   ├── *.old.png                                         各样品过滤前各项统计图
│   ├── *.new.png                                         各样品过滤后各项统计图
HTML_cont
		}
		else{
			print HTML <<HTML_cont;
│   ├── *.stat                                            各样品数据过滤详细情况
│   ├── *.pie.png                                         各样品测序质量饼图
│   ├── *.old.png                                         各样品过滤前各项统计图
│   └── *.new.png                                         各样品过滤后各项统计图
HTML_cont
		}
	}
	if($opts{isRrRNA} eq "yes"){
		print HTML <<HTML_cont;
│   └── *.rRNA.log                                        各样品与rRNA比对统计
HTML_cont
	}
}

print HTML <<HTML_cont;
├── $folders{AlignmentStat}                                    比对统计结果目录
HTML_cont

if(!$opts{read_type} =~ /^bam$/i || (exists $opts{source_dir} && $opts{source_dir} ne "none")){
	print HTML <<HTML_cont;
│   ├── *.align.stat                                      各样品HQ clean data去除rRNA后与参考基因组的比对统计表
HTML_cont
}

print HTML <<HTML_cont;
│   └── *_anchors.align.stat                              各样品Anchors Reads与参考基因组比对统计表
├── $folders{CircRNA}                                          环状RNA鉴定结果目录
│   ├── sites.log                                         环状RNA Reads类型统计表
│   ├── circ_candidates.bed                               环状RNA信息统计表
│   ├── circ_candidates.gtf                               环状RNA转录组注释 GTF 文件
│   ├── circ_candidates.fa                                环状RNA序列文件
│   ├── circ_candidates.info.xls                          环状RNA类型统计表
│   ├── exist.circ.info.xls                               已存在环状RNA类型统计表
│   └── novel.circ.info.xls                               新预测环状RNA类型统计表
├── $folders{Statistics}                                       环状RNA统计图目录
│   ├── circ.type.png                                     环状RNA类型分布
│   ├── circ.len.png                                      环状RNA长度分布
│   └── circ.chr.png                                      环状RNA染色体分布
HTML_cont

if($opts{isEnrich} eq "yes"){
	print HTML <<HTML_cont;
├── $folders{SourceGeneEnrichment}                             来源基因富集分析
│   ├── source_gene.glist.xls                             来源基因列表
HTML_cont
	if( -s "$outdir/$folders{SourceGeneEnrichment}/KO" ){
		if( -s "$outdir/$folders{SourceGeneEnrichment}/GO" ){
			print HTML <<HTML_cont;
│   ├── KO                                                Pathway富集分析结果目录
│   │   ├── source_gene.ko.xls                               来源基因基因集 KO 列表
│   │   ├── source_gene.path.xls                             来源基因基因集 Pathway 富集分析结果
│   │   ├── source_gene.path.png                             来源基因基因集 Pathway 富集分析气泡图
│   │   ├── source_gene_map                                  来源基因基因集 Pathway 富集分析通路图
│   │   └── source_gene.htm                                  来源基因基因集 Pathway 富集分析报告
HTML_cont
		}
		else{
			print HTML <<HTML_cont;
│   └── KO                                                Pathway富集分析结果目录
│        ├── source_gene.ko.xls                               来源基因基因集 KO 列表
│        ├── source_gene.path.xls                             来源基因基因集 Pathway 富集分析结果
│        ├── source_gene.path.png                             来源基因基因集 Pathway 富集分析气泡图
│        ├── source_gene_map                                  来源基因基因集 Pathway 富集分析通路图
│        └── source_gene.htm                                  来源基因基因集 Pathway 富集分析报告
HTML_cont
		}
	}
	if( -s "$outdir/$folders{SourceGeneEnrichment}/GO" ){
		print HTML <<HTML_cont;
│   └── GO                                                功能富集分析结果目录
│        ├── source_gene.wego.xls                             来源基因基因集 GO 汇总表
│        ├── source_gene.go.class.xls                         来源基因基因集 GO 分类表
│        ├── source_gene.go.class.svg                         来源基因基因集 GO 分类统计图-矢量图
│        ├── source_gene.go.class.png                         来源基因基因集 GO 分类统计图-位图
│        ├── source_gene_C.png                                来源基因基因集 Go Cellular Component 富集分析有向无环图
│        ├── source_gene_C.xls                                来源基因基因集 Go Cellular Component 富集分析结果
│        ├── source_gene_C.html                               来源基因基因集 Go Cellular Component 富集分析报告
│        ├── source_gene_F.png                                来源基因基因集 Go Molecular Function 富集分析有向无环图
│        ├── source_gene_F.xls                                来源基因基因集 Go Molecular Function 富集分析结果
│        ├── source_gene_F.html                               来源基因基因集 Go Molecular Function 富集分析报告
│        ├── source_gene_P.png                                来源基因基因集 Go Biological Process 富集分析有向无环图
│        ├── source_gene_P.xls                                来源基因基因集 Go Biological Process 富集分析结果
│        ├── source_gene_P.html                               来源基因基因集 Go Biological Process 富集分析报告
│        ├── GOView.html                                      功能富集分析网页报告索引
│        └── GOViewList.html                                  功能富集分析网页报告
HTML_cont
	}
}

print HTML <<HTML_cont;
├── $folders{ExpressionStat}                                   表达量统计结果目录
│   ├── circ.expression.annot.xls                         样品表达量统计表
HTML_cont

if(scalar(@group_lab) >= 1){
	print HTML <<HTML_cont;
│   ├── circ.group.expression.annot.xls                   样品表达量统计表
HTML_cont
}

print HTML <<HTML_cont;
│   └── circ.rpkm.distribution.png                        表达量丰度分布图
HTML_cont

if($opts{Sde} ne "none" && scalar(@sample_lab) >= 2){
	print HTML <<HTML_cont;
├── $folders{SamplesDifferentialExpression}                    样品间差异表达分析结果目录
│   ├── A-vs-B.genes.filter.annot.xls                     样品间A-vs-B显著差异基因表
│   ├── A-vs-B.genes.annot.xls                            样品间A-vs-B显著差异基因表
│   ├── A-vs-B.DE.volcano.png                             样品间A-vs-B差异基因火山图
│   ├── A-vs-B.DE.scatter.png                             样品间A-vs-B差异基因散点图
│   ├── geneDE.v.png                                      所有样品间差异基因统计图（纵向）
│   ├── geneDE.h.png                                      所有样品间差异基因统计图（横向）
│   └── geneDE.stat                                       所有样品间差异基因统计表
HTML_cont
}

if($opts{Gde} ne "none" && scalar(@group_lab) >= 2){
	print HTML <<HTML_cont;
├── $folders{GroupsDifferentialExpression}                     分组间差异表达分析结果目录
│   ├── A-vs-B.genes.filter.annot.xls                     分组间A-vs-B显著差异基因表
│   ├── A-vs-B.genes.annot.xls                            分组间A-vs-B显著差异基因表
│   ├── A-vs-B.DE.volcano.png                             分组间A-vs-B差异基因火山图
│   ├── geneDE.v.png                                      所有分组间差异基因统计图（纵向）
│   ├── geneDE.h.png                                      所有分组间差异基因统计图（横向）
│   └── geneDE.stat                                       所有分组间差异基因统计表
HTML_cont
}

if($opts{isAnnot} eq "yes" || $opts{isPredict} eq "yes"){
	if($opts{isAnnot} eq "yes"){
		print HTML <<HTML_cont;
├── $folders{CircBaseAnnotation}                               数据库注释结果目录
│   ├── circBase_annotation.xls                           环状RNA注释信息表
│   ├── circ_candidates.info.annot.xls                    全体环状RNA类型统计表
│   ├── exist.circ.info.annot.xls                         已存在环状RNA类型统计表
│   ├── novel.circ.info.annot.xls                         新预测环状RNA类型统计表
│   ├── exist.type.png                                    已存在环状RNA类型分布
│   ├── novel.type.png                                    新预测环状RNA类型分布
│   ├── exist.len.png                                     已存在环状RNA长度分布
│   ├── novel.len.png                                     新预测环状RNA长度分布
│   ├── exist.chr.png                                     已存在环状RNA染色体分布
│   ├── novel.chr.png                                     新预测环状RNA染色体分布
│   ├── exist.target.stat                                 环状RNA已存在靶向关系统计表
│   ├── exist.target.aln.annot.xls                        环状RNA已存在靶向关系信息表
│   └── exist.target.aln.annot_index_mir.xls              环状RNA已存在靶向关系信息表（以小RNA作索引）
HTML_cont
	}

	if($opts{isPredict} eq "yes"){
		print HTML <<HTML_cont;
├── $folders{TargetPrediction}                                环状RNA新预测靶向关系结果目录
│   ├── exist.target.stat                                 环状RNA新预测靶向关系统计表
│   ├── exist.target.aln.annot.xls                        环状RNA新预测靶向关系信息表
│   └── exist.target.aln.annot_index_mir.xls              环状RNA新预测靶向关系信息表（以小RNA作索引）
HTML_cont
	}
	
	if($opts{isMirTar} eq "yes"){
		print HTML <<HTML_cont;
├── $folders{MirTarget}                                       miTarBase靶向关系结果目录
│   ├── exist.target.stat                                 miTarBase靶向关系统计表
│   ├── exist.target.aln.annot.xls                        miTarBase靶向关系信息表
│   └── exist.target.aln.annot_index_mir.xls              miTarBase靶向关系信息表（以小RNA作索引）
HTML_cont
	}
	
	print HTML <<HTML_cont;
├── $folders{Cytoscape}                                       Cytoscape输入文件目录
│   ├── exist.circ.node                                   已存在环状RNA列表
│   ├── novel.circ.node                                   新预测环状RNA列表
│   ├── exist_circRNA_miRNA.edge                          环状RNA已存在靶向关系列表
HTML_cont

	if($opts{isPredict} eq "yes"){
		print HTML <<HTML_cont;
│   ├── novel_circRNA_miRNA.edge                          环状RNA新预测靶向关系列表
HTML_cont
	}
	
	if($opts{isMirTar} eq "yes"){
		print HTML <<HTML_cont;
│   ├── mRNA.node                                         mRNA列表
│   ├── mRNA_miRNA.edge                                   miTarBase靶向关系列表
HTML_cont
	}
	
	print HTML <<HTML_cont;
│   └── miRNA.nodes                                       小RNA列表
HTML_cont
}

print HTML <<HTML_cont;
├── Page_Config                                        结题报告相关文件目录
│   ├── content.html                                      结题报告主题内容页面
│   ├── image                                             结题报告必要图片
│   ├── doc                                               结题报告必要帮助文档
│   ├── css                                               结题报告样式设置相关文件
│   └── js                                                结题报告网页脚本
└── index.html                                         结题报告索引
				</pre>
			</section>
		</div>

		<!-- 帮助文档窗口 -->
		<div id="show_help">
			<h3>帮助文档</h3>
			<iframe id="help_page" name="help_page" src="http://www.genedenovo.com/"></iframe>
		</div>
		
		<!-- JS插件初始化 -->
		<script type="text/javascript">
			\$(document).ready(function() {
				\$("#report_body").jumpto({
					innerWrapper: "section",
					firstLevel: "> h3",
					secondLevel: "> h5",
					offset: 0,
					anchorTopPadding: 0,
					animate: 600,
					showTitle: "目录",
					closeButton: false
				});
				for (var i = 1; i <= $resp_tabs_cnt; i++){
					\$('#resp-tabs-list' + i).niceScroll({cursoropacitymax:0.5,cursorwidth:"8px"});
					\$('#resp-tabs-container' + i).niceScroll({cursoropacitymax:0.5,cursorwidth:"8px"});
					\$('#parentVerticalTab' + i).easyResponsiveTabs({
						type: 'vertical', //Types: default, vertical, accordion
						width: 'auto', //auto or any width like 600px
						fit: true, // 100% fit in a container
						closed: 'accordion', // Start closed if in accordion view
						tabidentify: 'hor_' + i, // The tab groups identifier
						activate: function(event) { // Callback function if tab is switched
							var \$tab = \$(this);
							var \$info = \$('#nested-tabInfo2');
							var \$name = \$('span', \$info);
							\$name.text(\$tab.text());
							\$info.show();
						}
					});
				}
			});
		</script>
	</body>
</html>
HTML_cont
close HTML;

##### Index #####

open INDEX, "> $outdir/index.html" || die $!;
print INDEX <<HTML_index;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<!-- 基本信息 -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>基迪奥生物 环状RNA分析 结题报告</title>
		
		<!-- CSS文档 -->
		<link rel="stylesheet" type="text/css" href="Page_Config/css/index.css" />
		
		<!-- JS脚本 -->
		<script src="Page_Config/js/jquery-1.9.1-min.js"></script>
	</head>
	<body>
		<!-- 结题报告页眉 -->
		<section>
			<div id="header_banner">
				<div id="banner_logo"></div>
				<div id="banner_title">基迪奥生物 <span> 环状RNA分析 </span> 结题报告</div>
				<div id="banner_bg_circRNA"></div>
			</div>
		</section>
		
		<!-- 结题报告主内容 -->
		<section>
			<iframe id="iframepage" src="Page_Config/content.html"></iframe>
		</section>
		
		<!-- JS脚本初始化 -->
		<script language="javascript">
			function frameresize(){
				var iframeheight = \$(window).height();
				\$('#iframepage').css('height', iframeheight - 85 + 'px');
			};
			if(window.attachEvent){
				document.getElementById("iframepage").attachEvent('onload', frameresize);
			}
			else{
				document.getElementById("iframepage").addEventListener('load', frameresize, false);
			} 
			\$(window).resize(frameresize);
			frameresize();
		</script>
	</body>
</html>
HTML_index
close INDEX;

##### sub program #####
sub info{
	my ($text) = @_;
	&showTime($text);
}

sub showTime
{
	my ($text) = @_;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}

sub reformConfig{
	my ($opts, $samples, $groups, $sample_lab, $group_lab, $sample_diff, $group_diff, $multi_diff) = @_;

	#dealing with sample info and relationship of difference comparison
	unless(exists $$opts{source_dir} && $$opts{source_dir} ne "none"){
		if(exists $$opts{sample} && $$opts{sample} ne "none"){
			my @samples = split /\|/, $$opts{sample};
			for(my $i = 0; $i < scalar(@samples); $i++){
				my @parts = split /\s*\:\s*/, $samples[$i];
				push(@{$sample_lab}, $parts[0]);
			}
		}
	}
	else{
		my @dir = `ls $$opts{source_dir}/align`;
		foreach my $dir (@dir){
			chomp $dir;
			if(-d "$$opts{source_dir}/align/$dir"){
				push(@{sample_lab}, $dir);
			}
		}
	}

	if(exists $$opts{group} && $$opts{group} ne "none"){
		my @groups = split /\|/, $$opts{group};
		for(my $i = 0; $i < scalar(@groups); $i++){
			my @parts = split /\s*\:\s*/, $groups[$i];
			push(@{$group_lab}, $parts[0]);
			my @lables = split /\s+/, $parts[1];
			for(my $j =0; $j < scalar(@lables); $j++){
				push(@{$groups{$parts[0]}}, $lables[$j]);
			}
		}
	}

	if(exists $$opts{Sde} && $$opts{Sde} ne "none"){
		my @pair = split /\,/, $$opts{Sde};
		for(my $i = 0; $i < scalar(@pair); $i++){
			my @tmp = split /\&/, $pair[$i];
			for(my $j = 0; $j < scalar(@tmp); $j++){
				push(@{$sample_diff{$pair[$i]}}, $tmp[$j]);
			}
		}
	}

	if(exists $$opts{Gde} && $$opts{Gde} ne "none"){
		my @pair = split /\,/, $$opts{Gde};
		for(my $i = 0; $i < scalar(@pair); $i++){
			my @tmp = split /\&/, $pair[$i];
			for(my $j = 0; $j < scalar(@tmp); $j++){
				push(@{$group_diff{$pair[$i]}}, $tmp[$j]);
			}
		}
	}

#	if(exists $$opts{MultiSamples} && $$opts{MultiSamples} ne "none"){
#		my @comparison = split /\,/, $$opts{MultiSamples};
#		for(my $i = 0; $i < scalar(@comparison); $i++){
#			push(@{$multi_diff}, $comparison[$i]);
#		}
#	}

#	if(exists $$opts{MultiGroups} && $$opts{MultiGroups} ne "none"){
#		my @comparison = split /\,/, $$opts{MultiGroups};
#		for(my $i = 0; $i < scalar(@comparison); $i++){
#			push(@{$multi_diff}, $comparison[$i]);
#		}
#	}

}

sub readConfig
{
	## initail local variable
	my ($config_file, $opts) = @_;

	## reading project config
	open CONFIG, "$config_file" || die $!;
	while(<CONFIG>){
		chomp;
		next if(/^#|^\s*$/);
		my @x = split /\s*:=\s*/;
		$x[0] =~ s/^\s+|\s+$//;
		$x[1] =~ s/^\s+|\s+$//;
		## dealing with samples' lables & groups' lables
		if($x[0] eq "sample" || $x[0] eq "group"){
			if(exists $$opts{$x[0]} && $$opts{$x[0]} ne "none"){
				$$opts{$x[0]} = join "|", $$opts{$x[0]}, $x[1];
			}
			else{
				$$opts{$x[0]} = $x[1];
			}
		}
		## dealing with simple config
		else{
			$$opts{$x[0]} = $x[1];
		}
	}
	close CONFIG;
}
