#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

=head1 Programe

	align4GATK.pl

=head1 Description

	This programme is used to predeal files for GATK call snp. This is a pipeline for aligning reads to RNAseq_used_ref.fa, gene fasta file, which is a result from RNAseq denovo pipeline. It is producing bam files & a bam list, which is providing to next pipeline(GATK pipe).

=head1 Options

	perl align4GATK.pl <-ref RNAseq_used_ref.fa> <-fq fq.list> [-out ./bam]

	Base Options:
	   *-ref          file          a fasta file named "RNAseq_used_ref.fa" in denovo output folder: Pipe_out/RNAseq_Ref
	   *-fq           file          a list file in format below, one fq file per line.
	                                <it or tag>\t<fq1_path>\t<fq2_path>
	    -out          dir           output path, Default: ./out
	Tophat Options:
	    -p            int           Use this many threads to align reads. The default is 4.
	    -mid          int           This is the expected (mean) inner distance between mate pairs. 
	                                For, example, for paired end runs with fragments selected at 300bp, 
	                                where each end is 50bp, you should set it to be 200. The default is 80bp.
	    -msd          int           The standard deviation for the distribution on inner distances between mate pairs. 
	                                The default is 50bp.
	    -q64

=head1 Samples

	perl align4GATK.pl -ref /Bio/Project/PROJECT/GDR0354/Denovo/Pipe_out/RNAseq_Ref/RNAseq_used_ref.fa \
	                   -fq /Bio/Project/PROJECT/GDR0354/Denovo/Pipe_out/RNAseq_Ref/fq.list \
	                   -out /Bio/Project/PROJECT/GDR0354/Denovo/Pipe_out/bam \
	                   -p 4 -mid 80 -msd 50 -q64

=cut

use utf8;
use strict;
use warnings;
use Getopt::Long;
use File::Basename qw/basename dirname/;
use File::Spec::Functions qw/rel2abs/;

### Read config & Pre-deal ###
my($ref_fa, $fq_list, $out_dir, $nt, $mid, $msd, $quals, $index, $cmd_forker);
GetOptions(
	"ref=s" => \$ref_fa,
	"fq=s" => \$fq_list,
	"out=s" => \$out_dir,
	"p=i" => \$nt,
	"mid=i" => \$mid,
	"msd=i" => \$msd,
	"q64:i" => \$quals,
);

die ` pod2text $0` unless($ref_fa);
die ` pod2text $0` unless($fq_list);
$out_dir = "./out" unless($out_dir);
$ref_fa = rel2abs($ref_fa);
$fq_list = rel2abs($fq_list);
$out_dir = rel2abs($out_dir);
$nt = 4 unless($nt);
$mid = 80 unless($mid);
$msd = 50 unless($msd);
$quals = (defined $quals) ? " --phred64-quals" : "";
$cmd_forker = `which cmd_process_forker.pl`;
chomp $cmd_forker;

&stop("Inexistent file: $ref_fa") unless(-s $ref_fa);
&stop("Inexistent file: $fq_list") unless(-s $fq_list);

`mkdir -p $out_dir`;
`mkdir -p $out_dir/bt2_index`;
`mkdir -p $out_dir/align`;
`mkdir -p $out_dir/SH`;

### Main ###
$index = &buildIndex($ref_fa, $out_dir);
&tophatAlign($index, $fq_list, $out_dir, $nt, $mid, $msd, $quals);

### Build Index for ref_fa ###
sub buildIndex{
	my ($ref_fa, $out_dir) = @_;
	my @suffix = qw/.fa .fasta/;
	my $ref_prefix = basename($ref_fa, @suffix);
	&showInfo("Building index...");
	open SH, "> $out_dir/SH/bulidIndex.sh" || die $!;
	print SH "ln -sf $ref_fa $out_dir/bt2_index/$ref_prefix.fa\n";
	print SH "bowtie2-build $ref_fa $out_dir/bt2_index/$ref_prefix\n";
	close SH;
	( 0 == system("perl $cmd_forker --CPU 1 -c $out_dir/SH/bulidIndex.sh > $out_dir/SH/bulidIndex.log 2>&1")) ? &showInfo("Building index finish successfully!") : &stop("Interrupted! Please check...");
	return "$out_dir/bt2_index/$ref_prefix";
}

sub tophatAlign{
	my ($index, $fq_list, $out_dir, $nt, $mid, $msd, $quals) = @_;
	my $cmd = "tophat --max-multihits 1 --no-coverage-search --no-novel-juncs --no-gtf-juncs --keep-fasta-order";
	$cmd .= " --num-threads $nt";
	$cmd .= " --mate-inner-dist $mid";
	$cmd .= " --mate-std-dev $msd";
	$cmd .= $quals;
	&showInfo("Parsing fq list & Start align");
	open FQLIST, "< $fq_list" || die $!;
	open BAMLIST, "> $out_dir/align/bam.list" || die $!;
	open SH, "> $out_dir/SH/tophatAlign.sh" || die $!;
	while(<FQLIST>){
		chomp;
		my @line = split /\t/;
		print SH "$cmd --rg-id $line[0] --rg-library $line[0] --rg-sample $line[0] --rg-platform-unit illumina --output-dir $out_dir/align/$line[0] $index $line[1] $line[2]\n";
		print BAMLIST "$line[0]\t$out_dir/align/$line[0]/accepted_hits.bam\n";
	}
	close SH;
	close BAMLIST;
	close FQLIST;
	( 0 == system("perl $cmd_forker --CPU 4 -c $out_dir/SH/tophatAlign.sh > $out_dir/SH/tophatAlign.log 2>&1")) ? &showInfo("Tophat align finish successfully!") : &showInfo("Tophat align failed!");
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

sub showTime{
	my ($text) = @_;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}
