#!perl
use warnings;
use strict;
use File::Basename qw(basename);

die "perl $0 <input dir> <go or kegg>\n" if @ARGV != 2;

if($ARGV[1] eq "go")
{
	my @files = `ls $ARGV[0]/*.txt`;

	my (%hash, %all, %name);

	foreach my $i(@files)
	{
		chomp($i);
#next if($i =~ /all_.\.txt$/);
		open FA, $i or die $!;
		$i = basename($i);
		my ($id, $type) = $i =~ /^(\S+)_([PFC])\.txt$/;
		$name{$id} = 0;
		my $t;
		if($type eq "P")
		{
			$t = "Biological Process";
		}elsif($type eq "F"){
			$t = "Molecular Function";
		}else{
			$t = "Cellular Component";
		}
		while(my $line = <FA>)
		{
			chomp($line);
			my @tmp = split /\t/, $line;
			my ($fz) = $tmp[2] =~ /^(\d+) of/;
			my ($fm) = $tmp[3] =~ /^(\d+) of/;
			my $rf = $fz / $fm;
			$hash{$id}{"$t\t$tmp[1]"}{rf} =  $rf;
			$hash{$id}{"$t\t$tmp[1]"}{pv} =  $tmp[4];
			$hash{$id}{"$t\t$tmp[1]"}{qv} =  $tmp[5];
			$all{"$t\t$tmp[1]"} = 0;
		}
		close FA;
	}

	open RF, "> rf.$ARGV[1]" or die $!;
	open PV, "> pv.$ARGV[1]" or die $!;
	open QV, "> qv.$ARGV[1]" or die $!;

	my @n = sort keys %name;

	print RF "Type\tTerm\t".join("\t", @n)."\n";
	print PV "Type\tTerm\t".join("\t", @n)."\n";
	print QV "Type\tTerm\t".join("\t", @n)."\n";

	foreach(sort keys %all)
	{
		my ($lrf, $lpv, $lqv);
		foreach my $i(sort keys %hash)
		{
			if(exists $hash{$i}{$_})
			{
				$lrf .= "$hash{$i}{$_}{rf}\t";
				$lpv .= "$hash{$i}{$_}{pv}\t";
				$lqv .= "$hash{$i}{$_}{qv}\t";
			}else{
				$lrf .= "NA\t";
				$lpv .= "NA\t";
				$lqv .= "NA\t";
			}
		}
		$lrf =~ s/\t$/\n/;
		$lpv =~ s/\t$/\n/;
		$lqv =~ s/\t$/\n/;
		print RF "$_\t$lrf";
		print PV "$_\t$lpv";
		print QV "$_\t$lqv";
	}
}elsif($ARGV[1] eq "kegg"){
	my @files = `ls $ARGV[0]/*.path`;

	my (%hash, %all, %name, %pw);

	my $b2c = "/home/guanpeikun/bin/WGCNA/ko_class.spread.txt";
	open B2C, $b2c or die $!;
	while(<B2C>)
	{
		chomp;
		my @tmp = split /\t/;
		$pw{$tmp[3]} = $tmp[2];
	}
	close B2C;

	foreach my $i(@files)
	{
		chomp($i);
#next if $i =~ /all\.path$/;
		open FA, $i or die $!;
		<FA>;
		$i = basename($i);
		my ($id) = $i =~ /^(\S+)\.path$/;
		$name{$id} = 0;
		while(my $line = <FA>)
		{
			chomp($line);
			my @tmp = split /\t/, $line;
			my $rf = $tmp[1] / $tmp[2];
			$pw{$tmp[0]} = "-" if(!exists $pw{$tmp[0]});
			$hash{$id}{"$pw{$tmp[0]}\t$tmp[0]"}{rf} =  $rf;
			$hash{$id}{"$pw{$tmp[0]}\t$tmp[0]"}{pv} =  $tmp[3];
			$hash{$id}{"$pw{$tmp[0]}\t$tmp[0]"}{qv} =  $tmp[4];
			$all{"$pw{$tmp[0]}\t$tmp[0]"} = 0;
		}
		close FA;
	}
	
	open RF, "> rf.$ARGV[1]" or die $!;
	open PV, "> pv.$ARGV[1]" or die $!;
	open QV, "> qv.$ARGV[1]" or die $!;

	my @n = sort keys %name;

	print RF "B_Pathway\tC_Pathway\t".join("\t", @n)."\n";
	print PV "B_Pathway\tC_Pathway\t".join("\t", @n)."\n";
	print QV "B_Pathway\tC_Pathway\t".join("\t", @n)."\n";

	foreach(sort keys %all)
	{
		my ($lrf, $lpv, $lqv);
		foreach my $i(sort keys %hash)
		{
			if(exists $hash{$i}{$_})
			{
				$lrf .= "$hash{$i}{$_}{rf}\t";
				$lpv .= "$hash{$i}{$_}{pv}\t";
				$lqv .= "$hash{$i}{$_}{qv}\t";
			}else{
				$lrf .= "NA\t";
				$lpv .= "NA\t";
				$lqv .= "NA\t";
			}
		}
		$lrf =~ s/\t$/\n/;
		$lpv =~ s/\t$/\n/;
		$lqv =~ s/\t$/\n/;
		print RF "$_\t$lrf";
		print PV "$_\t$lpv";
		print QV "$_\t$lqv";
	}
}else{
	die "choose correct options: go or kegg";
}

my @files;
if($ARGV[1] eq "go")
{
	@files = `ls *.go`;
}else{
	@files = `ls *.kegg`;
}

foreach(@files)
{
	chomp;
	my $rf = 0;
	if($_ =~ /rf/)
	{
		$rf = 0.05;
	}
	open FA, $_ or die $!;
	open TMP, "> $_.tmp" or die $!;
	my $head = <FA>;
	print TMP $head;
	while(my $line = <FA>)
	{
		chomp($line);
		my @tmp = split /\t/, $line;
		my @num = @tmp[2..$#tmp];
		my $n = 0;
		foreach my $i(@num)
		{
			next if($i eq "NA");
			if($rf == 0)
			{
				$n ++ if($i <= 0.05);
			}else{
				$n ++ if($i >= $rf);
			}
		}
		if($n > 0)
		{
			print TMP "$line\n";
		}
	}
	close FA;
	close TMP;

	my $test = `wc -l $_.tmp`;
	next if($test =~ /^1 /);
	open CMD, "> $ARGV[1].r" or die $!;
	print CMD "
	library(pheatmap)
	rawdata = read.table(\"$_.tmp\", header = T, sep = \"\\t\", quote =\"\", check.names = F)
	mat = rawdata[,2:length(colnames(rawdata))]
	rownames(mat) = rawdata[,2]
	mat = mat[,-1]
	if(\"$_\" == \"rf.go\" || \"$_\" == \"rf.kegg\")
	{
		mycolor = colorRampPalette(c(\"green\", \"white\", \"red\"),bias=3)(256)
	}else{
		mycolor = colorRampPalette(c(\"red\", \"white\", \"green\"),bias=4.5)(256)
	}
	annot = data.frame(class=rawdata[,1])
	rownames(annot)= rownames(mat)
	pheatmap(mat, legend_breaks=c(0, 0.05, 0.2, 0.4, 0.6, 0.8, 1), cluster_cols=F, cluster_rows=F, color=mycolor, display_numbers=T, annotation_row=annot, number_format=\"%.3f\",filename=\"$_.pdf\",cellwidth=25,cellheight=12)
	";

	`Rscript $ARGV[1].r`;
	`rm Rplots.pdf $_.tmp -rf`;
}
