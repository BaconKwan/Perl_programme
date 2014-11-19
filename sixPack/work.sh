perl preDeal4sixPack.pl new.no.fa > new.sixPack.fa
perl cds2pep.pl new.sixPack.fa new.pep.fa
java -jar ~/User/guanpeikun/tools/picard-tools/NormalizeFasta.jar I=new.pep.fa O=new.pep.norm.fa LINE_LENGTH=1000
sed -r -i 's/\*.*//g' new.pep.norm.fa
perl filter.pl new.pep.norm.fa new.pep.filter.fa
