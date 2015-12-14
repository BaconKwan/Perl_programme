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
		<!-- 基本信息 -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>基迪奥生物 WGCNA分析 结题报告</title>
		
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
			<!-- WGCNA分析方法介绍 -->
			<section id="wgcna_info" class="normal_cont">
				<h3>WGCNA介绍<a href="http://labs.genetics.ucla.edu/horvath/CoexpressionNetwork/Rpackages/WGCNA/" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<p>WGCNA（weighted gene co-expression network analysis，权重基因共表达网络分析）是一种分析多个样本基因表达模式的分析方法，可将表达模式相似的基因进行聚类，并分析模块与特定性状或表型之间的关联关系，因此在疾病以及其他性状与基因关联分析等方面的研究中被广泛应用。</p>
				<p>WGCNA算法是构建基因共表达网络的常用算法。我们使用R语言包进行分析。WGCNA算法首先假定基因网络服从无尺度分布，并定义基因共表达相关矩阵、基因网络形成的邻接函数，然后计算不同节点的相异系数，并据此构建分层聚类树(hierarchical clustering tree)，该聚类树的不同分支代表不同的基因模块(module)，模块内基因共表达程度高，而分属不同模块的基因共表达程度低。最后，探索模块与特定表型或疾病的关联关系，最终达到鉴定疾病治疗的靶点基因、基因网络的目的。</p>
			</section>

			<!-- <br /><hr /><br /> -->

			<!-- WGCNA过滤 -->
			<section id="filter" class="normal_cont">
				<h3>数据过滤<a href="doc/filter.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<p>在进行WGCNA分析之前，我们对选用的基因集进行筛选过滤，把低质量的对结果造成不稳定影响的基因或样品从中去掉，提高网络构建的精度。</p>
				<p>过滤掉的基因列表： <a href="../1.filter/0.removeGene.xls" target="_blank"> 0.removeGene.xls </a></p>
				<p>过滤掉的样本列表： <a href="../1.filter/0.removeSample.xls" target="_blank"> 0.removeSample.xls </a></p>
			</section>

			<!-- <br /><hr /><br /> -->

			<!-- WGCNA模块划分 -->
			<section id="module_construction" class="normal_cont">
				<h3>模块划分<a href="doc/module_construction.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
				<p>WGCNA算法首先假定基因网络服从无尺度网络分布（scale-free networks），即连接节点个数的对数（log(i)）与此节点出现概率的对数值（log(p(i))）为负相关关系。因此，构建WGCNA网络首先要计算基因间的表达相关系数，然后寻找使数据整体符合无尺度分布的power值（即找到最优的数值对基因间表达量的相关系数取n次幂），构建基因聚类树，并根据基因间的聚类关系进行基因模块的划分。再根据模块特征值的相似度对表达模式相近的模块进行合并。</p>
				<p>本次分析选用的特征参数如下：</p>
				<p>Power值： $wgcna{softPower}</p>
				<p>相似度： $wgcna{disSimilarity}</p>
				<p>基因-模块对应关系列表： <a href="../2.module_construction/4.netcolor2gene.xls" target="_blank"> 4.netcolor2gene.xls </a></p>
				<div id="parentVerticalTab1" class="VerticalTab">
					<ul id="resp-tabs-list1" class="resp-tabs-list hor_1">
						<li>样本层次聚类树</li>
						<li>Power值曲线</li>
						<li>模块特征值聚类树</li>
						<li>模块层次聚类树</li>
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

			<!-- <br /><hr /><br /> -->

			<!-- WGCNA模块概况 -->
			<section id="basic_info" class="normal_cont">
				<!--<h3>模块概况<a href="#" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>-->
				<h3>模块概况</h3>
				<p>WGCNA分析可以得到一系列总体上每个模块之间或是样品与模块之间的相关性和聚类关系。</p>
				<p>模块-模块相关性结果： <a href="../3.basic_info/5.ModuleModuleMembership.xls" target="_blank"> 5.ModuleModuleMembership.xls </a></p>
				<p>基因-模块相关性结果： <a href="../3.basic_info/6.geneModuleMembership.xls" target="_blank"> 6.geneModuleMembership.xls </a></p>
				<p>样本表达模式结果： <a href="../3.basic_info/7.SampleExpressionPattern.xls" target="_blank"> 7.SampleExpressionPattern.xls </a></p>
				<div id="parentVerticalTab2" class="VerticalTab">
					<ul id="resp-tabs-list2" class="resp-tabs-list hor_2">
						<li>模块间相关性热图</li>
						<!--<li>模块表达模式二维图</li>-->
						<li>样本表达模式热图</li>
						<li>模块基因聚类热图</li>
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

			<!-- <br /><hr /><br /> -->

			<!-- WGCNA表达模式 -->
			<section id="modules" class="normal_cont">
				<!--<h3>表达模式<a href="#" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>-->
				<h3>表达模式</h3>
				<p>WGCNA分析还可以得到每个模块包含的基因以及这些基因的表达模式等信息。</p>
				<p>基因总列表： <a href="../4.modules/10.all.glist.xls" target="_blank"> 10.all.glist.xls </a></p>
				<p>各模块网络信息（可用于Cytoscape作图<a href="doc/cytoscape.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a>）： <a href="../4.modules/cytoscape/" target="_blank"> Cytoscape输入文件目录 </a></p>
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
			
			<!-- <br /><hr /><br /> -->

			<!-- WGCNA富集分析 -->
			<section id="enrichment" class="normal_cont">
				<h3>富集分析<a href="doc/enrichment.html" target="help_page" onclick="show_help();"><img src="image/help.png" class="help_logo"></a></h3>
HTML_cont

if( -s "$out/5.enrichment/GO" || -s "$out/5.enrichment/KO"){
	if( -s "$out/5.enrichment/GO" ){
		print HTML <<HTML_cont;
				<p>各模块GO富集分析结果：</p>
				<table>
					<tr>
						<th>模块名称</th>
						<th>细胞组分</th>
						<th>分子功能</th>
						<th>生物学过程</th>
						<th>GO 分类表</th>
					</tr>
HTML_cont

		foreach (@files){
			print HTML <<HTML_cont;
					<tr>
						<td>${_}</td>
						<td><a href="../5.enrichment/GO/${_}.C.html" target="_blank">${_}.C</a></td>
						<td><a href="../5.enrichment/GO/${_}.F.html" target="_blank">${_}.F</a></td>
						<td><a href="../5.enrichment/GO/${_}.P.html" target="_blank">${_}.P</a></td>
						<td><a href="../5.enrichment/GO/${_}.secLevel.txt" target="_blank">${_}.secLevel.txt</a></td>
					</tr>
HTML_cont
		}

		print HTML <<HTML_cont;
				</table>
				<p>各模块GO富集分类柱状图：</p>
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
							<a href="../5.enrichment/GO/${_}.secLevel.png" target="_blank">
								<img src="../5.enrichment/GO/${_}.secLevel.png" />
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
				<p>GO富集分析热图：</p>
				<div id="parentVerticalTab5" class="VerticalTab">
					<ul id="resp-tabs-list5" class="resp-tabs-list hor_5">
						<li>P值热图</li>
						<li>Q值热图</li>
						<li>富集因子热图</li>
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
				<p>各模块KO富集分析结果：</p>
				<table>
					<tr>
						<th>模块名称</th>
						<th>Pathway富集结果</th>
						<th>Pathway注释表</th>
						<th>基因ID与K号对照表</th>
					</tr>
HTML_cont

		foreach (@files){
			print HTML <<HTML_cont;
					<tr>
						<td>${_}</td>
						<td><a href="../5.enrichment/KO/${_}.htm" target="_blank">${_}.htm</a></td>
						<td><a href="../5.enrichment/KO/${_}.path.xls" target="_blank">${_}.path.xls</a></td>
						<td><a href="../5.enrichment/KO/${_}.kopath.xls" target="_blank">${_}.kopath.xls</a></td>
					</tr>
HTML_cont
		}

		print HTML <<HTML_cont;
				</table>
				<p>各模块KO富集气泡图：</p>
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
				<p>KO富集分析热图：</p>
				<div id="parentVerticalTab7" class="VerticalTab">
					<ul id="resp-tabs-list7" class="resp-tabs-list hor_7">
						<li>P值热图</li>
						<li>Q值热图</li>
						<li>富集因子热图</li>
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
				<p>Pathway 富集分析汇总表： <a href="../5.enrichment/KO/all.pathway.xls" target="_blank"> all.pathway.xls </a></p>
HTML_cont
	}
}
else{
	print HTML <<HTML_cont;
				<p>没有进行富集分析</p>
HTML_cont
}

print HTML <<HTML_cont;
			</section>
			
			<!-- <br /><hr /><br /> -->

			<!-- 结题报告目录结构 -->
			<section id="catalog" class="normal_cont">
				<h3>目录结构</h3>
				<pre>
upload                                                报告总目录
├── 1.filter                                           过滤结果目录
│   ├── 0.removeGene.xls                                  过滤掉的基因列表
│   └── 0.removeSample.xls                                过滤掉的样本列表
├── 2.module_construction                              模块划分目录
│   ├── 1.sampleClustering.pdf                            样本层次聚类树-矢量图
│   ├── 1.sampleClustering.png                            样本层次聚类树-位图
│   ├── 2.softPower.pdf                                   Power值曲线图-矢量图
│   ├── 2.softPower.png                                   Power值曲线图-位图
│   ├── 3.eigengeneClustering.pdf                         特征值聚类树-矢量图
│   ├── 3.eigengeneClustering.png                         特征值聚类树-位图
│   ├── 4.ModuleTree.pdf                                  模块层次聚类树-矢量图
│   ├── 4.ModuleTree.png                                  模块层次聚类树-位图
│   └── 4.netcolor2gene.xls                               基因-模块对应关系列表
├── 3.basic_info                                       模块概况目录
│   ├── 5.ModuleModuleHeatmap.pdf                         模块间相关性热图-矢量图
│   ├── 5.ModuleModuleHeatmap.png                         模块间相关性热图-位图
│   ├── 5.ModuleModuleMembership.xls                      模块-模块相关性结果
│   ├── 6.geneModuleMembership.xls                        基因-模块相关性结果
│   ├── 7.SampleExpressionHeatmap.pdf                     样本表达模式热图-矢量图
│   ├── 7.SampleExpressionHeatmap.png                     样本表达模式热图-位图图
│   ├── 7.sampleExpressionPattern.xls                     样本表达模式结果
│   ├── 8.networkHeatmap.pdf                              模块基因聚类热图-矢量图
│   └── 8.networkHeatmap.png                              模块基因聚类热图-位图
├── 4.modules                                          表达模式目录
│   ├── 9.*Express.pdf                                    各模块表达模式热图-矢量图
│   ├── 9.*Express.png                                    各模块表达模式热图-位图
│   ├── 10.all.glit.xls                                   基因总列表
│   ├── 10.*glist.xls                                     各模块基因列表
│   └── cytoscape                                         Cytoscape输入文件目录
│       ├── 11.CytoscapeInput-nodes-*.txt                     各模块网络节点文件
│       └── 11.CytoscapeInput-edges-*.txt                     各模块网络节点关系文件
├── 5.enrichment                                       富集分析目录
│   ├── GO                                                GO 富集分析结果目录
│   │   ├── *.secLevel.txt                                   各模块基因集 GO 分类表
│   │   ├── *.secLevel.svg                                   各模块基因集 GO 分类统计图-矢量图
│   │   ├── *.secLevel.png                                   各模块基因集 GO 分类统计图-位图
│   │   ├── *.C.png                                          各模块基因集 Go Cellular Component 富集分析有向无环图
│   │   ├── *.F.png                                          各模块基因集 Go Molecular Function 富集分析有向无环图
│   │   ├── *.P.png                                          各模块基因集 Go Biological Process 富集分析有向无环图
│   │   ├── *.C.xls                                          各模块基因集 Go Cellular Component 富集分析结果
│   │   ├── *.F.xls                                          各模块基因集 Go Molecular Function 富集分析结果
│   │   ├── *.P.xls                                          各模块基因集 Go Biological Process 富集分析结果
│   │   ├── *.C.html                                         各模块基因集 Go Cellular Component 富集分析报告
│   │   ├── *.F.html                                         各模块基因集 Go Molecular Function 富集分析报告
│   │   ├── *.P.html                                         各模块基因集 Go Biological Process 富集分析报告
│   │   ├── pv.go.pdf                                        GO 富集分析P值热图-矢量图
│   │   ├── pv.go.png                                        GO 富集分析P值热图-位图
│   │   ├── qv.go.pdf                                        GO 富集分析Q值热图-矢量图
│   │   ├── qv.go.png                                        GO 富集分析Q值热图-位图
│   │   ├── rf.go.pdf                                        GO 富集分析富集因子热图-矢量图
│   │   ├── rf.go.png                                        GO 富集分析富集因子热图-位图
│   └── KO                                                KO 富集分析结果目录
│        ├── all.pathway.xls                                  Pathway 富集分析汇总表
│        ├── pv.kegg.pdf                                      Pathway 富集分析P值热图-矢量图
│        ├── pv.kegg.png                                      Pathway 富集分析P值热图-位图
│        ├── qv.kegg.pdf                                      Pathway 富集分析Q值热图-矢量图
│        ├── qv.kegg.png                                      Pathway 富集分析Q值热图-位图
│        ├── rf.kegg.pdf                                      Pathway 富集分析富集因子热图-矢量图
│        ├── rf.kegg.png                                      Pathway 富集分析富集因子热图-位图
│        ├── *.kopath .xls                                     各模块基因集 KO 列表
│        ├── *.path.xls                                       各模块基因集 Pathway 富集分析结果
│        ├── *.path.png                                       各模块基因集 Pathway 富集分析气泡图
│        ├── *_map                                            各模块基因集 Pathway 富集分析通路图
│        └── *.htm                                            各模块基因集 Pathway 富集分析报告
├── Page_Config                                        结题报告相关文件目录
│   ├── content.html                                      结题报告主题内容页面
│   ├── css                                               结题报告样式设置相关文件
│   ├── doc                                               结题报告必要帮助文档
│   ├── image                                             结题报告必要图片
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
		<!-- 基本信息 -->
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
		<title>基迪奥生物 WGCNA分析 结题报告</title>
		
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
				<div id="banner_title">基迪奥生物 <span> WGCNA分析 </span> 结题报告</div>
				<div id="banner_pic"></div>
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
