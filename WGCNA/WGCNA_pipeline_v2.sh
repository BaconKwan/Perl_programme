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

desc=/Bio/Database/Database/Ensembl/82release/Ovis_aries/lnc_RNAseq_ref/oas_test_annot/oas_test.Annot.txt
bgl=/Bio/Database/Database/Ensembl/82release/Ovis_aries/lnc_RNAseq_ref/oas.bgl
kopath=/Bio/Database/Database/Ensembl/82release/Ovis_aries/lnc_RNAseq_ref/oas_test_annot/oas_test.kopath
go_dir=/Bio/Database/Database/Ensembl/82release/Ovis_aries/lnc_RNAseq_ref/oas_test_annot
go_prefix=oas_test

## Checking Parameter

if [ $# -ne 2 ]; then 
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
         $OUT_DIR/2.module_construction \
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
export LD_LIBRARY_PATH=/Bio/User/luoyue/gcc-4.9.2/lib64:$LD_LIBRARY_PATH
for i in `ls 10.*ModuleConnectivity.xls`
do
	name=`basename $i ModuleConnectivity.xls | sed 's/10\.//'`
	cut -f 1 $i | sed '1i\GeneID' > ${name}.glist
	echo "==> processing with ${name}"

	# KO
	if [ -s $kopath ]; then
		mkdir -p KO
		cp ${name}.glist KO/${name}.glist
		perl /Bio/Database/Database/kegg/latest_kegg/shell/keggpath.pl PATH -f KO/${name}.glist -b $kopath -o KO/${name}
		perl /Bio/Database/Database/kegg/latest_kegg/shell/add_B_class.pl KO/${name}.path 6 KO/${name}.path.xls
		perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/keggGradient_v3.pl KO/${name}.path.xls 20 Q
		perl /Bio/Database/Database/kegg/latest_kegg/shell/keggMap_nodiff.pl -ko KO/${name}.kopath -outdir KO/${name}_map
		rm KO/${name}.glist KO/${name}.path -rf
	fi

	# GO
	if [ -s ${go_dir}/${go_prefix}.P ] && [ -s ${go_dir}/${go_prefix}.F ] && [ -s ${go_dir}/${go_prefix}.C ]; then
		mkdir -p GO
		cp ${name}.glist GO/${name}.glist
		perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/enrichGO.pl -g GO/${name}.glist -bg $bgl -a $go_dir/$go_prefix -op GO/${name} -ud nodiff
		rm GO/${name}.glist -rf
	fi
done

# Report
if [ -s $kopath ]; then
	perl /Bio/Database/Database/kegg/latest_kegg/shell/genPathHTML_v2.pl -indir KO
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/enrichmentHeatmap_v2.pl KO kegg

	# Generate all.pathway.xls
	cat *.kopath | cut -f 1 | sort -u > all.glist
	perl /Bio/Database/Database/kegg/latest_kegg/shell/keggpath.pl PATH -f all.glist -b $kopath -o KO/all
	perl /Bio/Database/Database/kegg/latest_kegg/shell/add_B_class.pl KO/all.path 6 KO/all.path.xls
	perl /home/guanpeikun/bin/WGCNA/bin/path_sta_v2.pl -i KO -o KO/all.pathway.xls 
	rm all.glist KO/all.kopath KO/all.path KO/all.path.xls -rf
fi

if [ -s ${go_dir}/${go_prefix}.P ] && [ -s ${go_dir}/${go_prefix}.F ] && [ -s ${go_dir}/${go_prefix}.C ]; then
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/enrichmentHeatmap_v2.pl GO go
fi

# Add desc & info
perl /home/guanpeikun/bin/WGCNA/bin/add_info.pl $EXP_TABLE *.glist
if [ -s $desc ]; then
	perl /home/guanpeikun/bin/WGCNA/bin/add_desc4WGCNA.pl $desc 1 *.glist
fi

# Rename files
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
mv 1.sampleClustering* 2.softPower* 3.eigengeneClustering* 4.ModuleTree* 4.netcolor2gene.xls $OUT_DIR/2.module_construction
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

## prepare for package
cd $OUT_DIR/..
OUT_DIR=`basename $OUT_DIR`
SIM_OUT_DIR=${OUT_DIR}_compact

## package

echo "==== package files ===="
tar -zcf WGCNA_report.tar.gz $OUT_DIR/1.filter $OUT_DIR/2.module_construction $OUT_DIR/3.basic_info $OUT_DIR/4.modules $OUT_DIR/5.enrichment $OUT_DIR/Page_Config $OUT_DIR/index.html

## generate Simpilify Report
echo "==== generate Simpilify report ===="
rm -rf $SIM_OUT_DIR && mkdir $SIM_OUT_DIR
cp -r --dereference $OUT_DIR/1.filter $OUT_DIR/2.module_construction $OUT_DIR/3.basic_info $OUT_DIR/4.modules $OUT_DIR/5.enrichment $OUT_DIR/Page_Config $OUT_DIR/index.html $SIM_OUT_DIR/
rm -rf $SIM_OUT_DIR/5.enrichment/KO/*_map/*
for i in xls txt ko path kegg wego go
do
	find $SIM_OUT_DIR -name "*.$i" | xargs sed -i '11,$d'
done
tar --dereference -zcf WGCNA_compact_report.tar.gz $SIM_OUT_DIR/*
cd -
