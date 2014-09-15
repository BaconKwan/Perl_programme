## Edit sam or bam files' header if it is needed
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=../py.sam O=py.sam ID=py LB=py PL=illumina SM=py PU=run
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=../pg.sam O=pg.sam ID=pg LB=pg PL=illumina SM=pg PU=run

## Merge sam or bam files
java -jar /home/guanpeikun/bin/picard-tools-1.115/MergeSamFiles.jar I=py.sam I=pg.sam O=t.sam SO=coordinate VALIDATION_STRINGENCY=LENIENT    

## Convert sam to bam
samtools view -bS t.sam -o t.bam

## Sort 
java -jar /home/guanpeikun/bin/picard-tools-1.115/SortSam.jar I=t.bam O=sort.bam SO=coordinate VALIDATION_STRINGENCY=LENIENT

## Mark Duplicates
java -jar /home/guanpeikun/bin/picard-tools-1.115/MarkDuplicates.jar I=t.bam O=mark.bam M=metrics VALIDATION_STRINGENCY=LENIENT

## Run this step in RNAseq pipeline when genome file contain N
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T SplitNCigarReads -R /Bio/Database/Database/Species/Oryza_indica/Oryza_indica.ASM465v1.22.dna_sm.toplevel.chr.fa -I mark.bam -o mark_snc.bam

## Make index for bam
samtools index mark.bam

## Make ref seq ready file
java -jar ~/bin/picard-tools-1.115/CreateSequenceDictionary.jar R=/Bio/Database/Database/Species/Oryza_indica/Oryza_indica.ASM465v1.22.dna_sm.toplevel.chr.fa O=/Bio/Database/Database/Species/Oryza_indica/Oryza_indica.ASM465v1.22.dna_sm.toplevel.chr.dict

## Realign to ref genom, -kown can be omitted if you don't have ref snp info
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /Bio/Database/Database/Species/Oryza_indica/Oryza_indica.ASM465v1.22.dna_sm.toplevel.chr.fa -I mark.bam -o bam.intervals -known /Bio/Database/Database/Species/Oryza_indica/oryza_indica.s.vcf

## Search indel
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner -R /Bio/Database/Database/Species/Oryza_indica/Oryza_indica.ASM465v1.22.dna_sm.toplevel.chr.fa -targetIntervals bam.intervals -I mark.bam -o realign.bam -known /Bio/Database/Database/Species/Oryza_indica/oryza_indica.s.vcf

java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T UnifiedGenotyper -glm BOTH -R /Bio/Database/Database/Species/Oryza_indica/Oryza_indica.ASM465v1.22.dna_sm.toplevel.chr.fa -I realign.bam -D /Bio/Database/Database/Species/Oryza_indica/oryza_indica.s.vcf -o test.vcf -metrics vcf.metrics -nct 6 -filterRNC -filterMBQ -filterNoBases -rf UnmappedRead -rf BadMate -rf DuplicateRead -rf NotPrimaryAlignment -rf MappingQualityUnavailable

convert2annovar.pl -format vcf4 omet.list --outfile gy -allsample

annotate_variation.pl --buildver Oryza_indica gy.py.avinput --outfile py /Bio/Database/Database/Species/Oryza_indica/
annotate_variation.pl --buildver Oryza_indica gy.pg.avinput --outfile pg /Bio/Database/Database/Species/Oryza_indica/

