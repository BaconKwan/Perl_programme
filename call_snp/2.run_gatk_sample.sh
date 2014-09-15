cd /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp2

java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=0S2/accepted_hits.bam O=0S2/accepted.bam ID=0S2 LB=0S2 PL=illumina SM=0S2 PU=run
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=CK1/accepted_hits.bam O=CK1/accepted.bam ID=CK1 LB=CK1 PL=illumina SM=CK1 PU=run
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=CK2/accepted_hits.bam O=CK2/accepted.bam ID=CK2 LB=CK2 PL=illumina SM=CK2 PU=run
java -jar /home/guanpeikun/bin/picard-tools-1.115/AddOrReplaceReadGroups.jar I=OS1/accepted_hits.bam O=OS1/accepted.bam ID=OS1 LB=OS1 PL=illumina SM=OS1 PU=run

java -jar /home/guanpeikun/bin/picard-tools-1.115/MergeSamFiles.jar \
		 I=0S2/accepted.bam \
		 I=OS1/accepted.bam \
		 I=CK1/accepted.bam \
		 I=CK2/accepted.bam \
		 O=group.bam SO=coordinate

samtools index group.bam

java -jar ~/bin/picard-tools-1.115/CreateSequenceDictionary.jar R=/Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa O=/Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.dict

java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -I group.bam -o bam.intervals

java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner -R /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -targetIntervals bam.intervals -I group.bam -o realign.bam

java -jar /home/sunyong/bin/gatk-3.2-2/GenomeAnalysisTK.jar -T UnifiedGenotyper -glm BOTH -R /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -I realign.bam -o UnifiedGenotype.vcf -metrics vcf.metrics -nct 6 -filterRNC -filterMBQ -filterNoBases -rf UnmappedRead -rf BadMate -rf DuplicateRead -rf NotPrimaryAlignment -rf MappingQualityUnavailable
