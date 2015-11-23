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
		<!-- ������Ϣ -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>���ϰ����� ��״RNA���� ���ⱨ��</title>
		
		<!-- CSS�ĵ� -->
		<link rel="stylesheet" type="text/css" href="css/report.css" />
		<link rel="stylesheet" type="text/css" href="css/jumpto.css" />
		<link rel="stylesheet" type="text/css" href="css/easy-responsive-tabs.css" />
		
		<!-- JS�ű� -->
		<script src="js/jquery-1.9.1-min.js"></script>
		<script src="js/modernizr-min.js"></script>
		<script src="js/jquery.jumpto-min.js"></script>
		<script src="js/jquery.nicescroll-min.js"></script>
		<script src="js/easyResponsiveTabs-min.js"></script>
		<script src="js/show_help-min.js"></script>
		
	</head>
	<body>
		<div id="report_body">
		
			<!-- ��Ŀ���� -->
			<section id="project_info" class="normal_cont">
				<h3>��Ŀ����</h3>
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
					<tr><td>��Ŀ���</td><td>$opts{project}</td></tr>
					<tr><td>��Ŀ����</td><td>$opts{content}</td></tr>
					<tr><td>�ο�������</td><td>$opts{reference}</td></tr>
					<tr><td>��Ʒ����</td><td>$project_info_sample_lab</td></tr>
HTML_cont

if(exists $opts{Sde} && $opts{Sde} ne "none"){
	print HTML <<HTML_cont;
					<tr><td>��Ʒ����췽��</td><td>$project_info_sample_diff</td></tr>
HTML_cont
}

if(scalar @group_lab > 0){
	print HTML <<HTML_cont;
					<tr><td>���鷽��</td><td>$project_info_group_lab</td></tr>
HTML_cont
}

if(exists $opts{Gde} && $opts{Gde} ne "none"){
	print HTML <<HTML_cont;
					<tr><td>�������췽��</td><td>$project_info_group_diff</td></tr>
HTML_cont
}

print HTML <<HTML_cont;
				</table>
			</section>
			
			<!-- <br /><hr /><br /> -->
			
			<!-- ���� -->
			<section id="introduction" class="normal_cont">
				<h3>�������</h3>
				<h5>ʵ����</h5>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="image/flow_001.png" target="_blank"><img src="image/flow_001.png" /></td>
						<td class="pic_table_desc" style="width: 50%"><p>��Ʒ��ȡ��RNA��ȥ��������RNA��Ȼ����Rnase Rø��������RNA���õ��Ļ�״RNA�м���fragmentation bufferʹ��Ƭ�ϳ�Ϊ��Ƭ�Σ�����Ƭ�Ϻ�Ļ�״RNAΪģ�壬�������������random hexamers���ϳ�cDNA��һ���������뻺��Һ��dNTPs��RNase H��DNA polymerase I�ϳ�cDNA�ڶ���������QiaQuick PCR�Լ��д�������EB����Һϴ�Ѿ�ĩ���޸����Ӽ��A���Ӳ����ͷ���پ���֬��������Ӿ����Ŀ�Ĵ�СƬ�Σ�������PCR�������Ӷ���������Ŀ��Ʊ������������õ��Ŀ���Illumina HiSeq<sup>TM</sup> 2500���в���</p></td>
					</tr>
					<tr>
						<td>ʵ������ͼ</td>
						<td></td>
					</tr>
				</table>
				<h5>��Ϣ�������</h5>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="image/flow_002.png" target="_blank"><img src="image/flow_002.png" /></td>
						<td class="pic_table_desc" style="width: 50%"><p>�õ��»����ݺ����Ƚ��������й��ˣ��õ�HQ Clean Reads��ÿ����Ʒ�� HQ Clean Reads �� �ο������� �ֱ���зֱ� TopHat �ȶԣ��õ�ÿ����Ʒ�ıȶԽ�����ӱȶԽ������ȡUnmapped Reads��Ȼ���ȡÿһ��Unmapped Reads�����ˣ�Ĭ��20bp�����õ�Anchors Reads����Anchors Reads��һ�αȶԵ��������ϣ����õ��ıȶԽ���ύ��find_circ�����������״RNA���õ������Ļ�״RNA����Ҫ�������ֽ��з�����1����״RNAͳ�ƣ�����ͳ��Reads���ͣ���״RNA���ͣ���״RNA�ֲ��ȣ�2�������������������������������������Ʒ�Ƚ�������Ƚ�������������3�����ݿ�ע�������Ԥ�⣬�����Ի�״RNA����circBase���ݿ�ע�ͣ��Ա�ע�͵Ļ�״RNA����Ϊ�Ѵ��ڻ�״RNA��δ��ע�͵Ļ�״RNA����Ϊ��Ԥ�⻷״RNA��Ȼ����Ѵ��ڻ�״RNA����starBaseСRNA�����ϵע�ͣ������ݿ������а����ϵ����Ϊ�Ѵ��ڰ����ϵ��Ȼ���ȫ�廷״RNA����СRNA����Ԥ�⣬�õ���Ԥ������ϵ����ð����ϵ�����ǿɴ�mirTarBase���ҵ��Ѵ��ڵ�СRNA��mRNA�����ϵ������������Ϣ�ɹ�������ͼ��<p></td>
					</tr>
					<tr>
						<td>��Ϣ��������ͼ</td>
						<td></td>
					</tr>
				</table>
			</section>
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	if($opts{isFilter} eq "yes"){
		print HTML <<HTML_cont;
	
			<!-- <br /><hr /><br /> -->
			
			<!-- �������� -->
			<section id="seq_stat" class="normal_cont">
				<h3>��������<a href="doc/seq_stat.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<h5>������������<a href="doc/seq_stat.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
										<p>��Ʒ <span class="sample_lab_strong">${_}</span> <span class="pic_table_strong">����ǰ</span> �����ɷֲ�ͼ</p>
									</td>
									<td>
										<a href="../$folders{ReadsStat}/${_}.new.png" target="_blank"><img src="../$folders{ReadsStat}/${_}.new.png" /></a>
										<p>��Ʒ <span class="sample_lab_strong">${_}</span> <span class="pic_table_strong">���˺�</span> �����ɷֲ�ͼ</p>
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
				<h5>����������������<a href="doc/seq_stat.html#sub_3" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
				<h5>������Ϣͳ��</h5>
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
					<caption>����ǰ������Ϣͳ�Ʊ�<a href="doc/seq_stat.html#sub_4_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th rowspan=2>Sample</th><th colspan=5>Before Filter</th><th colspan=5>After Filter</th></tr>
					<tr><th>Clean Data(bp)</th><th>Q20(%)</th><th>Q30(%)</th><th>N(%)</th><th>GC(%)</th><th>HQ Clean Data(bp)</th><th>Q20(%)</th><th>Q30(%)</th><th>N(%)</th><th>GC(%)</th></tr>
$reads_stat_line1
				</table>
				
				<p><br /></p>
				
				<table>
					<caption>Reads ������Ϣͳ�Ʊ�<a href="doc/seq_stat.html#sub_4_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Sample</th><th>Clean Reads Num</th><th>HQ Clean Reads Num(%)</th><th>Read Length</th><th>Adapter(%)</th><th>Low Quality(%)</th><th>Poly A(%)</th><th>N(%)</th></tr>
$reads_stat_line2
				</table>
			</section>
HTML_cont
	}
}

print HTML <<HTML_cont;

			<!-- <br /><hr /><br /> -->
			
			<!-- �ȶ�ͳ�� -->
			<section id="align_stat" class="normal_cont">
				<h3>�ȶ�ͳ��</h3>
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	if($opts{isRrRNA} eq "yes"){
		print HTML <<HTML_cont;
				<h5>�ȶԺ�����<a href="doc/align_stat.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
					<caption>HQ clean data �� rRNA �ıȶ�ͳ�Ʊ�</caption>
					<tr><th>Sample</th><th>All Reads Num</th><th>Mapped Reads</th><th>Unmapped Reads</th></tr>
$align_stat_rRNA
				</table>
HTML_cont
	}
}

print HTML <<HTML_cont;
				<h5>�ȶԻ�����<a href="doc/align_stat.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
					<caption>�ȶԺ������õ��� Unmapped Reads �� �ο������� �ıȶ�ͳ�Ʊ�</caption>
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
					<caption>Anchors Reads �� �ο������� �ȶ�ͳ�Ʊ�</caption>
					<tr><th>Sample</th><th>Reads Num</th><th>Mapped Reads</th><th>Mapping Ratio</th></tr>
$align_stat_anchors_align
				</table>
			</section>
			
			<!-- <br /><hr /><br /> -->
			
			<!-- ��״RNA���� -->
			<section id="circRNA_identify" class="normal_cont">
				<h3>��״RNA����<a href="doc/circRNA_identify.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<h5>��״RNA��Ϣͳ��</h5>
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
					<caption>��״RNA Reads����ͳ�Ʊ�<a href="doc/circRNA_identify.html#sub_1_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Type</th><th>Reads Num</th></tr>
\$circRNA_identify_site_log
				</table>
				<p><br /></p>
				-->
				<table>
					<caption>��״RNA��Ϣͳ�Ʊ�<a href="doc/circRNA_identify.html#sub_1_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Chr</th><th>Start</th><th>End</th><th>GeneID</th><th>Reads Num</th><th>Strand</th><th>Uniq Reads Num</th><th>...</th><th>Samples</th><th>Samples Counts</th><th>Edits</th><th>Anchor Overlap</th><th>Breakpoints</th></tr>
$circRNA_identify_info
				</table>
				<p>
					<ul>
						<li>��״RNA��Ŀ��<span class="pic_table_strong">$circRNA_gene_count</span></li>
						<li>��״RNA��Ϣͳ�Ʊ�<a href="../$folders{CircRNA}/circ_candidates.bed" target="_blank"> circ_candidates.bed </a></li>
					</ul>
				</p>
				<h5>��״RNA����ͳ��<a href="doc/circRNA_identify.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
					<caption>��״RNA����ͳ�Ʊ�<a href="doc/circRNA_identify.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Gene ID</th><th>Source Gene</th><th>Chr</th><th>Strand</th><th>Start</th><th>End</th><th>Length</th><th>Type</th></tr>
$circ_candidates_info
				</table>
				<p>
					<ul>
						<li>��״RNA����ͳ�Ʊ�<a href="../$folders{CircRNA}/circ_candidates.info.xls" target="_blank"> circ_candidates.info.xls </a></li>
						<li>��״RNA�����ļ���<a href="../$folders{CircRNA}/circ_candidates.fa" target="_blank"> circ_candidates.fa </a></li>
						<li>��״RNAת¼��ע�� GTF �ļ���<a href="../$folders{CircRNA}/circ_candidates.gtf" target="_blank"> circ_candidates.gtf </a></li>
					</ul>
				</p>
				<p>��״RNAͳ��ͼ</p>
HTML_cont
$resp_tabs_cnt++;
print HTML <<HTML_cont;
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
						<li>��״RNAȾɫ��ֲ�</li>
						<li>��״RNA���ȷֲ�</li>
						<li>��״RNA���ͷֲ�</li>
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
			
			<!-- ��Դ���򸻼����� -->
			<section id="source_gene_enrichment" class="normal_cont">
				<h3>��Դ���򸻼�����</h3>
				<p>
					<ul>
						<li>��Դ�����б�<a href="../$folders{SourceGeneEnrichment}/source_gene.glist.xls" target="_blank">source_gene.glist.xls</a></li>
					</ul>
				</p>
				<h5>Pathway��������<a href="doc/source_gene_enrichment.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

	unless( -s "$outdir/$folders{SourceGeneEnrichment}/KO"){
		print HTML <<HTML_cont;
				<p>����ȱ��KOע�ͣ�����޷�����Pathway����������</p>
HTML_cont
	}
	else{
		print HTML <<HTML_cont;
				<p>
					<ul>
						<li>Pathway�������������<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.htm" target="_blank">source_gene.htm</a></li>
						<li>Pathway MapĿ¼��<a href="../$folders{SourceGeneEnrichment}/KO/source_gene_map" target="_blank">source_gene_map</a></li>
						<li>Pathwayע�ͱ�<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.path.xls" target="_blank">source_gene.path.xls</a></li>
						<li>����ID��K�Ŷ��ձ�<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.ko.xls" target="_blank">source_gene.ko.xls</a></li>
					</ul>
				</p>
				<table class="pic_table">
					<tr><td>
						<a href="../$folders{SourceGeneEnrichment}/KO/source_gene.path.png" target="_blank"><img src="../$folders{SourceGeneEnrichment}/KO/source_gene.path.png" /></a>
					</td><tr>
					<tr><td>Pathway������������ͼ</td></tr>
				</table>
HTML_cont
	}
	
	print HTML <<HTML_cont;
				<h5>���ܸ�������<a href="doc/source_gene_enrichment.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
HTML_cont

	unless( -s "$outdir/$folders{SourceGeneEnrichment}/GO"){
		print HTML <<HTML_cont;
				<p>����ȱ��GOע�ͣ�����޷����й��ܸ���������</p>
HTML_cont
	}
	else{
		print HTML <<HTML_cont;
				<p>
					<ul>
						<li>���ܸ������������<a href="../$folders{SourceGeneEnrichment}/GO/GOView.html" target="_blank">GOView.html</a></li>
						<li>ϸ����ָ������������<a href="../$folders{SourceGeneEnrichment}/GO/source_gene_C.xls" target="_blank">source_gene_C.xls</a></li>
						<li>���ӹ��ܸ������������ <a href="../$folders{SourceGeneEnrichment}/GO/source_gene_F.xls" target="_blank">source_gene_F.xls</a></li>
						<li>����ѧ���̸������������ <a href="../$folders{SourceGeneEnrichment}/GO/source_gene_P.xls" target="_blank">source_gene_P.xls</a></li>
						<li>���ܸ������������<a href="../$folders{SourceGeneEnrichment}/GO/source_gene.go.class.xls" target="_blank">source_gene.go.class.xls</a></li>
					</ul>
				</p>
				<table class="pic_table">
					<tr><td>
						<a href="../$folders{SourceGeneEnrichment}/GO/source_gene.go.class.png" target="_blank"><img src="../$folders{SourceGeneEnrichment}/GO/source_gene.go.class.png" /></a>
					</td><tr>
					<tr><td>���ܸ�������������״ͼ</td></tr>
				</table>
HTML_cont
	}
	
	print HTML <<HTML_cont;
			</section>
HTML_cont
}
print HTML <<HTML_cont;

			<!-- <br /><hr /><br /> -->
			
			<!-- ����������� -->
			<section id="exp_diff" class="normal_cont">
				<h3>�����������<a href="doc/exp_diff.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<h5>�����ͳ��<a href="doc/exp_diff.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
				<table class="pic_table">
					<tr><td>
						<a href="../$folders{ExpressionStat}/circ.rpkm.distribution.png" target="_blank"><img src="../$folders{ExpressionStat}/circ.rpkm.distribution.png" /></a>
					</td><tr>
					<tr><td>�������ȷֲ�ͼ<a href="doc/exp_diff.html#sub_1_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></td></tr>
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
					<caption>��Ʒ�����ͳ�Ʊ�<a href="doc/exp_diff.html#sub_1_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
$exp_diff_sample_exp
				</table>
				<p>
					<ul>
						<li>��Ʒ�����ͳ�Ʊ�<a href="../$folders{ExpressionStat}/circ.expression.annot.xls" target="_blank"> circ.expression.annot.xls </a></li>
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
					<caption>��������ͳ�Ʊ�<a href="doc/exp_diff.html#sub_1_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
$exp_diff_group_exp
				</table>
				<p>
					<ul>
						<li>��������ͳ�Ʊ�<a href="../$folders{ExpressionStat}/circ.group.expression.annot.xls" target="_blank"> circ.group.expression.annot.xls </a></li>
					</ul>
				</p>
HTML_cont
}

if($opts{Sde} ne "none" && scalar(@sample_lab) >= 2){
	print HTML <<HTML_cont;
				<h5>��Ʒ����������<a href="doc/exp_diff.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
					<caption>��Ʒ��������ͳ�Ʊ�</caption>
					<tr><th>����Ƚ���</th><th>�����ϵ��������</th><th>�����µ��������</th><th>���������������</th><th>�������ע�ͱ�<a href="doc/exp_diff.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></th><th>�����������ע�ͱ�</th></tr>
$sample_diff_table
				</table>
				<p><br /></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{SamplesDifferentialExpression}/geneDE.h.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/geneDE.h.png" /></a></td>
						<td style="width: 50%"><a href="../$folders{SamplesDifferentialExpression}/geneDE.v.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/geneDE.v.png" /></a></td>
					</tr>
					<tr>
						<td><span class="pic_table_strong">��Ʒ��</span> �������ͳ����״ͼ������</td>
						<td><span class="pic_table_strong">��Ʒ��</span> �������ͳ����״ͼ������</td>
					</tr>
				</table>
				<p>��Ʒ��������ɢ��ͼ<a href="doc/exp_diff.html#sub_2_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
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
				<p>��Ʒ���������ɽͼ<a href="doc/exp_diff.html#sub_2_3" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$sample_diff_pair_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$sample_diff_pic_volcano_plot
					</div>
				</div>
				<p>��Ʒ�������ģʽ�������<a href="doc/exp_diff.html#sub_2_4" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{SamplesDifferentialExpression}/allsamples.heatmap.png" target="_blank"><img src="../$folders{SamplesDifferentialExpression}/allsamples.heatmap.png" /></a></td>
					</tr>
					<tr>
						<td>��Ʒ����������ͼ</td>
					</tr>
				</table>
HTML_cont
}

if($opts{Gde} ne "none" && scalar(@group_lab) >= 2){
	print HTML <<HTML_cont;
				<h5>�������������</h5>
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
					<caption>�����������ͳ�Ʊ�</caption>
					<tr><th>����Ƚ���</th><th>�����ϵ��������</th><th>�����µ��������</th><th>���������������</th><th>�������ע�ͱ�<a href="doc/exp_diff.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></th><th>�����������ע�ͱ�</th></tr>
$group_diff_table
				</table>
				<p><br /></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{GroupsDifferentialExpression}/geneDE.h.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/geneDE.h.png" /></a></td>
						<td style="width: 50%"><a href="../$folders{GroupsDifferentialExpression}/geneDE.v.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/geneDE.v.png" /></a></td>
					</tr>
					<tr>
						<td><span class="pic_table_strong">�����</span> �������ͳ����״ͼ������</td>
						<td><span class="pic_table_strong">�����</span> �������ͳ����״ͼ������</td>
					</tr>
				</table>
HTML_cont
	$resp_tabs_cnt++;
	print HTML <<HTML_cont;
				<p>������������ɽͼ<a href="doc/exp_diff.html#sub_2_3" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
$group_diff_pair_list
					</ul>
					<div id="resp-tabs-container$resp_tabs_cnt" class="resp-tabs-container hor_$resp_tabs_cnt">
$group_diff_pic_volcano_plot
					</div>
				</div>
				<p>����������ģʽ�������<a href="doc/exp_diff.html#sub_2_4" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></p>
				<table class="pic_table">
					<tr>
						<td style="width: 50%"><a href="../$folders{GroupsDifferentialExpression}/allgroups.heatmap.png" target="_blank"><img src="../$folders{GroupsDifferentialExpression}/allgroups.heatmap.png" /></a></td>
					</tr>
					<tr>
						<td>�������������ͼ</td>
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
			
			<!-- ���ݿ�ע�������Ԥ�� -->
			<section id="database_annot_and_predition" class="normal_cont">
				<h3>���ݿ�ע�������Ԥ��</h3>
				<p>
					<ul>
						<li>�����ϵ��������Cytoscape��ͼ<a href="doc/cytoscape.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>����<a href="../$folders{Cytoscape}/" target="_blank"> Cytoscape�����ļ�Ŀ¼ </a></li>
					</ul>
				</p>
HTML_cont

	if($opts{isAnnot} eq "yes"){
		print HTML <<HTML_cont;
				<h5>���ݿ�ע��<a href="doc/database_annot_and_predition.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
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
					<caption>��״RNAע�����ͳ��</caption>
					<tr><th>��״RNA����</th><th>�Ѵ��ڻ�״RNA��</th><th>��Ԥ�⻷״RNA��</th></tr>
					<tr><td>$circRNA_gene_count</td><td>$circRNA_exist_count</td><td>$circRNA_novel_count</td></tr>
				</table>
				<p><br /></p>
				<table>
					<caption>��״RNAע����Ϣ��<a href="doc/database_annot_and_predition.html#sub_1_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></caption>
					<tr><th>Gene ID</th><th>Annotation</th><th>Best Transcript</th><th>Gene Symbol</th><th>Study</th></tr>
$database_annot_info
				</table>
				<p>
					<ul>
						<li>��״RNAע����Ϣ��<a href="../$folders{CircBaseAnnotation}/circBase_annotation.xls" target="_blank"> circBase_annotation.xls </a></li>
						<li>��״RNA����ͳ�Ʊ���ע����Ϣ����
							<ul>
								<li><a href="../$folders{CircBaseAnnotation}/circ_candidates.info.annot.xls" target="_blank"> ȫ�廷״RNA����ͳ�Ʊ� </a></li>
								<li><a href="../$folders{CircBaseAnnotation}/exist.circ.info.annot.xls" target="_blank"> �Ѵ��ڻ�״RNA����ͳ�Ʊ� </a></li>
								<li><a href="../$folders{CircBaseAnnotation}/novel.circ.info.annot.xls" target="_blank"> ��Ԥ�⻷״RNA����ͳ�Ʊ� </a></li>
							</ul>
						</li>
					</ul>
				</p>
HTML_cont
		$resp_tabs_cnt++;
		print HTML <<HTML_cont;
				<p>�Ѵ��ں���Ԥ�⻷״RNAͳ��ͼ</p>
				<div id="parentVerticalTab$resp_tabs_cnt" class="VerticalTab">
					<ul id="resp-tabs-list$resp_tabs_cnt" class="resp-tabs-list hor_$resp_tabs_cnt">
						<li>�Ѵ��ڻ�״RNAȾɫ��ֲ�</li>
						<li>��Ԥ�⻷״RNAȾɫ��ֲ�</li>
						<li>�Ѵ��ڻ�״RNA���ȷֲ�</li>
						<li>��Ԥ�⻷״RNA���ȷֲ�</li>
						<li>�Ѵ��ڻ�״RNA���ͷֲ�</li>
						<li>��Ԥ�⻷״RNA���ͷֲ�</li>
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
				<h5>�����ϵԤ��<a href="doc/database_annot_and_predition.html#sub_2" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h5>
				<table>
					<caption>��״RNA�Ѵ��ڰ����ϵͳ�Ʊ�</caption>
					<tr><th>СRNA��Ŀ</th><th>�л�����Ŀ����״RNA��</th><th>�����ϵ��Ŀ</th></tr>
$database_annot_exist_target
				</table>
				<p>
					<ul>
						<li>��״RNA�Ѵ��ڰ����ϵ��Ϣ��<a href="doc/database_annot_and_predition.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>��
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
					<caption>��״RNA��Ԥ������ϵͳ�Ʊ�</caption>
					<tr><th>СRNA��Ŀ</th><th>�л�����Ŀ����״RNA��</th><th>�����ϵ��Ŀ</th></tr>
$database_annot_novel_target
				</table>
				<p>
					<ul>
						<li>��״RNA��Ԥ������ϵ��Ϣ��<a href="doc/database_annot_and_predition.html#sub_2_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>��
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
			
			<!-- mRNA�������� -->
			<section id="mirTar_analysis" class="normal_cont">
				<h3>mRNA��������<a href="doc/mirTar_analysis.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
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
					<caption>miTarBase�����ϵͳ�Ʊ�</caption>
					<tr><th>СRNA��Ŀ</th><th>�л�����Ŀ��mRNA��</th><th>�����ϵ��Ŀ</th></tr>
$exist_mirTar_novel_target
				</table>
				<p>
					<ul>
						<li>miTarBase�����ϵ��Ϣ��<a href="doc/mirTar_analysis.html#sub_1" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>��
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

			<!-- ���ⱨ��Ŀ¼�ṹ -->
			<section id="catalog" class="normal_cont">
				<h3>Ŀ¼�ṹ</h3>
				<pre>
upload                                                ������Ŀ¼
HTML_cont

if((exists $opts{source_dir} && $opts{source_dir} ne "none") || !($opts{read_type} =~ /^bam$/i)){
	if($opts{isFilter} eq "yes" || $opts{isRrRNA} eq "yes"){
		print HTML <<HTML_cont;
������ $folders{ReadsStat}                                        �����������Ŀ¼
HTML_cont
	}
	if($opts{isFilter} eq "yes"){
		if($opts{isRrRNA} eq "yes"){
			print HTML <<HTML_cont;
��   ������ *.stat                                            ����Ʒ���ݹ�����ϸ���
��   ������ *.pie.png                                         ����Ʒ����������ͼ
��   ������ *.old.png                                         ����Ʒ����ǰ����ͳ��ͼ
��   ������ *.new.png                                         ����Ʒ���˺����ͳ��ͼ
HTML_cont
		}
		else{
			print HTML <<HTML_cont;
��   ������ *.stat                                            ����Ʒ���ݹ�����ϸ���
��   ������ *.pie.png                                         ����Ʒ����������ͼ
��   ������ *.old.png                                         ����Ʒ����ǰ����ͳ��ͼ
��   ������ *.new.png                                         ����Ʒ���˺����ͳ��ͼ
HTML_cont
		}
	}
	if($opts{isRrRNA} eq "yes"){
		print HTML <<HTML_cont;
��   ������ *.rRNA.log                                        ����Ʒ��rRNA�ȶ�ͳ��
HTML_cont
	}
}

print HTML <<HTML_cont;
������ $folders{AlignmentStat}                                    �ȶ�ͳ�ƽ��Ŀ¼
HTML_cont

if(!$opts{read_type} =~ /^bam$/i || (exists $opts{source_dir} && $opts{source_dir} ne "none")){
	print HTML <<HTML_cont;
��   ������ *.align.stat                                      ����ƷHQ clean dataȥ��rRNA����ο�������ıȶ�ͳ�Ʊ�
HTML_cont
}

print HTML <<HTML_cont;
��   ������ *_anchors.align.stat                              ����ƷAnchors Reads��ο�������ȶ�ͳ�Ʊ�
������ $folders{CircRNA}                                          ��״RNA�������Ŀ¼
��   ������ sites.log                                         ��״RNA Reads����ͳ�Ʊ�
��   ������ circ_candidates.bed                               ��״RNA��Ϣͳ�Ʊ�
��   ������ circ_candidates.gtf                               ��״RNAת¼��ע�� GTF �ļ�
��   ������ circ_candidates.fa                                ��״RNA�����ļ�
��   ������ circ_candidates.info.xls                          ��״RNA����ͳ�Ʊ�
��   ������ exist.circ.info.xls                               �Ѵ��ڻ�״RNA����ͳ�Ʊ�
��   ������ novel.circ.info.xls                               ��Ԥ�⻷״RNA����ͳ�Ʊ�
������ $folders{Statistics}                                       ��״RNAͳ��ͼĿ¼
��   ������ circ.type.png                                     ��״RNA���ͷֲ�
��   ������ circ.len.png                                      ��״RNA���ȷֲ�
��   ������ circ.chr.png                                      ��״RNAȾɫ��ֲ�
HTML_cont

if($opts{isEnrich} eq "yes"){
	print HTML <<HTML_cont;
������ $folders{SourceGeneEnrichment}                             ��Դ���򸻼�����
��   ������ source_gene.glist.xls                             ��Դ�����б�
HTML_cont
	if( -s "$outdir/$folders{SourceGeneEnrichment}/KO" ){
		if( -s "$outdir/$folders{SourceGeneEnrichment}/GO" ){
			print HTML <<HTML_cont;
��   ������ KO                                                Pathway�����������Ŀ¼
��   ��   ������ source_gene.ko.xls                               ��Դ������� KO �б�
��   ��   ������ source_gene.path.xls                             ��Դ������� Pathway �����������
��   ��   ������ source_gene.path.png                             ��Դ������� Pathway ������������ͼ
��   ��   ������ source_gene_map                                  ��Դ������� Pathway ��������ͨ·ͼ
��   ��   ������ source_gene.htm                                  ��Դ������� Pathway ������������
HTML_cont
		}
		else{
			print HTML <<HTML_cont;
��   ������ KO                                                Pathway�����������Ŀ¼
��        ������ source_gene.ko.xls                               ��Դ������� KO �б�
��        ������ source_gene.path.xls                             ��Դ������� Pathway �����������
��        ������ source_gene.path.png                             ��Դ������� Pathway ������������ͼ
��        ������ source_gene_map                                  ��Դ������� Pathway ��������ͨ·ͼ
��        ������ source_gene.htm                                  ��Դ������� Pathway ������������
HTML_cont
		}
	}
	if( -s "$outdir/$folders{SourceGeneEnrichment}/GO" ){
		print HTML <<HTML_cont;
��   ������ GO                                                ���ܸ����������Ŀ¼
��        ������ source_gene.wego.xls                             ��Դ������� GO ���ܱ�
��        ������ source_gene.go.class.xls                         ��Դ������� GO �����
��        ������ source_gene.go.class.svg                         ��Դ������� GO ����ͳ��ͼ-ʸ��ͼ
��        ������ source_gene.go.class.png                         ��Դ������� GO ����ͳ��ͼ-λͼ
��        ������ source_gene_C.png                                ��Դ������� Go Cellular Component �������������޻�ͼ
��        ������ source_gene_C.xls                                ��Դ������� Go Cellular Component �����������
��        ������ source_gene_C.html                               ��Դ������� Go Cellular Component ������������
��        ������ source_gene_F.png                                ��Դ������� Go Molecular Function �������������޻�ͼ
��        ������ source_gene_F.xls                                ��Դ������� Go Molecular Function �����������
��        ������ source_gene_F.html                               ��Դ������� Go Molecular Function ������������
��        ������ source_gene_P.png                                ��Դ������� Go Biological Process �������������޻�ͼ
��        ������ source_gene_P.xls                                ��Դ������� Go Biological Process �����������
��        ������ source_gene_P.html                               ��Դ������� Go Biological Process ������������
��        ������ GOView.html                                      ���ܸ���������ҳ��������
��        ������ GOViewList.html                                  ���ܸ���������ҳ����
HTML_cont
	}
}

print HTML <<HTML_cont;
������ $folders{ExpressionStat}                                   �����ͳ�ƽ��Ŀ¼
��   ������ circ.expression.annot.xls                         ��Ʒ�����ͳ�Ʊ�
HTML_cont

if(scalar(@group_lab) >= 1){
	print HTML <<HTML_cont;
��   ������ circ.group.expression.annot.xls                   ��Ʒ�����ͳ�Ʊ�
HTML_cont
}

print HTML <<HTML_cont;
��   ������ circ.rpkm.distribution.png                        �������ȷֲ�ͼ
HTML_cont

if($opts{Sde} ne "none" && scalar(@sample_lab) >= 2){
	print HTML <<HTML_cont;
������ $folders{SamplesDifferentialExpression}                    ��Ʒ�������������Ŀ¼
��   ������ A-vs-B.genes.filter.annot.xls                     ��Ʒ��A-vs-B������������
��   ������ A-vs-B.genes.annot.xls                            ��Ʒ��A-vs-B������������
��   ������ A-vs-B.DE.volcano.png                             ��Ʒ��A-vs-B��������ɽͼ
��   ������ A-vs-B.DE.scatter.png                             ��Ʒ��A-vs-B�������ɢ��ͼ
��   ������ geneDE.v.png                                      ������Ʒ��������ͳ��ͼ������
��   ������ geneDE.h.png                                      ������Ʒ��������ͳ��ͼ������
��   ������ geneDE.stat                                       ������Ʒ��������ͳ�Ʊ�
HTML_cont
}

if($opts{Gde} ne "none" && scalar(@group_lab) >= 2){
	print HTML <<HTML_cont;
������ $folders{GroupsDifferentialExpression}                     ����������������Ŀ¼
��   ������ A-vs-B.genes.filter.annot.xls                     �����A-vs-B������������
��   ������ A-vs-B.genes.annot.xls                            �����A-vs-B������������
��   ������ A-vs-B.DE.volcano.png                             �����A-vs-B��������ɽͼ
��   ������ geneDE.v.png                                      ���з����������ͳ��ͼ������
��   ������ geneDE.h.png                                      ���з����������ͳ��ͼ������
��   ������ geneDE.stat                                       ���з����������ͳ�Ʊ�
HTML_cont
}

if($opts{isAnnot} eq "yes" || $opts{isPredict} eq "yes"){
	if($opts{isAnnot} eq "yes"){
		print HTML <<HTML_cont;
������ $folders{CircBaseAnnotation}                               ���ݿ�ע�ͽ��Ŀ¼
��   ������ circBase_annotation.xls                           ��״RNAע����Ϣ��
��   ������ circ_candidates.info.annot.xls                    ȫ�廷״RNA����ͳ�Ʊ�
��   ������ exist.circ.info.annot.xls                         �Ѵ��ڻ�״RNA����ͳ�Ʊ�
��   ������ novel.circ.info.annot.xls                         ��Ԥ�⻷״RNA����ͳ�Ʊ�
��   ������ exist.type.png                                    �Ѵ��ڻ�״RNA���ͷֲ�
��   ������ novel.type.png                                    ��Ԥ�⻷״RNA���ͷֲ�
��   ������ exist.len.png                                     �Ѵ��ڻ�״RNA���ȷֲ�
��   ������ novel.len.png                                     ��Ԥ�⻷״RNA���ȷֲ�
��   ������ exist.chr.png                                     �Ѵ��ڻ�״RNAȾɫ��ֲ�
��   ������ novel.chr.png                                     ��Ԥ�⻷״RNAȾɫ��ֲ�
��   ������ exist.target.stat                                 ��״RNA�Ѵ��ڰ����ϵͳ�Ʊ�
��   ������ exist.target.aln.annot.xls                        ��״RNA�Ѵ��ڰ����ϵ��Ϣ��
��   ������ exist.target.aln.annot_index_mir.xls              ��״RNA�Ѵ��ڰ����ϵ��Ϣ����СRNA��������
HTML_cont
	}

	if($opts{isPredict} eq "yes"){
		print HTML <<HTML_cont;
������ $folders{TargetPrediction}                                ��״RNA��Ԥ������ϵ���Ŀ¼
��   ������ exist.target.stat                                 ��״RNA��Ԥ������ϵͳ�Ʊ�
��   ������ exist.target.aln.annot.xls                        ��״RNA��Ԥ������ϵ��Ϣ��
��   ������ exist.target.aln.annot_index_mir.xls              ��״RNA��Ԥ������ϵ��Ϣ����СRNA��������
HTML_cont
	}
	
	if($opts{isMirTar} eq "yes"){
		print HTML <<HTML_cont;
������ $folders{MirTarget}                                       miTarBase�����ϵ���Ŀ¼
��   ������ exist.target.stat                                 miTarBase�����ϵͳ�Ʊ�
��   ������ exist.target.aln.annot.xls                        miTarBase�����ϵ��Ϣ��
��   ������ exist.target.aln.annot_index_mir.xls              miTarBase�����ϵ��Ϣ����СRNA��������
HTML_cont
	}
	
	print HTML <<HTML_cont;
������ $folders{Cytoscape}                                       Cytoscape�����ļ�Ŀ¼
��   ������ exist.circ.node                                   �Ѵ��ڻ�״RNA�б�
��   ������ novel.circ.node                                   ��Ԥ�⻷״RNA�б�
��   ������ exist_circRNA_miRNA.edge                          ��״RNA�Ѵ��ڰ����ϵ�б�
HTML_cont

	if($opts{isPredict} eq "yes"){
		print HTML <<HTML_cont;
��   ������ novel_circRNA_miRNA.edge                          ��״RNA��Ԥ������ϵ�б�
HTML_cont
	}
	
	if($opts{isMirTar} eq "yes"){
		print HTML <<HTML_cont;
��   ������ mRNA.node                                         mRNA�б�
��   ������ mRNA_miRNA.edge                                   miTarBase�����ϵ�б�
HTML_cont
	}
	
	print HTML <<HTML_cont;
��   ������ miRNA.nodes                                       СRNA�б�
HTML_cont
}

print HTML <<HTML_cont;
������ Page_Config                                        ���ⱨ������ļ�Ŀ¼
��   ������ content.html                                      ���ⱨ����������ҳ��
��   ������ image                                             ���ⱨ���ҪͼƬ
��   ������ doc                                               ���ⱨ���Ҫ�����ĵ�
��   ������ css                                               ���ⱨ����ʽ��������ļ�
��   ������ js                                                ���ⱨ����ҳ�ű�
������ index.html                                         ���ⱨ������
				</pre>
			</section>
		</div>

		<!-- �����ĵ����� -->
		<div id="show_help">
			<h3>�����ĵ�</h3>
			<iframe id="help_page" name="help_page" src="http://www.genedenovo.com/"></iframe>
		</div>
		
		<!-- JS�����ʼ�� -->
		<script type="text/javascript">
			\$(document).ready(function() {
				\$("#report_body").jumpto({
					innerWrapper: "section",
					firstLevel: "> h3",
					secondLevel: "> h5",
					offset: 0,
					anchorTopPadding: 0,
					animate: 600,
					showTitle: "Ŀ¼",
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
		<!-- ������Ϣ -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>���ϰ����� ��״RNA���� ���ⱨ��</title>
		
		<!-- CSS�ĵ� -->
		<link rel="stylesheet" type="text/css" href="Page_Config/css/index.css" />
		
		<!-- JS�ű� -->
		<script src="Page_Config/js/jquery-1.9.1-min.js"></script>
	</head>
	<body>
		<!-- ���ⱨ��ҳü -->
		<section>
			<div id="header_banner">
				<div id="banner_logo"></div>
				<div id="banner_title">���ϰ����� <span> ��״RNA���� </span> ���ⱨ��</div>
				<div id="banner_bg_circRNA"></div>
			</div>
		</section>
		
		<!-- ���ⱨ�������� -->
		<section>
			<iframe id="iframepage" src="Page_Config/content.html"></iframe>
		</section>
		
		<!-- JS�ű���ʼ�� -->
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
