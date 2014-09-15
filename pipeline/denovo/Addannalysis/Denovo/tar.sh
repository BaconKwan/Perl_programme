mkdir -p Add_annalysis_upload/Part1_assembly_annot
cp -r Part1_assembly_annot/evalue Add_annalysis_upload/Part1_assembly_annot
cp -r Part1_assembly_annot/Nr_species Add_annalysis_upload/Part1_assembly_annot
#cp -r Part1_assembly_annot/4_database Add_annalysis_upload/Part1_assembly_annot
mkdir -p Add_annalysis_upload/Part1_assembly_annot/4_database
mkdir -p Add_annalysis_upload/Part1_assembly_annot/n50
cp Part1_assembly_annot/4_database/*xls Add_annalysis_upload/Part1_assembly_annot/4_database
cp Part1_assembly_annot/4_database/*stat Add_annalysis_upload/Part1_assembly_annot/4_database
#cp Part1_assembly_annot/4_database/*png Add_annalysis_upload/Part1_assembly_annot/4_database
cp Part1_assembly_annot/n50/*n50 Part1_assembly_annot/n50/*xls Add_annalysis_upload/Part1_assembly_annot/n50

mkdir -p Add_annalysis_upload/Part2_SSR
#cp Part2_SSR/SSR_out/*.txt Add_annalysis_upload/Part2_SSR
cp Part2_SSR/SSR_out/*.misa Add_annalysis_upload/Part2_SSR
cp Part2_SSR/SSR_out/*.results Add_annalysis_upload/Part2_SSR
cp Part2_SSR/SSR_out/*.statistics* Add_annalysis_upload/Part2_SSR
cp Part2_SSR/SSR_out/*.png Add_annalysis_upload/Part2_SSR
#cp Part2_SSR/SSR_out/*.svg Add_annalysis_upload/Part2_SSR

mkdir -p Add_annalysis_upload/Part3_CDS
cd Part3_CDS
for i in `ls -d */`;do mkdir -p ../Add_annalysis_upload/Part3_CDS/$i && cp $i*.png ../Add_annalysis_upload/Part3_CDS/$i;done
for i in `ls -d */`;do mkdir -p ../Add_annalysis_upload/Part3_CDS/$i && cp $i*svg* ../Add_annalysis_upload/Part3_CDS/$i;done

cd ../
mkdir -p Add_annalysis_upload/Part4_pfam
cp Part4_pfam/result/*.name Add_annalysis_upload/Part4_pfam

for i in `find Add_annalysis_upload/Part1_assembly_annot/*/*`;do perl generate_xlsx_for_denovo.pl $i;done

for i in `find Add_annalysis_upload/Part2_SSR/*.results`;do perl generate_xlsx_for_denovo.pl $i;done
for i in `find Add_annalysis_upload/Part2_SSR/*.classify.txt`;do perl generate_xlsx_for_denovo.pl $i;done
for i in `find Add_annalysis_upload/Part2_SSR/*.totality.txt`;do perl generate_xlsx_for_denovo.pl $i;done
#for i in `find Add_annalysis_upload/Part2_SSR/*xls`;do perl generate_xlsx_for_denovo.pl $i;done
for i in `find Add_annalysis_upload/Part4_pfam/*`;do perl generate_xlsx_for_denovo.pl $i;done
cp Part1_assembly_annot/4_database/*png Add_annalysis_upload/Part1_assembly_annot/4_database
cp Part1_assembly_annot/n50/*reads_distribution*png Part1_assembly_annot/n50/*reads_distribution*svg Add_annalysis_upload/Part1_assembly_annot/n50
tar cf Add_annalysis_upload.tar Add_annalysis_upload
bzip2 -9 Add_annalysis_upload.tar
