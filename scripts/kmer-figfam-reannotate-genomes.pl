use strict;
use Bio::KBase::KmerAnnotationByFigfam::Client;
use Bio::KBase::CDMI::Client;
use Getopt::Long;
use JSON;
use Data::Dumper;
use Proc::ParallelLoop;

my $url;
my $port;
my $parallel = 1;

my $usage = "Usage: kmer-figfams-reannotate-genomes [--parallel N] [--port port] [--url url] < list-of-genome-ids \n";

my $rc = GetOptions("port=s" => \$port,
		    "url=s"  => \$url,
		    "parallel=s" => \$parallel,
		    );

if (!$rc || @ARGV != 0)
{
    die $usage;
}

if (!$url)
{
    if ($port)
    {
	$url = "http://localhost:$port/";
    }
}

my @work = <>;
chomp @work;

pareach \@work, sub {
    my $gid = shift;

    my $client = Bio::KBase::KmerAnnotationByFigfam::Client->new($url);
    my $cdm = Bio::KBase::CDMI::Client->new();

    process_genome($gid, $client, $cdm);

}, { Max_Workers => $parallel };


sub process_genome
{
    my($gid, $kmer_client, $cdm) = @_;

    my $fids = $cdm->genomes_to_fids([$gid], ['peg', 'CDS']);
print Dumper($fids);
    $fids = $fids->{$gid};
    my $prots = $cdm->fids_to_protein_sequences($fids);
print Dumper($fids, $prots);

    my $max_size = 1_000_000;
    my $size = 0;
    my @input;

    my $params = {
	kmer_size => 8,
	detailed => 0,
    };

    for my $fid (@$fids)
    {
	push(@input, [$fid, $prots->{$fid}]);
	$size += length($prots->{$fid});
	if ($size > $max_size)
	{
	    process_proteins($kmer_client, $params,\@input);
	    @input = ();
	    $size = 0;
	}
    }
    if (@input)
    {
	process_proteins($kmer_client, $params, \@input);
    }
}

sub process_proteins
{
    my($client, $params, $input) = @_;
    my $res = $client->annotate_proteins($input, $params);

    for my $ent (@$res)
    {
	my $details = $ent->[6];
	print join("\t", @$ent[0..5]), "\n";
	if (ref($details))
	{
	    print join("\t", '', @$_), "\n" foreach @$details;
	}
    }
}
