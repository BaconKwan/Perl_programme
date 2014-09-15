#!/usr/bin/perl -w
use strict;
open IN,"<Add.lib";
my $fa;
while (<IN>)
{
        chomp;
        my @inf=split /=/,$_;
        $fa=$inf[1] if $inf[0]=~/fa/;
}
my $base=`basename $fa`;
chomp $base;
`mkdir SSR_out`;
`perl ~/gaochuan/program/cut_id.pl $fa >SSR_out/$base`;
`cd SSR_out/ && perl /parastor/users/luoda/luo/DenovoRNA_additional_analysis_SOFTWARES/bin/transcriptome_run_ssr.pl $base`;
