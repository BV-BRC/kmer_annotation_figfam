package Bio::KBase::KmerAnnotationByFigfam::Client;

use POSIX;
use strict;
use Data::Dumper;
use URI;

my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};



=head1 NAME

Bio::KBase::KmerAnnotationByFigfam::Client

=head1 DESCRIPTION





=cut


sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'http://10.0.16.184:7105';
    }

    my $self = {
	client => Bio::KBase::KmerAnnotationByFigfam::Client::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    $ua->agent("Bio::KBase::KmerAnnotationByFigfam::Client UserAgent");
    bless $self, $class;
    return $self;
}




=head2 get_dataset_names

  $dataset_names = $obj->get_dataset_names()

=over 4

=item Parameter and return types

=begin html

<pre>
$dataset_names is a reference to a list where each element is a string

</pre>

=end html

=begin text

$dataset_names is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

sub get_dataset_names
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
        die "Invalid argument count for function get_dataset_names (received $n, expecting 0)";
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KmerAnnotationByFigfam.get_dataset_names",
	params => \@args,
    });
    if ($result) {
	if ($result->{error}) {
	    my $msg = $result->{error}->{error} || $result->{error}->{message};
	    $msg =  $self->{client}->json->encode($msg) if ref($msg);
	    die "Error $result->{error}->{code} invoking get_dataset_names:\n$msg\n";
	} else {
	    return wantarray ? @{$result->{result}} : $result->{result}->[0];
	}
    } else {
	die "Error invoking method get_dataset_names: " .  $self->{client}->status_line;
    }
}



=head2 get_default_dataset_name

  $default_dataset_name = $obj->get_default_dataset_name()

=over 4

=item Parameter and return types

=begin html

<pre>
$default_dataset_name is a string

</pre>

=end html

=begin text

$default_dataset_name is a string


=end text

=item Description



=back

=cut

sub get_default_dataset_name
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
        die "Invalid argument count for function get_default_dataset_name (received $n, expecting 0)";
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KmerAnnotationByFigfam.get_default_dataset_name",
	params => \@args,
    });
    if ($result) {
	if ($result->{error}) {
	    my $msg = $result->{error}->{error} || $result->{error}->{message};
	    $msg =  $self->{client}->json->encode($msg) if ref($msg);
	    die "Error $result->{error}->{code} invoking get_default_dataset_name:\n$msg\n";
	} else {
	    return wantarray ? @{$result->{result}} : $result->{result}->[0];
	}
    } else {
	die "Error invoking method get_default_dataset_name: " .  $self->{client}->status_line;
    }
}



=head2 annotate_proteins

  $hits = $obj->annotate_proteins($proteins, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$proteins is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (protein) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string

</pre>

=end html

=begin text

$proteins is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (protein) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string


=end text

=item Description



=back

=cut

sub annotate_proteins
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
        die "Invalid argument count for function annotate_proteins (received $n, expecting 2)";
    }
    {
	my($proteins, $params) = @args;

	my @_bad_arguments;
        (ref($proteins) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"proteins\" (value was \"$proteins\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotate_proteins:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    die $msg;
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KmerAnnotationByFigfam.annotate_proteins",
	params => \@args,
    });
    if ($result) {
	if ($result->{error}) {
	    my $msg = $result->{error}->{error} || $result->{error}->{message};
	    $msg =  $self->{client}->json->encode($msg) if ref($msg);
	    die "Error $result->{error}->{code} invoking annotate_proteins:\n$msg\n";
	} else {
	    return wantarray ? @{$result->{result}} : $result->{result}->[0];
	}
    } else {
	die "Error invoking method annotate_proteins: " .  $self->{client}->status_line;
    }
}



=head2 annotate_proteins_fasta

  $hits = $obj->annotate_proteins_fasta($protein_fasta, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$protein_fasta is a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string

</pre>

=end html

=begin text

$protein_fasta is a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
hit is a reference to a list containing 7 items:
	0: (id) a string
	1: (prot_function) a string
	2: (otu) a string
	3: (score) an int
	4: (nonoverlapping_hits) an int
	5: (overlapping_hits) an int
	6: (details) a reference to a list where each element is a hit_detail
hit_detail is a reference to a list containing 4 items:
	0: (offset) an int
	1: (oligo) a string
	2: (prot_function) a string
	3: (otu) a string


=end text

=item Description



=back

=cut

sub annotate_proteins_fasta
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
        die "Invalid argument count for function annotate_proteins_fasta (received $n, expecting 2)";
    }
    {
	my($protein_fasta, $params) = @args;

	my @_bad_arguments;
        (!ref($protein_fasta)) or push(@_bad_arguments, "Invalid type for argument 1 \"protein_fasta\" (value was \"$protein_fasta\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to annotate_proteins_fasta:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    die $msg;
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KmerAnnotationByFigfam.annotate_proteins_fasta",
	params => \@args,
    });
    if ($result) {
	if ($result->{error}) {
	    my $msg = $result->{error}->{error} || $result->{error}->{message};
	    $msg =  $self->{client}->json->encode($msg) if ref($msg);
	    die "Error $result->{error}->{code} invoking annotate_proteins_fasta:\n$msg\n";
	} else {
	    return wantarray ? @{$result->{result}} : $result->{result}->[0];
	}
    } else {
	die "Error invoking method annotate_proteins_fasta: " .  $self->{client}->status_line;
    }
}



=head2 call_genes_in_dna

  $hits = $obj->call_genes_in_dna($dna, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$dna is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a dna_hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
dna_hit is a reference to a list containing 6 items:
	0: (nhits) an int
	1: (id) a string
	2: (beg) an int
	3: (end) an int
	4: (protein_function) a string
	5: (otu) a string

</pre>

=end html

=begin text

$dna is a reference to a list where each element is a reference to a list containing 2 items:
	0: (id) a string
	1: (dna) a string
$params is a kmer_annotation_figfam_parameters
$hits is a reference to a list where each element is a dna_hit
kmer_annotation_figfam_parameters is a reference to a hash where the following keys are defined:
	kmer_size has a value which is an int
	dataset_name has a value which is a string
	return_scores_for_all_proteins has a value which is an int
	score_threshold has a value which is an int
	hit_threshold has a value which is an int
	sequential_hit_threshold has a value which is an int
	detailed has a value which is an int
	min_hits has a value which is an int
	min_size has a value which is an int
	max_gap has a value which is an int
dna_hit is a reference to a list containing 6 items:
	0: (nhits) an int
	1: (id) a string
	2: (beg) an int
	3: (end) an int
	4: (protein_function) a string
	5: (otu) a string


=end text

=item Description



=back

=cut

sub call_genes_in_dna
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
        die "Invalid argument count for function call_genes_in_dna (received $n, expecting 2)";
    }
    {
	my($dna, $params) = @args;

	my @_bad_arguments;
        (ref($dna) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"dna\" (value was \"$dna\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to call_genes_in_dna:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    die $msg;
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KmerAnnotationByFigfam.call_genes_in_dna",
	params => \@args,
    });
    if ($result) {
	if ($result->{error}) {
	    my $msg = $result->{error}->{error} || $result->{error}->{message};
	    $msg =  $self->{client}->json->encode($msg) if ref($msg);
	    die "Error $result->{error}->{code} invoking call_genes_in_dna:\n$msg\n";
	} else {
	    return wantarray ? @{$result->{result}} : $result->{result}->[0];
	}
    } else {
	die "Error invoking method call_genes_in_dna: " .  $self->{client}->status_line;
    }
}



=head2 estimate_closest_genomes

  $output = $obj->estimate_closest_genomes($proteins, $dataset_name)

=over 4

=item Parameter and return types

=begin html

<pre>
$proteins is a reference to a list where each element is a reference to a list containing 3 items:
	0: (id) a string
	1: (function) a string
	2: (translation) a string
$dataset_name is a string
$output is a reference to a list where each element is a reference to a list containing 3 items:
	0: (genome_id) a string
	1: (score) an int
	2: (genome_name) a string

</pre>

=end html

=begin text

$proteins is a reference to a list where each element is a reference to a list containing 3 items:
	0: (id) a string
	1: (function) a string
	2: (translation) a string
$dataset_name is a string
$output is a reference to a list where each element is a reference to a list containing 3 items:
	0: (genome_id) a string
	1: (score) an int
	2: (genome_name) a string


=end text

=item Description



=back

=cut

sub estimate_closest_genomes
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
        die "Invalid argument count for function estimate_closest_genomes (received $n, expecting 2)";
    }
    {
	my($proteins, $dataset_name) = @args;

	my @_bad_arguments;
        (ref($proteins) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"proteins\" (value was \"$proteins\")");
        (!ref($dataset_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"dataset_name\" (value was \"$dataset_name\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to estimate_closest_genomes:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    die $msg;
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "KmerAnnotationByFigfam.estimate_closest_genomes",
	params => \@args,
    });
    if ($result) {
	if ($result->{error}) {
	    my $msg = $result->{error}->{error} || $result->{error}->{message};
	    $msg =  $self->{client}->json->encode($msg) if ref($msg);
	    die "Error $result->{error}->{code} invoking estimate_closest_genomes:\n$msg\n";
	} else {
	    return wantarray ? @{$result->{result}} : $result->{result}->[0];
	}
    } else {
	die "Error invoking method estimate_closest_genomes: " .  $self->{client}->status_line;
    }
}





=head1 TYPES



=head2 kmer_annotation_figfam_parameters

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
kmer_size has a value which is an int
dataset_name has a value which is a string
return_scores_for_all_proteins has a value which is an int
score_threshold has a value which is an int
hit_threshold has a value which is an int
sequential_hit_threshold has a value which is an int
detailed has a value which is an int
min_hits has a value which is an int
min_size has a value which is an int
max_gap has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
kmer_size has a value which is an int
dataset_name has a value which is a string
return_scores_for_all_proteins has a value which is an int
score_threshold has a value which is an int
hit_threshold has a value which is an int
sequential_hit_threshold has a value which is an int
detailed has a value which is an int
min_hits has a value which is an int
min_size has a value which is an int
max_gap has a value which is an int


=end text

=back



=head2 hit_detail

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 4 items:
0: (offset) an int
1: (oligo) a string
2: (prot_function) a string
3: (otu) a string

</pre>

=end html

=begin text

a reference to a list containing 4 items:
0: (offset) an int
1: (oligo) a string
2: (prot_function) a string
3: (otu) a string


=end text

=back



=head2 hit

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 7 items:
0: (id) a string
1: (prot_function) a string
2: (otu) a string
3: (score) an int
4: (nonoverlapping_hits) an int
5: (overlapping_hits) an int
6: (details) a reference to a list where each element is a hit_detail

</pre>

=end html

=begin text

a reference to a list containing 7 items:
0: (id) a string
1: (prot_function) a string
2: (otu) a string
3: (score) an int
4: (nonoverlapping_hits) an int
5: (overlapping_hits) an int
6: (details) a reference to a list where each element is a hit_detail


=end text

=back



=head2 dna_hit

=over 4



=item Definition

=begin html

<pre>
a reference to a list containing 6 items:
0: (nhits) an int
1: (id) a string
2: (beg) an int
3: (end) an int
4: (protein_function) a string
5: (otu) a string

</pre>

=end html

=begin text

a reference to a list containing 6 items:
0: (nhits) an int
1: (id) a string
2: (beg) an int
3: (end) an int
4: (protein_function) a string
5: (otu) a string


=end text

=back



=cut

package Bio::KBase::KmerAnnotationByFigfam::Client::RpcClient;
use POSIX;
use strict;
use LWP::UserAgent;
use JSON::XS;

BEGIN {
    for my $method (qw/uri ua json content_type version id allow_call status_line/) {
	eval qq|
	    sub $method {
		\$_[0]->{$method} = \$_[1] if defined \$_[1];
		\$_[0]->{$method};
	    }
	    |;
	}
    }

sub new
{
    my($class) = @_;

    my $ua = LWP::UserAgent->new();
    my $json = JSON::XS->new->allow_nonref->utf8;
    
    my $self = {
	ua => $ua,
	json => $json,
    };
    return bless $self, $class;
}

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success || $result->content_type eq 'application/json') {

	my $txt = $result->content;

        return unless($txt); # notification?

	my $obj = eval { $self->json->decode($txt); };

	if (!$obj)
	{
	    die "Error parsing result: $@";
	}

	return $obj;
    }
    else {
        return;
    }
}

sub _get {
    my ($self, $uri) = @_;
    $self->ua->get(
		   $uri,
		   Accept         => 'application/json',
		  );
}

sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Legacy::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
