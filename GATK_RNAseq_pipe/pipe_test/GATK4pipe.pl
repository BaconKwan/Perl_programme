#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Getopt::Long;
use File::Basename qw/basename dirname/;
use File::Spec::Functions qw/rel2abs/;

#### Main Programme ####
my %opts;
GetOptions (\%opts, "bam=s", "fa=s", "dir=s", "prefix=s", "id=s", "snp=s", "out=s", "debug:i");
&usage if(!$opts{bam} || !$opts{fa} || !$opts{dir} || !$opts{prefix});

my $debug = (defined $opts{debug}) ? 1 : 0;
my $out_dir = (defined $opts{out}) ? $opts{out} : "out";

&main;
exit;

sub main{
	## checking step
	my ($gatk_path, $pc_path, $annovar_path, $pipe_bin, $forker_cmd, $forker_nc, $mcmd, $scmd, @bam_file, @tag, $ref_fa, $modif, $dedup, $snc, @ref_id, @ref_snp, $nct, $filter, $rf);
	&readConf(\$gatk_path, \$pc_path, \$annovar_path, \$pipe_bin, \$forker_cmd, \$forker_nc, \$mcmd, \$scmd, \@bam_file, \@tag, \$ref_fa, \$modif, \$dedup, \$snc, \@ref_id, \@ref_snp, \$nct, \$filter, \$rf);

	## preparing step
	`mkdir -p $out_dir`;
	`mkdir -p $out_dir/ref`;
	`mkdir -p $out_dir/data`;
	`mkdir -p $out_dir/dedup`;
	`mkdir -p $out_dir/deNDN`;
	`mkdir -p $out_dir/snc`;
	`mkdir -p $out_dir/intervals`;
	`mkdir -p $out_dir/realign`;
	`mkdir -p $out_dir/snp`;
	`mkdir -p $out_dir/annot`;
	`mkdir -p $out_dir/upload`;
	`mkdir -p $out_dir/SH`;

	open SH, "> $out_dir/SH/0.link_ref.sh" || die $!;
	foreach(@bam_file){
		my $tag = shift(@tag);
		print SH "ln -sf $_ $out_dir/ref/$tag.bam\n";
		$_ = "$out_dir/ref/$tag.bam";
	}
	&linkFiles(\@ref_id);
	&linkFiles(\@ref_snp);
	close SH;
		( 0 == &runSH("$mcmd $out_dir/SH/0.link_ref.sh >> $out_dir/SH/0.link_ref.log 2>&1")) ? &showInfo("finish link files") : &stop("Error, please check log!");

	## main script

	if($modif ne "no"){
		open SH, "> $out_dir/SH/1.modif.sh" || die $!;
		foreach(@bam_file){
			my $f = basename($_, ".bam");
			print SH "java -jar $pc_path/AddOrReplaceReadGroups.jar I=$_ O=$out_dir/data/${f}.bam ID=$f LB=$f SM=$f PL=illumina PU=run\n";
			$_ = "$out_dir/data/${f}.bam";
		}
		close SH;
		( 0 == &runSH("$mcmd $out_dir/SH/1.modif.sh >> $out_dir/SH/1.modif.log 2>&1")) ? &showInfo("finish Modif bam files' header") : &stop("Error, please check log!");
	}

	if($dedup ne "no"){
		open SH, "> $out_dir/SH/2.dedup.sh" || die $!;
		foreach(@bam_file){
			my $f = basename($_, ".bam");
			print SH "java -jar $pc_path/MarkDuplicates.jar I=$_ O=$out_dir/dedup/${f}_mark.bam M=$out_dir/dedup/${f}.metrics VALIDATION_STRINGENCY=LENIENT\n";
			$_ = "$out_dir/dedup/${f}_mark.bam";
		}
		close SH;
		( 0 == &runSH("$mcmd $out_dir/SH/2.dedup.sh >> $out_dir/SH/2.dedup.log 2>&1")) ? &showInfo("finish Mark duplication") : &stop("Error, please check log!");
	}

	open SH, "> $out_dir/SH/3.filterNDN.sh" || die $!;
		foreach(@bam_file){
			my @suffix = qw/_mark.bam .bam/;
			my $f = basename($_, @suffix);
			print SH "perl $pipe_bin/filterNDN.pl $_ $out_dir/deNDN/${f}_deNDN\n";
			$_ = "$out_dir/deNDN/${f}_deNDN.bam";
		}
	close SH;
	( 0 == &runSH("$mcmd $out_dir/SH/3.filterNDN.sh >> $out_dir/SH/3.filterNDN.log 2>&1")) ? &showInfo("finish filter NDN reads") : &stop("Error, please check log!");

	open SH, "> $out_dir/SH/4.CreatIndex.sh" || die $!;
		foreach(@bam_file){
			print SH "samtools index $_\n";
		}
	close SH;
	( 0 == &runSH("$mcmd $out_dir/SH/4.CreatIndex.sh >> $out_dir/SH/4.CreatIndex.log 2>&1")) ? &showInfo("finish Creat bam files index") : &stop("Error, please check log!");

	if($snc ne "no"){
		open SH, "> $out_dir/SH/5.SNC.sh" || die $!;
		foreach(@bam_file){
			my @suffix = qw/_deNDN.bam _mark.bam .bam/;
			my $f = basename($_, @suffix);
			print SH "java -jar $gatk_path -T SplitNCigarReads -R $ref_fa -I $_ -o $out_dir/snc/${f}_snc.bam -U ALLOW_N_CIGAR_READS -rf ReassignOneMappingQuality\n";
			$_ = "$out_dir/snc/${f}_snc.bam";
		}
		close SH;
		( 0 == &runSH("$mcmd $out_dir/SH/5.SNC.sh >> $out_dir/SH/5.SNC.log 2>&1")) ? &showInfo("finish Split'N'Trim") : &stop("Error, please check log!");
	}

	open SH, "> $out_dir/SH/6.RealignerTargetCreator.sh" || die $!;
	foreach(@bam_file){
		my @suffix = qw/_snc.bam _deNDN.bam _mark.bam .bam/;
		my $f = basename($_, @suffix);
		print SH "java -jar $gatk_path -T RealignerTargetCreator -R $ref_fa -I $_ -o $out_dir/intervals/${f}.intervals";
		foreach(@ref_id){
			print SH " -known $_";
		}
		print SH "\n";
	}
	close SH;
	( 0 == &runSH("$mcmd $out_dir/SH/6.RealignerTargetCreator.sh >> $out_dir/SH/6.RealignerTargetCreator.log 2>&1")) ? &showInfo("finish Creat intervals by realign reads to ref") : &stop("Error, please check log!");

	open SH, "> $out_dir/SH/7.IndelRealigner.sh" || die $!;
	foreach(@bam_file){
		my @suffix = qw/_snc.bam _deNDN.bam _mark.bam .bam/;
		my $f = basename($_, @suffix);
		print SH "java -jar $gatk_path -T IndelRealigner -R $ref_fa -targetIntervals $out_dir/intervals/${f}.intervals -I $_ -o $out_dir/realign/${f}_realign.bam";
		foreach(@ref_id){
			print SH " -known $_";
		}
		print SH "\n";
		$_ = "$out_dir/realign/${f}_realign.bam";
	}
	close SH;
	( 0 == &runSH("$mcmd $out_dir/SH/7.IndelRealigner.sh >> $out_dir/SH/7.IndelRealigner.log 2>&1")) ? &showInfo("finish Realign to interval regions") : &stop("Error, please check log!");

	open SH, "> $out_dir/SH/8.HaplotypeCaller.sh" || die $!;
	print SH "java -jar $gatk_path -T HaplotypeCaller -R $ref_fa -nct $nct $filter $rf -dontUseSoftClippedBases -stand_call_conf 20 -stand_emit_conf 20 -o $out_dir/snp/snp.vcf";
	foreach(@bam_file){
		print SH " -I $_";
	}
	foreach(@ref_snp){
		print SH " -D $_";
	}
	print SH "\n";
	close SH;
	( 0 == &runSH("$scmd $out_dir/SH/8.HaplotypeCaller.sh >> $out_dir/SH/8.HaplotypeCaller.log 2>&1")) ? &showInfo("finish Variant Calling") : &stop("Error, please check log!");

	open SH, "> $out_dir/SH/9.annot.sh" || die $!;
	print SH "perl $pipe_bin/format2annovar.pl $out_dir/snp/snp.vcf > $out_dir/annot/snp.avinput\n";
	print SH "perl $annovar_path/annotate_variation.pl --buildver $opts{prefix} $out_dir/annot/snp.avinput --outfile $out_dir/annot/snp_annot $opts{dir}\n";
	print SH "perl $pipe_bin/combine_annovar.pl $out_dir/annot/snp_annot.variant_function $out_dir/annot/snp_annot.exonic_variant_function $out_dir/annot/snp.avinput $out_dir/upload/snp.annot\n";
	print SH "perl $pipe_bin/split_sample_snp_stat4pipe.pl $out_dir/upload\n";
	close SH;
	( 0 == &runSH("$scmd $out_dir/SH/9.annot.sh >> $out_dir/SH/9.annot.log 2>&1")) ? &showInfo("finish Annotation") : &stop("Error, please check log!");

	&showInfo("==================== Step info");
	&showInfo("INFO : All steps finished!");
}

#### Sub Programme ####
sub usage{
	die"
	Usage: perl $0 -bam <listfile> -fa <file> -dir <path> -prefix <string> [-id <file>] [-snp <file>] [-out <path>] [-debug]

	Options:
		-bam                 string        *bam file list, one file per line
		-fa                  string        *genome fasta file
		-dir                 string        *path of ready files, which should have *_refGene.txt & *_refGeneMrna.fa inside
		-prefix              string        *should be content of * above
		-id                  string         know indels files split by \",\", example: file1,file2 ...
		-snp                 string         reference snp files split by \",\", example: file1,file2 ...
		-out                 string         output path
		-debug                              print scripts only, not run
	\n";
}

sub stop{
	my ($text) = @_;
	&showTime($text);
	exit;
}

sub showInfo{
	my ($text) = @_;
	&showTime($text);
}

sub runSH{
	my ($sh) = @_;
	&showTime($sh);
	return 0 if($debug);
	return system("$sh");
}

sub showTime{
	my ($text) = @_;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}

sub linkFiles{
	my ($tmp) = @_;
	foreach(@{$tmp}){
		my $f = basename($_);
		print SH "ln -sf $_ $out_dir/ref/${f}\n";
		$_ = "$out_dir/ref/${f}";
	}
}

sub join_values{
	my ($value, $line, $link) = @_;
	my @tmp = split /,/, $$line;
	foreach(@tmp){
		$_ = $link . $_;
	}
	$$value = join " ", @tmp;
}

sub set_values{
	my ($path, $files) = @_;
	@{$path} = split /,/, $$files;
	foreach(@{$path}){
		$_ = rel2abs($_);
	}
}

sub check_path{
	my ($path, $flag, $text) = @_;
	$$path =~ s/^\s+|\s+$//g;    #modif by gpk at 20141201, bug example "TK|_____/Bio/Project/PROJECT/GDR0224/RNAseq/out/align/TK/accepted_hits.bam."  -- the dot(blank) at last
	if(defined $$path){
		if( -s $$path ){
			&showInfo("INFO : $$path : OK!");
		}
		else{
			($flag) ? &stop("ERROR : $$path : Fail!") : &showInfo("WARNING : $$path : Fail!");
		}
	}
	else{
		($flag) ? &stop("ERROR : Malformed $text setting!") : &showInfo("WARNING : Malformed $text setting!");
	}
}

sub readConf{
	my ($gatk_path, $pc_path, $annovar_path, $pipe_bin, $forker_cmd, $forker_nc, $mcmd, $scmd, $bam_file, $tag, $ref_fa, $modif, $dedup, $snc, $ref_id, $ref_snp, $nct, $filter, $rf) = @_;
#&showInfo("==================== Loading config ...");
	$$gatk_path = "/home/sunyong/bin/GenomeAnalysisTK.jar";
	$$pc_path = "/home/guanpeikun/bin/picard-tools";
	$$annovar_path = "/home/guanpeikun/bin/annovar";
	$$pipe_bin= "/home/sunyong/bin";
	$$forker_cmd = `which cmd_process_forker.pl`;
	chomp $$forker_cmd;
#$$forker_nc = 4;
	open BAM, "< $opts{bam}" || die $!;
	while(<BAM>){
		chomp;
		my @line = split /\t/;
		push(@{$bam_file}, $line[1]);
		push(@{$tag}, $line[0]);
	}
	close BAM;
	$$ref_fa = rel2abs($opts{fa});
	$opts{dir} = rel2abs($opts{dir});
#$$modif = $line[1] if(defined $line[1]);
#$$dedup = $line[1] if(defined $line[1]);
#$$snc = $line[1] if(defined $line[1]);
	&set_values($ref_id, \$opts{id}) if(defined $opts{id});
	&set_values($ref_snp, \$opts{snp}) if(defined $opts{snp});
#$$nct = $line[1] if(defined $line[1]);
	my $ele;
	$ele = "filterRNC,filterMBQ,filterNoBases";
	&join_values($filter, \$ele, "-");
	$ele = "UnmappedRead,BadMate,DuplicateRead,NotPrimaryAlignment,MappingQualityUnavailable";
	&join_values($rf, \$ele, "-rf ");
	$ele = "";
#&showInfo("INFO : OK!");

## set default value
	&showInfo("==================== Output path");
	$out_dir = rel2abs($out_dir);
	&showInfo("INFO : $out_dir");
	&showInfo("==================== GATK tools");
	&check_path($gatk_path, 1, "gatk_path");
	&showInfo("==================== Picard tools");
	&check_path($pc_path, 1, "pc_path");
	&showInfo("==================== Annovar tools");
	&check_path($annovar_path, 1, "annovar_path");
	&showInfo("==================== Pipe bin");
	&check_path($pipe_bin, 1, "pipe_bin");
	&showInfo("==================== Forker tools");
	&check_path($forker_cmd, 0, "forker_cmd");
	$$forker_nc = @{$bam_file} if(!defined $$forker_nc);
	$$forker_nc = 1 if($$forker_nc < 1);
	$$forker_nc = 2 if($$forker_nc > 2);
	if((!defined $$forker_cmd) || !(-s $$forker_cmd)){
		$$mcmd = "sh";
		$$scmd = "sh";
	}
	else{
		$$mcmd = "$$forker_cmd --CPU $$forker_nc -c";
		$$scmd = "$$forker_cmd --CPU 1 -c";
	}
	&showInfo("==================== Bam files");
	&stop("ERROR : No files") if(0 == @{$bam_file});
	foreach(@{$bam_file}){
		&check_path(\$_, 1, "bam_file");
	}
	&showInfo("==================== Genome fasta file");
	&check_path($ref_fa, 1, "ref_fa");
	&showInfo("==================== ref path");
	&check_path(\$opts{dir}, 1, "dir");
	&showInfo("==================== ref prefix");
	&showInfo("INFO : $opts{prefix}");
	&showInfo("==================== Optional step");
	$$modif = "no" if(!defined $$modif);
	($$modif ne "no") ? &showInfo("Modif header : yes") : &showInfo("Modif header : no");
	$$dedup = "yes" if(!defined $$dedup);
	($$dedup ne "no") ? &showInfo("Mark duplication : yes") : &showInfo("Mark duplication : no");
	$$snc = "yes" if(!defined $$snc);
	($$snc ne "no") ? &showInfo("Split'N'Trim : yes") : &showInfo("Split'N'Trim : no");
	&showInfo("==================== Known Indels");
	&showInfo("WARNING : No files") if(0 == @{$ref_id});
	foreach(@{$ref_id}){
		&check_path(\$_, 0, "ref_id");
		exit if(!( -s $_));
	}
	&showInfo("==================== Reference SNPs");
	&showInfo("WARNING : No files") if(0 == @{$ref_snp});
	foreach(@{$ref_snp}){
		&check_path(\$_, 0 ,"ref_snp");
		exit if(!( -s $_));
	}
#&showInfo("==================== Number of CPU threads");
	$$nct = 2 if(!defined $$nct);
#$$nct = 1 if($$nct < 1);
#$$nct = 16 if($$nct > 16);
	&showInfo("INFO : $$nct");
	&showInfo("==================== Arguments for MalformedReadFilter");
	$$filter = "" if(!defined $$filter);
	&showInfo("INFO : $$filter");
	&showInfo("==================== Filters to apply to reads before analysis");
	$$rf = "" if(!defined $$rf);
	&showInfo("INFO : $$rf");
	&showInfo("==================================================");
	&showInfo("================ Check finished ==================");
	&showInfo("==================================================");
}
