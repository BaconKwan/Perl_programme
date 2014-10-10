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

my %opts;
GetOptions(\%opts, "gt=s", "pt=s", "xls=s", "conf=s", "prefix=s", "out=s");
&usage if(!$opts{gt} || !$opts{pt} || !$opts{xls} || !$opts{conf});
$opts{prefix} = $opts{prefix} ? $opts{prefix} : "profile";
$opts{out} = rel2abs($opts{out} ? $opts{out} : "out");

my ($get_ko, $path_find, $komap_nodiff, $get_wego, $draw_go, $batik, $func, $gen_html, $add_desc, $draw_png, $ref_path, $wego_file, $ko_file, $komap_file, $go_dir, $go_species, $desc_file, $desc_col);
my (%id, %folder);
my ($xls_line, $Sname);
&readconf(\$get_ko, \$path_find, \$komap_nodiff, \$get_wego, \$draw_go, \$batik, \$func, \$gen_html, \$add_desc, \$draw_png, \$ref_path, \$wego_file, \$ko_file, \$komap_file, \$go_dir, \$go_species, \$desc_file, \$desc_col);
&checkconf(\$get_ko, \$path_find, \$komap_nodiff, \$get_wego, \$draw_go, \$batik, \$func, \$gen_html, \$add_desc, \$draw_png, \$ref_path, \$wego_file, \$ko_file, \$komap_file, \$go_dir, \$go_species, \$desc_file, \$desc_col);

die "genetable not found!\n" if(!(-s "$opts{gt}"));
die "profiletable not found!\n" if(!(-s "$opts{pt}"));
die "XLS file not found!\n" if(!(-s "$opts{xls}"));
my @suffix = qw/_genetable.txt .table .txt/;
$Sname = basename($opts{gt}, @suffix);
$opts{gt} = rel2abs($opts{gt});
$opts{pt} = rel2abs($opts{pt});


print("Loading xls file ...\n");
open XLS, "< $opts{xls}" || die $!;
$xls_line = <XLS>;
chomp $xls_line;
$xls_line =~ s///g;
while(<XLS>){
	chomp;
	s///g;
	my $index = (split /\t/)[0];
	$index = uc($index);
	$id{$index} = $_;
}
close XLS;

print("Loading stem table ...\n");
open IN, "< $opts{gt}" || die $!;
<IN>;
while(<IN>){
	chomp;
	s/^\s+//g;
	s///g;
	my @line = split /\t/;
	push(@{$folder{$line[2]}}, $line[0]);
}
close IN;

print("Creating glist_files ...\n");
system("mkdir -p $opts{out}");
foreach my $i (sort keys %folder){
	open OUT, "> $opts{out}/$opts{prefix}_$i.glist" || die $!;
	print OUT "$xls_line\n";
	foreach(@{$folder{$i}}){
		print OUT "$id{$_}\n";
	}
	close OUT;
}

print("Creating shell scripts ...\n");
open SH, "> $opts{out}/enrich.sh" || die $!;
print SH 
"## enrich shell scripts for trends analysis
for i in `ls $opts{out}/*.glist`
do
	name=`basename \$i \".glist\"`
# KO
	mkdir -p $opts{out}/KO
	cut -f 1 \$i > $opts{out}/KO/\"\$name\".glist
	perl $get_ko -glist $opts{out}/KO/\"\$name\".glist -bg $ref_path/$ko_file -outdir $opts{out}/KO
	perl $path_find -fg $opts{out}/KO/\"\$name\".ko -komap $komap_file -bg $ref_path/$ko_file -output $opts{out}/KO/\"\$name\".path
	perl $komap_nodiff -ko $opts{out}/KO/\"\$name\".ko -komap $komap_file -outdir $opts{out}/KO/\"\$name\"_map
# GO
	mkdir -p $opts{out}/GO
	cut -f 1 \$i > $opts{out}/GO/\"\$name\".glist
	perl $get_wego $opts{out}/GO/\"\$name\".glist $ref_path/$wego_file > $opts{out}/GO/\"\$name\".wego
	perl $draw_go -gglist $opts{out}/GO/\"\$name\".wego -output $opts{out}/GO/\"\$name\".go
	java -jar $batik -m image/png $opts{out}/GO/\"\$name\".go.svg
done

perl $func -go -gldir $opts{out} -sdir $go_dir -species $go_species -outdir $opts{out}
perl $gen_html -indir $opts{out}/KO
\n";

if(defined $desc_file){
print SH
"
perl $add_desc $ref_path/$desc_file $desc_col $opts{out}/*.glist
rm $opts{out}/*.glist -rf
\n";
}

print SH
"rm $opts{out}/GO/*.glist $opts{out}/KO/*.glist -rf
for i in `ls $opts{out}/KO/*.path`; do mv \$i \$i.xls; done
for i in `ls $opts{out}/KO/*.ko`; do mv \$i \$i.xls; done
for i in `ls $opts{out}/GO/*.wego`; do mv \$i \$i.xls; done
for i in `ls $opts{out}/GO/*.txt`; do mv \$i `echo \$i | sed s/txt\$/xls/`; done

## Plotting shell scripts for trends analysis
echo \"Drawing ...\"
perl $draw_png $opts{gt} $opts{pt} $opts{out}/$Sname -n log

## END";
close SH;

print "OK ...\n";
exit;

sub usage{
	die"
	Usage: perl $0 -gt <genetable> -pt <profiletable> -xls <rpkm.xls> -conf <config> [-prefix <text>] [-out <text>]
	Options:
		-gt               string           *STEM analysis result in output folder, which names like *_genetable.txt
		-pt               string           *STEM analysis result in output folder, which names like *_profiletable.txt
		-xls              string           *input file for STEM analysis
		-conf             string           *config files
		-prefix           string            output classes prefixs, default: profile
		-out              string            output dir, default: ./out
	\n";
}

sub readconf{
	my($get_ko, $path_find, $komap_nodiff, $get_wego, $draw_go, $batik, $func, $gen_html, $add_desc, $draw_png, $ref_path, $wego_file, $ko_file, $komap_file, $go_dir, $go_species, $desc_file, $desc_col) = @_;
	open CONF, "< $opts{conf}" || die $!;
	print("Loding config ... \n");
	while(<CONF>){
		chomp;
		next if (/^[#]+|(^$)|(^\s+$)/);
		s/(^\s+)|(\s+$)//g;
		my @line = split /\s*=\s*/;
		if($line[0] =~ /get_ko/){
			$$get_ko = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /path_find/){
			$$path_find = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /komap_nodiff/){
			$$komap_nodiff = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /get_wego/){
			$$get_wego = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /draw_go/){
			$$draw_go = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /batik/){
			$$batik = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /func/){
			$$func = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /gen_html/){
			$$gen_html = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /add_desc/){
			$$add_desc = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /draw_png/){
			$$draw_png= rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /ref_path/){
			$$ref_path = rel2abs($line[1]) if(defined $line[1]);
		}
		elsif($line[0] =~ /wego_file/){
			$$wego_file = $line[1] if(defined $line[1]);
		}
		elsif($line[0] =~ /ko_file/){
			$$ko_file = $line[1] if(defined $line[1]);
		}
		elsif($line[0] =~ /komap_file/){
			$$komap_file = $line[1] if(defined $line[1]);
		}
		elsif($line[0] =~ /go_dir/){
			$$go_dir = $line[1] if(defined $line[1]);
		}
		elsif($line[0] =~ /go_species/){
			$$go_species = $line[1] if(defined $line[1]);
		}
		elsif($line[0] =~ /desc_file/){
			$$desc_file = $line[1] if(defined $line[1]);
		}
		elsif($line[0] =~ /desc_col/){
			$$desc_col = $line[1] if(defined $line[1]);
		}
	}
	close CONF;
}

sub checkconf{
	my($get_ko, $path_find, $komap_nodiff, $get_wego, $draw_go, $batik, $func, $gen_html, $add_desc, $draw_png, $ref_path, $wego_file, $ko_file, $komap_file, $go_dir, $go_species, $desc_file, $desc_col) = @_;
	die "Bad get_ko path\n" if(!defined $$get_ko || !(-s "$$get_ko"));
	die "Bad path_find path\n" if(!defined $$path_find || !(-s "$$path_find"));
	die "Bad komap_nodiff path\n" if(!defined $$komap_nodiff || !(-s "$$komap_nodiff"));
	die "Bad get_wego path\n" if(!defined $$get_wego || !(-s "$$get_wego"));
	die "Bad draw_go path\n" if(!defined $$draw_go || !(-s "$$draw_go"));
	die "Bad batik path\n" if(!defined $$batik || !(-s "$$batik"));
	die "Bad func path\n" if(!defined $$func || !(-s "$$func"));
	die "Bad gen_html path\n" if(!defined $$gen_html || !(-s "$$gen_html"));
	die "Bad add_desc path\n" if(!defined $$add_desc || !(-s "$$add_desc"));
	die "Bad draw_png path\n" if(!defined $$draw_png|| !(-s "$$draw_png"));
	die "Bad ref_path path\n" if(!defined $$ref_path || !(-s "$$ref_path"));
	die "Bad wego_file path\n" if(!defined $$wego_file || !(-s "$$ref_path/$$wego_file"));
	die "Bad ko_file path\n" if(!defined $$ko_file || !(-s "$$ref_path/$$ko_file"));
	die "Bad komap_file path\n" if(!defined $$komap_file || !(-s "$$komap_file"));
	die "Bad go_dir path\n" if(!defined $$go_dir || !(-s "$$go_dir"));
	die "Bad go_species path\n" if(!defined $$go_species || !(-s "$$go_dir/$$go_species.P") || !(-s "$$go_dir/$$go_species.C") || !(-s "$$go_dir/$$go_species.F"));
	die "missing X.conf files\n" if(!(-s "$$go_dir/P.conf") || !(-s "$$go_dir/C.conf") || !(-s "$$go_dir/F.conf"));
	die "Bad desc_file path\n" if(defined $$desc_file && !(-s "$$ref_path/$$desc_file"));
	die "Bad desc_col setting\n" unless($$desc_col =~ /^[0-9]+$/);
}
