#! /usr/bin/perl

#	Author:	BaconKwan
#	Email:	pkguan@genedenovo.com
#	Version:	1.0
#	Create date:	
#	Usage:	

use utf8;
use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::EMBL;

my $seq_io = Bio::SeqIO->new(-file => "$ARGV[0]" , -format => "EMBL" );
my $reference = "";
my $comment = "";
my $gene_num = 0;

while( my $seq_obj = $seq_io->next_seq )
{
=cut
	my $accession = $seq_obj->accession_number;
	my $description = $seq_obj->description;
	my $species = $seq_obj->species->common_name;
	my @classification = $seq_obj->species->classification;
	@classification = reverse (@classification);
	my $classification = join ( "; ", @classification );
	my $len = $seq_obj->length;
	my $version = $seq_obj->version;
	my ($date) = $seq_obj->get_dates;
	my $topology;
	if ( $seq_obj->is_circular )
	{
		$topology = "circular";
	}
	else
	{
		$topology = "linear";
	}

	my $anno_collection = $seq_obj->annotation;
	my @key = $anno_collection->get_all_annotation_keys;
	foreach my $key ( @key )
	{
		my @annotations = $anno_collection->get_Annotations($key);
		foreach my $value ( @annotations )
		{
			my $tagname = $value->tagname;
			if( $tagname eq "reference" )
			{
				my $authors = $value->authors;
				my $title = $value->title;
				my $location = $value->location;
				my $start = $value->start;
				my $end = $value->end;
				$reference.= $authors."|".$title."|".$location."|".$start."|".$end."#";
			}
			elsif( $tagname eq "comment" )
			{
				$comment = $value->text;
			}
		}
	}
=cut

	foreach my $feat_object ( $seq_obj->get_SeqFeatures )
	{
		if ( $feat_object->primary_tag eq "CDS" ){
			my @tags = $feat_object->get_all_tags();
			my ($gene, $locus_tag, $function, $note) = ("", "", "", "");
			foreach (@tags){
				if($_ eq "gene"){
					my @gene = $feat_object->get_tag_values($_);
					$gene = $gene[0];
				}
				elsif($_ eq "locus_tag"){
					my @locus_tag = $feat_object->get_tag_values($_);
					$locus_tag = $locus_tag[0];
				}
				elsif($_ eq "note"){
					my @note = $feat_object->get_tag_values($_);
					$note = $note[0];
				}
				elsif($_ eq "function"){
					my @function = $feat_object->get_tag_values($_);
					$function = $function[0];
				}
			}
			if($note ne ""){
				my (@goa) = $note =~ /GO:\S+/g;
				foreach my $go (@goa){
					my $txt = join "\t", $locus_tag, $locus_tag, $gene, $go, $function;
					print "$txt\n";
				}
			}
		}
		#$gene_num++;
	}
}
