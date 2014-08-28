#!perl -T

use Modern::Perl '2012';
use autodie      ':all';
no  indirect     'fatal';

use Readonly;

use Test::More;
use Test::Exception;
use CloudFlare::Client;

plan tests => 1;

# Check we can hit the service and it fails our call
throws_ok { Readonly my $api => CloudFlare::Client::->new( user   => 'user',
                                                           apikey => 'KEY');
          # Picked because takes no args
          $api->zoneLoadMulti } 'CloudFlare::Client::Exception::Upstream',
          'Upstream service exists and responds'
