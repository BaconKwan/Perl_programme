#!/usr/bin/perl

#	Author:	BaconKwan
#	Email:	terencest@gmail.com
#	Version:	1.0
#	Create date:	June 26, 2014
#	Usage:	
use warnings;
use utf8;
use strict;
use Getopt::Long;

my %opts;
GetOptions (\%opts, "fa=s", "gtf=s", "nr=s", "sp=s", "cog=s", "pa=s", "ke=s", "out=s");
&usage if(!$opts{fa} || !$opts{gtf} || !$opts{out});

## test options
#print "$opts{fa}\t$opts{gtf}\t$opts{nr}\t$opts{sp}\t$opts{cog}\t$opts{pa}\t$opts{ke}\t$opts{out}\n";

my %hash;

## Reading files
&read_fa_gtf;
&read_nr if(defined($opts{nr}));
&read_sp if(defined($opts{sp}));
&read_cog if(defined($opts{cog}));
&read_pa if(defined($opts{pa}));
&read_ke if(defined($opts{ke}));

## Output
## Print header
open OUT, "> $opts{out}.annot.xls" || die $!;
print OUT "gene_id\ttranscript_id\tlocus\texon_number\tgene_length";
print OUT "\tnr_description" if(defined($opts{nr}));
print OUT "\tswissprot_description" if(defined($opts{sp}));
print OUT "\tcog_function_description\tcog_functional_categories" if(defined($opts{cog}));
print OUT "\tpathways" if(defined($opts{pa}));
print OUT "\tkegg_description" if(defined($opts{ke}));
print OUT "\n";
foreach my $trans_id (sort keys %hash){
	## Print GeneID, transcriptID & gtf info
	&write_fa_gtf($trans_id);
	## Add nr info
	&write_nr($trans_id) if(defined($opts{nr}));
	## Add Swissport info
	&write_sp($trans_id) if(defined($opts{sp}));
	## Add cog info
	&write_cog($trans_id) if(defined($opts{cog}));
	## Add path info
	&write_pa($trans_id) if(defined($opts{pa}));
	## Add kegg info
	&write_ke($trans_id) if(defined($opts{ke}));
	## Line wrap
	print OUT "\n";
}
close OUT;

sub usage{
	print "
	Usage:	perl $0 -fa <fa_file> -gtf <gtf_file> -out <output_prefix> [options]
	Options:
		-fa     file    *fasta file
		-gtf    file    *gtf file
		-nr     file    nr blast result file -- *.blast.Nr.xls
		-sp     file    swissprot blast result file -- *.blast.Swissprot.xls
		-cog    file    cog blast result file -- *.cog.gene.annot.xls
		-pa     file    kegg blast result path file -- *.path
		-ke     file    kegg blast result file -- *.blast.kegg.xls
		-out    string  *output file prefix

";
	exit;
}

sub read_fa_gtf{
	## Reading fasta file
	open FA, "$opts{fa}" || die $!;
	$/ = "\n>";
	while(<FA>){
		s/>//g;
		my @line = split;
		$line[1] =~ s/gene=//;
		$hash{$line[0]}{fa} = $line[1];
	}
	$/ = "\n";
	close FA;

	## Reading gtf file
	open GTF, "$opts{gtf}" || die $!;
	while(<GTF>){
		chomp;
		my @line = split /\t/;
		if(/transcript_id "([^;]+)"/){
			push(@{$hash{$1}{gtf}}, "$line[0]:$line[3]:$line[4]");
		}
	}
	close GTF;
}

sub write_fa_gtf{
	print OUT "$hash{$_[0]}{fa}\t$_[0]";
	if(exists $hash{$_[0]}{gtf}){
		my $exon_num = @{$hash{$_[0]}{gtf}};
		my @parts = split /:/, pop(@{$hash{$_[0]}{gtf}});
		my $chromosome = $parts[0];
		my $start = $parts[1];
		my $end = $parts[2];
		my $len = $end - $start + 1;
		foreach(@{$hash{$_[0]}{gtf}}){
			@parts = split /:/;
			$len += $parts[2] - $parts[1] + 1;
			$end = $parts[2] if($parts[2] > $end);
			$start = $parts[1] if($parts[1] < $start);
		}
		print OUT "\t$chromosome:$start-$end\t$exon_num\t$len";
	}
	else{
		print OUT "\t--\t--\t--";
	}
}

sub read_nr{
	## Reading blast.Nr.xls
	open NR,"$opts{nr}" || die $!;
	while(<NR>){
		chomp;
		my @line = split /\t/;
		next if(exists $hash{$line[0]}{nr});
		$hash{$line[0]}{nr} = $line[$#line];
	}
	close NR;
}

sub write_nr{
	if (exists $hash{$_[0]}{nr}){
		print OUT "\t$hash{$_[0]}{nr}";
	}
	else{
		print OUT "\t--";
	}
}

sub read_sp{
	## Reading blast.Swissport.xls
	open SWISS, "$opts{sp}" || die $!;
	while(<SWISS>){
		chomp;
		my @line = split /\t/;
		next if(exists $hash{$line[0]}{swiss});
		if($line[$#line] =~ /\s+GN=/){
			$hash{$line[0]}{swiss} = $`;
		}
		elsif($line[$#line] =~ /\s+PE=/){
			$hash{$line[0]}{swiss} = $`;
		}
		elsif($line[$#line] =~ /\s+SV=/){
			$hash{$line[0]}{swiss} = $`;
		}
		else{
			$hash{$line[0]}{swiss} = $line[$#line];
		}
	}
	close SWISS;
}

sub write_sp{
	if (exists $hash{$_[0]}{swiss}){
		print OUT "\t$hash{$_[0]}{swiss}";
	}
	else{
		print OUT "\t--";
	}
}

sub read_cog{
	## Reading cog.gene.annot.xls
	open COG, "$opts{cog}" || die $!;
	<COG>;
	while(<COG>){
		chomp;
		my @line = split /\t/;
		next if(exists $hash{$line[0]}{cog});
		$line[7] =~ s/\s*;//;
		$hash{$line[0]}{cog} = "$line[5]\t$line[7]";
	}
	close COG;
}

sub write_cog{
	if (exists $hash{$_[0]}{cog}){
		print OUT "\t$hash{$_[0]}{cog}";
	}
	else{
		print OUT "\t--\t--";
	}
}

sub read_pa{
	## Reading path file
	open PATH,"$opts{pa}" || die $!;
	<PATH>;
	while(<PATH>){
		chomp;
		my @line = split /\t/;
		my @trans = split /;/, $line[3];
		foreach my $id (@trans){
			push(@{$hash{$id}{path}}, $line[0]);
		}
	}
	close PATH;
}

sub write_pa{
	if (exists $hash{$_[0]}{path}){
		my $paths = join "; ", @{$hash{$_[0]}{path}};
		print OUT "\t$paths";
	}
	else{
		print OUT "\t--";
	}
}

sub read_ke{
	## Reading kegg.xls
	open KEGG, "$opts{ke}" || die $!;
	while(<KEGG>){
		chomp;
		my @line = split /\t/;
		next if(exists $hash{$line[0]}{kegg});
		$hash{$line[0]}{kegg} = $line[12];
	}
	close KEGG;
}

sub write_ke{
	if (exists $hash{$_[0]}{kegg}){
		print OUT "\t$hash{$_[0]}{kegg}";
	}
	else{
		print OUT "\t--";
	}
}
