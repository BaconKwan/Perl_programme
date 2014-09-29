
use warnings;
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use File::Basename qw(basename);
use File::Spec::Functions qw(rel2abs);

##### main program #####
my $mainPL = basename($0);
my $testMode = 0;
my $gk;
GetOptions(
	"testMode:i" => \$testMode,
	"gk:s" => \$gk,
);

&main;
exit;

sub main
{
	&usage if(@ARGV != 2);

	&showTime("===== Start =====");
	my ($config, $outdir) = @ARGV;
	$config = rel2abs($config);
	$outdir = rel2abs($outdir);
	my (@cf, %samples, @labels, $deg, @group, @snp);
	&readConfig($config, \@cf, \%samples, \@labels, \$deg, \@group, \@snp);
	mkdir "$outdir";
	mkdir "$outdir/shell";
	my ($forker, $forker_opts) = @cf[0, 13];
	my ($genome, $bowtie2index, $annotation, $test, $bt2, $bt2o, $bt2i) = @cf[21..27];

##### filter reads and remove rRNA #####
	mkdir "$outdir/cleanData";
	my $filter_outdir = rel2abs("$outdir/cleanData");
	open CLEAN, "> $outdir/shell/filter.01.sh" or die $!;
	my ($filter, $filter_opts) = @cf[1, 14];
	
	if($bt2 eq 0)
	{
	##### filter reads of samples #####
		foreach my $i(keys %samples)
		{
			if(@{$samples{$i}} == 1)
			{
				print CLEAN "$filter -1 $samples{$i}[0] $filter_opts -o $filter_outdir/$i \n";
			}else{
				print CLEAN "$filter -1 $samples{$i}[0] -2 $samples{$i}[1] $filter_opts -o $filter_outdir/$i \n";
			}
		}
		my $filter_sh = rel2abs("$outdir/shell/filter.01.sh");
		&runSH("$forker $forker_opts -c $filter_sh");
	}else{
	##### filter rRNA of samples #####
		mkdir "$outdir/rRNA";
		open RRNA, "> $outdir/shell/rRNAremove.00.sh" or die $!;
		foreach my $i(keys %samples)
		{
			if(@{$samples{$i}} == 1)
			{
				print RRNA "$bt2 $bt2o -x $bt2i -U $samples{$i}[0] --un-gz $outdir/rRNA/$i\_1.fq.gz 2> $outdir/rRNA/$i.rRNA.log \n";
				print CLEAN "$filter -1 $outdir/rRNA/$i\_1.fq.gz $filter_opts -o $filter_outdir/$i \n";
			}else{
				print RRNA "$bt2 $bt2o -x $bt2i -1 $samples{$i}[0] -2 $samples{$i}[1] --un-conc-gz $outdir/rRNA/$i\_%.fq.gz 2> $outdir/rRNA/$i.rRNA.log \n";
				print CLEAN "$filter -1 $outdir/rRNA/$i\_1.fq.gz -2 $outdir/rRNA/$i\_2.fq.gz $filter_opts -o $filter_outdir/$i \n";
			}
		}
		&runSH("$forker $forker_opts -c $outdir/shell/rRNAremove.00.sh");
		&runSH("$forker $forker_opts -c $outdir/shell/filter.01.sh");
	}

##### align genome #####
	mkdir "$outdir/align";
	my $align_outdir = rel2abs("$outdir/align");
	open ALIGN, "> $outdir/shell/align.02.sh" or die $!;
	open BAML, "> $outdir/align/bam.list" or die $!;
	my ($align, $align_opts) = @cf[2, 15];
	foreach my $i(sort {$a cmp $b} keys %samples)
	{
		if(@{$samples{$i}} == 1)
		{
			print ALIGN "$align -o $align_outdir/$i $align_opts -G $annotation --rg-id $i --rg-library $i --rg-platform illumina --rg-sample $i $bowtie2index $filter_outdir/$i.fq.gz \n";
		}else{
			print ALIGN "$align -o $align_outdir/$i $align_opts -G $annotation --rg-id $i --rg-library $i --rg-platform illumina --rg-sample $i $bowtie2index $filter_outdir/${i}_1.fq.gz $filter_outdir/${i}_2.fq.gz \n";
		}
		print BAML "$i\t$align_outdir/$i/accepted_hits.bam\n";
	}
	my $align_sh = rel2abs("$outdir/shell/align.02.sh");
	&runSH("$forker $forker_opts -c $align_sh");
	
##### assembly transcript #####
	mkdir "$outdir/assembly";
	my $assembly_outdir = rel2abs("$outdir/assembly");
	open ASSEM, "> $outdir/shell/assembly.03.sh" or die $!;
	open GTF, "> $outdir/assembly/assembly_GTF.list" or die $!;
	my ($assembly, $assembly_opts) = @cf[3, 16];
	foreach my $i(keys %samples)
	{
		print ASSEM "$assembly -o $assembly_outdir/$i $assembly_opts -g $annotation -b $genome $align_outdir/$i/accepted_hits.bam \n";
		print GTF "$outdir/assembly/$i/transcripts.gtf\n";
	}
	my $assembly_sh = rel2abs("$outdir/shell/assembly.03.sh");
	&runSH("$forker $forker_opts -c $assembly_sh");
	
##### merge all transcript #####
	mkdir "$outdir/merge";
	my ($merge, $merge_opts) = @cf[6, 17];
	open MERGE, "> $outdir/shell/merge.04.sh" or die $!;
	print MERGE "$merge -o $outdir/merge -g $annotation --ref-sequence $genome $merge_opts $outdir/assembly/assembly_GTF.list \n";
	&runSH("$forker  --CPU 1 -c $outdir/shell/merge.04.sh");
	my $mygtf = "$outdir/merge/all.gtf";
	open CAT, "> $outdir/shell/cat.04.sh";
	print CAT "perl -lane 'print if(/class_code \"u\";/)' $outdir/merge/merged.gtf > $outdir/merge/newGene.tmp \n";
	print CAT "perl /home/sunyong/bin/filterNewGene.pl $outdir/merge/newGene.tmp > $outdir/merge/newGene.gtf \n";
	print CAT "/usr/bin/gffread $outdir/merge/newGene.gtf -g $genome -w $outdir/merge/newGene.fa \n";
	print CAT "cat $outdir/merge/newGene.gtf $annotation > $mygtf \n";
	&runSH("$forker  --CPU 1 -c $outdir/shell/cat.04.sh");
	my $gtf2bed = $cf[11]; # it`s not work
	
##### quant #####
	mkdir "$outdir/quant";
	my ($quant, $quant_opts) = @cf[4, 18];
	open QUANT, "> $outdir/shell/quant.05.sh" or die $!;
	foreach my $i(keys %samples)
	{
		print QUANT "$quant -o $outdir/quant/$i $quant_opts -b $genome $mygtf $align_outdir/$i/accepted_hits.bam \n";
	}
	my $quant_sh = rel2abs("$outdir/shell/quant.05.sh");
	&runSH("$forker $forker_opts -c $quant_sh");
	my $cxb;
	foreach my $i(@labels)
	{
		$cxb .= "$outdir/quant/$i/abundances.cxb ";
	}
	
##### norm and diffexpress #####
	mkdir "$outdir/norm";
	mkdir "$outdir/diffexpression";
	my ($norm, $de, $norm_opts, $de_opts) = @cf[5, 7, 19, 20];
	my $label = join ",", @labels;
	open DEG, "> $outdir/shell/de-norm.06.sh" or die $!;
	print DEG "$norm -o $outdir/norm -L $label $norm_opts $mygtf $cxb \n";
	if($deg eq 1)
	{
		print DEG "$de -o $outdir/diffexpression -L $label $de_opts -b $genome $mygtf $cxb \n";
	}else{
		my @tag = split /;/, $deg;
		$tag[-1] =~ s/\s*//;
		if(defined $tag[-1])
		{
			;
		}else{
			pop @tag;
		}
		open CONTRAST, "> $outdir/shell/contrast.txt" or die $!;
		print CONTRAST "condition_A	condition_B\n";
		foreach my $i(@tag)
		{
			my @tmp = split /&/, $i;
			print CONTRAST "$tmp[0]\t$tmp[1]\n";
		}
		print DEG "$de -o $outdir/diffexpression -L $label -C $outdir/shell/contrast.txt $de_opts -b $genome $mygtf $cxb \n";
	}
	&runSH("$forker  --CPU 2 -c $outdir/shell/de-norm.06.sh");

##### assess transcript #####
	mkdir "$outdir/assess";
	my ($satur, $rand, $pears, $bed) = @cf[8..10, 24];
	open ASS, "> $outdir/shell/assess.07.sh" or die $!;
	foreach my $i(keys %samples)
	{
		print ASS "perl $satur $align_outdir/$i/accepted_hits.bam $annotation $samples{$i}[0] 100000 $outdir/assess/$i \n";
		print ASS "python $rand -i $align_outdir/$i/accepted_hits.bam -r $bed -o $outdir/assess/$i \n";
		print ASS "perl /home/sunyong/bin/exonCoverage.pl $bed $outdir/assess/$i $align_outdir/$i/accepted_hits.bam \n";
	}
	print ASS "Rscript $pears $outdir/norm/genes.fpkm_table $outdir/assess \n";
	&runSH("$forker  --CPU 1 -c $outdir/shell/assess.07.sh");
	#&runSH("rm $outdir/assess/*.geneBodyCoverage.txt $outdir/assess/*.geneBodyCoverage_plot.r -rf");
	
##### group diffexpress #####
	if(@group == 1)
	{
		;
	}else{
		mkdir "$outdir/groupDiffexpression";
		mkdir "$outdir/groupNorm";
#		open GROUP, "> $outdir/shell/sample_sheet.txt" or die $!;
#		print GROUP "sample_id	group_label\n";
		my ($groupLabel, @gls, @cxb, $groupCXB);
		foreach my $key(@group)
		{
			my @tmp = split /\t/, $key;
			push @gls, $tmp[0];
			my @sample = split /&/, $tmp[1];
			my (@xxx, $xstring);
			foreach my $i(@sample)
			{
#				print GROUP "$outdir/quant/$i/abundances.cxb\t$tmp[0]\n";
				push @xxx, "$outdir/quant/$i/abundances.cxb";
			}
			$xstring = join ",", @xxx;
			push @cxb, $xstring;
		}
		$groupCXB = join " ", @cxb;
		$groupLabel = join ",", @gls;
		open GDEN, "> $outdir/shell/group.de-norm.08.sh" or die $!;
		print GDEN "$de -o $outdir/groupDiffexpression $de_opts -L $groupLabel -b $genome $mygtf $groupCXB \n";
		print GDEN "$norm -o $outdir/groupNorm $norm_opts -L $groupLabel $mygtf $groupCXB \n";
		&runSH("$forker  --CPU 2 -c $outdir/shell/group.de-norm.08.sh");
		
		mkdir "$outdir/groupMerge";
		open GMERGE, "> $outdir/shell/group.merge.09.sh" or die $!;
		foreach my $key(@group)
		{
			my @tmp = split /\t/, $key;
			open GGLIST, "> $outdir/assembly/$tmp[0].assembly_GTF.list" or die $!;
			my @sample = split /&/, $tmp[1];
			foreach my $i(@sample)
			{
				print GGLIST "$outdir/assembly/$i/transcripts.gtf\n";
			}
			print GMERGE "$merge -o $outdir/groupMerge/$tmp[0] -g $annotation --ref-sequence $genome $merge_opts $outdir/assembly/$tmp[0].assembly_GTF.list \n";
		}
		&runSH("$forker  --CPU 1 -c $outdir/shell/group.merge.09.sh"); # run only one merge sh every time. 
	}


##### annotate new gene #####
	my $spe = $cf[29];
	open ANG, "> $outdir/shell/annotateNewGene.10.sh" or die $!;
	print ANG "perl /home/sunyong/bin/blast_annot.pl $spe $outdir/merge/newGene.fa $outdir/merge/annotation \n";
	my $ap = "$outdir/merge/annotation/newGene/gene-annotation/newGene.fa";
	print ANG "perl /home/guanpeikun/bin/utility/integrate_annot.pl $outdir/merge/newGene.fa $outdir/merge/newGene.gtf $ap.blast.Nr.xls $ap.blast.Swissprot.xls $ap.cog.gene.annot.xls $ap.path $ap.blast.kegg.xls $outdir/merge/newGene \n";
	
	&runSH("$forker  --CPU 1 -c $outdir/shell/annotateNewGene.10.sh");


##### call snp and annotate #####
	if($snp[0] ne 0)
	{
		mkdir "$outdir/snp";
		open SNP, "> $outdir/shell/snp.11.sh" or die $!;
		print SNP "perl /home/guanpeikun/bin/GATK_RNAseq_pipe/pipe_test/GATK4pipe.pl -bam $outdir/align/bam.list -fa $genome -dir $snp[0] -prefix $snp[1] -out $outdir/snp \n";
		
		&runSH("sh $outdir/shell/snp.11.sh");
	}else{
		next;
	}

##### gene structure optimization #####
	open GSO, "> $outdir/shell/gso.12.1.sh" or die $!;
	foreach my $i(keys %samples)
	{
		print GSO "/usr/bin/cuffcompare -r $annotation -o $outdir/assembly/$i/$i $outdir/assembly/$i/transcripts.gtf \n";
	}
	&runSH("$forker $forker_opts -c $outdir/shell/gso.12.1.sh");
	open GSO2, "> $outdir/shell/gso.12.2.sh" or die $!;
	foreach my $i(keys %samples)
	{
		print GSO2 "sort -k 1,1 -k 4,4n -k 5,5n $outdir/assembly/$i/$i.combined.gtf > $outdir/assembly/$i/$i.sort.gtf \n";
	}
	&runSH("$forker $forker_opts -c $outdir/shell/gso.12.2.sh");
	open GSO3, "> $outdir/shell/gso.12.3.sh" or die $!;
	foreach my $i(keys %samples)
	{
		print GSO3 "perl /home/sunyong/bin/utr_stat.pl $annotation $outdir/assembly/$i/$i.sort.gtf $outdir/assembly/$i \n";
	}
	print GSO3 "perl /home/sunyong/bin/utr_stat.pl $annotation $outdir/merge/merged.gtf $outdir/assembly/merge \n";
	&runSH("$forker $forker_opts -c $outdir/shell/gso.12.3.sh");
	
##### upload data #####
	mkdir "$outdir/upload";
	open UL, "> $outdir/shell/upload.13.sh" or die $!;
	my $exp = $cf[12];
	
	mkdir "$outdir/upload/fqStat";
	if($bt2 ne 0)
	{
		print UL "cp $outdir/rRNA/*.rRNA.log $outdir/upload/fqStat -rf \n";
	}
	print UL "cp $outdir/cleanData/*.png $outdir/cleanData/*.stat $outdir/upload/fqStat -rf \n";
	print UL "for i in `ls $outdir/upload/fqStat/*.stat`;do a=`basename \$i .stat`;perl $exp \$i filter $outdir/upload/fqStat/\$a; done \n";
	
	mkdir "$outdir/upload/alignStat";
	print UL "for i in `ls $align_outdir/*/align_summary.txt`; do a=`dirname \$i`; b=`basename \$a`; cp \$i $outdir/upload/alignStat/\$b.align_summary.txt -rf; done \n";
	
	mkdir "$outdir/upload/assessStat";
	print UL "for i in `ls $outdir/assess/*.pdf`; do a=`basename \$i .pdf`; /usr/local/bin/convert \$i $outdir/upload/assessStat/\$a.png; done \n";
	print UL "cp $outdir/assess/*.png $outdir/upload/assessStat/ -rf \n";
	
	mkdir "$outdir/upload/expressionStat";
	print UL "perl $exp $outdir/norm/genes.fpkm_table interclass $outdir/upload/expressionStat/coverGene \n";
	print UL "perl $exp $outdir/norm/genes.fpkm_table fpkm $outdir/upload/expressionStat/fpkm.distribution \n";
	print UL "perl $exp $outdir/diffexpression/gene_exp.diff de-p-0.05 $outdir/upload/expressionStat/geneDE \n";
	if(@group != 1)
	{
		print UL "perl $exp $outdir/groupNorm/genes.fpkm_table interblock $outdir/upload/expressionStat/coverGene \n";
		print UL "perl $exp $outdir/groupDiffexpression/gene_exp.diff de-p-0.05 $outdir/upload/expressionStat/groupDE \n";
	}
	print UL "for i in `ls $outdir/upload/expressionStat/*.DE.xls`; do x=`basename \$i .DE.xls`; a=\${x%-*}; b=\${x#*-}; perl /home/sunyong/bin/diffexpressPearson.pl -f \$i -id1 \$a -id2 \$b -f1 8 -f2 9 -fc 10 -pq 12; done\n";
	
	$gk = rel2abs($gk);
	my $gkA = $cf[28];
	print UL "for i in `ls $outdir/upload/expressionStat/*.DEfilter.xls`; do a=`basename \$i .DEfilter.xls`; perl /home/sunyong/bin/addAnnotation.pl \$i $gkA $outdir/upload/expressionStat/\$a.DEfilter.aa.xls; done \n";
	print UL "rm $outdir/upload/expressionStat/*.DEfilter.xls -rf \n";
	print UL "perl /home/sunyong/bin/addAnnotation.pl $outdir/norm/genes.fpkm_table $gkA $outdir/upload/expressionStat/allsamples.fpkm.aa.xls \n";
	print UL "perl /home/sunyong/bin/pca_heatmap.pl pca $outdir/upload/expressionStat/geneDE.xls $outdir/upload/expressionStat/allsamples.fpkm.aa.xls $outdir/upload/expressionStat/allsamples\n";
	print UL "perl /home/sunyong/bin/pca_heatmap.pl hm $outdir/upload/expressionStat/geneDE.xls $outdir/upload/expressionStat/allsamples.fpkm.aa.xls $outdir/upload/expressionStat/allsamples\n";
	print UL "perl /home/sunyong/bin/enrich_GO-KEGG.pl $outdir/enrichment $gk \n";

	mkdir "$outdir/upload/enrichStat";
	print UL "cp $outdir/enrichment/GO $outdir/enrichment/Pathway $outdir/upload/enrichStat/ -rf \n";

	mkdir "$outdir/upload/newGene";
	print UL "cp $outdir/merge/newGene* $outdir/upload/newGene -rf \n";

	mkdir "$outdir/upload/snp";
	print UL "cp $outdir/snp/upload/* $outdir/upload/snp -rf \n";

	mkdir "$outdir/upload/gso";
	print UL "cp $outdir/assembly/*.png $outdir/assembly/*.xls $outdir/upload/gso -rf \n";
	
	&runSH("$forker  --CPU 1 -c $outdir/shell/upload.13.sh");

##### web && tar.gz #####
	open WTG, "> $outdir/shell/web_tg.14.sh" or die $!;
	print WTG "perl /home/miaoxin/WRITE_HTML/RNA_seq_cuff/write_index_rnaseqcuff.pl -config $config -outdir $outdir/upload \n";
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("%d.%.2d.%.2d.%.2d.%.2d.%.2d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	chdir "$outdir";
	print WTG "tar -zcf $format_time.tar.gz upload \n";
	&runSH("$forker  --CPU 1 -c $outdir/shell/web_tg.14.sh");
	chdir "..";
	
	&showTime("===== All done =====");
}

##### sub program #####
sub usage
{
	die(qq/
	Usage:	$mainPL <config> <outdir> [options]

	Note:
		0. The format of annotation must be gtf.
		1. Make sure consistency of Chromosome between genome and gtf.
		2. '12bed of config' must be processed before this pipeline, so you need to rewrite 'gtf2bed of config' to use itself.
		3. For diffexpression, default every two samples is processed, so you need to sort 'Samples Information of config' and 'group'.

	Options:
		--testMode        INT           1 means only print orders of scripts, default 0
		--gk              FILE          sh cofing of go and kegg
	\n/);
}

sub stop
{
	my ($text) = @_;
	&showTime($text);
	exit;
}

sub runSH
{
	my ($sh) = @_;
	&showTime($sh);
	return if($testMode == 1);
	`$sh`;
}

sub showTime
{
	my ($text) = @_;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	my $format_time = sprintf("[%d-%.2d-%.2d %.2d:%.2d:%.2d]",$year+1900,$mon+1,$mday,$hour,$min,$sec);
	print STDERR "$format_time $text\n";
}

sub readConfig
{
	my ($file, $opts, $hash, $label, $deg, $group, $snp) = @_;
	my $j = 0;
	open FA, $file or die $!;
	while(<FA>)
	{
		chomp;
		next if(/^#|^\s*$/);
		my @x = split /=/;
		if($x[0] =~ /threads/)
		{
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /filtration/)
		{
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /balign/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /assembly/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cquant/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cnorm/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cmerge/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /diffexpress/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /saturation/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /random/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /pearson/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /gtf2bed/){
			$x[1] =~ s/\s*//g;
			if(!-e $x[1])
			{
				#&stop("$x[0] software is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /forker/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /filter_fq/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /tophat/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cufflinks/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cuffmerge/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cuffquant/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cuffnorm/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /cuffdiff/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : options is not exists!\n");
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /genome/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : index is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /bowtie2index/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : index is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /annotation/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : gff/gtf is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /12bed/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : 12bed is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /expressStat/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : expressStat is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /ralign/){
			if($x[1] =~ /^\s*$/)
			{
				<FA>;
				<FA>;
				push @{$opts}, 0;
				push @{$opts}, 0;
				push @{$opts}, 0;
			}else{
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /rbowtie2/){
			push @{$opts}, $x[1];
		}elsif($x[0] =~ /rRNA2index/){
			$x[1] =~ s/\s*//g;
			push @{$opts}, $x[1];
		}elsif($x[0] =~ /gk_annot/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : GO&KEGG`s annotation is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /species/){
			if($x[1] =~ /^\s*$/)
			{
				&stop("$x[0] : species information is not exists!\n");
			}else{
				$x[1] =~ s/\s*//g;
				push @{$opts}, $x[1];
			}
		}elsif($x[0] =~ /label/){
			$x[1] =~ s/\s*//g;
			@{$$hash{$x[1]}} = ();
			push @{$label}, $x[1];

			my $fq1 = <FA>;
			chomp($fq1);
			my @t1 = split /=/, $fq1;
			$t1[1] =~ s/\s*//g;
			if(-e $t1[1])
			{
				push @{$$hash{$x[1]}}, $t1[1];
			}else{
				&stop("$t1[0] of $x[1] is not exists!\n");
			}

			my $fq2 = <FA>;
			next if($fq2 =~ /^\s*$/);
			chomp($fq2);
			my @t2 = split /=/, $fq2;
			next if(!defined $t2[1] or $t2[1] =~ /^\s*$/);
			$t2[1] =~ s/\s*//g;
			if(-e $t2[1])
			{
				push @{$$hash{$x[1]}}, $t2[1];
			}else{
				&stop("$t2[0] of $x[1] is not exists!\n");
			}
		}elsif($x[0] =~ /DEG/){
			if($x[1] =~ /^\s*$/)
			{
				$$deg = 1;
			}else{
				$x[1] =~ s/\s*//g;
				$$deg = $x[1];
			}
		}elsif($x[0] =~ /group/){
			if($x[1] =~ /^\s*$/ or !defined $x[1])
			{
				$$group[$j] = 0;
			}else{
				$x[1] =~ s/\s*//g;
				my @tmp = split /:/, $x[1];
				$$group[$j] = "$tmp[0]\t$tmp[1]";
				$j ++;
			}
		}elsif($x[0] =~ /annotdir/){
			if($x[1] =~ /^\s*$/ or !defined $x[1])
			{
				push @{$snp}, 0;
			}else{
				$x[1] =~ s/\s*//g;
				push @{$snp}, $x[1];
			}
		}elsif($x[0] =~ /annotpf/){
			if($x[1] =~ /^\s*$/ or !defined $x[1])
			{
				push @{$snp}, 0;
			}else{
				$x[1] =~ s/\s*//g;
				push @{$snp}, $x[1];
			}
		}
	}
	close FA;
	return (\@{$opts}, \%{$hash}, \@{$label}, \$deg, \@{$group}, \@{$snp});
}
