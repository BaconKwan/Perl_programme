perl stat.pl Bacillus_megaterium_dsm_319.operon.txt Bacillus_megaterium_dsm_319.exon.fa.go.class.xls bme
perl stat.pl Bacillus_subtilis_subsp_subtilis_str_168.operon.txt Bacillus_subtilis_168.exon.fa.go.class.xls bsu
perl stat.pl Bacillus_licheniformis_dsm_13_atcc_14580.operon.txt Bacillus_licheniformis_dsm_13_atcc_14580.exon.fa.go.class.xls bli


#3'UTR
Rscript boxplot.r bli.3utr.stat bli.3utr.xls 1 -4
Rscript boxplot.r bme.3utr.stat bme.3utr.xls 0 -5
Rscript boxplot.r bsu.3utr.stat bsu.3utr.xls 0 -5


#5'UTR
Rscript boxplot.r bli.5utr.stat bli.5utr.xls 0 -6
Rscript boxplot.r bme.5utr.stat bme.5utr.xls 0 -5
Rscript boxplot.r bsu.5utr.stat bsu.5utr.xls 0 -6
