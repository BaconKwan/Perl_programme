#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	0.99
#	Create date:	2015-XX-XX
#	Usage:	

use utf8;
use strict;
use warnings;

die "perl $0 <circ_candidates.bed> <gtf> <out_gtf> \n" unless(@ARGV eq 3);

my %circRNA;
my %circRNA_t;

open BED, "$ARGV[0]" || die $!;
while(<BED>){
	next if(/^#|^\s+$/);
	chomp;
	my @t = split /\t/;
	$t[1] += 1;
	($t[1], $t[2]) = ($t[2], $t[1]) if($t[1] > $t[2]);

	# get circRNA basic info
	$circRNA{$t[3]}{chr} = $t[0];
	$circRNA{$t[3]}{start} = $t[1];
	$circRNA{$t[3]}{end} = $t[2];
	$circRNA{$t[3]}{strand} = $t[5];
	@{$circRNA{$t[3]}{transcripts}} = ();
}
close BED;

my %gene;

open GTF, "$ARGV[1]" || die $!;
while(<GTF>){
	next if(/^#/);
	chomp;
	my @t = split /\t/;
	if($t[2] eq "exon"){
		my ($tmp_start, $tmp_end, $gene_id);
		($t[3] < $t[4]) ? (($tmp_start, $tmp_end) = ($t[3], $t[4])) : (($tmp_start, $tmp_end) = ($t[4], $t[3]));

		# get source_gene basic info
		$gene_id = $1 if($t[8] =~ /gene_name "([^;]+)";/);
		$gene_id = $1 if($t[8] =~ /gene_id "([^;]+)";/);

		# calculate exons union set
		unless(exists $gene{$t[0]}{$gene_id}){
			$gene{$t[0]}{$gene_id}{strand} = $t[6];
			push(@{$gene{$t[0]}{$gene_id}{exons}}, $tmp_start, $tmp_end);
		}
		else{
			my @exons = ();
			while(scalar(@{$gene{$t[0]}{$gene_id}{exons}}) > 0){
				if($tmp_end < $gene{$t[0]}{$gene_id}{exons}[0] - 1){
					push(@exons, $tmp_start, $tmp_end, @{$gene{$t[0]}{$gene_id}{exons}});
					last;
				}
				elsif($tmp_start > $gene{$t[0]}{$gene_id}{exons}[1] + 1){
					push(@exons, $gene{$t[0]}{$gene_id}{exons}[0], $gene{$t[0]}{$gene_id}{exons}[1]);
					shift(@{$gene{$t[0]}{$gene_id}{exons}});
					shift(@{$gene{$t[0]}{$gene_id}{exons}});
				}
				else{
					my @sites = ($gene{$t[0]}{$gene_id}{exons}[0], $gene{$t[0]}{$gene_id}{exons}[1], $tmp_start, $tmp_end);
					@sites = sort {$a <=> $b} @sites;
					shift(@{$gene{$t[0]}{$gene_id}{exons}});
					shift(@{$gene{$t[0]}{$gene_id}{exons}});
					$tmp_start = $sites[0];
					$tmp_end = $sites[-1];
				}
				# last one
				push(@exons, $tmp_start, $tmp_end) if(scalar(@{$gene{$t[0]}{$gene_id}{exons}}) == 0);
			}
			# refresh gene exons union set
			@{$gene{$t[0]}{$gene_id}{exons}} = @exons;
		}
	}
}
close GTF;

# For test
#foreach my $chr (sort {$a <=> $b} keys %gene){
#	foreach my $gene (sort keys $gene{$chr}){
#		my $txt = join "\t", $gene, $chr, $gene{$chr}{$gene}{strand}, @{$gene{$chr}{$gene}{exons}};
#		print "$txt\n";
#	}
#}

# gtf fixed format
my $gtf_c2 = "circ";
my $gtf_c3 = "exon";
my $gtf_c6 = ".";

open OUT, "> $ARGV[2]" || die $!;
foreach my $chr (sort {$a <=> $b} keys %gene){
	foreach my $circ_gid (keys %circRNA){
		# only process the RNAs in the same chr
		next if($circRNA{$circ_gid}{chr} ne $chr);

		foreach my $gene (keys $gene{$chr}){
			# skip the intergernic
			next if($circRNA{$circ_gid}{end} < $gene{$chr}{$gene}{exons}[0] || $circRNA{$circ_gid}{start} > $gene{$chr}{$gene}{exons}[-1]);

			# find the exon_pos
			my ($start_pos, $end_pos);
			for(my $i = 0; $i < @{$gene{$chr}{$gene}{exons}}; $i++){
				if($circRNA{$circ_gid}{start} < $gene{$chr}{$gene}{exons}[$i]){
					$start_pos = $i - 1;
					last;
				}
			}
			for(my $i = @{$gene{$chr}{$gene}{exons}} - 1; $i >= 0; $i--){
				if($circRNA{$circ_gid}{end} > $gene{$chr}{$gene}{exons}[$i]){
					$end_pos = $i + 1;
					last;
				}
			}

			my $cnt = sprintf("%.2d", scalar(@{$circRNA{$circ_gid}{transcripts}}) + 1);
			my $circ_tid = $circ_gid . "_" . $cnt;
			$circRNA_t{$circ_tid}{gene} = $circ_gid;
			$circRNA_t{$circ_tid}{host} = $gene;
			push(@{$circRNA{$circ_gid}{transcripts}}, $circ_tid);

			# classify and output gtf
			# $end_pos - $start_pos - 1 == 0
			if($end_pos - $start_pos - 1 == 0){
				if($start_pos % 2 != 0){
					if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
						$circRNA_t{$circ_tid}{type} = "intronic";
					}
					else{
						$circRNA_t{$circ_tid}{type} = "antisense";
					}
				}
				else{
					if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
						$circRNA_t{$circ_tid}{type} = "one_exon";
					}
					else{
						$circRNA_t{$circ_tid}{type} = "antisense";
					}
				}
				my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
				my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
				print OUT "$txt\t$annot\n";
			}
			
			# $end_pos - $start_pos - 1 == 1
			elsif($end_pos - $start_pos - 1 == 1){
				if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
					$circRNA_t{$circ_tid}{type} = "exon_intron";
				}
				else{
					$circRNA_t{$circ_tid}{type} = "antisense";
				}
				my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
				my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
				print OUT "$txt\t$annot\n";
			}

			# $end_pos - $start_pos - 1 > 1
			else{
				if($start_pos % 2 == 0 && ($end_pos - 1) % 2 == 0){
					if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
						$circRNA_t{$circ_tid}{type} = "annot_exons";
						my @exons = ($circRNA{$circ_gid}{start}, @{$gene{$chr}{$gene}{exons}}[$start_pos+1 .. $end_pos-1], $circRNA{$circ_gid}{end});
						for(my $i = 0; $i < @exons; $i += 2){
							my $exon_number = $i / 2 + 1;
							my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $exons[$i], $exons[$i+1], $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
							my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"$exon_number\"";
							print OUT "$txt\t$annot\n";
						}
					}
					else{
						$circRNA_t{$circ_tid}{type} = "antisense";
						my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
						my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
						print OUT "$txt\t$annot\n";
					}
				}

				elsif($start_pos % 2 == 0 && ($end_pos - 1) % 2 != 0){
					if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
						$circRNA_t{$circ_tid}{type} = "exon_intron";
						my @exons = ($circRNA{$circ_gid}{start}, @{$gene{$chr}{$gene}{exons}}[$start_pos+1 .. $end_pos-1], $gene{$chr}{$gene}{exons}[$end_pos-1] + 1, $circRNA{$circ_gid}{end});
						for(my $i = 0; $i < @exons; $i += 2){
							my $exon_number = $i / 2 + 1;
							my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $exons[$i], $exons[$i+1], $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
							my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"$exon_number\"";
							print OUT "$txt\t$annot\n";
						}
					}
					else{
						$circRNA_t{$circ_tid}{type} = "antisense";
						my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
						my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
						print OUT "$txt\t$annot\n";
					}
				}

				elsif($start_pos % 2 != 0 && ($end_pos - 1) % 2 == 0){
					if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
						$circRNA_t{$circ_tid}{type} = "exon_intron";
						my @exons = ($circRNA{$circ_gid}{start}, $gene{$chr}{$gene}{exons}[$start_pos+1] - 1, @{$gene{$chr}{$gene}{exons}}[$start_pos+1 .. $end_pos-1], $circRNA{$circ_gid}{end});
						for(my $i = 0; $i < @exons; $i += 2){
							my $exon_number = $i / 2 + 1;
							my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $exons[$i], $exons[$i+1], $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
							my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"$exon_number\"";
							print OUT "$txt\t$annot\n";
						}
					}
					else{
						$circRNA_t{$circ_tid}{type} = "antisense";
						my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
						my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
						print OUT "$txt\t$annot\n";
					}
				}

				elsif($start_pos % 2 != 0 && ($end_pos - 1) % 2 != 0){
					if($gene{$chr}{$gene}{strand} eq $circRNA{$circ_gid}{strand}){
						$circRNA_t{$circ_tid}{type} = "exon_intron";
						my @exons = ($circRNA{$circ_gid}{start}, $gene{$chr}{$gene}{exons}[$start_pos+1] - 1, @{$gene{$chr}{$gene}{exons}}[$start_pos+1 .. $end_pos-1], $gene{$chr}{$gene}{exons}[$end_pos-1] + 1, $circRNA{$circ_gid}{end});
						for(my $i = 0; $i < @exons; $i += 2){
							my $exon_number = $i / 2 + 1;
							my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $exons[$i], $exons[$i+1], $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
							my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"$exon_number\"";
							print OUT "$txt\t$annot\n";
						}
					}
					else{
						$circRNA_t{$circ_tid}{type} = "antisense";
						my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
						my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
						print OUT "$txt\t$annot\n";
					}
				}
				else{
					die "Error with $chr:$circRNA{$circ_gid}{start}-$circRNA{$circ_gid}{end}\t$circ_gid\t$circ_tid\n";
				}
			}
		}

		# deal with intergernic circRNA
		if(scalar @{$circRNA{$circ_gid}{transcripts}} == 0){
			my $circ_tid = $circ_gid . "_01";
			$circRNA_t{$circ_tid}{gene} = $circ_gid;
			$circRNA_t{$circ_tid}{host} = "NA";
			$circRNA_t{$circ_tid}{type} = "intergernic";
			push(@{$circRNA{$circ_gid}{transcripts}}, $circ_tid);
			my $txt = join "\t", $chr, $gtf_c2, $gtf_c3, $circRNA{$circ_gid}{start}, $circRNA{$circ_gid}{end}, $gtf_c6, $circRNA{$circ_gid}{strand}, $circRNA_t{$circ_tid}{type};
			my $annot = join "; ", "gene_id \"$circRNA_t{$circ_tid}{gene}\"", "transcript_id \"$circ_tid\"", "source_gene \"$circRNA_t{$circ_tid}{host}\"", "exon_number \"1\"";
			print OUT "$txt\t$annot\n";
		}

		# delete useless circRNA record since this circRNA is no need for the rest processing and improve performance
		foreach my $key (keys $circRNA{$circ_gid}){
			delete $circRNA{$circ_gid}{$key};
		}
		delete $circRNA{$circ_gid};
	}
}
close OUT;

