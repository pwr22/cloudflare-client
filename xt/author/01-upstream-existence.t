#!perl -T

use strict;
use warnings;
no indirect 'fatal';
use namespace::autoclean;

use Readonly;
use Test::More;
use Test::Exception;
use Test::RequiresInternet;

use CloudFlare::Client;

plan tests => 1;

# Check we can hit the service and it fails our call
throws_ok {
    Readonly my $api => CloudFlare::Client::->new(
        user   => 'user',
        apikey => 'KEY'
    );

    # Picked because takes no args
    $api->zoneLoadMulti
}
qr/API errored with/, 'Upstream service exists and responds';
