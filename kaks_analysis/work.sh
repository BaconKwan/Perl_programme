#perl get_single_copy_genefamily.pl all_orthomcl.out 2 > single_copy_genefamily.out
#perl run_msa.pl single_copy_genefamily.out all.pep all.cds.fa out_msa
#perl get_axt_file.pl out_msa/tmp.cds refH refN > H-N.axt
perl get_axt_file.pl out_msa/tmp.cds refN refH > N-H.axt
#perl /parastor/users/luoda/gaochuan/program/orthomcl/copy_from_BGI/read_singlecopy_genefamily_generate_category_list.pl single_copy_genefamily.out > category.txt
#perl /parastor/users/luoda/gaochuan/program/orthomcl/copy_from_BGI/super.pl category.txt out_msa/tmp.cds >out.phy

#perl file_format_change_to_fa.pl out.phy > out.phy.out.fa
#perl stat_orthologous_region.pl single_copy_genefamily.out ../blastp.m8 annotation.xls >orthologous_gene_pairs.list
