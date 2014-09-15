`mkdir Ref`
path=`pwd`
`ln -s $path/Denovo/pipe/*/annotation/KEGG/*.ko Ref`
`ln -s $path/Denovo/pipe/*/annotation/KEGG/*.path Ref`
`ln -s $path/Denovo/pipe/annot/go/*.wego Ref`
`ln -s $path/Denovo/pipe/annot/go/*.annot Ref`
`ln -s $path/Denovo/pipe/*/annotation/annotation.xls Ref`
`ln -s $path/Denovo/pipe/assembly_fill/*/cluster/*Unigene.fa Ref`
	name=`ls Ref/*.fa|sed 's/.fa//'|sed 's/Ref\///'`
`cut -f1,8 Ref/annotation.xls > Ref/$name.desc`
`awk '{print $1"\t"$1}' Ref/annotation.xls > Ref/$name.gene2tr`
annot=`ls Ref/*.annot|sed 's/Ref\///'`
`cd Ref && perl /Bio/Bin/pipe/RNA/denovo_2.0/annot2goa.pl $annot $name`
`cd ..`
`mkdir RNAseq`
`cp /Bio/Database/User/yaokaixin/bin/RNAseq/RNAseq_prepare/input.lib RNAseq`
`echo perl /Bio/Bin/pipe/dge2_2.0_RNAseq/dge2.pl  -species $name -outdir out -lib input.lib -komap /Bio/Database/Database/kegg/data/map_class/ko_map.tab -gnum 16 -gene  $path/Ref/$name.fa -ko $path/Ref/$name\.fa.ko -go $path/Ref/$name -desc $path/Ref/$name\.desc -taxid 3659  -gene2tr $path/Ref/$name\.gene2tr -path $path/Ref/$name\.fa.path -wego $path/Ref/$name\.fa.blast.Nr.xml.wego > RNAseq/run.sh`
