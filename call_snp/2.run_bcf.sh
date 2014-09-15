samtools mpileup -6 -u -g -d 800 -f /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -b /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/bam.list | bcftools call -vmO z -o /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/result.vcf.gz
tabix -p vcf /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/result.vcf.gz
bcftools stats -F /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/ref/Ensembl_Ref/Streptococcus_thermophilus.fa -s - /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/result.vcf.gz > /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/result.vcf.stat
mkdir -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/plots && plot-vcfstats -p /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/plots/ /Bio/Project/PROJECT/GDR0332-Streptococcus_thermophilus-4-Denovo-RNAseq/tophat_cufflinks/call_snp/group/result.vcf.stat
