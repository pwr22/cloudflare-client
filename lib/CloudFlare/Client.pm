package CloudFlare::Client;

# ABSTRACT: Object Orientated Interface to CloudFlare client API

use strict;
use warnings;
no indirect 'fatal';
use namespace::autoclean;
use Carp;
use Const::Fast;
use Moose;
use MooseX::StrictConstructor;
use Types::Standard 'Str';

use LWP::UserAgent 6.02;
use LWP::Protocol::https 6.02;    # Not used but we want the dependency
use JSON::MaybeXS;

# VERSION

# CF credentials
has '_user' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    init_arg => 'user',
);

has '_key' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    init_arg => 'apikey',
);

const my $UA_STRING => "CloudFlare::Client/$VERSION";

sub _buildUa {
    my $ua = LWP::UserAgent->new;
    $ua->agent($UA_STRING);
    return $ua;
}
has '_ua' => (
    is       => 'ro',
    isa      => 'LWP::UserAgent',
    init_arg => undef,
    builder  => '_buildUa',
);

# Calls through to the CF API, can throw exceptions under ::Exception::
const my $CF_URL => 'https://www.cloudflare.com/api_json.html';

sub _apiCall {
    my ( $self, $act, %args ) = @_;

    # query cloudflare
    my $res = $self->_ua->post(
        $CF_URL,
        {
            %args,

            # global args
            # override user specified
            tkn   => $self->_key,
            email => $self->_user,
            a     => $act,
        }
    );

    croak 'HTTP request failed with status ' . $res->status_line
      unless $res->is_success;

    my $info = decode_json( $res->decoded_content );

    unless ( $info->{result} eq 'success' ) {
        my $err_code_info =
          defined( $info->{err_code} )
          ? "code $info->{err_code}"
          : 'no error code';

        croak "API errored with $err_code_info and message $info->{msg}";
    }

    return $info->{response};
}

# all API calls are implemented through autoloading, the action is the method
sub AUTOLOAD {
    my $self = shift;

    our $AUTOLOAD;

    # pull action out of f.q. method name
    ( my $act = $AUTOLOAD ) =~ s/.*:://;
    return $self->_apiCall( $act, @_ );
}

__PACKAGE__->meta->make_immutable;
1;    # End of CloudFlare::Client

__END__

=for test_synopsis my ( $CF_USER, $CF_KEY, $ZONE, $INTERVAL );

=head1 SYNOPSIS

    use CloudFlare::Client;

    my $api = CloudFlare::Client->new(
        user   => $CF_USER,
        apikey => $CF_KEY
    );

    $api->stats( z => $ZONE, interval => $INTERVAL );

=head1 OVERVIEW

Please see the documentation at
L<https://www.cloudflare.com/docs/client-api.html> for information on the
CloudFlare client API and its arguments. API actions are mapped to methods of
the same name and arguments are passed in as a hash with keys as given in the
docs

Successful API calls return the response section from the upstream JSON
API. Failures for whatever reason throw exceptions under the
CloudFlare::Client::Exception:: namespace

=method new

Construct a new API object

    my $api = CloudFlare::Client->new(
        user   => $CF_USER,
        apikey => $CF_KEY,
    );

=head1 SEE ALSO

Mojo::Cloudflare
WebService::CloudFlare::Host

=head1 ACKNOWLEDGEMENTS

Thanks to CloudFlare providing an awesome free service with an API

=cut
