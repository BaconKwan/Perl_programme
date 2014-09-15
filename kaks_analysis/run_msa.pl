#!/usr/bin/perl

=head1 Name

 run_msa.pl  -- run multiple sequence alignment(MSA) of CDS sequences
 guided by protein alignments

=head1 Description

 the pep alignment guided CDS alignment core scripts are modified
 from pepMfa_to_cdsMfa.pl which is written by Fan Wei.

=head1 Version

 Author: Wang Zhuo, wangzhuo@genomics.org.cn
 Version: 1.0,  Date: 2010-09-28

=head1 Usage
  
 perl run_msa.pl <in.list> <in.pep> <in.cds> <outdir>
   <in.list>        input gene families composition file;
   <in.pep>         input peptide sequence file;
   <in.cds>         input CDS sequence file;
   <outdir>         output results to this directory;
   --method <str>   set MSA method, muscle or mafft, default muscle;

=cut

use strict;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;
use File::Path;  
use Getopt::Long;
use lib "$Bin";
use GACP qw(parse_config);

my $msa_method = "muscle";
GetOptions(
	"method:s" => \$msa_method,
);
die `pod2text $0` if (@ARGV != 4);

my ($inlst, $inpep, $incds, $outdir) = @ARGV;
my $config_file = "$Bin/config.txt";
my $msa_program = parse_config($config_file, $msa_method);
mkpath $outdir if (!-e $outdir);

my (@fam, %genes, %pep, %cds);
read_list($inlst, \@fam, \%genes);
read_seq($inpep, \%genes, \%pep);
read_seq($incds, \%genes, \%cds);

open CDS, ">$outdir/tmp.cds" or die "Can't write to file $outdir/tmp.cds\n";
open PEP, ">$outdir/tmp.pep" or die "Can't write to file $outdir/tmp.pep\n";

foreach my $p (@fam) {
	## Create fasta format cds, pep sequence file;
	my $pep_str;
	foreach (@{$p}[1..@{$p}-1]) {
		$pep_str .= ">$_\n$pep{$_}\n" if (exists $pep{$_});
	}
	open OUT, ">$outdir/in.pep" or die "Can't write to file $outdir/in.pep\n";
	print OUT $pep_str;
	close OUT;

	## Run muscle or mafft to get pep alignment;
	my $msa_option;
	if ($msa_method eq "muscle") {
		my $gene_num = @$p - 1;
		if ($gene_num <= 20) {
			$msa_option = '';
		} elsif ($gene_num > 20 && $gene_num < 50) {
			$msa_option = "-maxiters 8";
		} elsif ($gene_num >= 50 && $gene_num < 200) {
			$msa_option = "-maxiters 4";
		} elsif ($gene_num >= 200) {
			$msa_option = "-maxiters 2";
		}
		$msa_option .= " -in $outdir/in.pep";
	}
	elsif ($msa_method eq "mafft") {
		$msa_option = "--auto $outdir/in.pep";
	}
	my @pep_aln = `$msa_program $msa_option 2>/dev/null`;

	## Get CDS alignment from pep alignment;
	my (%aa, $name);
	foreach (@pep_aln) {
		if (/^>(\S+)/) {
			$name = $1;
		}
		else {
			$aa{$name} .= $_;
		}
	}
	$aa{$_} =~ s/\s+//g foreach (keys %aa);

	my %nt_aln;
	pepmfa_to_cdsmfa(\%cds, \%pep, \%aa, \%nt_aln);

	my $cds_aln_str = ">$p->[0]\n";
	foreach (keys %nt_aln) {
		my $tmpstr = sprintf "%-39s", $_;
		$cds_aln_str .= "$tmpstr $nt_aln{$_}\n";
	}
	print CDS $cds_aln_str;

	my $pep_aln_str = ">$p->[0]\n";
	foreach (keys %aa) {
		my $tmpstr = sprintf "%-39s", $_;
		$pep_aln_str .= "$tmpstr $aa{$_}\n";
	}
	print PEP $pep_aln_str;
}
close CDS;
close PEP;

sub pepmfa_to_cdsmfa {
	my ($h_cds, $h_pep, $h_aa_aln, $h_nt_aln) = @_;
	
	foreach my $name (keys %$h_aa_aln) 
	{
		if (!exists $h_cds->{$name}) {
			print STDERR "WARNING: CDS sequence for $name not exists.\n";
			next;
		}
		my $cds_orig = $h_cds->{$name};
		$cds_orig =~ s/\s+|---//g;
		$cds_orig = uc($cds_orig);

		my $cds;
		my $prot = $h_aa_aln->{$name};
		my $len_prot = length($prot);
		my $j = 0;
		for (my $i=0; $i<$len_prot; $i++) {
			my $aa = substr($prot,$i,1);
			if ($aa ne '-') {
				$cds .= substr($cds_orig,$j,3);
				$j += 3;
			} else {
				$cds .= '---';
			}
		}
		$h_nt_aln->{$name} = $cds;
	}
}

sub read_seq {
	my ($infile, $h_genes, $h_pep) = @_;

	open IN, "$infile" or die "Can't open file $infile\n";
	$/=">"; <IN>; $/="\n";
	while (<IN>) {
		chomp;
		my $head = $_;
		my $name = $1 if($head =~ /^(\S+)/);

		$/=">";
		my $seq = <IN>;
		chomp $seq;
		$seq =~ s/\s//g;
		$/="\n";

		if (exists $h_genes->{$name}) {
			warn "name $name is not uniq.\n" if (exists $h_pep->{$name});
			$h_pep->{$name} = $seq;
		}
	}
	close(IN);
}

sub read_list {
	my ($inlst, $a_fam, $h_genes) = @_;

	open IN, "$inlst" or die "Can't open file $inlst\n";
	while (<IN>) {
		my @arr1 = split /[\s\,]+/;
		push @{$a_fam}, [@arr1];
		$h_genes->{$_} = 1 foreach (@arr1[1..$#arr1]);
	}
	close IN;
}

