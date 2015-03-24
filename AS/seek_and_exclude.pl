#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use List::Util qw/max min/;
use List::MoreUtils qw/uniq/;

die "perl $0 <gtf> <rpkm> <junction.bed> <known.out> <novel.out> <filter> <sensitivity>\n" unless(@ARGV eq 7);

my (%hash, %rpkm, %gene, %stat);

open GTF, "$ARGV[0]" || die $!;
while(<GTF>){
	chomp;
	my @line = split /\t/;
	next unless($line[2] eq "exon");
	my ($chr, $site1, $site2, $sign, $gene_name) = ($line[0], $line[3], $line[4], $line[6], "-");
	my $info = pop(@line);
	my ($gene_id) = $info =~ /gene_id "([^;]+)";/;
	my ($transcript_id) = $info =~ /transcript_id "([^;]+)";/;
	$gene_name = $1 if($info =~ /gene_name "([^;]+)";/);

	$hash{$chr}{$transcript_id}{sign} = $sign;
	$hash{$chr}{$transcript_id}{gene_name} = $gene_name;
	$hash{$chr}{$transcript_id}{gene_id} = $gene_id;

	$gene{$chr}{$gene_id}{sign} = $sign;
	$gene{$chr}{$gene_id}{gene_name} = $gene_name;
	push(@{$gene{$chr}{$gene_id}{transcript_id}}, $transcript_id);

	($site1, $site2) = ($site2, $site1) if($site1 > $site2);
	if($sign eq "+"){
		push(@{$hash{$chr}{$transcript_id}{exons}}, $site1);
		push(@{$hash{$chr}{$transcript_id}{exons}}, $site2);
		if(!exists $gene{$chr}{$gene_id}{exons} || @{$gene{$chr}{$gene_id}{exons}} eq 0){
			push(@{$gene{$chr}{$gene_id}{exons}}, $site1);
			push(@{$gene{$chr}{$gene_id}{exons}}, $site2);
		}
		else{
			if(${$gene{$chr}{$gene_id}{exons}}[-1] >= $site1 && ${$gene{$chr}{$gene_id}{exons}}[-2] <= $site1){
				my @s = (${$gene{$chr}{$gene_id}{exons}}[-1], ${$gene{$chr}{$gene_id}{exons}}[-2], $site1, $site2);
				my $min = min(@s);
				my $max = max(@s);
				${$gene{$chr}{$gene_id}{exons}}[-2] = $min;
				${$gene{$chr}{$gene_id}{exons}}[-1] = $max;
			}
			else{
				push(@{$gene{$chr}{$gene_id}{exons}}, $site1);
				push(@{$gene{$chr}{$gene_id}{exons}}, $site2);
			}
		}
	}
	else{
		unshift(@{$hash{$chr}{$transcript_id}{exons}}, $site1);
		unshift(@{$hash{$chr}{$transcript_id}{exons}}, $site2);
		if(!exists $gene{$chr}{$gene_id}{exons} || @{$gene{$chr}{$gene_id}{exons}} eq 0){
			unshift(@{$gene{$chr}{$gene_id}{exons}}, $site1);
			unshift(@{$gene{$chr}{$gene_id}{exons}}, $site2);
		}
		else{
			if(${$gene{$chr}{$gene_id}{exons}}[0] >= $site1 && ${$gene{$chr}{$gene_id}{exons}}[1] <= $site1){
				my @s = (${$gene{$chr}{$gene_id}{exons}}[0], ${$gene{$chr}{$gene_id}{exons}}[1], $site1, $site2);
				my $min = min(@s);
				my $max = max(@s);
				${$gene{$chr}{$gene_id}{exons}}[0] = $max;
				${$gene{$chr}{$gene_id}{exons}}[1] = $min;
			}
			else{
				unshift(@{$gene{$chr}{$gene_id}{exons}}, $site1);
				unshift(@{$gene{$chr}{$gene_id}{exons}}, $site2);
			}
		}
	}
}
close GTF;

foreach my $c (%gene){
	foreach my $ge (%{$gene{$c}}){
		@{$gene{$c}{$ge}{transcript_id}} = uniq(@{$gene{$c}{$ge}{transcript_id}});
	}
}

=cut
foreach my $chr (sort keys %hash){
	foreach my $g(sort keys %{$gene{$chr}}){
		my $g_ex = join "\t", @{$gene{$chr}{$g}{exons}};
		print "$gene{$chr}{$g}{gene_name}\t$g\t$gene{$chr}{$g}{sign}\t$g_ex\n";
		foreach my $t (sort @{$gene{$chr}{$g}{transcript_id}}){
			my $t_ex = join "\t", @{$hash{$chr}{$t}{exons}};
			print "$hash{$chr}{$t}{gene_name}\t$t\t$hash{$chr}{$t}{sign}\t$t_ex\n";
		}
	}
}
=cut

open RPKM, "$ARGV[1]" || die $!;
<RPKM>;
while(<RPKM>){
	chomp;
	my @line = split /\t/;
	$rpkm{$line[0]} = $line[1];
}
close RPKM;

open KNOWN, "> $ARGV[3]" || die $!;
open NOVEL, "> $ARGV[4]" || die $!;
open BED, "$ARGV[2]" || die $!;
<BED>;
while(<BED>){
	chomp;
	my @line = split /\t/;
	next if($line[4] < $ARGV[5]); ## filter reads count less than ARGV[5]
	my ($chr, $block_start, $block_end, $jun_id, $reads, $sign) = @line[0..5];
	my @as_pos = split /,/, $line[10];
	my $as_start = $block_start + $as_pos[0];
	my $as_end = $block_end - $as_pos[1] + 1;
	my $as_len = $as_pos[0] + $as_pos[1];
	my $as_den = $reads / $as_len;
	($as_start, $as_end, $block_start, $block_end) = ($as_end, $as_start, $block_end, $block_start) if($sign eq "-");
	my $flag = 0;
	foreach my $id (sort keys %{$hash{$chr}}){
		next unless(exists $hash{$chr}{$id}{sign} && $sign eq $hash{$chr}{$id}{sign});
		my @pos = @{$hash{$chr}{$id}{exons}};
		pop(@pos);shift(@pos);
		for(my $i = 0; $i < @pos; $i += 2){
			if(abs($as_start - $pos[$i]) == $ARGV[6] && abs($as_end - $pos[$i+1]) == $ARGV[6]){
				$flag++;
				$rpkm{$id} = "0" unless(exists $rpkm{$id});
				my $txt = join "\t", $hash{$chr}{$id}{gene_id}, $hash{$chr}{$id}{gene_name}, $id, $rpkm{$id}, $jun_id, "$chr:$block_start,$as_start-$as_end,$block_end", $sign, $as_len, $reads, $as_den, "Known";
				print KNOWN "$txt\n";
				last;
			}
		}
	}
	if($flag == 0){
		my $factor;
		($sign eq "-") ? ($factor = -1) : ($factor = 1);
		my ($as_s, $as_e, $bl_s, $bl_e) = ($as_start * $factor, $as_end * $factor, $block_start * $factor, $block_end * $factor);
		my %this_gene;
		my $type = 0;
		foreach my $g (sort keys %{$gene{$chr}}){
			next unless(exists $gene{$chr}{$g}{sign} && $sign eq $gene{$chr}{$g}{sign});
			my ($g_fs, $g_le) = (${$gene{$chr}{$g}{exons}}[0] * $factor, ${$gene{$chr}{$g}{exons}}[-1] * $factor);
			if($bl_e < $g_fs || $bl_s > $g_le){
				next;
			}
			elsif($bl_e >= $g_fs && $as_e < $g_le && $as_s < $g_fs){
				push(@{$this_gene{2}}, $g);
				$type = 2;
				next;
			}
			elsif($bl_s <= $g_le && $as_s > $g_fs && $as_e > $g_le){
				push(@{$this_gene{3}}, $g);
				$type = 3;
				next;
			}
			else{
				push(@{$this_gene{1}}, $g);
				$type = 1;
				next;
			}
		}
		#intergenic
		if($type == 0){
			$stat{intergenic}++;
			my $txt = join "\t", "-", "-", "-", "-", $jun_id, "$chr:$block_start,$as_start-$as_end,$block_end", $sign, $as_len, $reads, $as_den, "intergenic";
			print NOVEL "$txt\n";
			next;
		}
		else{
			foreach my $this_gene (@{$this_gene{1}}){
				my $template = join "\t", $this_gene, $gene{$chr}{$this_gene}{gene_name}, "-", "-", $jun_id, "$chr:$block_start,$as_start-$as_end,$block_end", $sign, $as_len, $reads, $as_den;
				my $txt;
				my @pos = @{$gene{$chr}{$this_gene}{exons}};
				my ($proA, $proB) = ("off", "off");
				my ($n_A, $n_B) = (0, 0);
				for(my $i = 0; $i < @pos; $i += 2){
					$pos[$i] = $pos[$i] * $factor;
					$pos[$i+1] = $pos[$i+1] * $factor;
					$proA = "on" if($as_s > $pos[$i] && $as_s < $pos[$i+1]);
					$proA = "p3" if($as_s == $pos[$i+1]);
					$proA = "p3_in" if($bl_s <= $pos[$i+1] && $bl_s > $pos[$i] && $as_s > $pos[$i+1]);
					$proB = "p5_in" if($as_e < $pos[$i] && $bl_e >= $pos[$i] && $bl_e > $pos[$i+1]);
					$proB = "p5" if($as_e == $pos[$i]);
					$proB = "on" if($as_e > $pos[$i] && $as_e < $pos[$i+1]);
					($proA, $proB) = ("IR", "IR") if($as_s > $pos[$i] && $as_e < $pos[$i+1] && $as_s < $as_e);
					$n_A = $i+1 if($as_s == $pos[$i+1]);
					$n_B = $i if($as_e == $pos[$i]);
				}
				#IR
				if($proA eq "IR" && $proB eq "IR"){
					$stat{IR}++;
					$txt = join "\t", $template, "IR";
				}
				elsif($proA eq "off" || $proB eq "off"){
					$stat{other}++;
					$txt = join "\t", $template, "other";
				}
				#5`splice
				elsif($proA eq "on" && $proB eq "p5"){
					$stat{p5_splice}++;
					$txt = join "\t", $template, "p5_splice";
				}
				elsif($proA eq "on" && ($proB eq "p5_in" || $proB eq "on")){
					$stat{other}++;
					$txt = join "\t", $template, "other";
				}
				#3`splice
				elsif($proA eq "p3" && ($proB eq "p5_in" || $proB eq "on")){
					$stat{p3_splice}++;
					$txt = join "\t", $template, "p3_splice";
				}
				#ES or normal
				elsif($proA eq "p3" && $proB eq "p5"){
					if(1 == abs($n_A - $n_B)){
						$stat{normal}++;
						$txt = join "\t", $template, "normal";
					}
					else{
						$stat{ES}++;
						$txt = join "\t", $template, "ES";
					}
				}
				elsif($proA eq "p3_in" && ($proB eq "p5_in" || $proB eq "on")){
					$stat{other}++;
					$txt = join "\t", $template, "other";
				}
				elsif($proA eq "p3_in" && $proB eq "p5"){
					$stat{p5_splice}++;
					$txt = join "\t", $template, "p5_splice";
				}
				else{
					$stat{Error}++;
					$txt = join "\t", $template, "Error";
				}
				print NOVEL "$txt\n";
			}
			#AFS
			foreach my $this_gene (@{$this_gene{2}}){
				my $template = join "\t", $this_gene, $gene{$chr}{$this_gene}{gene_name}, "-", "-", $jun_id, "$chr:$block_start,$as_start-$as_end,$block_end", $sign, $as_len, $reads, $as_den;
				my @pos = @{$gene{$chr}{$this_gene}{exons}};
				my $class = 0;
				for(my $i = 0; $i < @pos; $i += 2){
					$pos[$i] = $pos[$i] * $factor;
					$pos[$i+1] = $pos[$i+1] * $factor;
					if($bl_e >= $pos[$i] && $as_e < $pos[$i+1]){
						$stat{AFS}++;
						my $txt = join "\t", $template, "AFS";
						print NOVEL "$txt\n";
						$class++;
						last;
					}
				}
				if($class == 0){
					$stat{other}++;
					my $txt = join "\t", $template, "other";
					print NOVEL "$txt\n";               
				}
			}
			#ALS
			foreach my $this_gene (@{$this_gene{3}}){
				my $template = join "\t", $this_gene, $gene{$chr}{$this_gene}{gene_name}, "-", "-", $jun_id, "$chr:$block_start,$as_start-$as_end,$block_end", $sign, $as_len, $reads, $as_den;
				my @pos = @{$gene{$chr}{$this_gene}{exons}};
				my $class = 0;
				for(my $i = $#pos; $i > 0; $i -= 2){
					$pos[$i-1] = $pos[$i-1] * $factor;
					$pos[$i] = $pos[$i] * $factor;
					if($as_s > $pos[$i-1] && $bl_s <= $pos[$i]){
						$stat{ALS}++;
						my $txt = join "\t", $template, "ALS";
						print NOVEL "$txt\n";
						$class++;
						last;
					}
				}
				if($class == 0){
					$stat{other}++;
					my $txt = join "\t", $template, "other";
					print NOVEL "$txt\n";               
				}
			}
		}
	}
	else{
		$stat{known}++;
	}
}
close BED;
close NOVEL;
close KNOWN;

foreach my $class (sort keys %stat){
	print "$class\t$stat{$class}\n";
}
