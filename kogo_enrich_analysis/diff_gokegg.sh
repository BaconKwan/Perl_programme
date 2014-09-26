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
	#awk -F "\t" '{printf("%s\t\t\t\t\t%s\n", $1, $2)}' $i > $dir/KO/"$name".glist
	cp $i $dir/KO/"$name".glist
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/getKO.pl -glist $dir/KO/"$name".glist -bg $ko -outdir $dir/KO
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/pathfind.pl -fg $dir/KO/"$name".ko -komap $komap -bg $ko -output $dir/KO/"$name".path
	perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/keggMap.pl -ko $dir/KO/"$name".ko -komap $komap -diff $dir/KO/"$name".glist -outdir $dir/KO/"$name"_map

# GO
	mkdir -p $dir/GO
	awk '{if ($2 >= 1){print $1}}' $i > $dir/GO/"$name"_up.glist
	awk '{if ($2 <= -1){print $1}}' $i > $dir/GO/"$name"_down.glist
	perl /home/guanpeikun/bin/kogo_enrich_analysis/getwego.pl $dir/GO/"$name"_up.glist $wego > $dir/GO/"$name"_up.wego
	perl /home/guanpeikun/bin/kogo_enrich_analysis/getwego.pl $dir/GO/"$name"_down.glist $wego > $dir/GO/"$name"_down.wego
	if [ -s $dir/GO/"$name"_up.wego ] && [ -s $dir/GO/"$name"_down.wego ]; then
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist $dir/GO/"$name"_up.wego,$dir/GO/"$name"_down.wego -output $dir/GO/"$name".go.class
	elif [ -s $dir/GO/"$name"_up.wego ]; then
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist $dir/GO/"$name"_up.wego -output $dir/GO/"$name".go.class
	elif [ -s $dir/GO/"$name"_down.wego ]; then
		perl /Bio/Bin/pipe/RNA/denovo_2.0/drawGO_black.pl -gglist $dir/GO/"$name"_down.wego -output $dir/GO/"$name".go.class
	fi
	java -jar /Bio/Bin/pipe/RNA/tools/batik-rasterizer.jar -m image/png $dir/GO/"$name".go.class.svg
done

echo '================================'
echo "processing functional programmes"
echo '================================'
perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/functional.pl -go -gldir $dir -sdir $go -species $go_species -outdir $dir
perl /Bio/Bin/pipe/RNA/denovo_2.0/functional/genPathHTML.pl -indir $dir/KO

if [ -e "$rpkm" ]; then
	perl /home/guanpeikun/bin/pipeline/RNAseq/add_desc_for_MultiGeneDiff.pl $rpkm $dir/*.glist
	rm $dir/*.glist -rf
fi

rm $dir/GO/*glist $dir/KO/*glist -rf
for i in `ls $dir/KO/*.path`; do mv $i $i.xls; done
for i in `ls $dir/KO/*.ko`; do mv $i $i.xls; done
for i in `ls $dir/GO/*.wego`; do mv $i $i.xls; done
for i in `ls $dir/GO/*.txt`; do mv $i `echo $i | sed s/txt$/xls/`; done

echo '================================'
echo 'All done'
