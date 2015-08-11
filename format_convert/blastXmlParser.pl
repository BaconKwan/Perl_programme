#!/usr/bin/perl  -w

use warnings;
use strict;

die "Usage: perl  blastParser  <xmlBlast>    <tableExport>" if ( @ARGV != 2 );

my ( $xmlBlast, $export ) = @ARGV;

open( XML,    $xmlBlast )     || die "$!";
open( EXPORT, ">$export" ) || die "$!";

local $/ = "<Iteration>";

my ( $query, $query_length ) = ( );

print EXPORT qq{query_name\thsp\tquery_length\tsubject_length\tquery_coverage(%)\tsubject_coverage(%)\tannotation\tscore\tbit_score\tevalue\tidentity(%)\tquery_frame\tquery_start\tquery_end\tsubject_frame\tsubject_start\tsubject_end\n};

while (<XML>) {

    next if ( $_ !~ /\<Iteration_query-def\>/ );

    ($query)        = $_ =~ /\<Iteration_query-def\>(.+?)\<\/Iteration_query-def\>/;
    ($query_length) = $_ =~ /\<Iteration_query-len\>(.+?)\<\/Iteration_query-len\>/;

    my ( $subject, $subject_length ) = ( );

    foreach my $hit (split /\<\/Hit\>/) {

        next if ( $hit !~ /\<Hit_def\>/ );

           ($subject)        =  $hit =~ /\<Hit_def\>(.+?)\<\/Hit_def\>/;
        my ($hit_id)         =  $hit =~ /\<Hit_id\>(.+?)\<\/Hit_id\>/;
            $hit_id          =~ s/^lcl\|//;
            $subject         =  $hit_id." $subject";
            $subject         =~ s/^gnl\S+\s+//;
            $subject         =~ s/\s+No definition line found//;
           ($subject_length) =  $hit =~ /\<Hit_len\>(.+?)\<\/Hit_len\>/;
        
        my (
            $hsp_number,  $query_coverage, $hit_coverage, $bit_score,     $score,        $evalue,     $identity_rate,
            $query_frame, $query_from,     $query_to,         $hit_frame,     $hit_from,     $hit_to
          )= ();

        foreach my $hsp (split /<\/Hsp>/, $hit) {

            next if ( $hsp !~ /\<Hsp_num\>/ );
            
            ($hsp_number)        = $hsp =~ /\<Hsp_num\>(.+?)\<\/Hsp_num\>/;
            
            ($bit_score)         = $hsp =~ /\<Hsp_bit-score\>(.+?)\<\/Hsp_bit-score\>/;
            ($score)             = $hsp =~ /\<Hsp_score\>(.+?)\<\/Hsp_score\>/;
            ($evalue)            = $hsp =~ /\<Hsp_evalue\>(.+?)\<\/Hsp_evalue\>/;
             
             $query_frame        = ($hsp =~ /\<Hsp_query-frame\>(.+?)\<\/Hsp_query-frame\>/) ? $1 : '/'; 
            ($query_from)        = $hsp =~ /\<Hsp_query-from\>(.+?)\<\/Hsp_query-from\>/;
            ($query_to)          = $hsp =~ /\<Hsp_query-to\>(.+?)\<\/Hsp_query-to\>/;
           
             $hit_frame          =($hsp =~ /\<Hsp_hit-frame\>(.+?)\<\/Hsp_hit-frame\>/) ?  $1 : '/';
            ($hit_from)          = $hsp =~ /\<Hsp_hit-from\>(.+?)\<\/Hsp_hit-from\>/;
            ($hit_to)            = $hsp =~ /\<Hsp_hit-to\>(.+?)\<\/Hsp_hit-to\>/;

            my ($identity)       = $hsp =~ /\<Hsp_identity\>(.+?)\<\/Hsp_identity\>/;
            my ($alignment_len)  = $hsp =~ /\<Hsp_align-len\>(.+?)\<\/Hsp_align-len\>/;

            $identity_rate   = sprintf("%.2f",($identity * 100 / $alignment_len));
            
            $query_coverage      = 100 * ( abs( $query_to   - $query_from)   + 1 ) / $query_length;
            $hit_coverage        = 100 * ( abs( $hit_to - $hit_from) + 1 ) / $subject_length;
            
            printf EXPORT qq{%s\t%s\t%s\t%s\t%.2f\t%.2f\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n},(
                   $query,   $hsp_number,    $query_length, $subject_length, $query_coverage, $hit_coverage,
                   $subject, $score,         $bit_score,    $evalue,         $identity_rate,
                   $query_frame,   $query_from,      $query_to,     $hit_frame,   $hit_from,       $hit_to);
        }
    }
}
local $/ = "\n";
close XML;
close EXPORT;
exit;