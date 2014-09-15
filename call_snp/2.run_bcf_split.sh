samtools mpileup -6 -u -g -d 800 -f /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/align/0S2/accepted_hits.bam | bcftools call -vmO z -o /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/result.vcf.gz &
samtools mpileup -6 -u -g -d 800 -f /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/align/CK1/accepted_hits.bam | bcftools call -vmO z -o /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/result.vcf.gz &
samtools mpileup -6 -u -g -d 800 -f /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/align/CK2/accepted_hits.bam | bcftools call -vmO z -o /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/result.vcf.gz &
samtools mpileup -6 -u -g -d 800 -f /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/align/OS1/accepted_hits.bam | bcftools call -vmO z -o /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/result.vcf.gz
tabix -p vcf /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/result.vcf.gz &
tabix -p vcf /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/result.vcf.gz &
tabix -p vcf /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/result.vcf.gz &
tabix -p vcf /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/result.vcf.gz
bcftools stats -F /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -s - /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/result.vcf.gz > /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/result.vcf.stat &
bcftools stats -F /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -s - /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/result.vcf.gz > /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/result.vcf.stat &
bcftools stats -F /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -s - /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/result.vcf.gz > /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/result.vcf.stat &
bcftools stats -F /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -s - /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/result.vcf.gz > /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/result.vcf.stat
mkdir -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/plots && plot-vcfstats -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/plots/ /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/0S2/result.vcf.stat &
mkdir -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/plots && plot-vcfstats -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/plots/ /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK1/result.vcf.stat &
mkdir -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/plots && plot-vcfstats -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/plots/ /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/CK2/result.vcf.stat &
mkdir -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/plots && plot-vcfstats -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/plots/ /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/OS1/result.vcf.stat
