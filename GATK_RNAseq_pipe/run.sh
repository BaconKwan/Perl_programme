## Modif bam files' header
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=align/Atzou/accepted_hits.bam O=Atzou.bam ID=Atzou LB=Atzou PL=illumina SM=Atzou PU=AtzouPU
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=align/Col/accepted_hits.bam O=Col.bam ID=Col LB=Col PL=illumina SM=Col PU=ColPU
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=align/spz2/accepted_hits.bam O=spz2.bam ID=spz2 LB=spz2 PL=illumina SM=spz2 PU=spz2PU
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=align/spz4/accepted_hits.bam O=spz4.bam ID=spz4 LB=spz4 PL=illumina SM=spz4 PU=spz4PU

## Mark duplication
java -jar /home/guanpeikun/bin/picard-tools-1.115/MarkDuplicates.jar I=Atzou.bam O=Atzou_mark.bam M=Atzou.metrics VALIDATION_STRINGENCY=LENIENT
java -jar /home/guanpeikun/bin/picard-tools-1.115/MarkDuplicates.jar I=Col.bam O=Col_mark.bam M=Col.metrics VALIDATION_STRINGENCY=LENIENT
java -jar /home/guanpeikun/bin/picard-tools-1.115/MarkDuplicates.jar I=spz2.bam O=spz2_mark.bam M=spz2.metrics VALIDATION_STRINGENCY=LENIENT
java -jar /home/guanpeikun/bin/picard-tools-1.115/MarkDuplicates.jar I=spz4.bam O=spz4_mark.bam M=spz4.metrics VALIDATION_STRINGENCY=LENIENT

## Creat fasta index & dict
samtools faidx ref/ath.fa
java -jar /home/guanpeikun/bin/picard-tools-1.115/CreateSequenceDictionary.jar R=./ref/ath.fa O=./ref/ath.dict

## Creat bam index
samtools index Atzou_mark.bam
samtools index Col_mark.bam
samtools index spz2_mark.bam
samtools index spz4_mark.bam

## Split'N'Trim
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T SplitNCigarReads -R ./ref/ath.fa -I Atzou_mark.bam -o Atzou_snc.bam -U ALLOW_N_CIGAR_READS
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T SplitNCigarReads -R ./ref/ath.fa -I Col_mark.bam -o Col_snc.bam -U ALLOW_N_CIGAR_READS
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T SplitNCigarReads -R ./ref/ath.fa -I spz2_mark.bam -o spz2_snc.bam -U ALLOW_N_CIGAR_READS
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T SplitNCigarReads -R ./ref/ath.fa -I spz4_mark.bam -o spz4_snc.bam -U ALLOW_N_CIGAR_READS

## Local realignment around indels
## 1) Creat intervals by realign reads to ref
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ./ref/ath.fa -I Atzou_snc.bam -o Atzou.intervals
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ./ref/ath.fa -I Col_snc.bam -o Col.intervals
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ./ref/ath.fa -I spz2_snc.bam -o spz2.intervals
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ./ref/ath.fa -I spz4_snc.bam -o spz4.intervals

## 2) Realign to interval regions
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner -R ./ref/ath.fa -targetIntervals Atzou.intervals -I Atzou_snc.bam -o Atzou_realign.bam
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner -R ./ref/ath.fa -targetIntervals Col.intervals -I Col_snc.bam -o Col_realign.bam
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner -R ./ref/ath.fa -targetIntervals spz2.intervals -I spz2_snc.bam -o spz2_realign.bam
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner -R ./ref/ath.fa -targetIntervals spz4.intervals -I spz4_snc.bam -o spz4_realign.bam

## Variant Calling by using UnifiedGenotyper
java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T UnifiedGenotyper -glm BOTH -R ./ref/ath.fa -I Atzou_realign.bam -I Col_realign.bam -I spz2_realign.bam -I spz4_realign.bam -o result.vcf -metrics result.metrics -nct 6 -filterRNC -filterMBQ -filterNoBases -rf UnmappedRead -rf BadMate -rf DuplicateRead -rf NotPrimaryAlignment -rf MappingQualityUnavailable

## Filter: variant recalibration & aplly the recalibration (need ref snp/indel vcf)
