#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin $Script);
use lib $Bin;
use Support_Program;
use Cwd 'abs_path';

sub usage {
	print <<USAGE;
usage:
	perl $0 [options]
copyright:
	Guangzhou Genedenovo Biotecnology Co.,Ltd
contact e-mail:
	miaoxin\@genedenovo.com
description:
	This program generate a series of programs to do RNA_denovo Project.
options:
	-help         : print this help info
	-lib    (str) : the lib file you must config correctly
	-outdir (str) : where the programs that will generate to ( default = . )
	-path   (str) : the path of additional used programs or files (default = $Bin/Add_Lib )
e.g.:
	perl $0 -lib denovo.lib
	perl $0 -lib denovo.lib -outdir pipe -path $Bin/Add_Lib
USAGE
}

##########################################################################################
# 初始化
##########################################################################################

my $path ||= "$Bin/Add_Lib";
my ($help,$lib,$outdir);
GetOptions(
	"help"=>\$help,
	"lib=s"=>\$lib,
	"outdir=s"=>\$outdir,
	"path=s"=>\$path,
);

if ((defined $help) || (! defined $lib) ){
	&usage;
	print "\nError : Where's the lib file?\n";
	exit 0;
}
$lib = abs_path($lib);

########################### This fuction will get some filenames in a specific directory
sub getKeys {
	my ($dir, $suffix, $result) = @_;
	return if (!-d $dir);
	for (glob("$dir/*$suffix")) {
		push @{$result}, $1 if (/^.*\/(.*)$suffix$/i);
	}
	@{$result} = sort @{$result};
}

#################################################################################################### Dir Structure

$outdir ||= './Pipe_Out';
system "mkdir -p $outdir";
$outdir = abs_path($outdir);

########################### This directory will contain SSR Result
my $summary_result_dir = $outdir.'/Summary';
system "mkdir -p $summary_result_dir" unless(-d $summary_result_dir);

my $stat_dir = $summary_result_dir.'/fq_Stat';
system "mkdir -p $stat_dir" unless(-d $stat_dir);

my $db4_dir = $summary_result_dir.'/4_database';
system "mkdir -p $db4_dir" unless (-d $db4_dir);

my $logs_dir = $summary_result_dir.'/All_Logs';
system "mkdir -p $logs_dir" unless (-d $logs_dir);

my $evalue_result_dir = $summary_result_dir.'/evalue';
system "mkdir -p $evalue_result_dir" unless (-d $evalue_result_dir);

########################### This directory will contain Some Config Information
my $con_dir = $summary_result_dir.'/Configuration';
system "mkdir -p $con_dir" unless (-d $con_dir);

my %config;
my $pro_log = "$con_dir\/program_path.txt";
Support_Program(\%config,$path,1,$pro_log);

########################### This directory will contain All the Shell Scripts
my $shdir = $outdir.'/SH';
system "mkdir -p $shdir" unless(-d $shdir);

my $data_process_dir = $shdir.'/0_data_pre_process';
system "mkdir -p $data_process_dir" unless(-d $data_process_dir);

my $assembly_dir = $shdir.'/1_assembly';
system "mkdir -p $assembly_dir" unless(-d $assembly_dir);

my $exp_dir = $shdir.'/2_exp';
system "mkdir -p $exp_dir" unless(-d $exp_dir);

my $annot_dir = $shdir.'/3_annot';
system "mkdir -p $annot_dir" unless(-d $annot_dir);

my $go_cds_ssr_pfam = $shdir.'/4_go_cds_ssr_pfam';
system "mkdir -p $go_cds_ssr_pfam" unless(-d $go_cds_ssr_pfam);

my $summary_dir = $shdir.'/5_summary';
system "mkdir -p $summary_dir" unless(-d $summary_dir);

########################### This directory will contain Processed fq
my $filtered_fq_dir="$outdir/FQ_process/filtered";
system "mkdir -p $filtered_fq_dir" unless (-d "$filtered_fq_dir");

########################### This directory will contain Assembly Result
my $assembly_result_dir=$outdir.'/Assembly';
system "mkdir -p $assembly_result_dir" unless(-d $assembly_result_dir);

########################### This directory will contain the references of RNAseq pipeline
my $ref_dir = $outdir.'/RNAseq_Ref';
system "mkdir -p $ref_dir" unless(-d $ref_dir);

########################### This directory will contain Annot Result
my $annot_result_dir = $outdir.'/Annot';
system "mkdir -p $annot_result_dir" unless(-d $annot_result_dir);

my $db_dir = $annot_result_dir.'/database';
system "mkdir -p $db_dir" unless(-d $db_dir);

my $blast_result_dir = $annot_result_dir.'/blast_result';
system "mkdir -p $blast_result_dir" unless(-d $blast_result_dir);

my $go_dir = $annot_result_dir.'/blast2go';
system "mkdir -p $go_dir" unless(-d $go_dir);

########################### This directory will contain CDS Result
my $cds_result_dir = $outdir.'/CDS';
system "mkdir -p $cds_result_dir" unless(-d $cds_result_dir);

my $rela_sp_dir = $cds_result_dir.'/Related_Species';
system "mkdir -p $rela_sp_dir" unless(-d $rela_sp_dir);

########################### This directory will contain SSR Result
my $ssr_result_dir = $outdir.'/SSR';
system "mkdir -p $ssr_result_dir" unless(-d $ssr_result_dir);

########################### This directory will contain SSR Result
my $pfam_result_dir = $outdir.'/Pfam';
system "mkdir -p $pfam_result_dir" unless(-d $pfam_result_dir);

########################### This directory will contain Exp Result
my $rpkm_dir=$outdir.'/RPKM';
system "mkdir -p $rpkm_dir" unless (-d $rpkm_dir);

########################### This directory will contain SOAP Result
my $soap_dir=$outdir.'/SOAP';
system "mkdir -p $soap_dir" unless (-d $soap_dir);

########################### This directory will contain
my $old_dir = $outdir.'/Old_SH';
system "mkdir -p $old_dir" unless(-d $old_dir);

########################### Time
my $time = '`date +%y-%m-%d.%H:%M:%S`';

########################### This directory will contain All Result Need to Upload
my $upload_dir = $outdir.'/Upload';
system "mkdir -p $upload_dir" unless(-d $upload_dir);

my $up_as_dir = $upload_dir.'/assembly';
system "mkdir -p  $up_as_dir" unless(-d $up_as_dir);

my $up_unigene_dir = $up_as_dir.'/Unigene';
system "mkdir -p  $up_unigene_dir" unless(-d $up_unigene_dir);

my $up_cds_dir = $upload_dir.'/CDS';
system "mkdir -p  $up_cds_dir" unless(-d $up_cds_dir);

my $up_rela_sp_dir = $up_cds_dir.'/Related_Species';
system "mkdir -p  $up_rela_sp_dir" unless(-d $up_rela_sp_dir);

my $up_anno_dir = $upload_dir.'/annotation';
system "mkdir -p  $up_anno_dir" unless(-d $up_anno_dir);

my $up_db4_dir = $up_anno_dir.'/4_database';
system "mkdir -p  $up_db4_dir" unless(-d $up_db4_dir);

my $up_nr_dir = $up_anno_dir.'/Nr';
system "mkdir -p  $up_nr_dir" unless(-d $up_nr_dir);

my $up_swsp_dir = $up_anno_dir.'/Swissprot';
system "mkdir -p  $up_swsp_dir" unless(-d $up_swsp_dir);

my $up_cog_dir = $up_anno_dir.'/COG';
system "mkdir -p  $up_cog_dir" unless(-d $up_cog_dir);

my $up_kegg_dir = $up_anno_dir.'/KEGG';
system "mkdir -p  $up_kegg_dir" unless(-d $up_kegg_dir);

my $up_go_dir = $up_anno_dir.'/GO';
system "mkdir -p  $up_go_dir" unless(-d $up_go_dir);

my $up_evalue_dir = $up_anno_dir.'/evalue';
system "mkdir -p  $up_evalue_dir" unless(-d $up_evalue_dir);

my $up_advance_dir = $upload_dir.'/advance';
system "mkdir -p  $up_advance_dir" unless(-d $up_advance_dir);

my $up_pfam_dir = $up_advance_dir.'/Pfam';
system "mkdir -p  $up_pfam_dir" unless(-d $up_pfam_dir);

my $up_ssr_dir = $up_advance_dir.'/SSR';
system "mkdir -p  $up_ssr_dir" unless(-d $up_ssr_dir);

########################### This directory will contain All the Unziped fq
my $fq_tmp = $outdir.'/fq_tmp';
system "mkdir -p $fq_tmp" unless (-d "$fq_tmp");

################ 读入 Config ################

my %option = ();
my $sample_name;
my @sample_name_list;
my @sample_data_list;
open IN,$lib or die "can't open the file $lib";
while (my $line = <IN>) {
	next if($line =~ /^\s*$/);
	next if ($line =~ /^\s*\#/);
	chomp $line;
	$line =~ s/\s*$//;
	if ($line =~ s/^>//){
		$sample_name=$line;
	}
	if ($line =~ s/^\~\~\>//){
		my @data = split /\:/,$line;
		$data[0] =~ s/\s*(\S+)\s*/$1/;
		$data[1] =~ s/\s*(\S+)\s*/$1/;
		push @sample_name_list,$data[0];
		push @sample_data_list,$data[1];
	}
	if ($line =~ /^(\S+)\s*=\s*(\S.*)$/){
		$option{$1} = $2;
	}
}
close IN;

if (-e "$shdir/$sample_name\_all_steps.sh"){
	my $date_now = `date +%y-%m-%d.%H-%M-%S`;
	chomp $date_now;
	my $old_dir_now = $old_dir."/".$date_now;
	system "mkdir -p $old_dir_now";
	system "find $shdir -maxdepth 2 -name \"*.sh\" -exec mv {} $old_dir_now \\;";
}

for my $j (@sample_name_list){
	my $sample_fq_dir = "$filtered_fq_dir/$j";
	system "mkdir -p $sample_fq_dir" unless (-d "$sample_fq_dir");
}

#################################### Test Parameters
#for my $i (keys %option){
#	print $i."\t".$option{$i}."\n";
#}
####################################

my $summary=$summary_dir."/1_summary.sh";
open SUMMARY,'>',$summary or die "can't open the summary sh $summary";

my $gzip_sh = $summary_dir.'/0_gzip.sh';
open GZIPSH,'>',$gzip_sh or die "can't open the gzip sh $gzip_sh";

my $upload_sh = $summary_dir.'/2_upload.sh';
open UPLOADSH,'>',$upload_sh or die "can't open the upload sh $upload_sh";

my $clear_sh = $summary_dir.'/3_clear.sh';
open CLEARSH,'>',$clear_sh or die "can't open the sh for rm the the mid file $clear_sh ";

my $all_step_sh = $shdir.'/'.$sample_name.'_all_steps.sh';
open ALLSTEP,'>',$all_step_sh or die "can't open the all step sh $all_step_sh ";

print ALLSTEP "\n#####################################################################\n";
print ALLSTEP "##############    RNA Transcriptome Assembly Donovo    ##############\n";
print ALLSTEP "############## Let's Get It Start Baby!   Are U Ready? ##############\n";
print ALLSTEP "#####################################################################\n\n\n";
print ALLSTEP "echo Denovo pipeline start at $time\n\n";

#################################################

my $sam_num = 1;

##############################################################
# Test Record File, Project Name
##############################################################

unless(exists $option{'denovo_record'}){
	die "Please specify the file path, which used to collect the project informations! It is very important!\n";
}

unless(exists $option{'project_name'}){
	die "Please input the project\'s name!\n";
}

##########################################################################################
#############  33 -> 64 and Merge
##########################################################################################

print ALLSTEP "#################### Data Pre-Process : Unzip, Check, Filter, Clean Up ####################\n\n";

my $unzip_fq_sh;
my $fq_check_sh;
my $filter_sh;
my $clear_unzip_sh;

$unzip_fq_sh = $data_process_dir.'/0_unzip_fq.sh';
open UNZIP,'>',$unzip_fq_sh or die "can't open the unzip fq shell $unzip_fq_sh";
print ALLSTEP "echo Start Unzip FQ at $time\n";
print ALLSTEP "perl $config{'cmd_process_forker'} --CPU $option{'CPU_pre_process'} -c $unzip_fq_sh\n";
print ALLSTEP "echo Finish Unzip FQ at $time\n\n";

if ($option{'fq_check'} eq "yes"){
	$fq_check_sh = $data_process_dir.'/1_fq_check.sh';
	open FQCHECK,'>',$fq_check_sh or die "can't open the fq check shell $fq_check_sh";
	$filter_sh = $data_process_dir.'/2_filter.sh';
	$clear_unzip_sh = $data_process_dir.'/3_clear_unzip.sh';

	print ALLSTEP "echo Start Check FQ at $time\n";
	print ALLSTEP "perl $config{'cmd_process_forker'} --CPU $option{'CPU_fq_check'} -c $fq_check_sh\n";
	print ALLSTEP "echo Finish Check FQ at $time\n\n";

}elsif ($option{'fq_check'} eq "no"){
	$filter_sh = $data_process_dir.'/1_filter.sh';
	$clear_unzip_sh = $data_process_dir.'/2_clear_unzip.sh';
}

print ALLSTEP "echo Start Filter FQ at $time\n";
print ALLSTEP "perl $config{'cmd_process_forker'} --CPU $option{'CPU_filter_fq'} -c $filter_sh\n";
print ALLSTEP "sh $clear_unzip_sh\n";
print ALLSTEP "echo Finish Filter FQ at $time\n\n";


open FILTER,'>',$filter_sh or die "can't open the filter shell $filter_sh";
open CLEARUN,'>',$clear_unzip_sh or die "can't open the clear unzipped fq shell $clear_unzip_sh";

my @rawdata_list = ();
if ($option{'33_to_64'} eq "yes"){

	&getKeys("$option{'rawdata_dir'}/",".fastq.gz", \@rawdata_list);
	for my $i(@rawdata_list){
		my $analy_name=0;
		for my $j (0..$#sample_data_list){
			if ($i =~ /$sample_data_list[$j]\.R1\..*/){
				$analy_name=$sample_name_list[$j]."_1";
			}
			if ($i =~ /$sample_data_list[$j]\.R2\..*/){
				$analy_name=$sample_name_list[$j]."_2";
			}
		}
		unless ($analy_name){
			die "Can't define $i.fastq.gz\n";
		}

		print UNZIP "gzip -kcd $option{'rawdata_dir'}/$i.fastq.gz > $fq_tmp/$analy_name.fq\n";
		if ($option{'fq_check'} eq "yes"){
			print FQCHECK "$config{'fastQValidator'} --file $fq_tmp/$analy_name.fq $option{fqv_option} > $logs_dir/$analy_name.check.log\n";
		}
		print CLEARUN "rm $fq_tmp/$analy_name.fq\n";
	}

}elsif ($option{'33_to_64'} eq "no"){

	&getKeys("$option{'rawdata_dir'}/",".fq.gz", \@rawdata_list);
	if ($rawdata_list[0]){
		for my $i(@rawdata_list){
			my $analy_name=0;
			for my $j (0..$#sample_data_list){
				if ($i =~ /$sample_data_list[$j]\_1/){
					$analy_name=$sample_name_list[$j]."_1";
				}
				if ($i =~ /$sample_data_list[$j]\_2/){
					$analy_name=$sample_name_list[$j]."_2";
				}
			}
			unless ($analy_name){
				die "Can't define $i.fq.gz\n";
			}

			print UNZIP "gzip -kcd $option{'rawdata_dir'}/$i.fq.gz > $fq_tmp/$analy_name.fq\n";
			if ($option{'fq_check'} eq "yes"){
				print FQCHECK "$config{'fastQValidator'} --file $fq_tmp/$analy_name.fq $option{fqv_option} > $logs_dir/$analy_name.check.log\n";
			}
			print CLEARUN "rm $fq_tmp/$analy_name.fq\n";
		}
	}else{
		&getKeys("$option{'rawdata_dir'}/",".fq.tar.bz2", \@rawdata_list);
		for my $i(@rawdata_list){
			my $analy_name=0;
			for my $j (0..$#sample_data_list){
				if ($i =~ /$sample_data_list[$j]\_1/){
					$analy_name=$sample_name_list[$j]."_1";
				}
				if ($i =~ /$sample_data_list[$j]\_2/){
					$analy_name=$sample_name_list[$j]."_2";
				}
			}
			unless ($analy_name){
				die "Can't define $i.fq.tar.bz2\n";
			}

			print UNZIP "tar -jxvf $option{'rawdata_dir'}/$i.fq.tar.bz2 > $fq_tmp/$analy_name.fq\n";
			if ($option{'fq_check'} eq "yes"){
				print FQCHECK "$config{'fastQValidator'} --file $fq_tmp/$analy_name.fq $option{fqv_option} > $logs_dir/$analy_name.check.log\n";
			}
			print CLEARUN "rm $fq_tmp/$analy_name.fq\n";
		}
	}
}
close UNZIP;
if ($option{'fq_check'} eq "yes"){
	close FQCHECK;
}

my ($fq_1_files,$fq_2_files,$filter_cmd);
my $stat_list;
for my $j (@sample_name_list){
	if ($option{'33_to_64'} eq "yes"){
		$filter_cmd .= "$config{filter_fq_33} $option{filter_fq_option} --Gnum 100 --fq1 $fq_tmp/$j\_1.fq --fq2 $fq_tmp/$j\_2.fq --out $filtered_fq_dir/$j/$j -p $config{gnuplot} > $logs_dir/$j\_filter.log 2>> $logs_dir/$j\_filter.log\n";
	}elsif ($option{'33_to_64'} eq "no"){
		$filter_cmd .= "$config{filter_fq} $option{filter_fq_option} --fq1 $fq_tmp/$j\_1.fq --fq2 $fq_tmp/$j\_2.fq --out $filtered_fq_dir/$j/$j -p $config{gnuplot} > $logs_dir/$j\_filter.log 2>> $logs_dir/$j\_filter.log\n";
	}
	$fq_1_files .= " $filtered_fq_dir/$j/$j\_1.fq ";
	$fq_2_files .= " $filtered_fq_dir/$j/$j\_2.fq ";

	if ($stat_list){
		$stat_list .=",$filtered_fq_dir/$j/$j.stat";
	}else{
		$stat_list ="$filtered_fq_dir/$j/$j.stat";
	}
	print SUMMARY "ln -s $filtered_fq_dir/$j/$j.stat $stat_dir/$j.stat\n";

	print GZIPSH "gzip $filtered_fq_dir/$j/$j\_1.fq ; $config{md5sum} $filtered_fq_dir/$j/$j\_1.fq.gz > $filtered_fq_dir/$j/$j\_1.fq.gz.md5\n";
	print GZIPSH "gzip $filtered_fq_dir/$j/$j\_2.fq ; $config{md5sum} $filtered_fq_dir/$j/$j\_2.fq.gz > $filtered_fq_dir/$j/$j\_2.fq.gz.md5\n";
}
print FILTER $filter_cmd;
close FILTER;

print CLEARUN "cat $fq_1_files > $fq_tmp/$sample_name\_for_Denovo_1.fq\n";
print CLEARUN "cat $fq_2_files > $fq_tmp/$sample_name\_for_Denovo_2.fq\n\n";

my $fq1 = "$fq_tmp/$sample_name\_for_Denovo_1.fq";
my $fq2 = "$fq_tmp/$sample_name\_for_Denovo_2.fq";
close CLEARUN;

##########################################################################################
#############  组装 补洞 聚类
##########################################################################################

my $sam = $sample_name;
my ($clu_result,$clu_filename,$clu_target,$clu_shell);

print ALLSTEP "\n#################### Assembly, Pick Longest Transcript ####################\n\n";

my $tmpfq_nodup = $sam."_nodup";
my $nodup_fq_dir="$outdir/FQ_process/nodup";

if ($option{rmdup_or_nor} eq "rmdup"){

	system "mkdir -p $nodup_fq_dir" unless (-d "$nodup_fq_dir");

	my $nodup="$assembly_dir/0_nodup.sh";
	open NODUP,'>',$nodup or die "can't open the remove duplication sh $nodup\n";
	print NODUP "perl $config{'duplication'} -fq1 $fq1 -fq2 $fq2 -out $nodup_fq_dir/$tmpfq_nodup \n";
	close NODUP;

	print CLEARSH "rm $nodup_fq_dir/$tmpfq_nodup\_1.fq\n";
	print CLEARSH "rm $nodup_fq_dir/$tmpfq_nodup\_2.fq\n";
	print CLEARSH "rm $nodup_fq_dir/$tmpfq_nodup.dup.list\n\n";

	print ALLSTEP "echo Start Delete Duplication at $time\n";
	print ALLSTEP "sh $nodup\n";
	print ALLSTEP "echo Finish Delete Duplication at $time\n\n";

}elsif ($option{rmdup_or_nor} eq "normalize"){
	unless ($option{'trinity_option'} =~ /normalize_reads/){
		$option{'trinity_option'} .= " --normalize_reads ";
	}
}

########################### 组装

my $sam_as="$assembly_dir/1_assembly.sh";
print ALLSTEP "echo Start Trinity Assembly at $time\n";
print ALLSTEP "sh $sam_as\n";
print ALLSTEP "echo Finish Trinity Assembly at $time\n\n";

open SAMAS,'>',$sam_as or die "can not open the assembly sh $sam_as";
if (exists $option{'trinity_option'}) {

	if ($option{rmdup_or_nor} eq "rmdup"){
		print SAMAS "$config{'Trinity'} $option{'trinity_option'} --left $nodup_fq_dir/$tmpfq_nodup\_1.fq --right $nodup_fq_dir/$tmpfq_nodup\_2.fq --output $assembly_result_dir > $assembly_result_dir/Trinity_$sam.log 2>> $assembly_result_dir/Trinity_$sam.log\n\n";
	}elsif ($option{rmdup_or_nor} eq "normalize"){
		print SAMAS "$config{'Trinity'} $option{'trinity_option'} --left $fq1 --right $fq2 --output $assembly_result_dir > $assembly_result_dir/Trinity_$sam.log 2>> $assembly_result_dir/Trinity_$sam.log\n\n";
	}
	
	print SUMMARY "\nln -s $assembly_result_dir/Trinity_$sam.log $logs_dir/Trinity_$sam.log\n";
}

if ($option{pick_longest} eq "yes"){
	print SAMAS "perl $config{get_longest_tr} -type Unigene -fa $assembly_result_dir/Trinity.fasta -output $assembly_result_dir/$sam-Unigene.fa\n\n";
}elsif ($option{pick_longest} eq "no"){
	print SAMAS "perl $config{change_id_trinity} -type Unigene -fa $assembly_result_dir/Trinity.fasta -output $assembly_result_dir/$sam-Unigene.fa\n\n";
}

print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.fa $up_unigene_dir/$sam-Unigene.fa\n";

print SAMAS "ln -s $assembly_result_dir/$sam-Unigene.fa.gene2tr $ref_dir/$sam-Unigene.fa.gene2tr\n";
print SAMAS "perl $config{Seq_N} $assembly_result_dir/$sam-Unigene.fa > $assembly_result_dir/$sam-Unigene.n50\n";
print SAMAS "perl $config{TrinityStats} $assembly_result_dir/Trinity.fasta > $assembly_result_dir/Trinity.stat\n";
print SAMAS "perl $config{fa_quality} -len -Head -gap -N -gc $assembly_result_dir/$sam-Unigene.fa\n";
#print SAMAS "perl $config{barplot} $assembly_result_dir/$sam-Unigene.fa.quality.xls $sam-Unigene -gap\n\n";
print SAMAS "perl $config{barplot} $assembly_result_dir/$sam-Unigene.fa.quality.xls $sam-Unigene\n\n";

print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.fa.quality.xls $up_unigene_dir/$sam-Unigene.fa.quality.xls\n";
print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.n50 $up_unigene_dir/$sam-Unigene.n50\n\n";

print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.length.txt $up_unigene_dir/$sam-Unigene.length.txt\n";
print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.length.svg $up_unigene_dir/$sam-Unigene.length.svg\n";
print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.length.png $up_unigene_dir/$sam-Unigene.length.png\n\n";

#print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.gap.txt $up_unigene_dir/$sam-Unigene.gap.txt\n";
#print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.gap.svg $up_unigene_dir/$sam-Unigene.gap.svg\n";
#print UPLOADSH "ln -s $assembly_result_dir/$sam-Unigene.gap.png $up_unigene_dir/$sam-Unigene.gap.png\n\n";

print SUMMARY "ln -s $assembly_result_dir/Trinity.stat $summary_result_dir/Trinity.stat\n\n";
print UPLOADSH "ln -s $assembly_result_dir/Trinity.stat $up_as_dir/Trinity.stat\n\n";

print SAMAS "if [ -f $assembly_result_dir/$sam-Unigene.fa ] ; then\nrm -rf $assembly_result_dir/both.fa* $assembly_result_dir/jellyfish.* $assembly_result_dir/inchworm.* $assembly_result_dir/tmp* $assembly_result_dir/target.* $assembly_result_dir/chrysalis $assembly_result_dir/iworm_* $assembly_result_dir/bowtie.* $assembly_result_dir/*.sam $assembly_result_dir/left.fa $assembly_result_dir/right.fa\nfi\n";
print SAMAS "if [ -d $assembly_result_dir/jaccard_clip_workdir ] ; then\n\trm -rf $assembly_result_dir/jaccard_clip_workdir\nfi\n";
print SAMAS "if [ -d $assembly_result_dir/insilico_read_normalization ] ; then\n\trm -rf $assembly_result_dir/insilico_read_normalization\nfi\n";
close SAMAS;

my $cat_qua_contig=$assembly_result_dir.'/'.$sam.'-Unigene.fa.quality.xls ';

####################################################### Quality

my $quality_dir=$outdir.'/Quality';
system "mkdir -p  $quality_dir" unless(-d $quality_dir);

my $quality_sam_sh=$assembly_dir.'/2_quality.sh';
print ALLSTEP "echo Start Quality at $time\n";
print ALLSTEP "sh $quality_sam_sh\n";
print ALLSTEP "echo Finish Quality at $time\n";

open SAMQUA,'>',$quality_sam_sh or die "can't open the sh of sam as quality $quality_sam_sh";

my $gene=$sample_name.'-Unigene.fa';
my $genepdf=$gene;
$genepdf=~s/\.fa$//;

if ($cat_qua_contig ne '') {
	print SAMQUA "perl $config{denovo_quality_type} -outdir $quality_dir -type Unigene $cat_qua_contig\n";
	print SAMQUA "tail -n +2 $cat_qua_contig | cut -f 1,2 > $quality_dir/$sam-Unigene.fa.len.xls\n";
	print SAMQUA "$config{fq_stat} -name $sample_name -in $stat_list -out $quality_dir/Sequencing_output.xls\n";

	print UPLOADSH "ln -s $quality_dir/Sequencing_output.xls $up_as_dir/Sequencing_output.xls\n\n";

}

my $who=`whoami`;
chomp $who;
my $report_time=`date +%y-%m-%d.%H:%M`;
chomp $report_time;

$option{"denovo_info"} ||="/home/$who/all_denovo_info.xls";
my $all_denovo_info_dir=dirname($option{'denovo_info'});
my $all_denovo_info=$option{'denovo_info'};
my $ownerinfo="$who"."_$report_time";
my $table_head;
if(-f $all_denovo_info){
	$table_head = "n";
}else{
	$table_head = "y";
	system "mkdir -p $all_denovo_info && rmdir $all_denovo_info";
}

############## !!!!!!!!!!!! 此程序还需修改 !!!!!!!!!!! ################
#print SAMQUA "perl $config{get_denovo_info} -lib $lib -fq $filtered_fq_dir -dir $outdir -outfile $all_denovo_info -table_head $table_head -ownerinfo $ownerinfo  2> /dev/null\n";
#print SAMQUA  'echo finish quality at `date +%y-%m-%d.%H:%M:%S` '."\n";
close SAMQUA;

##########################################################################################
####### 计算表达量
##########################################################################################

my $bwt_sh=$exp_dir.'/0_bwt.sh';
open BWT,'>',$bwt_sh or die "can't open the bwt sh $bwt_sh";
print ALLSTEP "\n\n#################### BWT, SOAP, Coverage, RPKM ####################\n\n";
print ALLSTEP "echo Start make BWT Index at $time\n";
print ALLSTEP "sh $bwt_sh\n";
print ALLSTEP "echo Finish make BWT Index at $time\n\n";

my $soap_sh=$exp_dir.'/1_soap.sh';
open SOAPSH,'>',$soap_sh or die "can't open the soap sh $soap_sh";
print ALLSTEP "echo Start SOAP align at $time\n";
print ALLSTEP "sh $soap_sh\n";
print ALLSTEP "echo Finish SOAP align at $time\n\n";

my $coverage_sh=$exp_dir.'/2_coverage.sh';
open COVERSH,'>',$coverage_sh or die "Can't open coverage sh $coverage_sh";
print ALLSTEP "echo Start caculate Coverage at $time\n";
print ALLSTEP "sh $coverage_sh\n";
print ALLSTEP "echo Finish caculate Coverage at $time\n\n";

my $rpkm_sh=$exp_dir.'/3_rpkm.sh';
open RPKM,'>',$rpkm_sh or die "can't open the rpkm sh $rpkm_sh";
print ALLSTEP "echo Start caculate RPKM at $time\n";
print ALLSTEP "sh $rpkm_sh\n";
print ALLSTEP "echo Finish caculate RPKM at $time\n\n";

my $del_pol_sh=$exp_dir.'/4_delete_pollution.sh';
open DELPOL,'>',$del_pol_sh or die "can't open the rpkm sh $del_pol_sh";
#print ALLSTEP "echo Start Delete Pollution at $time\n";
#print ALLSTEP "sh $del_pol_sh\n";
#print ALLSTEP "echo Finish Delete Pollution at $time\n";
print ALLSTEP "# This Step must be done by Manual Operation NOW !!!\n";
print ALLSTEP "# ---> $del_pol_sh\n";

#my $pvalue_sh=$shdir.'/pvalue.sh';
#my $functional_sh=$shdir.'/functional.sh';
#my $snp_sh=$shdir.'/first_snp.sh';

if (exists $option{soap}) {

#############  bwt
	if($gene ne ''){
		print BWT "ln -s $assembly_result_dir/$gene $soap_dir/$gene\n";
		print BWT "ln -s $quality_dir/$sam-Unigene.fa.len.xls $soap_dir/$sam-Unigene.fa.len.xls\n";
		print BWT "$config{'bwt'} $soap_dir/$gene > $soap_dir/$sample_name.bwt.log 2>> $soap_dir/$sample_name.bwt.log && echo finish bwt at `date +%y-%m-%d.%H:%M:%S`\n";
		print SUMMARY "ln -s $soap_dir/$sample_name.bwt.log $logs_dir/$sample_name.bwt.log\n";
	}else{
		print STDERR 'warnings : no fa to bwt for soap '."\n".'you can give the  clustered fa file in lib file by add unigene=xxxx'."\n";
	}
	close BWT;
	print CLEARSH "rm $soap_dir/$gene.index.* && echo finish rm bwt index file\n";

#############  soap
	my $soaplist=$soap_dir.'/soapfile.list';
	open SOAPLIST,'>',$soaplist or die "can't open the soap file list $soaplist ";

	system "mkdir -p $soap_dir/cover " unless (-d "$soap_dir/cover");

	my $soap_out_suffix1="PESoapAlign";
	my $soap_out_suffix2="PESoapSingle";
	my $soap_out_suffix3="PESoapUnmapped";

	if ($option{soap}=~/gz/) {
		$soap_out_suffix1.=".gz";
		$soap_out_suffix2.=".gz";
		$soap_out_suffix3.=".gz";
	}

	my $sam_soap = $sample_name;
	my $sam_soap_num=1;

	my $soap=$option{soap};
	print SOAPSH $config{$soap};

	print SOAPSH " -a $fq1 -b $fq2 " ;
	print SOAPSH ' -D '.$soap_dir.'/'.$gene.'.index ';

	unless (exists $option{soap_option}) {
		$option{soap_option}='-m 0 -x 1000 -s 40 -l 35 -v 3';
	}

	print SOAPSH $option{soap_option};
	print SOAPSH " -o $soap_dir/$sam_soap.$soap_out_suffix1 -2 $soap_dir/$sam_soap.$soap_out_suffix2 -u $soap_dir/$sam_soap.$soap_out_suffix3 2> $soap_dir/$sam_soap.soap.log\n\n";
	print SOAPSH "perl $config{seqStat} -clean $fq1 -soap $soap_dir/$sam_soap.$soap_out_suffix1,$soap_dir/$sam_soap.$soap_out_suffix2 -gene2tr $assembly_result_dir/$sam-Unigene.fa.gene2tr -prefix $soap_dir/$sam_soap.SequencingSaturation > $soap_dir/draw_saturation.log 2>> $soap_dir/draw_saturation.log\n";
	print SOAPSH "$config{'java'} -jar $config{'batik-rasterizer.jar'} $soap_dir/$sam_soap.SequencingSaturation.svg && echo Saturation svg to png at `date +%y-%m-%d.%H:%M:%S`\n";
	close SOAPSH;

	print SUMMARY "ln -s $soap_dir/$sam_soap.soap.log $logs_dir/$sam_soap.soap.log\n\n";
	print SUMMARY "ln -s $soap_dir/draw_saturation.log $logs_dir/draw_saturation.log\n\n";

	print UPLOADSH "ln -s $soap_dir/$sam_soap.SequencingSaturation.svg $up_unigene_dir/$sam_soap.SequencingSaturation.svg\n";
	print UPLOADSH "ln -s $soap_dir/$sam_soap.SequencingSaturation.png $up_unigene_dir/$sam_soap.SequencingSaturation.png\n\n";

	print SOAPLIST "$soap_dir/$sam_soap.$soap_out_suffix1\n$soap_dir/$sam_soap.$soap_out_suffix2";
	close SOAPLIST;

	print CLEARSH "rm $soap_dir/$sam_soap.$soap_out_suffix1 $soap_dir/$sam_soap.$soap_out_suffix2 $soap_dir/$sam_soap.$soap_out_suffix3 && echo finish rm $sam_soap soap \n";

############### coverage

my $gene_name=$sample_name."-Unigene";
	print COVERSH "perl $config{ReadsRandomInGene} $soap_dir/$sam-Unigene.fa.len.xls $soaplist $soap_dir/cover/$gene_name && echo finish ReadsRandomInGene at `date +%y-%m-%d.%H:%M:%S`\n";
	print COVERSH "$config{'java'} -jar $config{'batik-rasterizer.jar'} $soap_dir/cover/$gene_name.ReadsRandom.svg && echo svg to png at `date +%y-%m-%d.%H:%M:%S`\n\n";
	print COVERSH "perl $config{Soap_Coverage} -depth -coverage -fastaq -verbose -keyname $soap_dir/cover/$gene_name $soap_dir/$gene $soaplist && echo finish Soap_Coverage at `date +%y-%m-%d.%H:%M:%S`\n\n";
	print COVERSH "perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/1_Assemble/draw_unigene_vs_reads_distribution.pl $soap_dir/cover/$gene_name.Coverage.xls > $soap_dir/cover/$gene_name.reads_distribution.svg\n";
	print COVERSH "$config{'java'} -jar $config{'batik-rasterizer.jar'} $soap_dir/cover/$gene_name.reads_distribution.svg && echo svg to png at `date +%y-%m-%d.%H:%M:%S`\n";
	print COVERSH "perl /Bio/Bin/pipe/DenovoRNA_additional_analysis_SOFTWARES/bin/Programs_for_denovo_add/3_CDS/stat_unigene_vs_reads_distribution.pl $soap_dir/cover/$gene_name.Coverage.xls > $soap_dir/cover/$gene_name.reads_distribution.xls\n";
	close COVERSH;

	print UPLOADSH "ln -s $soap_dir/cover/$gene_name.ReadsRandom.svg $up_unigene_dir/$gene_name.ReadsRandom.svg\n";
	print UPLOADSH "ln -s $soap_dir/cover/$gene_name.ReadsRandom.png $up_unigene_dir/$gene_name.ReadsRandom.png\n\n";
	print UPLOADSH "ln -s $soap_dir/cover/$gene_name.Coverage.xls $up_unigene_dir/$gene_name.Coverage.xls\n\n";
	print UPLOADSH "ln -s $soap_dir/cover/$gene_name.reads_distribution.svg $up_unigene_dir/$gene_name.reads_distribution.svg\n";
	print UPLOADSH "ln -s $soap_dir/cover/$gene_name.reads_distribution.png $up_unigene_dir/$gene_name.reads_distribution.png\n";
	print UPLOADSH "ln -s $soap_dir/cover/$gene_name.reads_distribution.xls $up_unigene_dir/$gene_name.reads_distribution.xls\n\n";

############## rpkm

	my $diff_gene=$soap_dir.'/'.$gene;
	my $genelen=$soap_dir.'/'.$gene.'.quality.xls';

	print CLEARSH "rm $fq1 $fq2\n";
	print CLEARSH "rm -r $fq_tmp\n\n";
	print RPKM "perl $config{rpkm} -len $soap_dir/$sam-Unigene.fa.len.xls -list $soaplist -out $rpkm_dir/rpkm.xls && echo finish get rpkm at `date +%y-%m-%d.%H:%M:%S`\n";
	print RPKM "perl $config{drag_top_reads_num_fa} -top_n 20 -fa $soap_dir/$gene -list $rpkm_dir/sorted_by_reads.xls -out $rpkm_dir/reads_num_top_20.fa && echo finish get top 20 reads num fasta at `date +%y-%m-%d.%H:%M:%S`\n";
	print RPKM "perl $config{rpkm_stat} $rpkm_dir/rpkm.xls $soap_dir/$sam_soap.soap.log $rpkm_dir/$sam.rpkm.stat\n";
	close RPKM;

	print DELPOL "\ntouch $rpkm_dir/del_list\n\n";
	print DELPOL "# Now you perhaps already got the top 20 expressed unigenes : $rpkm_dir/reads_num_top_20.fa\n";
	print DELPOL "# The list order of it is according to the Reads Num from high to low\n";
	print DELPOL "# You may write the delete list by blastn these 20 highly expressed unigenes to nt database through this page:\n";
	print DELPOL "# http://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome\n\n";
	print DELPOL "# Once the delete list has been writen, you can run the program as follows:\n\n";
	print DELPOL "perl $config{delete_by_unigene_id} -fa $soap_dir/$gene -del_list $rpkm_dir/del_list -out $rpkm_dir/RNAseq_used_ref.fa";
	close DELPOL;

}

##########################################################################################
#############  注释
##########################################################################################

my $blast_annot=$annot_dir."/blast_annot.sh";
open ANNOT,'>',$blast_annot or die "can't open the blast pl $blast_annot";
print ALLSTEP "\n\n#################### BLAST, GO, CDS, SSR, Pfam ####################\n\n";
print ALLSTEP "echo Start BLAST+ Database Annot at $time\n";
print ALLSTEP "sh $blast_annot\n";
print ALLSTEP "echo Finish BLAST+ Database Annot at $time\n\n";

my $blast_cog_sh=$annot_dir.'/0_blast_cog.sh';
my $blast_swsp_sh=$annot_dir.'/0_blast_swsp.sh';
my $blast_kegg_sh=$annot_dir.'/0_blast_kegg.sh';
my $blast_nr_sh=$annot_dir.'/0_blast_nr.sh';

my $annot_cog_sh=$annot_dir.'/1_annot_cog.sh';
my $annot_swsp_sh=$annot_dir.'/1_annot_swsp.sh';
my $annot_kegg_sh=$annot_dir.'/1_annot_kegg.sh';
my $annot_nr_sh=$annot_dir.'/1_annot_nr.sh';

my $db_dir_cog = $db_dir.'/COG';
my $db_dir_swsp = $db_dir.'/SwissProt';
my $db_dir_kegg = $db_dir.'/KEGG';
my $db_dir_nr = $db_dir.'/Nr';

#	print SUMMARY <<TEMSUMMARY;

#if [ -f $rpkm_dir/RNAseq_used_ref.fa ] ; then
#	ln -s $rpkm_dir/RNAseq_used_ref.fa $ref_dir/RNAseq_used_ref.fa
#else
#	ln -s $assembly_result_dir/$sam-Unigene.fa $ref_dir/RNAseq_used_ref.fa
#fi

#TEMSUMMARY
	print SUMMARY "ln -s $rpkm_dir/RNAseq_used_ref.fa $ref_dir/RNAseq_used_ref.fa\n\n";

print ANNOT "ln -s $assembly_result_dir/$sam-Unigene.fa $annot_result_dir/$gene\n\n";
print ANNOT "perl $config{fastaDeal} -cutf $option{cut_num} $annot_result_dir/$gene -outdir $annot_result_dir\n\n";
my $success_num = $option{cut_num} + 1;

if ($option{blast_cog} eq "yes"){

	system "mkdir -p $blast_result_dir/COG_result";
	print ANNOT "perl $config{cmd_process_forker} --CPU $option{cog_processes} -c $blast_cog_sh > $annot_result_dir/blast_cog.log 2>> $annot_result_dir/blast_cog.log \n";
	print ANNOT "error_cog=\$(grep -i \"Error\" $annot_result_dir/blast_cog.log)\nif [ -n \"\$error_cog\" ]\nthen echo COG BLAST went Wrong !!!\n";
	print ANNOT "elif [ \$(grep -i \"success\" $annot_result_dir/blast_cog.log | wc -l) != $success_num ]\nthen echo There are some step remain to BLAST COG !!!\nelse echo All the $option{cut_num} fasta had been blasted COG successfully; sh $annot_cog_sh\nfi\n\n";

	print SUMMARY "ln -s $annot_result_dir/blast_cog.log $logs_dir/blast_cog.log\n\n";

	system "mkdir -p $db_dir_cog" unless(-d $db_dir_cog);

	open ANNOT_COG,'>',$annot_cog_sh or die "can't open the sh $annot_cog_sh";
	open BLAST_COG,'>',$blast_cog_sh or die "can't open the sh $blast_cog_sh";

	print ANNOT_COG "cat $blast_result_dir/COG_result/*.blast.cog > $db_dir_cog/$gene.blast.cog && echo finish cat cog at $time\n\n";
	print ANNOT_COG "perl $config{get_annot_info} $option{blast_parser_option} -input $db_dir_cog/$gene.blast.cog -out $db_dir_cog/$gene.blast.cog.xls -id $config{cog_id} && echo finish blast_parser cog at $time\n\n";
	print ANNOT_COG "perl $config{cog_parser} $db_dir_cog/$gene.blast.cog.xls && echo finish cog_parser at $time\n\n";
	print ANNOT_COG "mv $db_dir_cog/$gene.blast.cog.xls.cog.class $db_dir_cog/$gene.cog.gene.annot.xls \n\n";
	print ANNOT_COG "mv $db_dir_cog/$gene.blast.cog.xls.class.gene $db_dir_cog/$gene.cog.class.annot.xls\n\n";
	print ANNOT_COG "perl $config{cog_R} $db_dir_cog/$gene.cog.class.annot.xls $db_dir_cog/$gene.cog $gene && echo finish draw cog pdf at $time\n\n";
	close ANNOT_COG;
}

if ($option{blast_swsp} eq "yes"){

	system "mkdir -p $blast_result_dir/SWSP_result";
	print ANNOT "perl $config{cmd_process_forker} --CPU $option{swsp_processes} -c $blast_swsp_sh > $annot_result_dir/blast_swsp.log 2>> $annot_result_dir/blast_swsp.log \n";
	print ANNOT "error_swsp=\$(grep -i \"Error\" $annot_result_dir/blast_swsp.log)\nif [ -n \"\$error_swsp\" ]\nthen echo SwissProt BLAST went Wrong !!!\n";
	print ANNOT "elif [ \$(grep -i \"success\" $annot_result_dir/blast_swsp.log | wc -l) != $success_num ]\nthen echo There are some step remain to BLAST SwissProt !!!\nelse echo All the $option{cut_num} fasta had been blasted SwissProt successfully; sh $annot_swsp_sh\nfi\n\n";

	print SUMMARY "ln -s $annot_result_dir/blast_swsp.log $logs_dir/blast_swsp.log\n\n";

	system "mkdir -p $db_dir_swsp" unless(-d $db_dir_swsp);

	open ANNOT_SWSP,'>',$annot_swsp_sh or die "can't open the sh $annot_swsp_sh";
	open BLAST_SWSP,'>',$blast_swsp_sh or die "can't open the sh $blast_swsp_sh";

	print ANNOT_SWSP "cat $blast_result_dir/SWSP_result/*.blast.swsp > $db_dir_swsp/$gene.blast.swsp && echo finish cat swissprot at $time\n\n";
	print ANNOT_SWSP "perl $config{get_annot_info} $option{blast_parser_option} -input $db_dir_swsp/$gene.blast.swsp -out $db_dir_swsp/$gene.blast.swsp.xls -id $config{swi_id} && echo finish blast_parser swissprot at $time\n\n";
	close ANNOT_SWSP;
}
if ($option{blast_kegg} eq "yes"){

	system "mkdir -p $blast_result_dir/KEGG_result";
	print ANNOT "perl $config{cmd_process_forker} --CPU $option{kegg_processes} -c $blast_kegg_sh > $annot_result_dir/blast_kegg.log 2>> $annot_result_dir/blast_kegg.log \n";
	print ANNOT "error_kegg=\$(grep -i \"Error\" $annot_result_dir/blast_kegg.log)\nif [ -n \"\$error_kegg\" ]\nthen echo KEGG BLAST went Wrong !!!\n";
	print ANNOT "elif [ \$(grep -i \"success\" $annot_result_dir/blast_kegg.log | wc -l) != $success_num ]\nthen echo There are some step remain to BLAST SwissProt !!!\nelse echo All the $option{cut_num} fasta had been blasted KEGG successfully; sh $annot_kegg_sh\nfi\n\n";

	print SUMMARY "ln -s $annot_result_dir/blast_kegg.log $logs_dir/blast_kegg.log\n\n";

	system "mkdir -p $db_dir_kegg" unless(-d $db_dir_kegg);

	open ANNOT_KEGG,'>',$annot_kegg_sh or die "can't open the sh $annot_kegg_sh";
	open BLAST_KEGG,'>',$blast_kegg_sh or die "can't open the sh $blast_kegg_sh";

	my $kegg_id_defined = $option{kegg_db}."_id";
	print ANNOT_KEGG "cat $blast_result_dir/KEGG_result/*.blast.kegg > $db_dir_kegg/$gene.blast.kegg && echo finish cat kegg at $time\n\n";
	print ANNOT_KEGG "perl $config{get_annot_info} $option{blast_parser_option} -input $db_dir_kegg/$gene.blast.kegg -out $db_dir_kegg/$gene.blast.kegg.xls -id $config{$kegg_id_defined} && echo finish blast_parser kegg at $time\n\n";
	print ANNOT_KEGG "perl $config{blast2ko} -input $annot_result_dir/$gene -type blastout -output $db_dir_kegg/$gene.ko -blastout $db_dir_kegg/$gene.blast.kegg && echo finish blast2ko class at $time\n\n";
	my $map_defined = $option{kegg_db};
	$map_defined =~ s/kegg_/map_/;
	print ANNOT_KEGG "perl $config{pathfind} -komap $config{$map_defined} -fg $db_dir_kegg/$gene.ko -output $db_dir_kegg/$gene.path && echo finish pathfind at $time\n\n";
	print ANNOT_KEGG "perl $config{keggMap_nodiff} -komap $config{$map_defined} -ko $db_dir_kegg/$gene.ko -outdir $db_dir_kegg/$gene\_map && echo finish keggMap_nodiff at $time\n\n";
	print ANNOT_KEGG "perl $config{genPathHTML} -indir $db_dir_kegg && echo finish genPathHTML at $time\n\n";
	print ANNOT_KEGG "ln -s $db_dir_kegg/$gene.ko $ref_dir/$gene.ko\n";
	print ANNOT_KEGG "ln -s $db_dir_kegg/$gene.path $ref_dir/$gene.path\n";
	close ANNOT_KEGG;
}
if ($option{blast_nr} eq "yes"){

	system "mkdir -p $blast_result_dir/Nr_result";
	print ANNOT "perl $config{cmd_process_forker} --CPU $option{nr_processes} -c $blast_nr_sh > $annot_result_dir/blast_nr.log 2>> $annot_result_dir/blast_nr.log \n";
	print ANNOT "error_nr=\$(grep -i \"Error\" $annot_result_dir/blast_nr.log)\nif [ -n \"\$error_nr\" ]\nthen echo Nr BLAST went Wrong !!!\n";
	print ANNOT "elif [ \$(grep -i \"success\" $annot_result_dir/blast_nr.log | wc -l) != $success_num ]\nthen echo There are some step remain to BLAST Nr !!!\nelse echo All the $option{cut_num} fasta had been blasted Nr successfully; sh $annot_nr_sh\nfi\n\n";

	print SUMMARY "ln -s $annot_result_dir/blast_nr.log $logs_dir/blast_nr.log\n\n";

	system "mkdir -p $db_dir_nr" unless(-d $db_dir_nr);

	open ANNOT_NR,'>',$annot_nr_sh or die "can't open the sh $annot_nr_sh";
	open BLAST_NR,'>',$blast_nr_sh or die "can't open the sh $blast_nr_sh";

	print ANNOT_NR "cat $blast_result_dir/Nr_result/*.blast.nr > $db_dir_nr/$gene.blast.nr && echo finish cat nr at $time\n\n";
	print ANNOT_NR "perl $config{blast_parser_New} $option{blast_parser_option} $db_dir_nr/$gene.blast.nr > $db_dir_nr/$gene.blast.Nr.xls && echo finish blast_parser Nr at $time\n\n";
	close ANNOT_NR;

}

#print UPLOADSH "ln -s $config{'COG.readme.txt'} $up_cog_dir/COG.readme.txt\n";
print UPLOADSH "ln -s $db_dir_cog/$gene.blast.cog.xls $up_cog_dir/$gene.blast.cog.xls\n";
print UPLOADSH "ln -s $db_dir_cog/$gene.cog.gene.annot.xls $up_cog_dir/$gene.cog.gene.annot.xls\n";
print UPLOADSH "ln -s $db_dir_cog/$gene.cog.class.annot.xls $up_cog_dir/$gene.cog.class.annot.xls\n";
print UPLOADSH "ln -s $db_dir_cog/$gene.cog.pdf $up_cog_dir/$gene.cog.pdf\n";
print UPLOADSH "ln -s $db_dir_cog/$gene.cog.png $up_cog_dir/$gene.cog.png\n\n";

#print UPLOADSH "ln -s $config{'KEGG.readme.txt'} $up_kegg_dir/KEGG.readme.txt\n";
print UPLOADSH "ln -s $db_dir_kegg/$gene.blast.kegg.xls $up_kegg_dir/$gene.blast.kegg.xls\n";
print UPLOADSH "ln -s $db_dir_kegg/$gene.ko $up_kegg_dir/$gene.ko\n";
print UPLOADSH "ln -s $db_dir_kegg/$gene.path $up_kegg_dir/$gene.path\n";
print UPLOADSH "ln -s $db_dir_kegg/$gene.htm $up_kegg_dir/$gene.htm\n";
print UPLOADSH "ln -s $db_dir_kegg/$gene\_map $up_kegg_dir/$gene\_map\n\n";

#print UPLOADSH "ln -s $config{'Nr.readme.txt'} $up_nr_dir/Nr.readme.txt\n";
print UPLOADSH "ln -s $db_dir_nr/$gene.blast.Nr.xls $up_nr_dir/$gene.blast.Nr.xls\n\n";

#print UPLOADSH "ln -s $config{'Swissprot.readme.txt'} $up_swsp_dir/Swissprot.readme.txt\n";
print UPLOADSH "ln -s $db_dir_swsp/$gene.blast.swsp.xls $up_swsp_dir/$gene.blast.swsp.xls\n\n";

print ANNOT "perl $config{get_sam_by_rpkm_new} -rpkm $rpkm_dir/rpkm.xls -output $annot_result_dir/$gene.rpkm.annot.xls -nr $db_dir_nr/$gene.blast.Nr.xls -swissprot $db_dir_swsp/$gene.blast.swsp.xls -cog $db_dir_cog/$gene.cog.gene.annot.xls -kegg $db_dir_kegg/$gene.ko && echo finish add blast annot to rpkm at $time\n";
print SUMMARY "ln -s $annot_result_dir/$gene.rpkm.annot.xls $summary_result_dir/$gene.rpkm.annot.xls\n";

for my $i (1..$option{cut_num}){
	if ($option{blast_cog} eq "yes"){
		print BLAST_COG "$config{blastx} -seg no -query $annot_result_dir/$gene.cut/$gene.$i -db $config{cog} -outfmt 6 -num_threads $option{cog_threads} -evalue $option{e_value} -out $blast_result_dir/COG_result/$gene.$i.blast.cog\n";
	}
#		print BLAST_COG "/usr/bin/blastall -e 1e-5 -F F -d $config{cog} -i $annot_result_dir/$gene.cut/$gene.$i -m 8 -o $annot_result_dir/$gene.cut/$gene.$i.cog.old -p blastx -a 3\n";

	if ($option{blast_swsp} eq "yes"){
		print BLAST_SWSP "$config{blastx} -seg no -query $annot_result_dir/$gene.cut/$gene.$i -db $config{swissprot} -outfmt 6 -num_threads $option{swsp_threads} -evalue $option{e_value} -out $blast_result_dir/SWSP_result/$gene.$i.blast.swsp\n";
	}
#		print BLAST_SWSP "/usr/bin/blastall -e 1e-5 -F F -d $config{swissprot} -i $annot_result_dir/$gene.cut/$gene.$i -m 8 -o $annot_result_dir/$gene.cut/$gene.$i.swsp.old -p blastx -a 3\n";

	if ($option{blast_kegg} eq "yes"){
		print BLAST_KEGG "$config{blastx} -seg no -query $annot_result_dir/$gene.cut/$gene.$i -db $config{$option{kegg_db}} -outfmt 6 -num_threads $option{kegg_threads} -evalue $option{e_value} -out $blast_result_dir/KEGG_result/$gene.$i.blast.kegg\n";
	}
#		print BLAST_KEGG "/usr/bin/blastall -e 1e-5 -F F -d $config{$option{kegg_db}} -i $annot_result_dir/$gene.cut/$gene.$i -m 8 -o $annot_result_dir/$gene.cut/$gene.$i.kegg.old -p blastx -a 3\n";

	if ($option{blast_nr} eq "yes"){
		print BLAST_NR "$config{blastx} -seg no -query $annot_result_dir/$gene.cut/$gene.$i -db $config{$option{nr_db}} -num_threads $option{nr_threads} -evalue $option{e_value} -out $blast_result_dir/Nr_result/$gene.$i.blast.nr\n";
	}
#		print BLAST_NR "/usr/bin/blastall -e 1e-5 -F F -d $config{$option{nr_db}} -i $annot_result_dir/$gene.cut/$gene.$i -o $annot_result_dir/$gene.cut/$gene.$i.nr.old -p blastx -a 3\n";
}

close BLAST_COG;
close BLAST_SWSP;
close BLAST_KEGG;
close BLAST_NR;


################################# BLAST2GO

my $nr2go=$go_cds_ssr_pfam."/0_nr2go.sh";
open NR2GO,'>',$nr2go or die "can't open the nr2go sh $nr2go";
print ALLSTEP "echo Start BLAST+ Nr Annot to GO at $time\n";
print ALLSTEP "sh $nr2go\n";
print ALLSTEP "echo Finish BLAST+ Nr Annot to GO at $time\n\n";

if (exists $option{nr2go_option}) {
	print NR2GO "ln -s $db_dir_nr/$gene.blast.nr $go_dir/$gene.blast.nr\n";
	print NR2GO "perl $config{'blast+_m0_m5_ww'} $option{nr2go_option} -input $go_dir/$gene.blast.nr -output $go_dir/$gene.blast.nr.xml && echo finish m0 to xml at $time\n\n";

	print NR2GO "$config{java} -Xms5g -Xmx20g -jar $config{'blast2go.jar'} -prop $config{'b2gPipe.properties'} -a -in $go_dir/$gene.blast.nr.xml -out $go_dir/$gene.blast.nr.xml > $go_dir/blast2go.log 2>> $go_dir/blast2go.log && echo finish get annot from xml at $time\n\n";

	print SUMMARY "ln -s $go_dir/blast2go.log $logs_dir/blast2go.log\n\n";
	print CLEARSH "\nrm $db_dir_nr/$gene.blast.nr\n";
	print CLEARSH "\nrm $go_dir/$gene.blast.nr.xml\n\n";

	print NR2GO "perl $config{annot2wego} -i $go_dir/$gene.blast.nr.xml.annot -outdir $go_dir/ && echo finish get wego file at $time\n";
	print NR2GO "perl $config{annot2goa} $go_dir/$gene.blast.nr.xml.annot $go_dir/$gene && echo finish annot2go at $time\n\n";
	print NR2GO "ln -s $go_dir/$gene.blast.nr.xml.wego $ref_dir/$gene.wego\n";
	print NR2GO "ln -s $go_dir/$gene.C $ref_dir/$gene.C\n";
	print NR2GO "ln -s $go_dir/$gene.F $ref_dir/$gene.F\n";
	print NR2GO "ln -s $go_dir/$gene.P $ref_dir/$gene.P\n";
	print NR2GO "ln -s $go_dir/C.conf  $go_dir/F.conf  $go_dir/P.conf $ref_dir/\n\n";
	print NR2GO "perl $config{drawGO_sort} -gglist $go_dir/$gene.blast.nr.xml.wego -output $go_dir/$gene.GO -go $config{go_class} && echo finish draw svg at $time\n";
	print NR2GO "$config{java} -jar $config{'batik-rasterizer.jar'} -m image/png $go_dir/$gene.GO.svg && echo finish draw go svg to png at $time\n\n";

	print NR2GO "perl $config{addGOAnnot} -go $go_dir/$gene -input $annot_result_dir/$gene.rpkm.annot.xls -output $annot_result_dir/annotation.xls && echo finish add go to rpkm at $time\n\n";
	print NR2GO "cut -f 1,8 $annot_result_dir/annotation.xls > $annot_result_dir/$gene.desc\n";
	print NR2GO "ln -s $annot_result_dir/$gene.desc $ref_dir/$gene.desc\n\n";
	print NR2GO "perl $config{stat_top_hit_species} $annot_result_dir/annotation.xls 8 > $annot_result_dir/Nr.species.stat.xls\n";
	print NR2GO "perl $config{draw_species_hist} $annot_result_dir/Nr.species.stat.xls > $annot_result_dir/Nr.species.stat.xls.svg\n";
	print NR2GO "$config{java} -jar $config{'batik-rasterizer.jar'} -m image/png $annot_result_dir/Nr.species.stat.xls.svg && echo finish draw species svg to png at $time\n\n";
	close NR2GO;

	print SUMMARY "ln -s $annot_result_dir/annotation.xls $summary_result_dir/annotation.xls\n";
	print SUMMARY "ln -s $annot_result_dir/Nr.species.stat.xls $summary_result_dir/Nr.species.stat.xls\n";

	print UPLOADSH "ln -s $annot_result_dir/Nr.species.stat.xls $up_anno_dir/Nr.species.stat.xls\n";
	print UPLOADSH "ln -s $annot_result_dir/Nr.species.stat.xls.svg $up_anno_dir/Nr.species.stat.xls.svg\n";
	print UPLOADSH "ln -s $annot_result_dir/Nr.species.stat.xls.png $up_anno_dir/Nr.species.stat.xls.png\n\n";
	print UPLOADSH "ln -s $annot_result_dir/annotation.xls $up_anno_dir/annotation.xls\n\n";
#	print UPLOADSH "ln -s $config{'annotation.readme.txt'} $up_anno_dir/annotation.readme.txt\n\n";

#	print UPLOADSH "ln -s $config{'GO.readme.txt'} $up_go_dir/GO.readme.txt\n";
	print UPLOADSH "ln -s $go_dir/$gene.GO.xls $up_go_dir/$gene.GO2gene.xls\n";
	print UPLOADSH "ln -s $go_dir/$gene.blast.nr.xml.wego $up_go_dir/$gene.gene2GO.xls\n";
	print UPLOADSH "ln -s $go_dir/$gene.GO.svg $up_go_dir/$gene.GO.svg\n";
	print UPLOADSH "ln -s $go_dir/$gene.GO.png $up_go_dir/$gene.GO.png\n";

	my $godb=<<GODB;
blast2go = $config{'blast2go.jar'}
b2gPipe_properties = $config{'b2gPipe.properties'}
go_class = $config{go_class}
go_alias = $config{go_alias}
GODB

	open GODBFILE,'>',$con_dir.'/go_db.txt' or die "can't open the go db file info";
	print GODBFILE $godb;
	close GODBFILE;

	open WEGOHEAD,'>',$go_dir.'/wego.head' or die "can't open the head of wego ";
	print WEGOHEAD "geneID\tGO\n";
	close WEGOHEAD;

}

##########################################################################################
############# ESTscan
##########################################################################################

my $cds_sh=$go_cds_ssr_pfam."/1_cds.sh";
open CDSSH,'>',$cds_sh or die "can't open the cds sh $cds_sh";
print ALLSTEP "echo Start CDS prediction at $time\n";
print ALLSTEP "sh $cds_sh\n";
print ALLSTEP "echo Finish CDS prediction at $time\n\n";

my $est_dir=$cds_result_dir.'/ESTscan';
system "mkdir -p  $est_dir " unless(-d $est_dir);

my $gene_name=$gene;
$gene_name=~s/\.fa$// if ($gene ne '');

if (exists $option{"cds_len"}){

	my $cwd_cat_xls;
	my $cwd_cat_xls_sign;

	if ($option{blast_nr} eq "yes") {
		$cwd_cat_xls.="$db_dir_nr/$gene.blast.Nr.xls,";
		$cwd_cat_xls_sign.=" -nr $db_dir_nr/$gene.blast.Nr.xls ";
	}
	if ($option{blast_swsp} eq "yes") {
		$cwd_cat_xls.="$db_dir_swsp/$gene.blast.swsp.xls,";
		$cwd_cat_xls_sign.=" -swissprot $db_dir_swsp/$gene.blast.swsp.xls ";
	}
	if ($option{blast_kegg} eq "yes") {
		$cwd_cat_xls.="$db_dir_kegg/$gene.blast.kegg.xls,";
		$cwd_cat_xls_sign.=" -kegg $db_dir_kegg/$gene.blast.kegg.xls ";
	}
	if ($option{blast_cog} eq "yes") {
		$cwd_cat_xls.="$db_dir_cog/$gene.blast.cog.xls";
		$cwd_cat_xls_sign.=" -cog $db_dir_cog/$gene.blast.cog.xls ";
	}

	print CDSSH "ln -s $assembly_result_dir/$sam-Unigene.fa $cds_result_dir/$gene\n";

	print CDSSH "perl $config{get_cds_blast} -fa $cds_result_dir/$gene -xls $cwd_cat_xls -out $cds_result_dir/$gene_name.blast -L $option{cds_len}\n";
	if(-e "$est_dir/mrna.seq"){
		print CDSSH "rm -r $est_dir/*\n";
	}
	print CDSSH <<TEMPSH;
ln -s $cds_result_dir/$gene_name.blast.mrna.fa $est_dir/mrna.seq

perl $config{prepare_data} -e $cds_result_dir/$gene_name.conf > $cds_result_dir/prepare_data.log 2>> $cds_result_dir/prepare_data.log
perl $config{build_model} $cds_result_dir/$gene_name.conf > $cds_result_dir/build_model.log 2>> $cds_result_dir/build_model.log

$config{estscan} $cds_result_dir/$gene_name.blast.no.fa -o $cds_result_dir/$gene_name.ESTscan.cds.fa.score -t $cds_result_dir/$gene_name.ESTscan.protein.fa.score -M $est_dir/Matrices/*.smat

perl $config{clear_score}  $cds_result_dir/$gene_name.ESTscan.cds.fa.score $cds_result_dir/$gene_name.ESTscan.cds.fa -debug
perl $config{clear_score}  $cds_result_dir/$gene_name.ESTscan.protein.fa.score  $cds_result_dir/$gene_name.ESTscan.protein.fa -debug

perl $config{fa_quality}  -len -Head -gap -N -gc $cds_result_dir/$gene_name.blast.cds.fa
perl $config{fa_quality}  -len -Head -gap -N -gc $cds_result_dir/$gene_name.ESTscan.cds.fa
perl $config{fa_quality}  -len -Head  $cds_result_dir/$gene_name.blast.protein.fa
perl $config{fa_quality}  -len -Head  $cds_result_dir/$gene_name.ESTscan.protein.fa

perl $config{barplot}  $cds_result_dir/$gene_name.blast.cds.fa.quality.xls  $gene_name.blast.cds.fa
perl $config{barplot}  $cds_result_dir/$gene_name.ESTscan.cds.fa.quality.xls  $gene_name.ESTscan.cds.fa
perl $config{barplot_protein}  $cds_result_dir/$gene_name.blast.protein.fa.quality.xls  $gene_name.blast.protein.fa
perl $config{barplot_protein}  $cds_result_dir/$gene_name.ESTscan.protein.fa.quality.xls  $gene_name.ESTscan.protein.fa
TEMPSH

	print SUMMARY "ln -s $cds_result_dir/prepare_data.log $logs_dir/cds_prepare_data.log\n";
	print SUMMARY "ln -s $cds_result_dir/build_model.log $logs_dir/cds_build_model.log\n\n";

	open ESTCONF,'>',$cds_result_dir.'/'.$gene_name.'.conf' or die "can't open the conf of ESTscan $cds_result_dir/$gene_name.conf";
	print ESTCONF <<TEMPCONG;

################################################################################
#
# Parameters for $gene_name
# (use PERL syntax!)
#
\$organism = \"$gene_name\";\
\$hightaxo = \"\";
\$dbfiles =\"\";
\$ugdata = \"\";
\$estdata = \"\";
\$datadir = \"$est_dir\";
\$nb_isochores = 2;
\$tuplesize = 6;
\$minmask = 30;
#
# End of File
#
################################################################################

TEMPCONG
	close ESTCONF;

	print CLEARSH 'rm -r '.$est_dir.'/*  && echo finish rm ESTsan cds mid files at time '.$time."\n";

##########################################################################################
############# gene orientation
##########################################################################################

	print CDSSH "\nperl $config{sign}";
	print CDSSH " -ESTscan $cds_result_dir/$gene_name.ESTscan.cds.fa -fa $cds_result_dir/$gene -outdir $cds_result_dir $cwd_cat_xls_sign";
	print CDSSH " && echo finish get the sign from blast and ESTscan at time $time\n";

	print CDSSH "perl $config{Seq_N} $cds_result_dir/$gene_name.5-3.fa > $cds_result_dir/$gene_name.5-3.n50\n\n";

	print CDSSH "ln -s $annot_result_dir/Nr.species.stat.xls $rela_sp_dir/Nr.species.stat.xls\n";
	print CDSSH "ln -s $soap_dir/cover/$gene_name.Coverage.xls $rela_sp_dir/$gene_name.Coverage.xls\n";
	print CDSSH "cat $cds_result_dir/$gene_name.blast.cds.fa $cds_result_dir/$gene_name.ESTscan.cds.fa > $rela_sp_dir/$sam.cds.fa\n\n";
	print CDSSH "perl $config{cut_id} $rela_sp_dir/$sam.cds.fa > $rela_sp_dir/$sam.cds.cut_id.fa\n";
	print CDSSH "cd $rela_sp_dir/\n";
	print CDSSH "/usr/bin/formatdb -i $rela_sp_dir/$sam.cds.cut_id.fa -p F\n";
	print CDSSH "perl $config{find_rela_sp} -name $sam -sp_file $rela_sp_dir/Nr.species.stat.xls -species_dir $option{species_cds_dir} -outdir $rela_sp_dir -upload_cds_dir $up_rela_sp_dir\n";
	if ($option{designated_sp} ne "none"){
		open DSPS,">$rela_sp_dir/designated_species.stat.xls" or die $!;
		my @dsps = split /,/,$option{designated_sp};
		for my $dsp (@dsps){
			print DSPS "$dsp\t99999\n";
		}
		close DSPS;
		print CDSSH "\nperl $config{find_designed_rela_sp} -name $sam -sp_file $rela_sp_dir/designated_species.stat.xls -species_dir $option{species_cds_dir} -outdir $rela_sp_dir -upload_cds_dir $up_rela_sp_dir\n";
	}
	print CDSSH "cd $shdir/\n";

	close CDSSH;

	print UPLOADSH "ln -s $cds_result_dir/$gene_name.orientation.xls $up_unigene_dir/$gene_name.orientation.xls\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.no_orientation.fa $up_unigene_dir/$gene_name.no_orientation.fa\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.5-3.fa $up_unigene_dir/$gene_name.5-3.fa\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.5-3.n50 $up_unigene_dir/$gene_name.5-3.n50\n\n";

	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.protein.fa $up_cds_dir/$gene_name.blast.protein.fa\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa $up_cds_dir/$gene_name.blast.cds.fa\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa $up_cds_dir/$gene_name.ESTscan.cds.fa\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.protein.fa $up_cds_dir/$gene_name.ESTscan.protein.fa\n\n";

	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa.length.txt $up_cds_dir/$gene_name.blast.cds.fa.length.txt\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa.length.svg $up_cds_dir/$gene_name.blast.cds.fa.length.svg\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa.length.png $up_cds_dir/$gene_name.blast.cds.fa.length.png\n\n";

#	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa.gap.txt $up_cds_dir/$gene_name.blast.cds.fa.gap.txt\n";
#	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa.gap.svg $up_cds_dir/$gene_name.blast.cds.fa.gap.svg\n";
#	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.cds.fa.gap.png $up_cds_dir/$gene_name.blast.cds.fa.gap.png\n\n";

	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa.length.txt $up_cds_dir/$gene_name.ESTscan.cds.fa.length.txt\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa.length.svg $up_cds_dir/$gene_name.ESTscan.cds.fa.length.svg\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa.length.png $up_cds_dir/$gene_name.ESTscan.cds.fa.length.png\n\n";

#	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa.gap.txt $up_cds_dir/$gene_name.ESTscan.cds.fa.gap.txt\n";
#	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa.gap.svg $up_cds_dir/$gene_name.ESTscan.cds.fa.gap.svg\n";
#	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.cds.fa.gap.png $up_cds_dir/$gene_name.ESTscan.cds.fa.gap.png\n\n";

	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.protein.fa.length.txt $up_cds_dir/$gene_name.blast.protein.fa.length.txt\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.protein.fa.length.svg $up_cds_dir/$gene_name.blast.protein.fa.length.svg\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.blast.protein.fa.length.png $up_cds_dir/$gene_name.blast.protein.fa.length.png\n\n";

	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.protein.fa.length.txt $up_cds_dir/$gene_name.ESTscan.protein.fa.length.txt\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.protein.fa.length.svg $up_cds_dir/$gene_name.ESTscan.protein.fa.length.svg\n";
	print UPLOADSH "ln -s $cds_result_dir/$gene_name.ESTscan.protein.fa.length.png $up_cds_dir/$gene_name.ESTscan.protein.fa.length.png\n\n";

	print UPLOADSH "ln -s $config{'blast-2.2.23-ia32-win32.exe'} $up_cds_dir/blast-2.2.23-ia32-win32.exe\n";
	print UPLOADSH "ln -s $config{'formatN.bat'} $up_cds_dir/formatN.bat\n";
	print UPLOADSH "ln -s $config{'formatP.bat'} $up_cds_dir/formatP.bat\n";
	print UPLOADSH "ln -s $config{'runBlastn.bat'} $up_cds_dir/runBlastn.bat\n";
	print UPLOADSH "ln -s $config{'runBlastx.bat'} $up_cds_dir/runBlastx.bat\n";
	print UPLOADSH "ln -s $config{'usage.txt'} $up_cds_dir/usage.txt\n\n";

	print UPLOADSH "if [ -s $rela_sp_dir/find_related_species.ok ]; then\n\tsh $rela_sp_dir/find_related_species.ok\nfi\n\n";
	print UPLOADSH "if [ -e $rela_sp_dir/find_designed_related_species.ok ]; then\n\tsh $rela_sp_dir/find_designed_related_species.ok\nfi\n\n";

}

my $ssr_sh=$go_cds_ssr_pfam."/2_ssr.sh";
open SSRSH,'>',$ssr_sh or die "can't open the ssr sh $ssr_sh";
print ALLSTEP "echo Start SSR prediction at $time\n";
print ALLSTEP "sh $ssr_sh\n";
print ALLSTEP "echo Finish SSR prediction at $time\n\n";

print SSRSH "ln -s $assembly_result_dir/$sam-Unigene.fa $ssr_result_dir/$gene\n";
print SSRSH "perl $config{misa} $ssr_result_dir/$gene\n";
print SSRSH "perl $config{misa_result_ssr_statistic} $ssr_result_dir/$gene.statistics \n";
print SSRSH "perl $config{draw_zhifang_svg} $ssr_result_dir/$gene.statistics.drawSVG.txt > $ssr_result_dir/$gene.statistics.distribution_of_ssr.svg\n";
print SSRSH "$config{java} -jar $config{'batik-rasterizer.jar'} -m image/png $ssr_result_dir/$gene.statistics.distribution_of_ssr.svg\n";
print SSRSH "perl $config{p3_in} $ssr_result_dir/$gene.misa > $ssr_result_dir/$gene.p3_primer3.log\n";
print SSRSH "$config{primer3_core} < $ssr_result_dir/$gene.p3in > $ssr_result_dir/$gene.p3out\n";
print SSRSH "perl $config{p3_out} $ssr_result_dir/$gene.p3out $ssr_result_dir/$gene.misa >>$ssr_result_dir/$gene.p3_primer3.log\n";
close SSRSH;

print SUMMARY "ln -s $ssr_result_dir/$gene.p3_primer3.log $logs_dir/$gene.p3_primer3.log\n\n";

print UPLOADSH "ln -s $ssr_result_dir/$gene.misa $up_ssr_dir/$gene.misa\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.statistics $up_ssr_dir/$gene.statistics\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.statistics.distribution_of_ssr.svg $up_ssr_dir/$gene.statistics.distribution_of_ssr.svg\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.statistics.distribution_of_ssr.png $up_ssr_dir/$gene.statistics.distribution_of_ssr.png\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.statistics.totality.txt $up_ssr_dir/$gene.statistics.totality.txt\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.statistics.drawSVG.txt $up_ssr_dir/$gene.statistics.drawSVG.txt\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.statistics.classify.txt $up_ssr_dir/$gene.statistics.classify.txt\n";
print UPLOADSH "ln -s $ssr_result_dir/$gene.results $up_ssr_dir/$gene.results\n\n";

my $pfam_sh=$go_cds_ssr_pfam."/3_pfam.sh";
open PFAMSH,'>',$pfam_sh or die "can't open the ssr sh $pfam_sh";
print ALLSTEP "echo Start Pfam Annotation at $time\n";
print ALLSTEP "sh $pfam_sh\n";
print ALLSTEP "echo Finish Pfam Annotation at $time\n\n";
print PFAMSH "ln -s $cds_result_dir/$gene_name.blast.protein.fa  $pfam_result_dir/$gene_name.blast.protein.fa\n";
print PFAMSH "ln -s $cds_result_dir/$gene_name.ESTscan.protein.fa $pfam_result_dir/$gene_name.ESTscan.protein.fa\n";
print PFAMSH "cat $pfam_result_dir/$gene_name.blast.protein.fa $pfam_result_dir/$gene_name.ESTscan.protein.fa > $pfam_result_dir/$gene_name.protein.fa\n";
print PFAMSH "perl $config{cut_id} $pfam_result_dir/$gene_name.protein.fa > $pfam_result_dir/$gene_name.protein.cut_id.fa\n";
print PFAMSH "perl $config{pfam_scan} -fasta $pfam_result_dir/$gene_name.protein.cut_id.fa -dir $config{pfam_DATA} -cpu $option{pfam_cpu} > $pfam_result_dir/$gene_name.protein.fa.pfamA\n";
print PFAMSH "perl $config{pfam_result_change} $config{pfam_DATA}/Pfam-A.hmm.dat $pfam_result_dir/$gene_name.protein.fa.pfamA > $pfam_result_dir/$gene_name.protein.fa.pfamA.name\n";
close PFAMSH;
print UPLOADSH "ln -s $pfam_result_dir/$gene_name.protein.fa.pfamA.name $up_pfam_dir/$gene_name.protein.fa.pfamA.name.xls\n\n";

##########################################################################################
####### 总结统计，生成报告
##########################################################################################

print ALLSTEP "\n\n#################### Summary, Report, Tar ####################\n\n";
print ALLSTEP "echo Start Package at $time\n";
print ALLSTEP "perl $config{'cmd_process_forker'} --CPU $option{'CPU_pre_process'} -c $gzip_sh\n";
print ALLSTEP "echo Finish Package at $time\n\n";

print ALLSTEP "echo Start Generate Summary at $time\n";
print ALLSTEP "sh $summary\n";
print ALLSTEP "echo Finish Generate Summary at $time\n\n";

print ALLSTEP "echo Start Upload at $time\n";
print ALLSTEP "sh $upload_sh > $outdir/upload.log 2>> $outdir/upload.log\n";
print ALLSTEP "echo Finish Upload at $time\n\n";

print ALLSTEP "\n###################### Be Sure that Your Results Are All Correct! ######################\n";
print ALLSTEP "echo Start CLEAR at $time\n";
print ALLSTEP "#sh $clear_sh\n";
print ALLSTEP "echo Finish CLEAR at $time\n\n";

print SUMMARY "perl $config{stat_evalue} $summary_result_dir/annotation.xls 7 > $evalue_result_dir/evalue.Nr.stat.xls\n";
print SUMMARY "perl $config{stat_evalue} $summary_result_dir/annotation.xls 11 > $evalue_result_dir/evalue.Swissprot.stat.xls\n";
print SUMMARY "perl $config{stat_evalue} $summary_result_dir/annotation.xls 15 > $evalue_result_dir/evalue.COG.stat.xls\n";
print SUMMARY "perl $config{stat_evalue} $summary_result_dir/annotation.xls 19 > $evalue_result_dir/evalue.KEGG.stat.xls\n\n";
print SUMMARY "perl $config{draw_evalue_pie} $evalue_result_dir/evalue.Nr.stat.xls\n";
print SUMMARY "perl $config{draw_evalue_pie} $evalue_result_dir/evalue.Swissprot.stat.xls\n";
print SUMMARY "perl $config{draw_evalue_pie} $evalue_result_dir/evalue.COG.stat.xls\n";
print SUMMARY "perl $config{draw_evalue_pie} $evalue_result_dir/evalue.KEGG.stat.xls\n\n";

print UPLOADSH "ln -s $evalue_result_dir/evalue.Nr.stat.xls $up_evalue_dir/evalue.Nr.stat.xls\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.Swissprot.stat.xls $up_evalue_dir/evalue.Swissprot.stat.xls\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.COG.stat.xls $up_evalue_dir/evalue.COG.stat.xls\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.KEGG.stat.xls $up_evalue_dir/evalue.KEGG.stat.xls\n\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.Nr.stat.xls.pie.png $up_evalue_dir/evalue.Nr.stat.xls.pie.png\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.Swissprot.stat.xls.pie.png $up_evalue_dir/evalue.Swissprot.stat.xls.pie.png\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.COG.stat.xls.pie.png $up_evalue_dir/evalue.COG.stat.xls.pie.png\n";
print UPLOADSH "ln -s $evalue_result_dir/evalue.KEGG.stat.xls.pie.png $up_evalue_dir/evalue.KEGG.stat.xls.pie.png\n\n";

print SUMMARY "cut -f 1,5,9,16,18 $summary_result_dir/annotation.xls > $summary_result_dir/annotation.short.xls\n\n";

print SUMMARY "perl $config{'4_database'} $summary_result_dir/annotation.short.xls $db4_dir\n";
print SUMMARY "perl $config{draw_four_database_annot_venn} $summary_result_dir/4_database > $summary_result_dir/4_database/venn.svg\n";
print SUMMARY "$config{java} -jar $config{'batik-rasterizer.jar'} -m image/png $summary_result_dir/4_database/venn.svg\n";
close SUMMARY;

print UPLOADSH "ln -s $db4_dir/COG_id.xls $up_db4_dir/COG_id.xls\n";
print UPLOADSH "ln -s $db4_dir/KEGG_id.xls $up_db4_dir/KEGG_id.xls\n";
print UPLOADSH "ln -s $db4_dir/Nr_id.xls $up_db4_dir/Nr_id.xls\n";
print UPLOADSH "ln -s $db4_dir/Swissprot_id.xls $up_db4_dir/Swissprot_id.xls\n";
print UPLOADSH "ln -s $db4_dir/venn.svg $up_db4_dir/venn.svg\n";
print UPLOADSH "ln -s $db4_dir/venn.png $up_db4_dir/venn.png\n\n";
print UPLOADSH "ln -s $db4_dir/4_database_anno.stat $up_db4_dir/4_database_anno.stat\n\n";

#print UPLOADSH "ln -s $config{'Unigene.readme.txt'} $up_unigene_dir/Unigene.readme.txt\n";
print UPLOADSH "ln -s $config{'CDS.readme.txt'} $up_cds_dir/CDS.readme.txt\n";

print UPLOADSH "\nperl $config{write_html} -config $lib -indir $upload_dir -outdir $upload_dir -noimage\n";
print UPLOADSH "cd $outdir\n";
print UPLOADSH "tar --dereference -zcvf $sam.upload.tar.gz Upload\n";

