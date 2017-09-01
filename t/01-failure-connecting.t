# This file aims to test the failure of an API call when a
# connection cannot be made

use strict;
use warnings;
use namespace::autoclean;
use Const::Fast;
no indirect 'fatal';

use Test::More 'no_plan';
use Test::Exception;

package CloudFlare::Client::Test {
    use Moose;
    use MooseX::StrictConstructor;

    use Test::LWP::UserAgent;

    extends 'CloudFlare::Client';

    # Override the real user agent with a mocked one
    # It will always fail to connect
    sub _build_ua { Test::LWP::UserAgent->new() }

    __PACKAGE__->meta->make_immutable;
}

my $api = CloudFlare::Client::Test->new( user => 'user', apikey => 'KEY' );

throws_ok { $api->request( 'get', 'zones' ) }
qr/HTTP request failed with status 404 Not Found/,
  "methods die with a connection error";
