use strict;
use warnings;
no indirect 'fatal';

use Const::Fast;
use Test::More 'no_plan';
use Test::Exception;
use Test::RequiresInternet;

use CloudFlare::Client;

# Check we can hit the service and it fails our call
throws_ok {
    my $api = CloudFlare::Client->new(
        user   => 'user',
        apikey => 'KEY'
    );

    # Picked because takes no args
    $api->request('GET', 'zones');
}
qr/API reported error/, 'Upstream service exists and responds';
