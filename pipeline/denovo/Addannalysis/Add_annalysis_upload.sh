for i in $(ls pipe/*final.sh)
do
a=`basename $i|sed 's/.final.sh//'`
mkdir Add_annalysis_upload
cd Add_annalysis_upload 
cp -r /Bio/Database/User/yaokaixin/bin/Addannalysis/Denovo/* .
perl /Bio/Database/User/yaokaixin/bin/Addannalysis/Denovo/create-shells.pl $a $a
cd Part1_assembly_annot 
sh run_part1.sh
cd ../Part2_SSR
sh run_part2.sh
cd ../Part3_CDS
perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/3_CDS/before_run.pl $a $a
cd ../Part4_pfam
sh run_part4.sh
done
