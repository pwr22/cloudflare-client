#!perl -T

# This file aims to test the correct functioning of all API calls
package CloudFlare::Client::Test;

use strict; use warnings; use mro 'c3'; use namespace::autoclean;

use Readonly;
use Try::Tiny;
use Moose; use MooseX::StrictConstructor;

use Test::More; use Test::Exception; use Test::LWP::UserAgent;
use HTTP::Response;
use JSON::Any;

plan tests => 1;

extends 'CloudFlare::Client';

# Build a simple valid response
# Response payload
Readonly my $RSP_PL   => { val => 1};
# Full response
Readonly my $CNT_DATA => { result => 'success', response => $RSP_PL};
# Reponse from server
Readonly my $CNT_RSP  => HTTP::Response::->new(200);
$CNT_RSP->content(JSON::Any::->objToJson($CNT_DATA));

# Override the real user agent with a mocked one
# It will always return the valid response $CNT_RSP
sub _buildUa {
    Readonly my $ua => Test::LWP::UserAgent::->new;
    $ua->map_response(qr{www.cloudflare.com/api_json.html},
                      $CNT_RSP);
    $ua}
__PACKAGE__->meta->make_immutable;

# Catch potential failure
Readonly my $API => try {
    CloudFlare::Client::Test::->new( user    => 'user', apikey  => 'KEY')}
    catch { diag $_ };
# Valid values
Readonly my $ZONE  => 'zone.co.uk';
Readonly my $ITRVL => 20;
# method => [{ key => args }, ...]
Readonly my %tstSpec => (
    stats         => [{ z => $ZONE, interval => $ITRVL}]);
for my $method ( sort keys %tstSpec ) {
    for my $args (@{ $tstSpec{$method} }) {
        lives_and { is_deeply($API->$method(%$args), $RSP_PL) }
            "$method works"}}
