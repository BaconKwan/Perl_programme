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
use File::Basename qw/basename fileparse/;
use File::Spec::Functions qw/rel2abs/;

my %opts;
GetOptions(\%opts, "in=s", "cm=s", "n1=i", "n2=i", "nor=s", "spot:i", "o=s", "ref=s", "pf=s", "komap=s");
&usage unless(defined $opts{in} && defined $opts{ref} && defined $opts{pf} && defined $opts{komap});

## initial arguments
my @in_file = split /,/, $opts{in};
foreach(@in_file){
	if(-s $_){
		$_ = rel2abs($_);
	}
}

$opts{ref} = rel2abs($opts{ref});
$opts{komap} = rel2abs($opts{komap});

$opts{cm} = (defined $opts{cm}) ? $opts{cm} : "stem";
die "Illegal Clustering_Method" unless($opts{cm} eq "stem" || $opts{cm} eq "kmeans");
$opts{cm} = "STEM Clustering Method" if($opts{cm} eq "stem");
$opts{cm} = "K-means" if($opts{cm} eq "kmeans");

if($opts{cm} eq "STEM Clustering Method"){
	$opts{n1} = (defined $opts{n1}) ? $opts{n1} : 20;
}
else{
	$opts{n1} = (defined $opts{n1}) ? $opts{n1} : 10;
}
if($opts{cm} eq "STEM Clustering Method"){
	$opts{n2} = (defined $opts{n2}) ? $opts{n2} : 1;
}
else{
	$opts{n2} = (defined $opts{n2}) ? $opts{n2} : 20;
}
die "Illegal n1 value ( n1 < 1 )" unless($opts{n1} > 0);
die "Illegal n2 value ( n2 < 0 )" unless($opts{n2} >= 0);

$opts{nor} = (defined $opts{nor}) ? $opts{nor} : "log";
die "Illegal Normalize_Data Method" unless($opts{nor} eq "log" || $opts{nor} eq "n" || $opts{nor} eq "i");
$opts{nor} = "Log normalize data" if($opts{nor} eq "log");
$opts{nor} = "Normalize data" if($opts{nor} eq "n");
$opts{nor} = "No normalization" if($opts{nor} eq "i");

$opts{spot} = (defined $opts{spot}) ? "true" : "false";
$opts{o} = (defined $opts{o}) ? $opts{o} : ".";
$opts{o} = rel2abs($opts{o});

## main 
`mkdir -p $opts{o}/stem $opts{o}/stem/input $opts{o}/stem/output $opts{o}/enrich`;
open SH, "> $opts{o}/run.sh" || die $!;
foreach(@in_file){
	my $name = basename($_);
	print SH "ln -s $_ $opts{o}/$name\n";
	open CONF, "> $opts{o}/stem/input/$name" || die $!;
	print CONF
"#Main Input:
Data_File	$opts{o}/$name
Clustering_Method[STEM Clustering Method,K-means]	$opts{cm}
Maximum_Number_of_Model_Profiles	$opts{n1}
Maximum_Unit_Change_in_Model_Profiles_between_Time_Points	$opts{n2}
Number_of_Clusters_K	$opts{n1}
Number_of_Random_Starts	$opts{n2}
Normalize_Data[Log normalize data,Normalize data,No normalization/add 0]	$opts{nor}
Spot_IDs_included_in_the_data_file	$opts{spot}

#Repeat data
Repeat_Data_is_from[Different time periods,The same time period]	Different time periods

#Comparison Data:
Comparison_Minimum_Number_of_genes_in_intersection	5
Comparison_Maximum_Uncorrected_Intersection_pvalue	0.0050

#Filtering:
Maximum_Number_of_Missing_Values	0
Minimum_Correlation_between_Repeats	0.0
Minimum_Absolute_Log_Ratio_Expression	1.0
Change_should_be_based_on[Maximum-Minimum,Difference From 0]	Maximum-Minimum
Pre-filtered_Gene_File	

#Model Profiles
Maximum_Correlation	1.0
Number_of_Permutations_per_Gene	50
Maximum_Number_of_Candidate_Model_Profiles	1000000
Significance_Level	0.05
Correction_Method[Bonferroni,False Discovery Rate,None]	Bonferroni
Permutation_Test_Should_Permute_Time_Point_0	true

#Clustering Profiles:
Clustering_Minimum_Correlation	0.7
Clustering_Minimum_Correlation_Percentile	0.0

#Gene Annotations:
Category_ID_File	
Include_Biological_Process	false
Include_Molecular_Function	false
Include_Cellular_Process	false
Only_include_annotations_with_these_evidence_codes	
Only_include_annotations_with_these_taxon_IDs	

#GO Analysis:
Multiple_hypothesis_correction_method_enrichment[Bonferroni,Randomization]	Randomization
Minimum_GO_level	3
GO_Minimum_number_of_genes	5
Number_of_samples_for_randomized_multiple_hypothesis_correction	500

#Interface Options
Gene_display_policy_on_main_interface[Do not display,Display only selected,Display all]	Do not display
Gene_Color(R,G,B)	204,51,0
Display_Model_Profile	false
Display_Profile_ID	false
Display_details_when_ordering	false
Show_Main_Y-axis_gene_tick_marks	false
Main_Y-axis_gene_tick_interval	1.0
Y-axis_scale_for_genes_on_main_interface_should_be[Gene specific,Profile specific,Global]	Profile specific
Scale_should_be_based_on_only_selected_genes	false
Y-axis_scale_on_details_windows_should_be[Determined automatically,Fixed]	Determined automatically
Y_Scale_Min	-3.0
Y_Scale_Max	3.0
Tick_interval	1.0
X-axis_scale_should_be[Uniform,Based on real time]	Uniform
";
	close CONF;
}
print SH 
"Xvfb :1 &
export DISPLAY=:1
java -mx1024M -jar /home/guanpeikun/bin/trends_analysis/stem/stem.jar -b $opts{o}/stem/input $opts{o}/stem/output
";
foreach(@in_file){
	my $name = basename($_);
	my $tname = (fileparse($_, qr/\.[^.]*/))[0];
	print SH "ln -s $opts{o}/stem/output/${tname}_profiletable.txt $opts{o}/${tname}_profiletable.txt\n";
	print SH "ln -s $opts{o}/stem/output/${tname}_genetable.txt $opts{o}/${tname}_genetable.txt\n";
	print SH "perl /home/guanpeikun/bin/trends_analysis/trends_analysis.pl -gt $opts{o}/${tname}_genetable.txt -pt $opts{o}/${tname}_profiletable.txt -xls $opts{o}/$name -conf $opts{o}/ta.conf -prefix ${tname} -out $opts{o}/enrich\n";
}
close SH;

open CONF, "> $opts{o}/ta.conf" || die $!;
print CONF
"## trends analysis config ##
## programmes path ##
get_ko              =  /Bio/Bin/pipeline/RNA/denovo_2.0/functional/getKO.pl
path_find           =  /Bio/Bin/pipeline/RNA/denovo_2.0/functional/pathfind.pl
komap_nodiff        =  /Bio/Bin/pipeline/RNA/denovo_2.0/functional/keggMap_nodiff.pl
get_wego            =  /home/guanpeikun/bin/kogo_enrich_analysis/getwego.pl
draw_go             =  /Bio/Bin/pipeline/RNA/denovo_2.0/drawGO_black.pl
batik               =  /Bio/Bin/pipeline/RNA/tools/batik-rasterizer.jar
func                =  /Bio/Bin/pipeline/RNA/denovo_2.0/functional/functional_nodiff.pl
gen_html            =  /Bio/Bin/pipeline/RNA/denovo_2.0/functional/genPathHTML.pl
add_desc            =  /home/guanpeikun/bin/trends_analysis/add_desc.pl
draw_png            =  /home/guanpeikun/bin/trends_analysis/draw_trend_analysis.pl
## basic files ##
ref_path            =  $opts{ref}
wego_file           =  $opts{pf}.wego
ko_file             =  $opts{pf}.ko
komap_file          =  $opts{komap}
go_dir              =  $opts{ref}
go_species          =  $opts{pf}
desc_file           =  $opts{pf}.dec.xls
";
close CONF;

`sh $opts{o}/run.sh >> $opts{0}/run.log 2>&1`;
`rm $opts{o}/ta.conf -rf`;
#`sh $opts{o}/enrich/enrich.sh >> $opts{o}/enrich/enrich.log 2>&1`;
print
"
modif $opts{o}/enrich/enrich.sh before run it if necessary 
sh $opts{o}/enrich/enrich.sh >> $opts{o}/enrich/enrich.log 2>&1
\n";

sub usage{
	die"
Usage: perl $0 -in <file1,file2...> -ref <path> -pf <prefix> -komap <path> [options]
Options:
	BASIC
		-in        string       *ready RPKM table files for input, split by \",\"
		-o         string        output dir, default: ./
	GOKEGG ENRICH
		-ref       string       *ref folder path, which is used to store xxx.wego, xxx.ko, xxx.P, xxx.C, xxx.F, xxx.dec.xls, etc.
		-pf        string       *prefix of files in ref folder must be unified, like \"xxx\" above
		-komap     string       *komap absolute path, example: /Bio/Database/Database/kegg/data/map_class/animal_ko_map.tab
		                         [XXX]_ko_map.tab          [XXX] can be replace by fungi, microorganism, plant, prokaryote, etc.
	STEM
		-cm        string        Clustering_Method
		                         stem        -- STEM Clustering Method [default]
		                         kmeans      -- K-means Method
		-n1        int           STEM Clustering Method: Maximum_Number_of_Model_Profiles, default: 20
		                         K-means Method: Number_of_Clusters_K, default: 10
		-n2        int           STEM Clustering Method: Maximum_Unit_Change_in_Model_Profiles_between_Time_Points, default: 1
		                         K-means Method: Number_of_Random_Starts, default: 20
		-nor       string        Normalize_Data Method
		                         log         -- Log normalize data [default]
		                         n           -- Normalize data
		                         i           -- No normalization / add 0
		-spot      boolean       Spot_IDs_included_in_the_data_file, default: false
\n";
}
