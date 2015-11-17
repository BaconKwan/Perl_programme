#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.2
#	Create date:	2015-09-22
#	Usage:	generate HTML report for WGCNA

use strict;
use warnings;
use File::Basename qw/basename dirname/;
use File::Spec::Functions qw/rel2abs/;

die "perl $0 <out_dir> <WGCNA.options>\n" if(@ARGV != 2);

my ($out, $option_file) = @ARGV;
my $bin_file = rel2abs($0);
my $base_dir = dirname($bin_file);

#################################### read wgcna options ###########################################

my %wgcna;
open IN, "$option_file" || die $!;
while(<IN>){
	chomp;
	my @tmp = split /\s*=\s*/;
	$wgcna{$tmp[0]} = $tmp[1];
}
close IN;
$wgcna{disSimilarity} = 1 - $wgcna{disSimilarity};

mkdir "$out/Page_Config";
mkdir "$out/Page_Config/image"; system("cp $base_dir/Page_Config_All/image_wgcna/* $out/Page_Config/image/ -rf");
mkdir "$out/Page_Config/doc"; system("cp $base_dir/Page_Config_All/doc_wgcna/* $out/Page_Config/doc/ -rf");
mkdir "$out/Page_Config/js"; system("cp $base_dir/Page_Config_All/js/*-min.js $out/Page_Config/js/ -rf");
mkdir "$out/Page_Config/css"; system("cp $base_dir/Page_Config_All/css/* $out/Page_Config/css/ -rf");

#################################### generate content HTML code ###########################################

open HTML, "> $out/Page_Config/content.html" || die $!;
print HTML <<HTML_cont;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<!-- ������Ϣ -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>���ϰ����� WGCNA���� ���ⱨ��</title>
		
		<!-- CSS�ĵ� -->
		<link rel="stylesheet" type="text/css" href="css/report.css" />
		<link rel="stylesheet" type="text/css" href="css/jumpto.css" />
		<link rel="stylesheet" type="text/css" href="css/easy-responsive-tabs.css" />
		
		<!-- JS�ű� -->
		<script src="js/jquery-1.9.1/jquery.min.js"></script>
		<script src="js/modernizr.js"></script>
		<script src="js/jquery.jumpto.js"></script>
		<script src="js/jquery.nicescroll.min.js"></script>
		<script src="js/easyResponsiveTabs.js"></script>
		<script src="js/show_help.js"></script>
		
		
	</head>
	<body>
		<div id="report_body">
			<!-- WGCNA������������ -->
			<section id="wgcna_info" class="normal_cont">
				<h3>WGCNA����<a href="http://labs.genetics.ucla.edu/horvath/CoexpressionNetwork/Rpackages/WGCNA/" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<p>WGCNA��weighted gene co-expression network analysis��Ȩ�ػ��򹲱�������������һ�ַ����������������ģʽ�ķ����������ɽ����ģʽ���ƵĻ�����о��࣬������ģ�����ض���״�����֮��Ĺ�����ϵ������ڼ����Լ�������״�������������ȷ�����о��б��㷺Ӧ�á�</p>
				<p>WGCNA�㷨�ǹ������򹲱������ĳ����㷨������ʹ��R���԰����з�����WGCNA�㷨���ȼٶ�������������޳߶ȷֲ�����������򹲱����ؾ��󡢻��������γɵ��ڽӺ�����Ȼ����㲻ͬ�ڵ������ϵ�������ݴ˹����ֲ������(hierarchical clustering tree)���þ������Ĳ�ͬ��֧����ͬ�Ļ���ģ��(module)��ģ���ڻ��򹲱��̶ȸߣ���������ͬģ��Ļ��򹲱��̶ȵ͡����̽��ģ�����ض����ͻ򼲲��Ĺ�����ϵ�����մﵽ�����������Ƶİе���򡢻��������Ŀ�ġ�</p>
			</section>

			<br /><hr /><br />

			<!-- WGCNA���� -->
			<section id="filter" class="normal_cont">
				<h3>���ݹ���<a href="doc/wgcna_filter.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<p>�ڽ���WGCNA����֮ǰ�����Ƕ�ѡ�õĻ��򼯽���ɸѡ���ˣ��ѵ������ĶԽ����ɲ��ȶ�Ӱ��Ļ������Ʒ����ȥ����������繹���ľ��ȡ�</p>
				<p>���˵��Ļ����б� <a href="../1.filter/0.removeGene.xls"> 0.removeGene.xls </a></p>
				<p>���˵��������б� <a href="../1.filter/0.removeSample.xls"> 0.removeSample.xls </a></p>
			</section>

			<br /><hr /><br />

			<!-- WGCNAģ�黮�� -->
			<section id="module_construction" class="normal_cont">
				<h3>ģ�黮��<a href="doc/wgcna_assess.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<p>WGCNA�㷨���ȼٶ�������������޳߶�����ֲ���scale-free networks���������ӽڵ�����Ķ�����log(i)����˽ڵ���ָ��ʵĶ���ֵ��log(p(i))��Ϊ����ع�ϵ����ˣ�����WGCNA��������Ҫ��������ı�����ϵ����Ȼ��Ѱ��ʹ������������޳߶ȷֲ���powerֵ�����ҵ����ŵ���ֵ�Ի�������������ϵ��ȡn���ݣ�����������������������ݻ����ľ����ϵ���л���ģ��Ļ��֡��ٸ���ģ������ֵ�����ƶȶԱ��ģʽ�����ģ����кϲ���</p>
				<p>���η���ѡ�õ������������£�</p>
				<p>Powerֵ�� $wgcna{softPower}</p>
				<p>���ƶȣ� $wgcna{disSimilarity}</p>
				<p>����-ģ���Ӧ��ϵ�б� <a href="../2.module_construction/4.netcolor2gene.xls"> 4.netcolor2gene.xls </a></p>
				<div id="parentVerticalTab1" class="VerticalTab">
					<ul id="resp-tabs-list1" class="resp-tabs-list hor_1">
						<li>������ξ�����</li>
						<li>Powerֵ����</li>
						<li>ģ������ֵ������</li>
						<li>ģ���ξ�����</li>
					</ul>
					<div id="resp-tabs-container1" class="resp-tabs-container hor_1">
						<div>
							<a href="../2.module_construction/1.sampleClustering.png" target="_blank">
								<img src="../2.module_construction/1.sampleClustering.png" />
							</a>
						</div>
						<div>
							<a href="../2.module_construction/2.softPower.png" target="_blank">
								<img src="../2.module_construction/2.softPower.png" />
							</a>
						</div>
						<div>
							<a href="../2.module_construction/3.eigengeneClustering.png" target="_blank">
								<img src="../2.module_construction/3.eigengeneClustering.png" />
							</a>
						</div>
						<div>
							<a href="../2.module_construction/4.ModuleTree.png" target="_blank">
								<img src="../2.module_construction/4.ModuleTree.png" />
							</a>
						</div>
					</div>
				</div>
			</section>

			<br /><hr /><br />

			<!-- WGCNAģ��ſ� -->
			<section id="basic_info" class="normal_cont">
				<!--<h3>ģ��ſ�<a href="#" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>-->
				<h3>ģ��ſ�</h3>
				<p>WGCNA�������Եõ�һϵ��������ÿ��ģ��֮�������Ʒ��ģ��֮�������Ժ;����ϵ��</p>
				<p>ģ��-ģ������Խ���� <a href="../3.basic_info/5.ModuleModuleMembership.xls"> 5.ModuleModuleMembership.xls </a></p>
				<p>����-ģ������Խ���� <a href="../3.basic_info/6.geneModuleMembership.xls"> 6.geneModuleMembership.xls </a></p>
				<p>�������ģʽ����� <a href="../3.basic_info/7.SampleExpressionPattern.xls"> 7.SampleExpressionPattern.xls </a></p>
				<div id="parentVerticalTab2" class="VerticalTab">
					<ul id="resp-tabs-list2" class="resp-tabs-list hor_2">
						<li>ģ����������ͼ</li>
						<!--<li>ģ����ģʽ��άͼ</li>-->
						<li>�������ģʽ��ͼ</li>
						<li>ģ����������ͼ</li>
					</ul>
					<div id="resp-tabs-container2" class="resp-tabs-container hor_2">
						<div>
							<a href="../3.basic_info/5.ModuleModuleHeatmap.png" target="_blank">
								<img src="../3.basic_info/5.ModuleModuleHeatmap.png" />
							</a>
						</div>
						<!--
						<div>
							<a href="../3.basic_info/5.ModuleModuleMatrix.png" target="_blank">
								<img src="../3.basic_info/5.ModuleModuleMatrix.png" />
							</a>
						</div>
						-->
						<div>
							<a href="../3.basic_info/7.SampleExpressionHeatmap.png" target="_blank">
								<img src="../3.basic_info/7.SampleExpressionHeatmap.png" />
							</a>
						</div>
						<div>
							<a href="../3.basic_info/8.networkHeatmap.png" target="_blank">
								<img src="../3.basic_info/8.networkHeatmap.png" />
							</a>
						</div>
					</div>
				</div>
			</section>

			<br /><hr /><br />

			<!-- WGCNA���ģʽ -->
			<section id="modules" class="normal_cont">
				<!--<h3>���ģʽ<a href="#" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>-->
				<h3>���ģʽ</h3>
				<p>WGCNA���������Եõ�ÿ��ģ������Ļ����Լ���Щ����ı��ģʽ����Ϣ��</p>
				<p>�������б� <a href="../4.modules/10.all.glist.xls" target="_blank"> 10.all.glist.xls </a></p>
				<p>��ģ��������Ϣ��������Cytoscape��ͼ<a href="doc/wgcna_cytoscape.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>���� <a href="../4.modules/cytoscape/" target="_blank"> Cytoscape�����ļ�Ŀ¼ </a></p>
				<div id="parentVerticalTab3" class="VerticalTab">
					<ul id="resp-tabs-list3" class="resp-tabs-list hor_3">
HTML_cont

my @files = `ls $out/4.modules/9.*Express.pdf`;
foreach (@files){
	chomp;
	$_ =~ s/^.*9\.//;
	$_ =~ s/Express\.pdf$//;
	print HTML <<HTML_cont;
						<li>$_</li>
HTML_cont
}
print HTML <<HTML_cont;
					</ul>
					<div id="resp-tabs-container3" class="resp-tabs-container hor_3">
HTML_cont
foreach (@files){
	print HTML <<HTML_cont;
						<div>
							<a href="../4.modules/9.${_}Express.png" target="_blank">
								<img src="../4.modules/9.${_}Express.png" />
							</a>
						</div>
HTML_cont
}

print HTML <<HTML_cont;
					</div>
				</div>
			</section>
			
			<br /><hr /><br />

			<!-- WGCNA�������� -->
			<section id="enrichment" class="normal_cont">
				<h3>��������<a href="doc/wgcna_enrich.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
HTML_cont

if( -s "$out/5.enrichment/GO" || -s "$out/5.enrichment/KO"){
	if( -s "$out/5.enrichment/GO" ){
		print HTML <<HTML_cont;
				<p>��ģ��GO�������������</p>
				<table>
					<tr>
						<th>ģ������</th>
						<th>ϸ�����</th>
						<th>���ӹ���</th>
						<th>����ѧ����</th>
						<th>GO �����</th>
					</tr>
HTML_cont

		foreach (@files){
			print HTML <<HTML_cont;
					<tr>
						<td>${_}</td>
						<td><a href="../5.enrichment/GO/${_}_C.html" target="_blank">${_}_C</a></td>
						<td><a href="../5.enrichment/GO/${_}_F.html" target="_blank">${_}_F</a></td>
						<td><a href="../5.enrichment/GO/${_}_P.html" target="_blank">${_}_P</a></td>
						<td><a href="../5.enrichment/GO/${_}.go.xls" target="_blank">${_}.go.xls</a></td>
					</tr>
HTML_cont
		}

		print HTML <<HTML_cont;
				</table>
				<p>��ģ��GO����������״ͼ��</p>
				<div id="parentVerticalTab4" class="VerticalTab">
					<ul id="resp-tabs-list4" class="resp-tabs-list hor_4">
HTML_cont

		foreach (@files){
			print HTML <<HTML_cont;
						<li>$_</li>
HTML_cont
		}
		print HTML <<HTML_cont;
					</ul>
					<div id="resp-tabs-container4" class="resp-tabs-container hor_4">
HTML_cont
		foreach (@files){
			print HTML <<HTML_cont;
						<div>
							<a href="../5.enrichment/GO/${_}.go.png" target="_blank">
								<img src="../5.enrichment/GO/${_}.go.png" />
							</a>
						</div>
HTML_cont
		}

		print HTML <<HTML_cont;
					</div>
				</div>
HTML_cont
		if( -s "$out/5.enrichment/GO/pv.go.png" && -s "$out/5.enrichment/GO/qv.go.png" && -s "$out/5.enrichment/GO/rf.go.png"){
			print HTML <<HTML_cont;
				<p>GO����������ͼ��</p>
				<div id="parentVerticalTab5" class="VerticalTab">
					<ul id="resp-tabs-list5" class="resp-tabs-list hor_5">
						<li>Pֵ��ͼ</li>
						<li>Qֵ��ͼ</li>
						<li>����������ͼ</li>
					</ul>
					<div id="resp-tabs-container5" class="resp-tabs-container hor_5">
						<div>
							<a href="../5.enrichment/GO/pv.go.png" target="_blank">
								<img src="../5.enrichment/GO/pv.go.png" />
							</a>
						</div>
						<div>
							<a href="../5.enrichment/GO/qv.go.png" target="_blank">
								<img src="../5.enrichment/GO/qv.go.png" />
							</a>
						</div>
						<div>
							<a href="../5.enrichment/GO/rf.go.png" target="_blank">
								<img src="../5.enrichment/GO/rf.go.png" />
							</a>
						</div>
					</div>
				</div>
HTML_cont
		}
	}

	if( -s "$out/5.enrichment/KO" ){
		print HTML <<HTML_cont;
				<p>��ģ��KO�������������</p>
				<table>
					<tr>
						<th>ģ������</th>
						<th>Pathway�������</th>
						<th>Pathwayע�ͱ�</th>
						<th>KOע�ͱ�</th>
					</tr>
HTML_cont

		foreach (@files){
			print HTML <<HTML_cont;
					<tr>
						<td>${_}</td>
						<td><a href="../5.enrichment/KO/${_}.htm" target="_blank">${_}.htm</a></td>
						<td><a href="../5.enrichment/KO/${_}.path.xls" target="_blank">${_}.path.xls</a></td>
						<td><a href="../5.enrichment/KO/${_}.ko.xls"target="_blank">${_}.ko.xls</a></td>
					</tr>
HTML_cont
		}

		print HTML <<HTML_cont;
				</table>
				<p>��ģ��KO��������ͼ��</p>
				<div id="parentVerticalTab6" class="VerticalTab">
					<ul id="resp-tabs-list6" class="resp-tabs-list hor_6">
HTML_cont

		foreach (@files){
			print HTML <<HTML_cont;
						<li>$_</li>
HTML_cont
		}
		print HTML <<HTML_cont;
					</ul>
					<div id="resp-tabs-container6" class="resp-tabs-container hor_6">
HTML_cont
		foreach (@files){
			print HTML <<HTML_cont;
						<div>
							<a href="../5.enrichment/KO/${_}.path.png" target="_blank">
								<img src="../5.enrichment/KO/${_}.path.png" />
							</a>
						</div>
HTML_cont
		}

		print HTML <<HTML_cont;
					</div>
				</div>
HTML_cont
		if( -s "$out/5.enrichment/KO/pv.kegg.png" && -s "$out/5.enrichment/KO/qv.kegg.png" && -s "$out/5.enrichment/KO/rf.kegg.png"){
			print HTML <<HTML_cont;
				<p>KO����������ͼ��</p>
				<div id="parentVerticalTab7" class="VerticalTab">
					<ul id="resp-tabs-list7" class="resp-tabs-list hor_7">
						<li>Pֵ��ͼ</li>
						<li>Qֵ��ͼ</li>
						<li>����������ͼ</li>
					</ul>
					<div id="resp-tabs-container7" class="resp-tabs-container hor_7">
						<div>
							<a href="../5.enrichment/KO/pv.kegg.png" target="_blank">
								<img src="../5.enrichment/KO/pv.kegg.png" />
							</a>
						</div>
						<div>
							<a href="../5.enrichment/KO/qv.kegg.png" target="_blank">
								<img src="../5.enrichment/KO/qv.kegg.png" />
							</a>
						</div>
						<div>
							<a href="../5.enrichment/KO/rf.kegg.png" target="_blank">
								<img src="../5.enrichment/KO/rf.kegg.png" />
							</a>
						</div>
					</div>
				</div>
HTML_cont
		}
		print HTML <<HTML_cont;
				<p>Pathway �����������ܱ� <a href="../5.enrichment/KO/all.pathway.xls" target="_blank"> all.pathway.xls </a></p>
HTML_cont
	}
}
else{
	print HTML <<HTML_cont;
				<p>û�н��и�������</p>
HTML_cont
}

print HTML <<HTML_cont;
			</section>
			
			<br /><hr /><br />

			<!-- ���ⱨ��Ŀ¼�ṹ -->
			<section id="catalog" class="normal_cont">
				<h3>Ŀ¼�ṹ</h3>
				<pre>
upload                                                ������Ŀ¼
������ 1.filter                                           ���˽��Ŀ¼
��   ������ 0.removeGene.xls                                  ���˵��Ļ����б�
��   ������ 0.removeSample.xls                                ���˵��������б�
������ 2.module_construction                              ģ�黮��Ŀ¼
��   ������ 1.sampleClustering.pdf                            ������ξ�����-ʸ��ͼ
��   ������ 1.sampleClustering.png                            ������ξ�����-λͼ
��   ������ 2.softPower.pdf                                   Powerֵ����ͼ-ʸ��ͼ
��   ������ 2.softPower.png                                   Powerֵ����ͼ-λͼ
��   ������ 3.eigengeneClustering.pdf                         ����ֵ������-ʸ��ͼ
��   ������ 3.eigengeneClustering.png                         ����ֵ������-λͼ
��   ������ 4.ModuleTree.pdf                                  ģ���ξ�����-ʸ��ͼ
��   ������ 4.ModuleTree.png                                  ģ���ξ�����-λͼ
��   ������ 4.netcolor2gene.xls                               ����-ģ���Ӧ��ϵ�б�
������ 3.basic_info                                       ģ��ſ�Ŀ¼
��   ������ 5.ModuleModuleHeatmap.pdf                         ģ����������ͼ-ʸ��ͼ
��   ������ 5.ModuleModuleHeatmap.png                         ģ����������ͼ-λͼ
��   ������ 5.ModuleModuleMembership.xls                      ģ��-ģ������Խ��
��   ������ 6.geneModuleMembership.xls                        ����-ģ������Խ��
��   ������ 7.SampleExpressionHeatmap.pdf                     �������ģʽ��ͼ-ʸ��ͼ
��   ������ 7.SampleExpressionHeatmap.png                     �������ģʽ��ͼ-λͼͼ
��   ������ 7.sampleExpressionPattern.xls                     �������ģʽ���
��   ������ 8.networkHeatmap.pdf                              ģ����������ͼ-ʸ��ͼ
��   ������ 8.networkHeatmap.png                              ģ����������ͼ-λͼ
������ 4.modules                                          ���ģʽĿ¼
��   ������ 9.*Express.pdf                                    ��ģ����ģʽ��ͼ-ʸ��ͼ
��   ������ 9.*Express.png                                    ��ģ����ģʽ��ͼ-λͼ
��   ������ 10.all.glit.xls                                   �������б�
��   ������ 10.*glist.xls                                     ��ģ������б�
��   ������ cytoscape                                         Cytoscape�����ļ�Ŀ¼
��       ������ 11.CytoscapeInput-nodes-*.txt                     ��ģ������ڵ��ļ�
��       ������ 11.CytoscapeInput-edges-*.txt                     ��ģ������ڵ��ϵ�ļ�
������ 5.enrichment                                       ��������Ŀ¼
��   ������ GO                                                GO �����������Ŀ¼
��   ��   ������ *.wego.xls                                       ��ģ����� GO ���ܱ�
��   ��   ������ *.go.xls                                         ��ģ����� GO �����
��   ��   ������ *.go.svg                                         ��ģ����� GO ����ͳ��ͼ-ʸ��ͼ
��   ��   ������ *.go.png                                         ��ģ����� GO ����ͳ��ͼ-λͼ
��   ��   ������ *_C.png                                          ��ģ����� Go Cellular Component �������������޻�ͼ
��   ��   ������ *_F.png                                          ��ģ����� Go Molecular Function �������������޻�ͼ
��   ��   ������ *_P.png                                          ��ģ����� Go Biological Process �������������޻�ͼ
��   ��   ������ *_C.xls                                          ��ģ����� Go Cellular Component �����������
��   ��   ������ *_F.xls                                          ��ģ����� Go Molecular Function �����������
��   ��   ������ *_P.xls                                          ��ģ����� Go Biological Process �����������
��   ��   ������ *_C.html                                         ��ģ����� Go Cellular Component ������������
��   ��   ������ *_F.html                                         ��ģ����� Go Molecular Function ������������
��   ��   ������ *_P.html                                         ��ģ����� Go Biological Process ������������
��   ��   ������ pv.go.pdf                                        GO ��������Pֵ��ͼ-ʸ��ͼ
��   ��   ������ pv.go.png                                        GO ��������Pֵ��ͼ-λͼ
��   ��   ������ qv.go.pdf                                        GO ��������Qֵ��ͼ-ʸ��ͼ
��   ��   ������ qv.go.png                                        GO ��������Qֵ��ͼ-λͼ
��   ��   ������ rf.go.pdf                                        GO ������������������ͼ-ʸ��ͼ
��   ��   ������ rf.go.png                                        GO ������������������ͼ-λͼ
��   ��   ������ GOViewList.html                                  GO ����������ҳ��������
��   ��   ������ GOView.html                                      GO ����������ҳ����
��   ������ KO                                                KO �����������Ŀ¼
��       ������ all.pathway.xls                                   Pathway �����������ܱ�
��       ������ pv.kegg.pdf                                       Pathway ��������Pֵ��ͼ-ʸ��ͼ
��       ������ pv.kegg.png                                       Pathway ��������Pֵ��ͼ-λͼ
��       ������ qv.kegg.pdf                                       Pathway ��������Qֵ��ͼ-ʸ��ͼ
��       ������ qv.kegg.png                                       Pathway ��������Qֵ��ͼ-λͼ
��       ������ rf.kegg.pdf                                       Pathway ������������������ͼ-ʸ��ͼ
��       ������ rf.kegg.png                                       Pathway ������������������ͼ-λͼ
��       ������ *.ko.xls                                          ��ģ����� KO �б�
��       ������ *.path.xls                                        ��ģ����� Pathway �����������
��       ������ *.path.png                                        ��ģ����� Pathway ������������ͼ
��       ������ *_map                                             ��ģ����� Pathway ��������ͨ·ͼ
��       ������ *.htm                                             ��ģ����� Pathway ������������
������ Page_Config                                        ���ⱨ������ļ�Ŀ¼
��   ������ content.html                                      ���ⱨ����������ҳ��
��   ������ css                                               ���ⱨ����ʽ��������ļ�
��   ������ doc                                               ���ⱨ���Ҫ�����ĵ�
��   ������ image                                             ���ⱨ���ҪͼƬ
��   ������ js                                                ���ⱨ����ҳ�ű�
������ index.html                                         ���ⱨ������
				</pre>
			</section>
		</div>

		<!-- �����ĵ����� -->
		<div id="show_help">
			<h3>�����ĵ�</h3>
			<iframe id="help_page" name="help_page" src="http://labs.genetics.ucla.edu/horvath/CoexpressionNetwork/Rpackages/WGCNA/"></iframe>
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
				for (var i = 1; i <= 7; i++){
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

#################################### generate index HTML code ###########################################

open INDEX, "> $out/index.html" || die $!;
print INDEX <<HTML_index;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<!-- ������Ϣ -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>���ϰ����� WGCNA���� ���ⱨ��</title>
		
		<!-- CSS�ĵ� -->
		<link rel="stylesheet" type="text/css" href="Page_Config/css/index.css" />
		
		<!-- JS�ű� -->
		<script src="Page_Config/js/jquery-1.9.1/jquery.min.js"></script>
	</head>
	<body>
		<!-- ���ⱨ��ҳü -->
		<section>
			<div id="header_banner">
				<div id="banner_logo"></div>
				<div id="banner_title">���ϰ����� <span> WGCNA���� </span> ���ⱨ��</div>
				<div id="banner_bg"></div>
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