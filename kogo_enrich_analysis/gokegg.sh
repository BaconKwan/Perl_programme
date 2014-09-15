# annotation
wego=
ko=
go=
go_species=
mapko=

# Pathway
for i in LISTS
do
	keyname=`echo $i | sed 's/.*\/\(.*\)\.glist$/\1/'`
	glist=`basename $i | sed 's/\.glist$/\.glist/'`
	glist=OUTK/$glist
	awk -F "\t" '{printf("%s\t\t\t\t\t%s\n", $1, $2)}' $i > $glist
	perl /Bio/Bin/pipe/dge2_2.0_RNAseq/functional/getKO.pl -glist $glist -bg $ko -outdir OUTK
	perl /Bio/Bin/pipe/dge2_2.0_RNAseq/functional/pathfind.pl -fg OUTK/$keyname.ko -komap $mapko -bg $ko -output OUTK/$keyname.path
	cp OUTK/$keyname.path OUTK/$keyname.path.xls
	perl /Bio/Bin/pipe/dge2_2.0_RNAseq/functional/keggMap.pl -ko OUTK/$keyname.ko -komap $mapko -diff $glist -outdir OUTK/$keyname\_map
done
perl /Bio/Bin/pipe/dge2_2.0_RNAseq/functional/genPathHTML.pl -indir OUTK

# GO
for i in LISTS
do
	name=`basename $i`
	name=`echo $name |sed 's/\.glist$//'`
	awk '{if ($2 > 1){print $1}}' $i > OUTG/$name\_up.glist
	awk '{if ($2 < -1){print $1}}' $i > OUTG/$name\_down.glist
	perl /home/guanpeikun/bin/kogo_enrich_analysis/getwego.pl OUTG/$name\_up.glist $wego > OUTG/$name\_up.wego
	perl /home/guanpeikun/bin/kogo_enrich_analysis/getwego.pl OUTG/$name\_down.glist $wego > OUTG/$name\_down.wego
	if [ -s OUTG/$name\_up.wego ] && [ -s OUTG/$name\_down.wego ]; then
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist OUTG/$name\_up.wego,OUTG/$name\_down.wego -output OUTG/$name.go.class
	elif [ -s OUTG/$name\_up.wego ]; then
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist OUTG/$name\_up.wego -output OUTG/$name.go.class
	elif [ -s OUTG/$name\_down.wego ]; then
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist OUTG/$name\_down.wego -output OUTG/$name.go.class
	fi
	java -jar /Bio/Bin/pipe/RNA/tools/batik-rasterizer.jar -m image/png OUTG/$name.go.class.svg
done
rm OUTG/*glist
perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/functional.pl -go -gldir GOUP -sdir $go -species $go_species -outdir GOUP
for j in $(ls OUTG/*txt)
do
	xls=`echo $j | sed 's/txt$/xls/'`
	`cp $j $xls`
done
