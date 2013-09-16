use strict;
use Data::Dumper;
use Bio::KBase::DeploymentConfig;
use URI;
use Net::FTP;

my $cfg = Bio::KBase::DeploymentConfig->new('KmerAnnotationByFigfam',
					    { 
						'kmer-ftp-site' => 'ftp://ftp.theseed.org/FIGfams',
					    });

my $kmer_data = $cfg->setting('kmer-data');
$kmer_data or die "$0: configuration variable kmer-data was not set";
if (! -d $kmer_data)
{
    mkdir $kmer_data || die "$0: cannot mkdir $kmer_data: $!";
}

if (! -d "$kmer_data/ACTIVE")
{
    mkdir "$kmer_data/ACTIVE" || die "$0: cannot mkdir $kmer_data/ACTIVE: $!";
}

my $kmer_tmp = "$kmer_data/tmp";
if (! -d $kmer_tmp)
{
    mkdir $kmer_tmp || die "$0: cannot mkdir $kmer_tmp: $!";
}

    
my $url = $cfg->setting('kmer-ftp-site');
$url or die "$0: configuration variable kmer-ftp-site was not set";
my $uri = URI->new($url);

$uri->scheme eq 'ftp' or die "$0: Only ftp URLs are allowed for kmer-ftp-site";

my $ftp = Net::FTP->new(Host => $uri->host,
			Port => $uri->port);

my $user = $uri->user || "anonymous";
my $hostname = `hostname`;
chomp $hostname;
my $pass = $uri->password || "kbaseuser\@$hostname";

$ftp->login($user, $pass) || die "$0: FTP login failed";

$ftp->cwd($uri->path) || die "$0: FTP cwd " . $uri->path . " failed";

my @files = $ftp->ls();
@files or die "$0: No files found";

my @figfam_files = grep { /^Release\d+\.figfams\.tgz/ } @files;

my %kmers;
my %ffs;
for my $f (@files)
{
    if ($f =~ /^Release(\d+)\.figfams\.tgz/)
    {
	$ffs{$1} = $f;
    }
    elsif ($f =~ /^Release(\d+)\.kmers\.(\d+)\.tgz/)
    {
	$kmers{$1}->{$2} = $f;
    }
}

print Dumper(\%ffs, \%kmers);

my @ok_fams = grep { ref($kmers{$_}) eq 'HASH' } keys %ffs;

for my $fam (@ok_fams)
{
    #
    # This code relies on the internal structure of the figfam releases.
    # That's OK.
    #
    if (! -s "$kmer_data/Release$fam/families.2c")
    {
	print "Load base release for $fam\n";
	download_and_unpack($ffs{$fam});
    }
    for my $k (keys %{$kmers{$fam}})
    {
	if (! -s "$kmer_data/Release$fam/Merged/$k/table.binary")
	{
	    print "Load k=$k kmers for $fam\n";
	    download_and_unpack($kmers{$fam}->{$k});
	}
    }
    if (! -d "$kmer_data/ACTIVE/Release$fam")
    {
	symlink("../Release$fam", "$kmer_data/ACTIVE/Release$fam") or die "symlink ../Release$fam $kmer_data/ACTIVE/Release$fam failed: $!";
    }
}

#
# If no default symlink set, change to the highest release number.
#
if (! -d "$kmer_data/DEFAULT")
{
    opendir(D, $kmer_data) or die "opendir $kmer_data failed: $!";
    my @rels;
    while (my $d = readdir(D))
    {
	if ($d =~ /^Release(\d+)$/)
	{
	    push(@rels, $1);
	}
    }
    closedir(D);
    if (@rels)
    {
	@rels = sort { $b <=> $a } @rels;
	my $max = $rels[0];
	print "Marking release $max as default\n";
	symlink("Release$max", "$kmer_data/DEFAULT") || die "symlink Release$max $kmer_data/DEFAULT failed: $!";
    }
}

sub download_and_unpack
{
    my($file) = @_;
    print "DL '$file'\n";
    my $file_url = "$url/$file";
    my $rc;
    if (! -s "$kmer_tmp/$file")
    {
	$rc = system("curl", "-L", "-o", "$kmer_tmp/$file", $file_url);
	$rc == 0 or die "Error downloading $file_url to $kmer_tmp/$file";
    }
    $rc = system("tar", "-C", $kmer_data, "-x", "-z", "-p", "-f", "$kmer_tmp/$file");
    $rc == 0 or die "Error untarring $kmer_tmp/$file";
}
