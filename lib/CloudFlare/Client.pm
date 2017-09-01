package CloudFlare::Client;

# ABSTRACT: Object Orientated Interface to CloudFlare client API

use strict;
use warnings;
use namespace::autoclean;
use Carp;
use Const::Fast;
use Moose;
use MooseX::StrictConstructor;
use Types::Standard 'Str';
use Try::Tiny;
no indirect 'fatal';

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

sub _build_ua {
    my $ua = LWP::UserAgent->new;
    $ua->agent($UA_STRING);

    return $ua;
}
has '_ua' => (
    is       => 'ro',
    isa      => 'LWP::UserAgent',
    init_arg => undef,              # Can't be passed by user
    builder  => '_build_ua',
);

const my $BASE_URI => 'https://api.cloudflare.com/client/v4/';

# Make a request to the API
sub request {
    my ( $self, $type, $end_point, $params ) = @_;

    my $lwp_method = lc $type;

    # These are optional
    my @content_params =
      defined $params ? ( Content => encode_json($params) ) : ();

    my $res = $self->_ua->$lwp_method(
        $BASE_URI . $end_point,
        'X-Auth-Email' => $self->_user,
        'X-Auth-Key'   => $self->_key,
        'Content-Type' => 'application/json',    # Dunno if this is required
        @content_params,
    );

    unless ( $res->is_success ) {
        my $content_type =
          defined $res->header('Content-Type')
          ? $res->header('Content-Type')
          : '';

        my $errors_info =
          $content_type eq 'application/json'
          ? ' and API reported error(s) '
          . encode_json( decode_json( $res->decoded_content )->{errors} )
          : '';

        croak 'HTTP request failed with status ', $res->status_line,
          $errors_info;
    }

    croak 'Only JSON responses are supported'
      unless $res->header('Content-Type') eq 'application/json';

    my $res_content = decode_json( $res->decoded_content );

    croak 'API reported error(s) ', encode_json( $res_content->{errors} )
      unless $res_content->{success};

    return $res_content;
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

=method request

Make a request to the API

    # $api->request( $TYPE, $PATH[, $JSON_B])
    $api->request( 'GET', 'zones' );

=head1 SEE ALSO

Mojo::Cloudflare
WebService::CloudFlare::Host

=head1 ACKNOWLEDGEMENTS

Thanks to CloudFlare providing an awesome free service with an API

=cut
