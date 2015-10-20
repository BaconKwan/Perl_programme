#!/bin/bash

##########################################################################################################
##                          This shell scripts if for WGCNA automatic pipeline                          ##
##########################################################################################################
##      NOTICE: Since WGCNA is using R and can not be recovered once you disconnect with the server.    ##
##              So, we strongly recommend you using "screen" shell environment.                         ##
##########################################################################################################

## Main Programme

WGCNA=/home/guanpeikun/bin/WGCNA/InModuleWGCNA.r
REPORT=/home/guanpeikun/bin/WGCNA/WGCNA_report.pl

## Parameters for Enrichment

ko=/Bio/Project/PROJECT/GDI0668/pipe_test/ref/sctu27.fa.ko
komap=/Bio/Database/Database/kegg/data/map_class/microorganism_ko_map.tab
wego=/Bio/Project/PROJECT/GDI0668/pipe_test/ref/sctu27.fa.blast.nr.xml.wego
go_dir=/Bio/Project/PROJECT/GDI0668/pipe_test/ref
go_prefix=sctu27.fa
desc=/Bio/Project/PROJECT/GDI0668/pipe_test/ref/sctu27.fa.desc.xls

## Checking Parameter

if [ $# != 2 ]; then 
	echo "sh $0 <exp_matrix> <out_dir>"
	exit 0
else
	if [ ! -s $1 ]; then
		echo "Input expression matrix: $1 is not exists!"
		exit 0
	fi
	if [ ! -d $2 ]; then
		echo "Output directory: $2 is not exists!"
		exit 0
	fi
	if [ ! -s $WGCNA ]; then
		echo "Main programme: $WGCNA is not exists!"
		exit 0
	fi
fi

## Count Down
echo "The pipeline will be started in 5 seconds, please make sure you're using \"screen\" shell environment or you can terminate it with CTRL+C."
for i in `seq 5 -1 1`
do
	echo "${i}.."
	sleep 1.2;
done
echo "Launch at `date`, enjoy yourself!"

##########################################################################################################

## Initialization

EXP_TABLE=$1
OUT_DIR=$2

## Creat Output Directory

echo "==== creat output directorys ===="
mkdir -p $OUT_DIR/1.filter \
         $OUT_DIR/2.feature_evaluation \
         $OUT_DIR/3.basic_info \
         $OUT_DIR/4.modules \
         $OUT_DIR/4.modules/cytoscape \
         $OUT_DIR/5.enrichment

## WGCNA

echo "==== deal with expression matrix ===="
sed -i '2,$s/\t-/\t0/g' $EXP_TABLE
echo "==== WGCNA analysis ===="
Rscript $WGCNA $EXP_TABLE || exit 0;

## Enrichment & integrates information
echo "==== enrichment ===="
for i in `ls 10.*ModuleConnectivity.xls`
do
	name=`basename $i ModuleConnectivity.xls | sed 's/10\.//'`
	cut -f 1 $i | sed '1i\GeneID' > ${name}.glist
	echo "==> processing with ${name}"

	# KO
	if [ -s $ko ]; then
		mkdir -p KO
		cp ${name}.glist KO/${name}.glist
		perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/getKO.pl -glist KO/${name}.glist -bg $ko -outdir KO
		perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/pathfind.pl -fg KO/${name}.ko -bg $ko -komap $komap -output KO/${name}.path
		perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/keggGradient.pl KO/${name}.path 20
		perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/keggMap_nodiff.pl -ko KO/${name}.ko -komap $komap -outdir KO/${name}_map
		rm KO/${name}.glist -rf
	fi

	# GO
	if [ -s $wego ]; then
		mkdir -p GO
		cp ${name}.glist GO/${name}.glist
		perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/getwego.pl GO/${name}.glist $wego > GO/${name}.wego
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist GO/${name}.wego -output GO/${name}.go
		java -jar /Bio/Bin/pipe/RNA/tools/batik-rasterizer.jar -m image/png GO/${name}.go.svg
		rm GO/${name}.glist -rf
	fi
done

# Report
if [ -s $ko ]; then
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/genPathHTML.pl -indir KO
	perl /home/guanpeikun/bin/WGCNA/enrichmentHeatmap.pl KO kegg
fi

if [ -s ${go_dir}/${go_prefix}.P ] && [ -s ${go_dir}/${go_prefix}.F ] && [ -s ${go_dir}/${go_prefix}.C ]; then
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/functional_nodiff.pl -go -gldir ./ -sdir $go_dir -species $go_prefix -outdir ./
	perl /home/guanpeikun/bin/WGCNA/enrichmentHeatmap.pl GO go
fi

# Add desc & info
perl /home/guanpeikun/bin/WGCNA/add_info.pl $EXP_TABLE *.glist
if [ -s $desc ]; then
	perl /home/guanpeikun/bin/WGCNA/add_desc4WGCNA.pl $desc 1 *.glist
fi

# Generate all.pathway.xls
if [ -s $ko ]; then
	cut -f 1 all.glist > KO/all.glist
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/getKO.pl -glist KO/all.glist -bg $ko -outdir KO
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/pathfind.pl -fg KO/all.ko -bg $ko -komap $komap -output KO/all.path
	perl /home/guanpeikun/bin/WGCNA/path_sta.pl -i KO -o KO/all.pathway.xls && rm KO/all.glist KO/all.ko KO/all.path -rf
fi

# Rename files
for i in `ls KO/*.path`; do mv $i $i.xls; done
for i in `ls KO/*.ko`; do mv $i $i.xls; done
for i in `ls GO/*.wego`; do mv $i $i.xls; done
for i in `ls GO/*.txt`; do mv $i `echo $i | sed s/txt$/xls/`; done
for i in `ls *.glist`; do mv $i 10.$i.xls; done

## Convert pdf to png

echo "==== convert pdf to png ===="
for i in `ls *.pdf`
do
	id=`basename $i .pdf`;
	convert $i ${id}.png;
done

## Arrange Files

echo "==== arrange files ===="
mv WGCNA.options *.RData $OUT_DIR
mv 0.remove* $OUT_DIR/1.filter
mv 1.sampleClustering* 2.softPower* 3.eigengeneClustering* 4.ModuleTree* 4.netcolor2gene.xls $OUT_DIR/2.feature_evaluation
mv 5.Module* 6.gene* 7.Sample* 8.network* $OUT_DIR/3.basic_info
mv 9.*Express* 10.*glist.xls $OUT_DIR/4.modules
mv 11.CytoscapeInput* $OUT_DIR/4.modules/cytoscape
mv GO KO $OUT_DIR/5.enrichment
mv *go* $OUT_DIR/5.enrichment/GO
mv *kegg* $OUT_DIR/5.enrichment/KO
rm 10.*ModuleConnectivity.xls

## generate Report

echo "==== generate report ===="
perl $REPORT $OUT_DIR $OUT_DIR/WGCNA.options || exit 0;

## package

echo "==== package files ===="
tar -zvcf WGCNA_report.tar.gz $OUT_DIR/1.filter $OUT_DIR/2.feature_evaluation $OUT_DIR/3.basic_info $OUT_DIR/4.modules $OUT_DIR/5.enrichment $OUT_DIR/Page_Config $OUT_DIR/index.html
