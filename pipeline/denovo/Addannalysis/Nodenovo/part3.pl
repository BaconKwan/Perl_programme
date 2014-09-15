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

