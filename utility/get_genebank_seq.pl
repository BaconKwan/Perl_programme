#!/usr/bin/perl -w

use strict;
use Getopt::Std;
use Bio::DB::GenPept;    ## for mRNA/protein sequence
use Bio::DB::GenBank;    ## for NT seqs
use Bio::SeqIO;

my %opts = ( D => 'GenPept' , T => 'id' );
getopts( 'D:T:f:Lh', \%opts );

&usage if(@ARGV == 0 || $opts{h});

# the array used to save id or acc number
my @id;

if ( $opts{L} ) {
	die "id or acc must be saved in one list file!\n" if ( $#ARGV != 0 || ! -e $ARGV[0]);
	while (<>) {
		chomp;
		push @id, $_;
	}
}
else {
	push @id, $_ foreach (@ARGV);
}

# init the DB
my $db;

if ( $opts{D} eq "GenPept" ) {
	$db = new Bio::DB::GenPept();
}
elsif ( $opts{D} eq "GenBank" ) {
	$db = new Bio::DB::GenBank();
}
else {
	die "ERROR:now just can get sequence from GenPept and GenBank Database\n";
}

# init output
my $out;

if ( $opts{f} ) {
	$out = new Bio::SeqIO( -format => 'fasta', -file => ">$opts{f}" );
}
else {
	$out = new Bio::SeqIO( -format => 'fasta' );
}

# get the seuqnece by Stream
my $seqio = $db->get_Stream_by_id([@id]);
while( my $seq = $seqio->next_seq ) {
	$out->write_seq($seq);
}

=head get the sequence one by one
foreach (@id) {
	my $seq;
	
	if ($opts{T} eq "id"){
		$seq = $db->get_Seq_by_id($_);
	}
	elsif($opts{T} eq "acc"){
		$seq = $db->get_Seq_by_acc($_);
	} 

	if ($seq) {
		$out->write_seq($seq);
	}
	else {
		warn "can't find seq for '$_'\n";
	}
}
=cut

$out->close();

sub usage{
	print qq(
Usage:   perl $0 [options] <id/acc>s|<id/acc list file>

Options: -D STR    Database name, GenPept or GenBank [GenPept]
         -f STR    output the result to file ,[STDOUT]
         -L        the input is the id/acc list file
         -h        show this info
\n);
	exit;
}