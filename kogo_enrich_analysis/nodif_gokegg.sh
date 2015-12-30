###
dir=`pwd`
ref=
wego=
ko=
komap=/Bio/Database/Database/kegg/data/map_class/animal_ko_map.tab
go=$ref/
go_species=
rpkm=

###
echo "START at `date`"

for i in `ls $dir/*.glist`
do
	name=`basename $i ".glist"`
	`sed -i '1i\GeneID' $i`
	echo '================================'
	echo "processing with $name"
	echo '================================'

# KO
	mkdir -p $dir/KO
	cp $i $dir/KO/"$name".glist
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/getKO.pl -glist $dir/KO/"$name".glist -bg $ko -outdir $dir/KO
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/pathfind.pl -fg $dir/KO/"$name".ko -komap $komap -bg $ko -output $dir/KO/"$name".path
	/Bio/bin/perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/keggGradient_v3.pl $dir/KO/"$name".path 20 Q
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/keggMap_nodiff.pl -ko $dir/KO/"$name".ko -komap $komap -outdir $dir/KO/"$name"_map

# GO
	mkdir -p $dir/GO
	cp $i $dir/GO/"$name".glist
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/getwego.pl $dir/GO/"$name".glist $wego > $dir/GO/"$name".wego
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/drawGO_sort.pl -gglist $dir/GO/"$name".wego -output $dir/GO/"$name".go
	java -jar /Bio/Bin/pipe/RNA/tools/batik-rasterizer.jar -m image/png $dir/GO/"$name".go.svg
done

echo '================================'
echo "processing functional programmes"
echo '================================'
perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/genPathHTML.pl -indir $dir/KO
perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/nodiff/functional_nodiff.pl -go -gldir $dir -sdir $go -species $go_species -outdir $dir

if [ -e "$rpkm" ]; then
	perl /Bio/Bin/pipe/RNA/ref_RNASeq/Softwares/enrich/add_desc.pl $rpkm 1 $dir/*.glist
	rm $dir/*.glist -rf
fi

rm $dir/GO/*glist $dir/KO/*glist -rf
for i in `ls $dir/KO/*.path`; do mv $i $i.xls; done
for i in `ls $dir/KO/*.ko`; do mv $i $i.xls; done
for i in `ls $dir/GO/*.wego`; do mv $i $i.xls; done
for i in `ls $dir/GO/*.txt`; do mv $i `echo $i | sed s/txt$/xls/`; done

echo '================================'
echo 'All done'
