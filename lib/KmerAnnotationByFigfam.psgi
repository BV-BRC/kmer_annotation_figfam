use Bio::KBase::KmerAnnotationByFigfam::KmerAnnotationByFigfamImpl;

use Bio::KBase::KmerAnnotationByFigfam::Service;
use Plack::Middleware::CrossOrigin;
use Plack::Builder;



my @dispatch;

{
    my $obj = Bio::KBase::KmerAnnotationByFigfam::KmerAnnotationByFigfamImpl->new;
    push(@dispatch, 'KmerAnnotationByFigfam' => $obj);
}


my $server = Bio::KBase::KmerAnnotationByFigfam::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $rpc_handler = sub { $server->handle_input(@_) };

$handler = builder {
    mount "/ping" => sub { $server->ping(@_); };
    mount "/auth_ping" => sub { $server->auth_ping(@_); };
    mount "/" => $rpc_handler;
};

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
